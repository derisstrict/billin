import 'dart:convert';

import 'package:billin/model/receipt.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

const _promptAsset = 'assets/prompts/receipt_extraction.json';

// Override for an Android emulator or a physical device, e.g.:
//   flutter run --dart-define=LLAMA_BASE_URL=http://10.0.2.2:9931
// The llama.cpp server must also listen on 0.0.0.0 (`--host 0.0.0.0`).
const _defaultBaseUrl = String.fromEnvironment(
  'LLAMA_BASE_URL',
  defaultValue: 'http://127.0.0.1:9931',
);

class ReceiptService {
  ReceiptService({Dio? dio, String? baseUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _normalizeBaseUrl(baseUrl ?? _defaultBaseUrl),
              connectTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(minutes: 1),
              receiveTimeout: const Duration(minutes: 5),
              headers: const {'Content-Type': 'application/json'},
            ),
          );

  final Dio _dio;
  String? _templateJson;

  Future<ReceiptData> extractFromImage(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    if (imageBytes.isEmpty) {
      throw const ReceiptException('Gambar struk kosong.');
    }

    final dataUrl = 'data:$mimeType;base64,${base64Encode(imageBytes)}';

    try {
      final body = await _buildBody(dataUrl);
      final response = await _dio.post<dynamic>(
        '/v1/chat/completions',
        data: body,
        options: Options(responseType: ResponseType.json),
      );

      final data = response.data;
      if (data is! Map) {
        throw const ReceiptException('Respons server tidak valid.');
      }

      final content = _extractContent(Map<String, dynamic>.from(data));
      return ReceiptData.fromJson(_decodeContent(content));
    } on ReceiptException {
      rethrow;
    } on DioException catch (error) {
      throw ReceiptException(_messageFor(error));
    } on FormatException {
      throw const ReceiptException(
        'Hasil model bukan JSON yang valid. Coba pindai ulang.',
      );
    }
  }

  Future<Map<String, dynamic>> _buildBody(String dataUrl) async {
    _templateJson ??= await rootBundle.loadString(_promptAsset);
    final decoded = jsonDecode(_templateJson!);
    if (decoded is! Map<String, dynamic>) {
      throw const ReceiptException('Template prompt tidak valid.');
    }

    if (!_replaceImageUrl(decoded, dataUrl)) {
      throw const ReceiptException(
        'Placeholder {{receipt_image}} tidak ditemukan pada template prompt.',
      );
    }

    return decoded;
  }

  /// Replaces `{{receipt_image}}` anywhere in the template and returns whether
  /// it found the placeholder.
  bool _replaceImageUrl(dynamic node, String dataUrl) {
    var replaced = false;

    if (node is Map) {
      for (final key in node.keys.toList()) {
        final value = node[key];
        if (key == 'url' && value == '{{receipt_image}}') {
          node[key] = dataUrl;
          replaced = true;
        } else {
          replaced = _replaceImageUrl(value, dataUrl) || replaced;
        }
      }
    } else if (node is List) {
      for (final item in node) {
        replaced = _replaceImageUrl(item, dataUrl) || replaced;
      }
    }

    return replaced;
  }

  String _extractContent(Map<String, dynamic> data) {
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const ReceiptException('Model tidak mengembalikan hasil.');
    }

    final first = choices.first;
    if (first is! Map) {
      throw const ReceiptException('Format respons model tidak dikenal.');
    }

    final message = first['message'];
    final content = message is Map ? message['content'] : null;
    if (content is! String || content.trim().isEmpty) {
      throw const ReceiptException('Model tidak mengembalikan hasil.');
    }

    return content;
  }

  Map<String, dynamic> _decodeContent(String content) {
    var cleaned = content.trim();

    final fenced = RegExp(
      r'^```(?:json)?\s*([\s\S]*?)\s*```$',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (fenced != null) {
      cleaned = fenced.group(1)!.trim();
    }

    // Be defensive if the model adds a sentence before/after the JSON object.
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start >= 0 && end > start) {
      cleaned = cleaned.substring(start, end + 1);
    }

    final decoded = jsonDecode(cleaned);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object.');
    }

    return decoded;
  }

  String _messageFor(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'Server llama.cpp tidak merespons. Pastikan server berjalan lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server llama.cpp (${_dio.options.baseUrl}).';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final detail = _serverDetail(error.response);
        if (detail.isEmpty) {
          return 'Server llama.cpp mengembalikan error'
              '${statusCode == null ? '' : ' $statusCode'}.';
        }
        return 'Server llama.cpp error $statusCode: $detail';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat server tidak valid.';
      case DioExceptionType.unknown:
        return 'Gagal memindai struk: ${error.message ?? 'kesalahan jaringan'}.';
    }
  }

  String _serverDetail(Response<dynamic>? response) {
    final data = response?.data;
    if (data is! Map) {
      return '';
    }

    final error = data['error'];
    if (error is Map && error['message'] is String) {
      return (error['message'] as String).trim();
    }
    if (error is String) {
      return error.trim();
    }
    if (data['message'] is String) {
      return (data['message'] as String).trim();
    }

    return '';
  }
}

class ReceiptException implements Exception {
  const ReceiptException(this.message);

  final String message;

  @override
  String toString() => message;
}

String _normalizeBaseUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.endsWith('/')) {
    return trimmed.substring(0, trimmed.length - 1);
  }
  return trimmed;
}
