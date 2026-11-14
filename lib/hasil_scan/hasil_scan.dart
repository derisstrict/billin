import 'package:billin/common/c_app_bar.dart';
import 'package:billin/common/c_colors.dart';
import 'package:billin/common/c_container.dart';
import 'package:billin/common/currency_formatter.dart';
import 'package:billin/hasil_scan/item_card.dart';
import 'package:billin/model/receipt.dart';
import 'package:billin/model/receipt_validation.dart';
import 'package:billin/service/receipt_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HasilScan extends StatefulWidget {
  const HasilScan({super.key});

  @override
  State<HasilScan> createState() => _HasilScanState();
}

class _HasilScanState extends State<HasilScan> {
  static const _supportedMimeTypes = {'image/jpeg', 'image/png', 'image/webp'};
  static const _maxImageBytes = 10 * 1024 * 1024;

  final ReceiptService _receiptService = ReceiptService();
  final ImagePicker _imagePicker = ImagePicker();

  ReceiptData _receipt = ReceiptData.demo();
  bool _isScanning = false;

  Future<void> _onScanPressed() async {
    if (_isScanning) {
      return;
    }

    final source = await _pickSource();
    if (source == null || !mounted) {
      return;
    }

    XFile? file;
    try {
      file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1800,
        imageQuality: 85,
      );
    } catch (error) {
      if (mounted) {
        _showError(
          'Gagal membuka '
          '${source == ImageSource.camera ? 'kamera' : 'galeri'}: $error',
        );
      }
      return;
    }

    if (file == null || !mounted) {
      return;
    }

    await _scanFile(file);
  }

  Future<ImageSource?> _pickSource() {
    final supportsCamera =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    if (!supportsCamera) {
      return Future.value(ImageSource.gallery);
    }

    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: CColors.accent),
              title: const Text('Ambil dari Kamera'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: CColors.accent,
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _scanFile(XFile file) async {
    final mimeType = _mimeTypeFor(file);
    if (!_supportedMimeTypes.contains(mimeType)) {
      _showError('Format gambar tidak didukung. Gunakan JPEG, PNG, atau WebP.');
      return;
    }

    setState(() => _isScanning = true);

    try {
      final bytes = await file.readAsBytes();
      if (bytes.lengthInBytes > _maxImageBytes) {
        _showError(
          'Ukuran gambar terlalu besar (maks. 10 MB). Pilih gambar lain.',
        );
        return;
      }

      final receipt = await _receiptService.extractFromImage(
        bytes,
        mimeType: mimeType,
      );

      if (!mounted) {
        return;
      }
      setState(() => _receipt = receipt);
      _showMessage('Struk berhasil dipindai.');
    } on ReceiptException catch (error) {
      if (mounted) {
        _showError(error.message);
      }
    } catch (error) {
      if (mounted) {
        _showError('Gagal memindai struk: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  String _mimeTypeFor(XFile file) {
    final mimeType = file.mimeType?.toLowerCase().trim();
    if (mimeType == 'image/jpg') {
      return 'image/jpeg';
    }
    if (mimeType != null && mimeType.isNotEmpty) {
      return mimeType;
    }

    final path = file.path.toLowerCase();
    if (path.endsWith('.png')) {
      return 'image/png';
    }
    if (path.endsWith('.webp')) {
      return 'image/webp';
    }
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
      return 'image/jpeg';
    }

    return 'image/jpeg';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CColors.danger,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool accent = false}) {
    final accentStyle = TextStyle(
      fontWeight: FontWeight(700),
      color: CColors.accent,
    );

    return Row(
      children: [
        Text(label, style: accent ? accentStyle : null),
        const Spacer(),
        Text(
          value,
          style: accent
              ? accentStyle
              : const TextStyle(fontWeight: FontWeight(700)),
        ),
      ],
    );
  }

  Widget _mismatchWarning(ReceiptData receipt, ReceiptValidation validation) {
    final isGrandTotalMismatch = validation.hasGrandTotalMismatch;
    final expected = isGrandTotalMismatch
        ? validation.expectedGrandTotal
        : validation.itemsSubtotal;
    final actual = isGrandTotalMismatch
        ? receipt.grandTotal
        : receipt.subtotal.round();
    final message = isGrandTotalMismatch
        ? 'Total item + pajak/layanan - diskon '
              '(${formatRupiah(expected)}) tidak cocok dengan grand total '
              'struk (${formatRupiah(actual)}). '
              'Selisih ${formatRupiah(validation.primaryDifference.abs())}. '
              'Periksa harga item, diskon, pajak, atau biaya layanan.'
        : 'Total item (${formatRupiah(expected)}) tidak cocok dengan subtotal '
              'struk (${formatRupiah(actual)}). '
              'Selisih ${formatRupiah(validation.primaryDifference.abs())}. '
              'Periksa harga atau diskon item.';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CColors.danger.withAlpha(20),
        border: BoxBorder.all(
          color: CColors.danger.withAlpha(50),
          width: 0.5
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: CColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: CColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receipt = _receipt;
    final itemCount = receipt.items.length;
    final validation = ReceiptValidation.fromReceipt(receipt);

    return Scaffold(
      backgroundColor: CColors.background,
      appBar: CAppBar("Hasil Scan"),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Stack(
                alignment: AlignmentGeometry.bottomEnd,
                children: [
                  CContainer(
                    child: Column(
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: CColors.accent.withAlpha(50),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.store_outlined,
                                size: 34,
                                color: CColors.accent,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  receipt.merchantName.isEmpty
                                      ? 'Merchant tidak diketahui'
                                      : receipt.merchantName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight(700),
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  receipt.date.isEmpty
                                      ? '-'
                                      : receipt.dateLabel,
                                  style: TextStyle(
                                    fontWeight: FontWeight(400),
                                    fontSize: 14,
                                    color: CColors.textGray,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: List.generate(
                            150 ~/ 2.5,
                            (index) => Expanded(
                              child: Container(
                                color: index % 2 == 0
                                    ? Colors.transparent
                                    : CColors.border,
                                height: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              "Item Terdeteksi ($itemCount)",
                              style: TextStyle(
                                fontWeight: FontWeight(600),
                                fontSize: 14,
                                color: CColors.textGray,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "Subtotal",
                              style: TextStyle(
                                fontWeight: FontWeight(600),
                                fontSize: 14,
                                color: CColors.textGray,
                              ),
                            ),
                            const SizedBox(width: 45),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (receipt.items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Belum ada item terdeteksi.',
                              style: TextStyle(
                                fontSize: 14,
                                color: CColors.textGray,
                              ),
                            ),
                          )
                        else
                          ...receipt.items.map(
                            (item) => ItemCard(
                              key: ValueKey(item.id),
                              itemName: item.name.isEmpty
                                  ? 'Item tanpa nama'
                                  : item.name,
                              subtext:
                                  '${item.qtyLabel} x ${formatRupiah(item.price)}',
                              price: formatRupiah(item.total),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: CColors.accent.withAlpha(50),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: CColors.accent,
                                size: 18,
                              ),
                              Text(
                                "Tambah Item Manual",
                                style: TextStyle(
                                  color: CColors.accent,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _isScanning ? null : _onScanPressed,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: CColors.accent.withAlpha(
                                _isScanning ? 25 : 50,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              spacing: 5,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isScanning)
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: CColors.accent,
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.document_scanner_outlined,
                                    color: CColors.accent,
                                    size: 18,
                                  ),
                                Text(
                                  _isScanning
                                      ? "Memindai struk..."
                                      : "Temp Scan Item",
                                  style: TextStyle(
                                    color: CColors.accent,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: List.generate(
                            150 ~/ 2.5,
                            (index) => Expanded(
                              child: Container(
                                color: index % 2 == 0
                                    ? Colors.transparent
                                    : CColors.border,
                                height: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Column(
                          spacing: 5,
                          children: [
                            _summaryRow(
                              "Subtotal ($itemCount item)",
                              formatRupiah(receipt.subtotal),
                            ),
                            if (receipt.tax > 0)
                              _summaryRow("Pajak", formatRupiah(receipt.tax)),
                            if (receipt.serviceCharge > 0)
                              _summaryRow(
                                "Biaya Layanan",
                                formatRupiah(receipt.serviceCharge),
                              ),
                            if (receipt.discounts > 0)
                              _summaryRow(
                                "Diskon",
                                "- ${formatRupiah(receipt.discounts)}",
                              ),
                            _summaryRow(
                              "Grand Total",
                              formatRupiah(receipt.grandTotal),
                              accent: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 32,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      height: 100,
                      decoration: BoxDecoration(
                        color: CColors.background,
                        shape: BoxShape.circle,
                        border: BoxBorder.all(color: CColors.border),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 32,
                    left: -5,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      height: 100,
                      decoration: BoxDecoration(
                        color: CColors.background,
                        shape: BoxShape.circle,
                        border: BoxBorder.all(color: CColors.border),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    left: 0,
                    bottom: -18,
                    child: Row(
                      children: List.generate(
                        19,
                        (index) => Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: index % 2 == 0
                                  ? Colors.transparent
                                  : CColors.background,
                              shape: BoxShape.circle,
                              border: BoxBorder.all(
                                color: index % 2 == 0
                                    ? Colors.transparent
                                    : CColors.border,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (validation.hasMismatch) ...[
                const SizedBox(height: 10),
                _mismatchWarning(receipt, validation),
              ],
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Lanjutkan",
                      style: TextStyle(
                        fontWeight: FontWeight(700),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
