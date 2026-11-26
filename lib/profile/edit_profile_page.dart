import 'package:billin/common/c_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const _blue = Color(0xFF2F80ED);
  static const _green = Color(0xFF5BA800);

  final _supabase = Supabase.instance.client;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = _supabase.auth.currentUser;
    final email = user?.email ?? '';
    final name = (user?.userMetadata?['username'] as String?)?.trim();

    _emailCtrl.text = email;
    _nameCtrl.text = (name != null && name.isNotEmpty)
        ? name
        : email.split('@').first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = _supabase.auth.currentUser;
    if (user == null || _saving) return;

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty) {
      _msg('Nama pengguna tidak boleh kosong.', error: true);
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _msg('Format email tidak valid.', error: true);
      return;
    }

    final emailChanged = email != (user.email ?? '');

    setState(() => _saving = true);
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          email: emailChanged ? email : null,
          data: {'username': name, 'display_name': name},
        ),
      );

      if (!mounted) return;
      _msg(
        emailChanged
            ? 'Tersimpan. Cek email baru untuk konfirmasi perubahan.'
            : 'Profil berhasil diperbarui.',
      );
      Navigator.pop(context);
    } on AuthException catch (e) {
      _msg(e.message, error: true);
    } catch (e) {
      _msg('Gagal menyimpan: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _msg(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? Colors.red : Colors.green,
        content: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CAppBar('Edit Profile'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 14),
              _LabeledField(
                label: 'Nama Pengguna',
                hint: 'Ubah nama pengguna baru',
                controller: _nameCtrl,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 14),
              _LabeledField(
                label: 'Email',
                hint: 'Masukkan email baru yang valid',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check, size: 18),
                  label: const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

/// Ikon + judul + subjudul
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFD6E8FB),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.manage_accounts_outlined,
            size: 18,
            color: _EditProfilePageState._blue,
          ),
        ),
        const SizedBox(width: 6),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _EditProfilePageState._blue,
                height: 1.1,
              ),
            ),
            Text(
              'Perbarui nama pengguna dan email pada akun anda',
              style: TextStyle(
                fontSize: 9,
                color: Color(0xFF9E9E9E),
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Label + kolom isian abu-abu
class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF757575),
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
