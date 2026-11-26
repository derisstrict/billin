import 'package:billin/common/c_app_bar.dart';
import 'package:billin/common/c_colors.dart';
import 'package:billin/common/c_container.dart';
import 'package:billin/common/currency_formatter.dart';
import 'package:billin/hasil_scan/item_card.dart';
import 'package:billin/model/receipt.dart';
import 'package:billin/model/receipt_validation.dart';
import 'package:billin/split_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HasilScan extends StatefulWidget {
  final ReceiptData receipt;

  const HasilScan({super.key, required this.receipt});

  @override
  State<HasilScan> createState() => _HasilScanState();
}

class _HasilScanState extends State<HasilScan> {
  late ReceiptData _receipt = widget.receipt;

  Future<void> _addItem() async {
    final result = await showDialog<_EditItemResult>(
      context: context,
      builder: (_) => const _EditItemDialog(
        title: 'Tambah Item',
        icon: Icons.add_box_outlined,
      ),
    );
    final created = result?.item;
    if (created == null || !mounted) {
      return;
    }

    final nextId = _receipt.items.fold<int>(
          0,
          (maxId, item) => item.id > maxId ? item.id : maxId,
        ) +
        1;
    final updatedItems = List<ReceiptItem>.from(_receipt.items)
      ..add(created.copyWith(id: nextId));
    setState(() {
      _receipt = _receipt.copyWith(items: updatedItems);
    });
  }

  Future<void> _editItem(int index, ReceiptItem item) async {
    final result = await showDialog<_EditItemResult>(
      context: context,
      builder: (_) => _EditItemDialog(item: item),
    );
    if (result == null || !mounted) {
      return;
    }

    final updatedItems = List<ReceiptItem>.from(_receipt.items);
    if (result.deleted) {
      updatedItems.removeAt(index);
    } else if (result.item != null) {
      updatedItems[index] = result.item!;
    } else {
      return;
    }
    setState(() {
      _receipt = _receipt.copyWith(items: updatedItems);
    });
  }

  Future<void> _editSummaryField({
    required String label,
    required int initialValue,
    required ReceiptData Function(int value) onSave,
  }) async {
    final updated = await showDialog<int>(
      context: context,
      builder: (_) => _EditSummaryDialog(
        label: label,
        initialValue: initialValue,
      ),
    );
    if (updated == null || !mounted) {
      return;
    }

    setState(() {
      _receipt = onSave(updated);
    });
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool accent = false,
    required VoidCallback onEdit,
  }) {
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
        IconButton(
          padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
          constraints: BoxConstraints(
            minHeight: 32,
          ),
          onPressed: onEdit,
          style: const ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: Icon(Icons.edit_outlined, size: 20, color: CColors.textGray),
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
        border: BoxBorder.all(color: CColors.danger.withAlpha(50), width: 0.5),
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
                          for (final entry in receipt.items.asMap().entries)
                            ItemCard(
                              key: ValueKey('${entry.key}_${entry.value.id}'),
                              itemName: entry.value.name.isEmpty
                                  ? 'Item tanpa nama'
                                  : entry.value.name,
                              subtext:
                                  '${entry.value.qtyLabel} x ${formatRupiah(entry.value.price)}',
                              price: formatRupiah(entry.value.total),
                              onPressed: () =>
                                  _editItem(entry.key, entry.value),
                            ),
                        const SizedBox(height: 10),
                        Material(
                          color: CColors.accent.withAlpha(50),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: _addItem,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
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
                          spacing: 2,
                          children: [
                            _summaryRow(
                              "Subtotal ($itemCount item)",
                              formatRupiah(receipt.subtotal),
                              onEdit: () => _editSummaryField(
                                label: 'Subtotal',
                                initialValue: receipt.subtotal.round(),
                                onSave: (value) =>
                                    _receipt.copyWith(subtotal: value),
                              ),
                            ),
                            if (receipt.tax > 0)
                              _summaryRow(
                                "Pajak",
                                formatRupiah(receipt.tax),
                                onEdit: () => _editSummaryField(
                                  label: 'Pajak',
                                  initialValue: receipt.tax,
                                  onSave: (value) =>
                                      _receipt.copyWith(tax: value),
                                ),
                              ),
                            if (receipt.serviceCharge > 0)
                              _summaryRow(
                                "Biaya Layanan",
                                formatRupiah(receipt.serviceCharge),
                                onEdit: () => _editSummaryField(
                                  label: 'Biaya Layanan',
                                  initialValue: receipt.serviceCharge,
                                  onSave: (value) =>
                                      _receipt.copyWith(serviceCharge: value),
                                ),
                              ),
                            if (receipt.discounts > 0)
                              _summaryRow(
                                "Diskon",
                                "- ${formatRupiah(receipt.discounts)}",
                                onEdit: () => _editSummaryField(
                                  label: 'Diskon',
                                  initialValue: receipt.discounts,
                                  onSave: (value) =>
                                      _receipt.copyWith(discounts: value),
                                ),
                              ),
                            _summaryRow(
                              "Grand Total",
                              formatRupiah(receipt.grandTotal),
                              accent: true,
                              onEdit: () => _editSummaryField(
                                label: 'Grand Total',
                                initialValue: receipt.grandTotal,
                                onSave: (value) =>
                                    _receipt.copyWith(grandTotal: value),
                              ),
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
              Material(
                color: CColors.accent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SplitPage(receipt: receipt),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _dialogInputDecoration({
  double borderRadius = 10,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    isDense: true,
    focusColor: Colors.white,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: CColors.textGray),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: CColors.accent, width: 2),
    ),
  );
}

Widget _dialogTitle(
  String title, {
  IconData icon = Icons.edit_outlined,
}) {
  return Row(
    spacing: 8,
    children: [
      Container(
        decoration: BoxDecoration(
          color: CColors.accent.withValues(alpha: .3),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.all(3),
        child: Icon(icon, color: CColors.accent),
      ),
      Text(
        title,
        style: TextStyle(
          color: CColors.accent,
          fontWeight: const FontWeight(600),
          fontSize: 18,
        ),
      ),
    ],
  );
}

List<Widget> _dialogActions({
  required VoidCallback onCancel,
  required VoidCallback onConfirm,
  VoidCallback? onDelete,
}) {
  return [
    Row(
      children: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
        const Spacer(),
        if (onDelete != null) ...[
          TextButton(
            onPressed: onDelete,
            child: Text('Delete', style: TextStyle(color: CColors.danger)),
          ),
          const Spacer(),
        ],
        TextButton(
          onPressed: onConfirm,
          child: const Text('OK', style: TextStyle(color: Colors.black)),
        ),
      ],
    ),
  ];
}

class _EditItemResult {
  final ReceiptItem? item;
  final bool deleted;

  const _EditItemResult({this.item, this.deleted = false});
}

class _EditItemDialog extends StatefulWidget {
  final ReceiptItem? item;
  final String title;
  final IconData icon;

  const _EditItemDialog({
    this.item,
    this.title = 'Edit Item',
    this.icon = Icons.edit_outlined,
  });

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _qtyController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _priceController = TextEditingController(
      text: item != null ? item.price.toString() : '',
    );
    _qtyController = TextEditingController(
      text: (item?.qty.round().clamp(1, 999999) ?? 1).toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _adjustQty(int delta) {
    final current = int.tryParse(_qtyController.text.trim()) ?? 1;
    final next = (current + delta).clamp(1, 999999);
    _qtyController.text = next.toString();
    _qtyController.selection = TextSelection.collapsed(
      offset: _qtyController.text.length,
    );
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.trim());
    final qty = int.tryParse(_qtyController.text.trim());

    if (name.isEmpty) {
      setState(() => _errorText = 'Nama item tidak boleh kosong.');
      return;
    }
    if (price == null || price < 0) {
      setState(() => _errorText = 'Harga satuan harus berupa angka valid.');
      return;
    }
    if (qty == null || qty < 1) {
      setState(() => _errorText = 'Jumlah porsi minimal 1.');
      return;
    }

    final result = widget.item != null
        ? widget.item!.copyWith(
            name: name,
            price: price,
            qty: qty,
            total: (qty * price).round(),
          )
        : ReceiptItem(
            id: 0,
            name: name,
            qty: qty,
            price: price,
            total: (qty * price).round(),
          );

    Navigator.pop(context, _EditItemResult(item: result));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _dialogTitle(widget.title, icon: widget.icon),
      backgroundColor: Colors.white,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nama Item', style: TextStyle(color: CColors.textGray)),
            TextField(
              controller: _nameController,
              decoration: _dialogInputDecoration(),
            ),
            const SizedBox(height: 15),
            Text('Harga Satuan', style: TextStyle(color: CColors.textGray)),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: _dialogInputDecoration(),
            ),
            const SizedBox(height: 15),
            Text('Jumlah Porsi', style: TextStyle(color: CColors.textGray)),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: _dialogInputDecoration(
                borderRadius: 15,
                prefixIcon: IconButton(
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minHeight: 14,
                    minWidth: 14,
                  ),
                  onPressed: () => _adjustQty(1),
                  icon: Icon(Icons.add, color: CColors.accent),
                ),
                suffixIcon: IconButton(
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minHeight: 14,
                    minWidth: 14,
                  ),
                  onPressed: () => _adjustQty(-1),
                  icon: Icon(Icons.remove, color: CColors.accent),
                ),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorText!,
                style: TextStyle(color: CColors.danger, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: _dialogActions(
        onCancel: () => Navigator.pop(context),
        onDelete: widget.item != null
            ? () => Navigator.pop(context, const _EditItemResult(deleted: true))
            : null,
        onConfirm: _submit,
      ),
    );
  }
}

class _EditSummaryDialog extends StatefulWidget {
  final String label;
  final int initialValue;

  const _EditSummaryDialog({required this.label, required this.initialValue});

  @override
  State<_EditSummaryDialog> createState() => _EditSummaryDialogState();
}

class _EditSummaryDialogState extends State<_EditSummaryDialog> {
  late final TextEditingController _valueController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(
      text: widget.initialValue.toString(),
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_valueController.text.trim());
    if (value == null || value < 0) {
      setState(() => _errorText = 'Nilai harus berupa angka valid.');
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _dialogTitle('Edit ${widget.label}'),
      backgroundColor: Colors.white,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.label, style: TextStyle(color: CColors.textGray)),
          TextField(
            controller: _valueController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: _dialogInputDecoration(),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorText!,
              style: TextStyle(color: CColors.danger, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: _dialogActions(
        onCancel: () => Navigator.pop(context),
        onConfirm: _submit,
      ),
    );
  }
}
