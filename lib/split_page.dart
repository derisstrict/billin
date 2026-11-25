import 'package:billin/common/c_app_bar.dart';
import 'package:billin/common/c_colors.dart';
import 'package:billin/common/currency_formatter.dart';
import 'package:billin/common/section_heading.dart';
import 'package:billin/model/receipt.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SplitPage extends StatefulWidget {
  final ReceiptData? receipt;

  const SplitPage({super.key, this.receipt});

  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  late final ReceiptData _data = widget.receipt ?? ReceiptData.demo();
  final Set<int> _assignedIndexes = <int>{};

  int get _assignedSubtotal => _assignedIndexes.fold(
    0,
    (sum, index) => sum + _data.items[index].total,
  );

  int get _allItemsSubtotal =>
      _data.items.fold(0, (sum, item) => sum + item.total);

  double get _assignedRatio =>
      _allItemsSubtotal == 0 ? 0 : _assignedSubtotal / _allItemsSubtotal;

  int get _taxShare => (_data.tax * _assignedRatio).round();

  int get _serviceShare => (_data.serviceCharge * _assignedRatio).round();

  int get _discountShare => (_data.discounts * _assignedRatio).round();

  int get _totalShare =>
      _assignedSubtotal + _taxShare + _serviceShare - _discountShare;

  Widget _summaryRow(
    String label,
    String value, {
    Color? valueColor,
    Widget? leading,
  }) {
    return Row(
      children: [
        if (leading != null) ...[leading, const SizedBox(width: 5)],
        Text(label),
        const Spacer(),
        Text(value, style: TextStyle(color: valueColor)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final itemCount = data.items.length;

    return Scaffold(
      backgroundColor: CColors.background,
      appBar: CAppBar("Split Bill"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: BoxBorder.all(color: CColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: CColors.accent.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.store_outlined,
                            color: CColors.accent,
                            size: 28,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.merchantName.isEmpty
                                    ? 'Merchant tidak diketahui'
                                    : data.merchantName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight(700),
                                ),
                              ),
                              Text(
                                data.date.isEmpty ? '-' : data.dateLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: CColors.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Symbols.edit_square,
                            weight: 600,
                            color: CColors.accent,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          "Grand Total",
                          style: TextStyle(fontWeight: FontWeight(500)),
                        ),
                        Spacer(),
                        Text(
                          formatRupiah(data.grandTotal),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight(700),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: CColors.background,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        spacing: 5,
                        children: [
                          _summaryRow(
                            "Subtotal",
                            formatRupiah(data.subtotal),
                          ),
                          _summaryRow("Pajak", formatRupiah(data.tax)),
                          _summaryRow(
                            "Biaya Layanan",
                            formatRupiah(data.serviceCharge),
                          ),
                          _summaryRow(
                            "Diskon",
                            data.discounts > 0
                                ? "- ${formatRupiah(data.discounts)}"
                                : formatRupiah(0),
                            valueColor: CColors.accent,
                            leading: Icon(
                              Symbols.percent_discount,
                              weight: 600,
                              color: CColors.accent,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SectionHeading("Anggota"),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: BoxBorder.all(color: CColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: CColors.accent,
                          ),
                          onPressed: () {},
                          child: Row(
                            spacing: 5,
                            children: [
                              Icon(
                                Symbols.manage_accounts,
                                weight: 600,
                                size: 20,
                                color: Colors.white,
                              ),
                              Text(
                                "Kelola",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.person, size: 18),
                        Text("3 orang", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 15),
                    Wrap(
                      spacing: 15,
                      runSpacing: 10,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: BoxBorder.all(
                              color: CColors.accent.withAlpha(50),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: CColors.accent.withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: CColors.accent,
                                  size: 16,
                                ),
                              ),
                              Text(
                                "Ayu (Anda)",
                                style: TextStyle(
                                  fontWeight: FontWeight(600),
                                  color: CColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: BoxBorder.all(
                              color: Color(0XFFA800B7).withAlpha(50),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Color(0XFFA800B7).withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Color(0XFFA800B7),
                                  size: 16,
                                ),
                              ),
                              Text(
                                "Budi",
                                style: TextStyle(color: Color(0XFFA800B7)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: BoxBorder.all(
                              color: Color(0XFF5EA500).withAlpha(50),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Color(0XFF5EA500).withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Color(0XFF5EA500),
                                  size: 16,
                                ),
                              ),
                              Text(
                                "Citra",
                                style: TextStyle(color: Color(0XFF5EA500)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SectionHeading("Item ($itemCount item)"),
              if (data.items.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: BoxBorder.all(color: CColors.border),
                  ),
                  child: Text(
                    'Belum ada item terdeteksi.',
                    style: TextStyle(fontSize: 14, color: CColors.textGray),
                  ),
                )
              else
                ...List.generate(data.items.length, (index) {
                  final item = data.items[index];
                  final assigned = _assignedIndexes.contains(index);
                  final assignment = assigned
                      ? _currentUserAssignment
                      : _previewSharedAssignments
                      ? _demoAssignments[index % _demoAssignments.length]
                      : _soloAssignment;

                  return _SplitItemCard(
                    key: ValueKey('${item.id}-$index'),
                    item: item,
                    assignment: assignment,
                    assigned: assigned,
                    onTap: () {
                      setState(() {
                        if (!_assignedIndexes.add(index)) {
                          _assignedIndexes.remove(index);
                        }
                      });
                    },
                  );
                }),
              SectionHeading("Hasil"),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: BoxBorder.all(color: CColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Rincian pengeluaran kamu"),
                        Spacer(),
                        Text(
                          "${_assignedIndexes.length} item dipilih",
                          style: TextStyle(
                            fontSize: 12,
                            color: CColors.textGray,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: BoxBorder.all(color: CColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Symbols.receipt_long, weight: 600),
                            ],
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Pengeluaran",
                                      style: TextStyle(
                                        fontWeight: FontWeight(700),
                                      ),
                                    ),
                                    Spacer(),
                                    Text(formatRupiah(_totalShare)),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  children: [
                                    Text("Subtotal"),
                                    Spacer(),
                                    Text(formatRupiah(_assignedSubtotal)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Pajak"),
                                    Spacer(),
                                    Text(formatRupiah(_taxShare)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Biaya Layanan"),
                                    Spacer(),
                                    Text(formatRupiah(_serviceShare)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Symbols.percent_discount,
                                      weight: 600,
                                      size: 16,
                                      color: CColors.accent,
                                    ),
                                    SizedBox(width: 5),
                                    Text("Diskon"),
                                    Spacer(),
                                    Text(
                                      _discountShare > 0
                                          ? "- ${formatRupiah(_discountShare)}"
                                          : formatRupiah(0),
                                      style: TextStyle(
                                        color: CColors.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // TODO: show the friend breakdown again once other members
                    // can join and assign their own items.
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.save,
                            weight: 400,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Simpan",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
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

class _DemoMember {
  final String name;
  final Color color;

  const _DemoMember(this.name, this.color);
}

class _DemoAssignment {
  final String label;
  final IconData icon;
  final Color color;
  final List<_DemoMember> members;

  const _DemoAssignment({
    required this.label,
    required this.icon,
    required this.color,
    required this.members,
  });
}

final _demoMembers = [
  _DemoMember('Ayu', CColors.accent),
  _DemoMember('Budi', const Color(0XFFA800B7)),
  _DemoMember('Citra', const Color(0XFF5EA500)),
];

/// Demo assignment patterns kept from the original hardcoded page until a real
/// member/assignment model exists. Set [_previewSharedAssignments] to true to
/// preview the Berbagi/Masing-masing variants.
final List<_DemoAssignment> _demoAssignments = [
  _DemoAssignment(
    label: 'Berbagi',
    icon: Symbols.spoke,
    color: CColors.textShared,
    members: _demoMembers,
  ),
  _DemoAssignment(
    label: 'Masing-masing',
    icon: Symbols.groups,
    color: CColors.textEach,
    members: [_demoMembers[0], _demoMembers[2]],
  ),
  _DemoAssignment(
    label: 'Masing-masing',
    icon: Symbols.groups,
    color: CColors.textEach,
    members: [_demoMembers[1]],
  ),
  _DemoAssignment(
    label: 'Masing-masing',
    icon: Symbols.groups,
    color: CColors.textEach,
    members: [_demoMembers[0], _demoMembers[1]],
  ),
];

/// Flip to true to preview the shared card variants while they are not part of
/// the real assignment flow yet.
const bool _previewSharedAssignments = false;

/// A card with no assignment yet: no header and no member chips.
final _soloAssignment = _DemoAssignment(
  label: '',
  icon: Symbols.person,
  color: CColors.accent,
  members: const <_DemoMember>[],
);

/// Temporary current user until auth is wired into the split flow.
final _currentUserAssignment = _DemoAssignment(
  label: 'Ayu (Anda)',
  icon: Symbols.person,
  color: CColors.accent,
  members: [_demoMembers[0]],
);

class _SplitItemCard extends StatelessWidget {
  final ReceiptItem item;
  final _DemoAssignment assignment;
  final bool assigned;
  final VoidCallback onTap;

  const _SplitItemCard({
    super.key,
    required this.item,
    required this.assignment,
    required this.assigned,
    required this.onTap,
  });

  Widget _memberChip(_DemoMember member) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: BoxBorder.all(color: member.color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: member.color.withAlpha(20),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.person, color: member.color, size: 14),
          ),
          Text(
            member.name,
            style: TextStyle(color: member.color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memberCount = assignment.members.length;
    final showHeader = memberCount > 1;
    final itemName = item.name.isEmpty ? 'Item tanpa nama' : item.name;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color:Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: BoxBorder.all(
              color: assigned
                  ? CColors.accent.withAlpha(120)
                  : CColors.border,
            ),
          ),
          child: Column(
            children: [
              if (showHeader) ...[
                Row(
                  children: [
                    Icon(
                      assignment.icon,
                      weight: 600,
                      size: 16,
                      color: assignment.color,
                    ),
                    SizedBox(width: 5),
                    Text(
                      assignment.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: assignment.color,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.person, size: 16),
                    SizedBox(width: 5),
                    Text(
                      "$memberCount orang",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${item.qtyLabel}x $itemName",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight(600),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    formatRupiah(item.total),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight(600),
                    ),
                  ),
                ],
              ),
              if (assignment.members.isNotEmpty) ...[
                Divider(color: CColors.border),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: assignment.members
                            .map((member) => _memberChip(member))
                            .toList(),
                      ),
                    ),
                    if (showHeader) ...[
                      SizedBox(width: 10),
                      Text(
                        "${formatRupiah(item.total / memberCount)}/orang",
                        style: TextStyle(
                          fontSize: 12,
                          color: CColors.textGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
