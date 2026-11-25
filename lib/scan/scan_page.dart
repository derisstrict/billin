import 'dart:typed_data';

import 'package:billin/common/c_colors.dart';
import 'package:billin/hasil_scan/hasil_scan.dart';
import 'package:billin/model/receipt.dart';
import 'package:billin/scan/receipt_scanner.dart';
import 'package:billin/service/receipt_service.dart';
import 'package:flutter/material.dart';

class ScanPage extends StatefulWidget {
  final Uint8List imageBytes;
  final String mimeType;

  const ScanPage({
    super.key,
    required this.imageBytes,
    this.mimeType = 'image/jpeg',
  });

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ReceiptService _service = ReceiptService();

  late Uint8List _capturedBytes = widget.imageBytes;
  late String _mimeType = widget.mimeType;
  bool _isProcessing = false;
  bool _isRetaking = false;

  Future<void> _retake() async {
    if (_isProcessing || _isRetaking) {
      return;
    }
    _isRetaking = true;

    try {
      final outcome = await scanReceipt();
      if (!mounted) {
        return;
      }

      switch (outcome.status) {
        case ReceiptScanStatus.success:
          final bytes = outcome.imageBytes;
          if (bytes == null) {
            return;
          }
          setState(() {
            _capturedBytes = bytes;
            _mimeType = 'image/jpeg';
          });
        case ReceiptScanStatus.cancelled:
          return;
        case ReceiptScanStatus.unsupported:
          _showMessage('Pemindai struk hanya tersedia di Android.');
        case ReceiptScanStatus.failure:
          debugPrint('Gagal memindai ulang: ${outcome.error}');
          _showMessage('Gagal membuka pemindai struk. Coba lagi.');
      }
    } finally {
      _isRetaking = false;
    }
  }

  Future<void> _process() async {
    if (_isProcessing) {
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final ReceiptData data = await _service.extractFromImage(
        _capturedBytes,
        mimeType: _mimeType,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HasilScan(receipt: data)),
      );
    } on ReceiptException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('Terjadi kesalahan tak terduga. Coba lagi.');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showMessage(String text) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Scan Struk',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [_buildPreview(), if (_isProcessing) _buildLoading()],
      ),
    );
  }

  Widget _buildPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(_capturedBytes, fit: BoxFit.contain),
        Positioned(
          left: 24,
          right: 24,
          bottom: 32,
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : _retake,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                    ),
                    child: const Text('Ulangi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isProcessing ? null : _process,
                    style: FilledButton.styleFrom(
                      backgroundColor: CColors.accent,
                    ),
                    child: const Text('Gunakan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Membaca struk...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
