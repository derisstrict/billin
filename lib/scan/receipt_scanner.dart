import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

/// Result of trying to open the native document scanner.
enum ReceiptScanStatus { success, cancelled, unsupported, failure }

class ReceiptScanOutcome {
  const ReceiptScanOutcome._(this.status, {this.imageBytes, this.error});

  const ReceiptScanOutcome.cancelled() : this._(ReceiptScanStatus.cancelled);

  const ReceiptScanOutcome.unsupported()
    : this._(ReceiptScanStatus.unsupported);

  const ReceiptScanOutcome.failure(Object error)
    : this._(ReceiptScanStatus.failure, error: error);

  ReceiptScanOutcome.success(Uint8List imageBytes)
    : this._(ReceiptScanStatus.success, imageBytes: imageBytes);

  final ReceiptScanStatus status;
  final Uint8List? imageBytes;
  final Object? error;
}

/// Opens the ML Kit document scanner and returns the first captured page.
///
/// The scanner is only available on Android. Other platforms return
/// [ReceiptScanStatus.unsupported] without touching the plugin.
Future<ReceiptScanOutcome> scanReceipt() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return const ReceiptScanOutcome.unsupported();
  }

  final scanner = DocumentScanner(
    options: DocumentScannerOptions(
      documentFormats: const {DocumentFormat.jpeg},
      mode: ScannerMode.base, // crop dan rotasi saja, tanpa filter
      pageLimit: 1,
      isGalleryImport: true, // sekalian bisa impor dari galeri
    ),
  );

  try {
    final result = await scanner.scanDocument();
    final paths = result.images;
    if (paths == null || paths.isEmpty) {
      return const ReceiptScanOutcome.cancelled();
    }

    final bytes = await File(paths.first).readAsBytes();
    if (bytes.isEmpty) {
      return const ReceiptScanOutcome.failure('Hasil pindai kosong.');
    }

    return ReceiptScanOutcome.success(bytes);
  } on PlatformException catch (error) {
    if (isScannerCancellation(error)) {
      return const ReceiptScanOutcome.cancelled();
    }
    return ReceiptScanOutcome.failure(error);
  } catch (error) {
    return ReceiptScanOutcome.failure(error);
  } finally {
    try {
      await scanner.close();
    } catch (error) {
      debugPrint('Gagal menutup pemindai dokumen: $error');
    }
  }
}

/// The Android plugin reports a user cancel as a platform error instead of an
/// empty result.
bool isScannerCancellation(Object error) {
  if (error is! PlatformException || error.code != 'DocumentScanner') {
    return false;
  }
  return error.message?.toLowerCase().contains('cancel') ?? false;
}
