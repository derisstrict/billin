import 'package:flutter/material.dart';

import 'auth_widgets.dart';
import 'page_transitions.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: panggil API login di sini, lalu pindah ke halaman utama.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form login valid')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Masuk Ke Akun Anda',
      subtitle: 'Silakan masukkan detail\nakunmu untuk melanjutkan',
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
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kata sandi wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            GradientButton(text: 'Login', onPressed: _submit),
            const SizedBox(height: 10),
            AuthFooter(
              text: 'Tidak punya akun?',
              actionText: 'Buat Akun',
              onTap: () => Navigator.pushReplacement(
                context,
                fadeRoute(const RegisterScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}