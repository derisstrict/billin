import 'package:billin/scan/receipt_scanner.dart';
import 'package:billin/scan/scan_page.dart';
import 'package:flutter/material.dart';

bool _isOpeningScanner = false;

/// Launches the native scanner directly from the current page. The preview
/// page is only pushed after a page was captured, so cancelling never opens
/// and closes a temporary Flutter page.
Future<void> openReceiptScanner(BuildContext context) async {
  if (_isOpeningScanner) {
    return;
  }
  _isOpeningScanner = true;

  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  final ReceiptScanOutcome outcome;
  try {
    outcome = await scanReceipt();
  } finally {
    _isOpeningScanner = false;
  }

  switch (outcome.status) {
    case ReceiptScanStatus.success:
      final bytes = outcome.imageBytes;
      if (bytes == null || !context.mounted) {
        return;
      }
      navigator.push(
        MaterialPageRoute<void>(builder: (_) => ScanPage(imageBytes: bytes)),
      );
    case ReceiptScanStatus.cancelled:
      return;
    case ReceiptScanStatus.unsupported:
      if (!context.mounted) {
        return;
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Pemindai struk hanya tersedia di Android.'),
          ),
        );
    case ReceiptScanStatus.failure:
      debugPrint('Gagal membuka pemindai struk: ${outcome.error}');
      if (!context.mounted) {
        return;
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka pemindai struk. Coba lagi.'),
          ),
        );
  }
}
