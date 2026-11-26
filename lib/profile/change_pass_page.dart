import 'package:billin/common/c_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  static const _blue = Color(0xFF2F80ED);
  static const _green = Color(0xFF5BA800);

  final _supabase = Supabase.instance.client;
  bool _saving = false;

  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;

    final user = _supabase.auth.currentUser;
    final email = user?.email;
    final oldPass = _oldCtrl.text;
    final newPass = _newCtrl.text;

    if (user == null || email == null) {
      _msg('Sesi berakhir. Silakan login ulang.', error: true);
      return;
    }
    if (oldPass.isEmpty || newPass.isEmpty || _confirmCtrl.text.isEmpty) {
      _msg('Semua kolom wajib diisi.', error: true);
      return;
    }
    if (newPass.length < 6) {
      _msg('Kata sandi baru minimal 6 karakter.', error: true);
      return;
    }
    if (newPass != _confirmCtrl.text) {
      _msg('Konfirmasi kata sandi tidak sama.', error: true);
      return;
    }
    if (newPass == oldPass) {
      _msg('Kata sandi baru harus berbeda dari yang lama.', error: true);
      return;
    }

    setState(() => _saving = true);
    try {
      // 1. verifikasi sandi lama
      await _supabase.auth.signInWithPassword(email: email, password: oldPass);
    } on AuthException {
      _msg('Kata sandi lama salah.', error: true);
      if (mounted) setState(() => _saving = false);
      return;
    } catch (e) {
      _msg('Gagal memverifikasi: $e', error: true);
      if (mounted) setState(() => _saving = false);
      return;
    }

    try {
      // 2. ganti sandi
      await _supabase.auth.updateUser(UserAttributes(password: newPass));
      if (!mounted) return;
      _msg('Kata sandi berhasil diubah.');
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
      appBar: CAppBar('Ubah Kata Sandi'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 14),
              _PasswordField(
                label: 'Kata Sandi Lama',
                hint: 'Masukkan kata sandi lama',
                controller: _oldCtrl,
              ),
              const SizedBox(height: 14),
              _PasswordField(
                label: 'Kata Sandi Baru',
                hint: 'Masukkan kata sandi baru',
                controller: _newCtrl,
              ),
              const SizedBox(height: 14),
              _PasswordField(
                label: 'Konfirmasi Kata Sandi',
                hint: 'Masukkan kata sandi baru',
                controller: _confirmCtrl,
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

/// Ikon gembok + judul + subjudul
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
            Icons.lock_outline,
            size: 18,
            color: _ChangePasswordPageState._blue,
          ),
        ),
        const SizedBox(width: 6),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubah Kata Sandi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _ChangePasswordPageState._blue,
                height: 1.1,
              ),
            ),
            Text(
              'Buat kata sandi yang berbeda dari sebelumnya',
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

/// Label + field kata sandi dengan tombol mata (tampil/sembunyi)
class _PasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF757575),
            ),
          ),
        ),
        TextField(
          controller: widget.controller,
          obscureText: _obscure,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: widget.hint,
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
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: const Color(0xFFBDBDBD),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
