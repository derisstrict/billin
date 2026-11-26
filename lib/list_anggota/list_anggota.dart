import 'dart:async';

import 'package:billin/common/c_app_bar.dart';
import 'package:billin/common/c_colors.dart';
import 'package:billin/common/c_container.dart';
import 'package:billin/common/section_heading.dart';
import 'package:billin/list_anggota/card_anggota.dart';
import 'package:billin/model/group.dart';
import 'package:billin/service/group_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

class ListAnggota extends StatefulWidget {
  final String groupToken;
  final String? currentMemberId;

  const ListAnggota({
    super.key,
    required this.groupToken,
    this.currentMemberId,
  });

  @override
  State<ListAnggota> createState() => _ListAnggotaState();
}

class _ListAnggotaState extends State<ListAnggota> {
  final GroupService _service = GroupService();
  final TextEditingController _nameController = TextEditingController();

  GroupData? _group;
  Timer? _pollTimer;
  bool _loading = true;
  bool _adding = false;
  String? _removingMemberId;
  String? _error;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    _load(initial: true);
    _pollTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (_adding || _removingMemberId != null) {
        return;
      }
      _load();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load({bool initial = false}) async {
    if (initial) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final group = await _service.fetchGroup(widget.groupToken);
      if (!mounted) {
        return;
      }
      setState(() {
        _group = group;
        _loading = false;
        _error = null;
        _connectionError = null;
      });
    } on GroupException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (_group == null) {
          _loading = false;
          _error = error.message;
        } else {
          _connectionError = error.message;
        }
      });
    }
  }

  Future<void> _copyLink() async {
    final url = _group?.joinUrl ?? '';
    if (url.isEmpty) {
      _showMessage('Link undangan belum tersedia.');
      return;
    }

    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) {
      return;
    }
    _showMessage('Link undangan disalin.');
  }

  Future<void> _addMember() async {
    if (_adding) {
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('Masukkan nama anggota terlebih dahulu.');
      return;
    }

    setState(() => _adding = true);

    try {
      final created = await _service.addMember(widget.groupToken, name);
      if (!mounted) {
        return;
      }
      _nameController.clear();
      setState(() {
        _group = created.group;
        _connectionError = null;
      });
      _showMessage('Anggota berhasil ditambahkan.');
    } on GroupException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _adding = false);
      }
    }
  }

  Future<void> _removeMember(GroupMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Hapus Anggota',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus ${member.name} dari tagihan?',
          style: TextStyle(fontSize: 13, color: CColors.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: CColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _removingMemberId = member.id);

    try {
      final updated = await _service.removeMember(widget.groupToken, member.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _group = updated;
        _connectionError = null;
      });
      _showMessage('Anggota berhasil dihapus.');
    } on GroupException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _removingMemberId = null);
      }
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: CColors.background,
        appBar: CAppBar("Anggota"),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final group = _group;
    if (group == null) {
      return Scaffold(
        backgroundColor: CColors.background,
        appBar: CAppBar("Anggota"),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error ?? 'Gagal memuat anggota.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: CColors.textGray),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _load(initial: true),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: CColors.background,
      appBar: CAppBar("Anggota"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              if (_connectionError != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CColors.danger.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CColors.danger.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        color: CColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Koneksi terganggu: $_connectionError',
                          style: TextStyle(fontSize: 12, color: CColors.danger),
                        ),
                      ),
                      TextButton(
                        onPressed: _load,
                        child: Text(
                          'Muat ulang',
                          style: TextStyle(color: CColors.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_adding || _removingMemberId != null)
                LinearProgressIndicator(
                  minHeight: 2,
                  color: CColors.accent,
                  backgroundColor: CColors.accent.withAlpha(30),
                ),
              CContainer(
                child: Column(
                  spacing: 15,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: CColors.accent.withAlpha(50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.link,
                            color: CColors.accent,
                            size: 26,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Undang Melalui Link",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Kirim link ke teman anda untuk bergabung",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: CColors.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
                      decoration: BoxDecoration(
                        color: CColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              group.joinUrl.isEmpty
                                  ? 'Link undangan belum tersedia'
                                  : group.joinUrl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: group.joinUrl.isEmpty
                                    ? CColors.textGray
                                    : CColors.text,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: group.joinUrl.isEmpty ? null : _copyLink,
                            tooltip: 'Salin link',
                            icon: Icon(
                              Icons.copy,
                              color: CColors.textGray,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              CContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 15,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: CColors.accent.withAlpha(50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Symbols.group_add,
                            color: CColors.accent,
                            size: 26,
                            weight: 600,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Tambah Anggota Manual",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Tambahkan anggota secara manual",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: CColors.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: CColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: _nameController,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (!_adding) {
                                  _addMember();
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Masukkan nama anggota',
                                hintStyle: TextStyle(
                                  color: CColors.textGray,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _adding ? null : _addMember,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CColors.accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _adding
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Tambah",
                                  style: TextStyle(fontSize: 12),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SectionHeading("Anggota Terdaftar"),
              Row(
                spacing: 5,
                children: [
                  Icon(Icons.info_outline, size: 16, color: CColors.textGray),
                  Expanded(
                    child: Text(
                      "Semua anggota yang terdaftar sudah dapat memilih item",
                      style: TextStyle(fontSize: 12, color: CColors.textGray),
                    ),
                  ),
                ],
              ),
              Column(
                spacing: 5,
                children: group.members.map((member) {
                  final isMe = member.id == widget.currentMemberId;
                  final canDelete =
                      !member.isHost && !isMe && _removingMemberId == null;

                  return CardAnggota(
                    name: '${member.name}${isMe ? ' (Anda)' : ''}',
                    role: member.isHost ? 'Pembuat' : 'Anggota',
                    colorIndex: member.colorIndex,
                    onDelete: canDelete ? () => _removeMember(member) : null,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
