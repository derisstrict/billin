import 'dart:async';

import 'package:billin/common/c_app_bar.dart';
import 'package:billin/common/c_colors.dart';
import 'package:billin/common/currency_formatter.dart';
import 'package:billin/common/section_heading.dart';
import 'package:billin/hasil_scan/hasil_scan.dart';
import 'package:billin/list_anggota/list_anggota.dart';
import 'package:billin/model/group.dart';
import 'package:billin/model/receipt.dart';
import 'package:billin/service/group_service.dart';
import 'package:billin/service/session.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SplitPage extends StatefulWidget {
  final ReceiptData? receipt;
  final String? groupToken;
  final String? memberId;

  const SplitPage({super.key, this.receipt, this.groupToken, this.memberId});

  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  final GroupService _service = GroupService();

  late ReceiptData _fallbackReceipt;
  GroupData? _group;
  String? _token;
  String? _memberId;
  Timer? _pollTimer;

  int _lastRevision = -1;
  bool _loading = true;
  bool _saving = false;
  bool _isLocalMode = false;
  String? _error;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    _fallbackReceipt = widget.receipt ?? ReceiptData.demo();
    _bootstrap();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    _pollTimer?.cancel();
    setState(() {
      _loading = true;
      _error = null;
      _connectionError = null;
    });

    try {
      if (widget.groupToken != null) {
        final group = await _service.fetchGroup(widget.groupToken!);
        if (!mounted) {
          return;
        }
        setState(() {
          _group = group;
          _token = widget.groupToken;
          _memberId = widget.memberId ?? group.host?.id;
          _lastRevision = group.revision;
          _loading = false;
          _isLocalMode = false;
        });
      } else {
        final created = await _service.createGroup(
          receipt: _fallbackReceipt,
          hostName: currentUserName,
        );
        if (!mounted) {
          return;
        }
        setState(() {
          _group = created.group;
          _token = created.group.token;
          _memberId = created.memberId;
          _lastRevision = created.group.revision;
          _loading = false;
          _isLocalMode = false;
        });
      }
      _startPolling();
    } on GroupException catch (error) {
      _useLocalMode(error.message);
    } catch (_) {
      _useLocalMode('Terjadi kesalahan saat menghubungi server BillIn.');
    }
  }

  void _useLocalMode(String message) {
    if (!mounted) {
      return;
    }
    final local = GroupData.local(_fallbackReceipt, hostName: currentUserName);
    setState(() {
      _group = local;
      _token = null;
      _memberId = local.host?.id;
      _lastRevision = local.revision;
      _loading = false;
      _isLocalMode = true;
      _error = message;
    });
  }

  void _startPolling() {
    _pollTimer?.cancel();
    if (_isLocalMode) {
      return;
    }
    _pollTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) => _refresh(),
    );
  }

  Future<void> _refresh() async {
    final token = _token;
    if (token == null || _saving) {
      return;
    }

    try {
      final group = await _service.fetchGroup(token);
      if (!mounted) {
        return;
      }
      if (group.revision != _lastRevision) {
        setState(() {
          _group = group;
          _lastRevision = group.revision;
          _connectionError = null;
        });
      } else if (_connectionError != null) {
        setState(() => _connectionError = null);
      }
    } on GroupException catch (error) {
      if (mounted) {
        setState(() => _connectionError = error.message);
      }
    }
  }

  Future<void> _toggleItem(int index) async {
    final group = _group;
    final memberId = _memberId;
    if (group == null || memberId == null || _saving) {
      return;
    }

    final selected = group.selectedIndexes(memberId);
    if (!selected.add(index)) {
      selected.remove(index);
    }

    setState(() {
      _group = group.withAssignments(memberId, selected);
      _saving = true;
    });

    if (_isLocalMode) {
      setState(() => _saving = false);
      return;
    }

    final token = _token;
    if (token == null) {
      setState(() => _saving = false);
      return;
    }

    try {
      final updated = await _service.updateAssignments(
        token,
        memberId,
        selected,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _group = updated;
        _lastRevision = updated.revision;
        _saving = false;
        _connectionError = null;
      });
    } on GroupException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _group = group;
        _saving = false;
      });
      _showMessage(error.message);
    }
  }

  void _openMembers() {
    if (_isLocalMode || _token == null) {
      _showMessage('Kelola anggota membutuhkan koneksi ke server BillIn.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ListAnggota(groupToken: _token!, currentMemberId: _memberId),
      ),
    );
  }

  Future<void> _editReceipt() async {
    final group = _group;
    final memberId = _memberId;
    if (group == null || _saving) {
      return;
    }
    if (!(group.memberById(memberId)?.isHost ?? false)) {
      _showMessage('Hanya host yang dapat mengubah struk.');
      return;
    }

    final updatedReceipt = await Navigator.of(context).push<ReceiptData>(
      MaterialPageRoute<ReceiptData>(
        builder: (_) => HasilScan(
          receipt: group.receipt,
          isEditMode: true,
        ),
      ),
    );

    if (updatedReceipt == null || !mounted) {
      return;
    }

    final previousGroup = group;
    final previousFallback = _fallbackReceipt;
    final nextGroup = group.withReceipt(updatedReceipt);

    setState(() {
      _fallbackReceipt = updatedReceipt;
      _group = nextGroup;
      _saving = true;
    });

    if (_isLocalMode || _token == null || memberId == null) {
      setState(() => _saving = false);
      return;
    }

    try {
      final synced = await _service.updateReceipt(
        token: _token!,
        memberId: memberId,
        receipt: updatedReceipt,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _group = synced;
        _fallbackReceipt = synced.receipt;
        _lastRevision = synced.revision;
        _saving = false;
        _connectionError = null;
      });
    } on GroupException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _fallbackReceipt = previousFallback;
        _group = previousGroup;
        _saving = false;
      });
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _statusBanner(
    String message, {
    VoidCallback? onRetry,
    String retryLabel = 'Coba lagi',
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CColors.danger.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CColors.danger.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: CColors.danger, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: CColors.danger),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(retryLabel, style: TextStyle(color: CColors.danger)),
            ),
        ],
      ),
    );
  }

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

  Widget _friendRow(GroupMember member) {
    final group = _group;
    if (group == null) {
      return const SizedBox.shrink();
    }

    final share = group.shareFor(member.id);
    final color = CColors.memberColor(member.colorIndex);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              member.name,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
          Text(
            formatRupiah(share.total),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: CColors.background,
        appBar: CAppBar("Split Bill"),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final group = _group;
    if (group == null) {
      return Scaffold(
        backgroundColor: CColors.background,
        appBar: CAppBar("Split Bill"),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error ?? 'Gagal memuat tagihan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: CColors.textGray),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _bootstrap,
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final receipt = group.receipt;
    final itemCount = receipt.items.length;
    final memberId = _memberId;
    final share = memberId == null
        ? const MemberShare(
            itemCount: 0,
            subtotal: 0,
            tax: 0,
            service: 0,
            discount: 0,
            total: 0,
          )
        : group.shareFor(memberId);

    return Scaffold(
      backgroundColor: CColors.background,
      appBar: CAppBar("Split Bill"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              if (_isLocalMode)
                _statusBanner(
                  'Mode lokal: ${_error ?? 'server tidak terhubung.'}',
                  onRetry: _bootstrap,
                ),
              if (_connectionError != null)
                _statusBanner(
                  'Koneksi terganggu: $_connectionError',
                  onRetry: _refresh,
                  retryLabel: 'Muat ulang',
                ),
              if (_saving)
                LinearProgressIndicator(
                  minHeight: 2,
                  color: CColors.accent,
                  backgroundColor: CColors.accent.withAlpha(30),
                ),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: CColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
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
                                receipt.merchantName.isEmpty
                                    ? 'Merchant tidak diketahui'
                                    : receipt.merchantName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                receipt.date.isEmpty ? '-' : receipt.dateLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: CColors.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (group.memberById(memberId)?.isHost ?? false)
                          IconButton(
                            onPressed: _saving ? null : _editReceipt,
                            icon: Icon(
                              Symbols.edit_square,
                              weight: 600,
                              color: CColors.accent,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          "Grand Total",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Text(
                          formatRupiah(receipt.grandTotal),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: CColors.background,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        spacing: 5,
                        children: [
                          _summaryRow(
                            "Subtotal",
                            formatRupiah(receipt.subtotal),
                          ),
                          _summaryRow("Pajak", formatRupiah(receipt.tax)),
                          _summaryRow(
                            "Biaya Layanan",
                            formatRupiah(receipt.serviceCharge),
                          ),
                          _summaryRow(
                            "Diskon",
                            receipt.discounts > 0
                                ? "- ${formatRupiah(receipt.discounts)}"
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
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: CColors.border),
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
                          onPressed: _openMembers,
                          child: Row(
                            spacing: 5,
                            children: [
                              Icon(
                                Symbols.manage_accounts,
                                weight: 600,
                                size: 20,
                                color: Colors.white,
                              ),
                              const Text(
                                "Kelola",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.person, size: 18),
                        Text(
                          "${group.members.length} orang",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 15,
                      runSpacing: 10,
                      children: group.members.map((member) {
                        return _MemberChip(
                          member: member,
                          isCurrentUser: member.id == memberId,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SectionHeading("Item ($itemCount item)"),
              if (receipt.items.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: CColors.border),
                  ),
                  child: Text(
                    'Belum ada item terdeteksi.',
                    style: TextStyle(fontSize: 14, color: CColors.textGray),
                  ),
                )
              else
                ...List.generate(receipt.items.length, (index) {
                  final item = receipt.items[index];
                  final assigned =
                      memberId != null &&
                      (group.assignments[index]?.contains(memberId) ?? false);

                  return _SplitItemCard(
                    key: ValueKey('${item.id}-$index'),
                    item: item,
                    assignees: group.assigneesFor(index),
                    assigned: assigned,
                    onTap: _saving ? null : () => _toggleItem(index),
                  );
                }),
              SectionHeading("Hasil"),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: CColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text("Rincian pengeluaran kamu"),
                        const Spacer(),
                        Text(
                          "${share.itemCount} item dipilih",
                          style: TextStyle(
                            fontSize: 12,
                            color: CColors.textGray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: CColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [Icon(Symbols.receipt_long, weight: 600)],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Total Pengeluaran",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(formatRupiah(share.total)),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    const Text("Subtotal"),
                                    const Spacer(),
                                    Text(formatRupiah(share.subtotal)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Pajak"),
                                    const Spacer(),
                                    Text(formatRupiah(share.tax)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Biaya Layanan"),
                                    const Spacer(),
                                    Text(formatRupiah(share.service)),
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
                                    const SizedBox(width: 5),
                                    const Text("Diskon"),
                                    const Spacer(),
                                    Text(
                                      share.discount > 0
                                          ? "- ${formatRupiah(share.discount)}"
                                          : formatRupiah(0),
                                      style: TextStyle(color: CColors.accent),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (group.members.length > 1) ...[
                      const SizedBox(height: 12),
                      const Text(
                        "Rincian pengeluaran teman",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      ...group.members
                          .where((member) => member.id != memberId)
                          .map(
                            (member) => Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: _friendRow(member),
                            ),
                          ),
                      Text(
                        '*Sudah termasuk pajak, biaya layanan dan diskon.',
                        style: TextStyle(fontSize: 10, color: CColors.textGray),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Material(
                      color: CColors.accent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () =>
                            _showMessage('Pilihan sudah tersimpan otomatis.'),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
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

class _MemberChip extends StatelessWidget {
  final GroupMember member;
  final bool isCurrentUser;

  const _MemberChip({required this.member, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final color = CColors.memberColor(member.colorIndex);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withAlpha(isCurrentUser ? 120 : 50),
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.person, color: color, size: 16),
          ),
          Text(
            '${member.name}${isCurrentUser ? ' (Anda)' : ''}',
            style: TextStyle(
              fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitItemCard extends StatelessWidget {
  final ReceiptItem item;
  final List<GroupMember> assignees;
  final bool assigned;
  final VoidCallback? onTap;

  const _SplitItemCard({
    super.key,
    required this.item,
    required this.assignees,
    required this.assigned,
    required this.onTap,
  });

  Widget _memberChip(GroupMember member) {
    final color = CColors.memberColor(member.colorIndex);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.person, color: color, size: 14),
          ),
          Text(member.name, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memberCount = assignees.length;
    final badge = splitBadgeFor(memberCount, item.qty);
    final showHeader = badge != ItemSplitBadge.solo;
    final shared = badge == ItemSplitBadge.shared;
    final headerColor = shared ? CColors.textShared : CColors.textEach;
    final headerIcon = shared ? Symbols.spoke : Symbols.groups;
    final headerLabel = shared ? 'Berbagi' : 'Masing-masing';
    final itemName = item.name.isEmpty ? 'Item tanpa nama' : item.name;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: assigned ? CColors.accent.withAlpha(120) : CColors.border,
            ),
          ),
          child: Column(
            children: [
              if (showHeader) ...[
                Row(
                  children: [
                    Icon(headerIcon, weight: 600, size: 16, color: headerColor),
                    const SizedBox(width: 5),
                    Text(
                      headerLabel,
                      style: TextStyle(fontSize: 12, color: headerColor),
                    ),
                    const Spacer(),
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      "$memberCount orang",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${item.qtyLabel}x $itemName",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formatRupiah(item.total),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (assignees.isNotEmpty) ...[
                Divider(color: CColors.border),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: assignees
                            .map((member) => _memberChip(member))
                            .toList(),
                      ),
                    ),
                    if (showHeader) ...[
                      const SizedBox(width: 10),
                      Text(
                        "${formatRupiah(item.total / memberCount)}/orang",
                        style: TextStyle(fontSize: 12, color: CColors.textGray),
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
