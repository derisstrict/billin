import 'package:billin/model/group.dart';
import 'package:billin/model/receipt.dart';
import 'package:billin/service/base_url_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const _configuredBaseUrl = String.fromEnvironment('BILLIN_API_BASE_URL');

class GroupService {
  GroupService({Dio? dio, String? baseUrl})
    : _useGlobalBaseUrl = dio == null && baseUrl == null,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: BaseUrlConfig.normalize(baseUrl ?? baseUrlNotifier.value),
              connectTimeout: const Duration(seconds: 8),
              sendTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              headers: const {'Content-Type': 'application/json'},
            ),
          );

  /// Reactive base URL config used by default-constructed [GroupService] instances.
  static final BaseUrlConfig baseUrlConfig = BaseUrlConfig(
    prefsKey: 'billin_api_base_url',
    defaultUrlBuilder: () => _defaultBaseUrl,
  );

  static ValueNotifier<String> get baseUrlNotifier => baseUrlConfig.notifier;
  static String get defaultBaseUrl => baseUrlConfig.defaultUrl;
  static String get currentBaseUrl => baseUrlConfig.currentUrl;
  static String? validateBaseUrl(String value) => BaseUrlConfig.validate(value);
  static Future<void> loadSavedBaseUrl() => baseUrlConfig.loadSaved();
  static Future<void> setBaseUrl(String url) => baseUrlConfig.setUrl(url);
  static Future<void> resetBaseUrl() => baseUrlConfig.resetUrl();

  final Dio _dio;
  final bool _useGlobalBaseUrl;

  String get activeBaseUrl =>
      _useGlobalBaseUrl ? baseUrlNotifier.value : _dio.options.baseUrl;

  static String get _defaultBaseUrl {
    if (_configuredBaseUrl.trim().isNotEmpty) {
      return _configuredBaseUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    return 'http://10.0.2.2:5000';
  }

  Future<CreatedGroup> createGroup({
    required ReceiptData receipt,
    required String hostName,
  }) async {
    return _guard(() async {
      final response = await _dio.post<dynamic>(
        '/api/groups',
        data: {'receipt': receipt.toJson(), 'host_name': hostName},
      );
      final data = _asMap(response.data);
      return _createdGroup(data);
    });
  }

  Future<GroupData> fetchGroup(String token) async {
    return _guard(() async {
      final response = await _dio.get<dynamic>(
        '/api/groups/${Uri.encodeComponent(token)}',
      );
      return _group(response.data);
    });
  }

  Future<GroupData> resolveLink(String link) async {
    return _guard(() async {
      final response = await _dio.get<dynamic>(
        '/api/groups/resolve',
        queryParameters: {'link': link},
      );
      return _group(response.data);
    });
  }

  Future<CreatedGroup> addMember(String token, String name) async {
    return _guard(() async {
      final response = await _dio.post<dynamic>(
        '/api/groups/${Uri.encodeComponent(token)}/members',
        data: {'name': name},
      );
      final data = _asMap(response.data);
      return _createdGroup(data);
    });
  }

  Future<GroupData> removeMember(String token, String memberId) async {
    return _guard(() async {
      final response = await _dio.delete<dynamic>(
        '/api/groups/${Uri.encodeComponent(token)}/members/'
        '${Uri.encodeComponent(memberId)}',
      );
      return _group(response.data);
    });
  }

  Future<GroupData> updateAssignments(
    String token,
    String memberId,
    Set<int> itemIndexes,
  ) async {
    return _guard(() async {
      final response = await _dio.put<dynamic>(
        '/api/groups/${Uri.encodeComponent(token)}/members/'
        '${Uri.encodeComponent(memberId)}/assignments',
        data: {'item_indexes': itemIndexes.toList()..sort()},
      );
      return _group(response.data);
    });
  }

  Future<GroupData> updateReceipt({
    required String token,
    required String memberId,
    required ReceiptData receipt,
  }) async {
    return _guard(() async {
      final response = await _dio.put<dynamic>(
        '/api/groups/${Uri.encodeComponent(token)}/receipt',
        data: {
          'member_id': memberId,
          'receipt': receipt.toJson(),
        },
      );
      return _group(response.data);
    });
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    if (_useGlobalBaseUrl) {
      _dio.options.baseUrl = baseUrlNotifier.value;
    }
    try {
      return await action();
    } on GroupException {
      rethrow;
    } on DioException catch (error) {
      throw GroupException(_messageFor(error));
    } catch (_) {
      throw const GroupException('Terjadi kesalahan tak terduga. Coba lagi.');
    }
  }

  CreatedGroup _createdGroup(Map<String, dynamic> data) {
    return CreatedGroup(
      group: GroupData.fromJson(_asMap(data['group'])),
      memberId: data['member_id']?.toString() ?? '',
    );
  }

  GroupData _group(dynamic data) {
    return GroupData.fromJson(_asMap(_asMap(data)['group']));
  }

  String _messageFor(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final apiError = data['error'];
      if (apiError is Map && apiError['message'] is String) {
        return (apiError['message'] as String).trim();
      }
      if (apiError is String && apiError.trim().isNotEmpty) {
        return apiError.trim();
      }
      if (data['message'] is String) {
        return (data['message'] as String).trim();
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'Server BillIn tidak merespons. Coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server BillIn (${_dio.options.baseUrl}).';
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        return 'Server BillIn mengembalikan error'
            '${status == null ? '' : ' $status'}.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat server tidak valid.';
      case DioExceptionType.unknown:
        return 'Gagal terhubung ke server BillIn: '
            '${error.message ?? 'kesalahan jaringan'}.';
    }
  }
}

class CreatedGroup {
  final GroupData group;
  final String memberId;

  const CreatedGroup({required this.group, required this.memberId});
}

class GroupException implements Exception {
  const GroupException(this.message);

  final String message;

  @override
  String toString() => message;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  throw const GroupException('Respons server tidak valid.');
}
