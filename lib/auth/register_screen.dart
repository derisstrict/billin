import 'package:flutter/material.dart';

import 'auth_widgets.dart';
import 'login_screen.dart';
import 'page_transitions.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form register valid')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Bergabung Sekarang!',
      subtitle: 'Isi data di bawah ini untuk\nmendaftarkan akun barumu',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AuthField(
              label: 'Email',
              hint: 'Masukkan email anda',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Email wajib diisi';
                if (!text.contains('@') || !text.contains('.')) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            AuthField(
              label: 'Kata Sandi',
              hint: 'Masukkan kata sandi',
              controller: _passwordController,
              obscure: true,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kata sandi wajib diisi';
                }
                if (value.length < 6) {
                  return 'Kata sandi minimal 6 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            AuthField(
              label: 'Konfirmasi Kata Sandi',
              hint: 'Konfirmasi kata sandi',
              controller: _confirmController,
              obscure: true,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi kata sandi wajib diisi';
                }
                if (value != _passwordController.text) {
                  return 'Kata sandi tidak sama';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            GradientButton(text: 'Buat Akun', onPressed: _submit),
            const SizedBox(height: 10),
            AuthFooter(
              text: 'Sudah punya akun?',
              actionText: 'Login',
              onTap: () => Navigator.pushReplacement(
                context,
                fadeRoute(const LoginScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}