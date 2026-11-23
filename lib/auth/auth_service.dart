import 'package:billin/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:billin/auth/login_screen.dart';
import 'package:billin/auth/auth_widgets.dart';
import 'package:billin/auth/register_screen.dart';
import 'package:billin/auth/page_transitions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<void> login(
    String? email,
    String password,
    BuildContext context,
  ) async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final User? user = res.user;
      if (user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(errorMessage(e), style: TextStyle(color: Colors.white)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString(), style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  Future<void> signUp(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Daftar berhasil! Silahkan Login.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        // Navigator.pop(context); // balik ke login
        Navigator.pushReplacement(context, fadeRoute(const LoginScreen()));
      }
    } on AuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            errorMessage(e),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await supabase.auth.signOut();

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.message, style: const TextStyle(color: Colors.white)),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}

String errorMessage(AuthException e) {
  final code = e.code ?? '';
  final msg = e.message.toLowerCase();

  if (code == 'user_already_exists' || msg.contains('already registered')) {
    return 'Email sudah terdaftar. Silakan login.';
  }
  if (code == 'invalid_credentials' || msg.contains('invalid login')) {
    return 'Email atau kata sandi salah.';
  }
  return 'Terjadi kesalahan. Coba lagi.';
}
