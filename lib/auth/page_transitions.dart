import 'package:flutter/material.dart';

/// Empat pilihan transisi halaman. Pakai salah satunya di Navigator, contoh:
/// Navigator.pushReplacement(context, fadeSlideRoute(const RegisterScreen()));

/// 1. Fade: halaman lama memudar, halaman baru muncul pelan.
/// Paling halus untuk dua halaman dengan background yang sama.
PageRoute<T> fadeRoute<T>(Widget page, {int ms = 450}) {
  return PageRouteBuilder<T>(
    transitionDuration: Duration(milliseconds: ms),
    reverseTransitionDuration: Duration(milliseconds: ms),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}

/// 2. Fade + geser sedikit dari bawah: terasa ringan dan modern.
PageRoute<T> fadeSlideRoute<T>(Widget page, {int ms = 450}) {
  return PageRouteBuilder<T>(
    transitionDuration: Duration(milliseconds: ms),
    reverseTransitionDuration: Duration(milliseconds: ms),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// 3. Geser horizontal dari kanan (atau kiri kalau [fromRight] = false).
/// Cocok: Login -> Register dari kanan, Register -> Login dari kiri.
PageRoute<T> slideRoute<T>(
  Widget page, {
  bool fromRight = true,
  int ms = 450,
}) {
  return PageRouteBuilder<T>(
    transitionDuration: Duration(milliseconds: ms),
    reverseTransitionDuration: Duration(milliseconds: ms),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset(fromRight ? 1 : -1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

/// 4. Zoom halus + fade: halaman baru membesar dari sedikit lebih kecil.
PageRoute<T> scaleFadeRoute<T>(Widget page, {int ms = 450}) {
  return PageRouteBuilder<T>(
    transitionDuration: Duration(milliseconds: ms),
    reverseTransitionDuration: Duration(milliseconds: ms),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}