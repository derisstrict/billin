import 'dart:typed_data';

import 'dart:io';
import 'package:billin/hasil_scan/hasil_scan.dart';
import 'package:billin/model/receipt.dart';
import 'package:billin/service/receipt_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:billin/common/c_colors.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class ScanPage extends StatefulWidget{
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>{
  final ReceiptService _service = ReceiptService();
  final ImagePicker _picker = ImagePicker();

  CameraController? _controller;
  String? _cameraError;
  FlashMode _flash = FlashMode.off;

  Uint8List? _capturedBytes;
  String _mimeType = 'image/jpeg';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scanDocument());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() => _cameraError = 'Kamera tidak ditemukan.');
        return;
      }

      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      await controller.setFlashMode(_flash);

      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _cameraError = null;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = switch (e.code) {
          'CameraAccessDenied' ||
          'CameraAccessDeniedWithoutPrompt' ||
          'CameraAccessRestricted' =>
            'Izin kamera ditolak. Aktifkan lewat pengaturan perangkat.',
          _ => 'Gagal membuka kamera: ${e.description ?? e.code}',
        };
      });
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null) return;
    final next = _flash == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await controller.setFlashMode(next);
    setState(() => _flash = next);
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _capturedBytes = bytes;
        _mimeType = 'image/jpeg';
      });
    } on CameraException catch (e) {
      _showMessage('Gagal mengambil foto: ${e.description ?? e.code}');
    }
  }

  Future<void> _pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _capturedBytes = bytes;
      _mimeType = file.mimeType ?? 'image/jpeg';
    });
  }

  Future<void> _scanDocument() async{
    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormats: {DocumentFormat.jpeg},
        mode: ScannerMode.base,   // crop dan rotasi saja, tanpa filter
        pageLimit: 1,
        isGalleryImport: true,    // sekalian bisa impor dari galeri
      ),
    );
    try {
      final result = await scanner.scanDocument();
      final paths = result.images;
      if (paths == null || paths.isEmpty) {
        if (mounted) Navigator.of(context).maybePop(); // user batal
        return;
      }
      final bytes = await File(paths.first).readAsBytes();
      if (!mounted) return;
      setState(() {
        _capturedBytes = bytes;
        _mimeType = 'image/jpeg';
      });
      } catch (e) {
        _showMessage('Gagal membuka scanner: $e');
      } finally {
        scanner.close();
      }
    }

  void _retake() {
  setState(() => _capturedBytes = null);
  _scanDocument();
}

  Future<void> _process() async {
    final bytes = _capturedBytes;
    if (bytes == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final ReceiptData data = await _service.extractFromImage(
        bytes,
        mimeType: _mimeType,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HasilScan(receipt: data)),
      );
    } on ReceiptException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('Terjadi kesalahan tak terduga. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
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
          style:TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _capturedBytes != null ? _buildPreview() : _buildCamera(),
          if (_isProcessing) _buildLoading(),
        ],
      ),
    );
  }

  Widget _buildCamera() {
    return Center(
      child: FilledButton(
        onPressed: _scanDocument,
        child: const Text('Scan struk'),
      ),
    );
  }

  Widget _buildPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(_capturedBytes!, fit: BoxFit.contain),
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
                    style: FilledButton.styleFrom(backgroundColor: CColors.accent),
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

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Icon(icon, color: const Color(0xFF2196F3), size: 24),
      ),
    );
  }
}