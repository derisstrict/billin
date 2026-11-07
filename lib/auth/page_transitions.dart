import 'package:flutter/material.dart';

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