import 'package:flutter/material.dart';

class CColors {
  static Color accent = Color(0xFF2196F3);
  static Color background = Color(0xFFF3F4F6);
  static Color textGray = Color(0xFF8C8C8C);
  static Color text = Color(0xFF27272A);
  static Color border = Color(0xFFE7E5E4);
  static Color danger = Color(0xFFFF6467);
  static Color textShared = Color(0xFF00A63E);
  static Color textEach = Color(0xFF7F22FE);

  // Keep in sync with MEMBER_COLORS in billin-web/billin.py.
  static const List<Color> memberPalette = [
    Color(0xFF2196F3),
    Color(0xFFA800B7),
    Color(0xFF5EA500),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF14B8A6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  static Color memberColor(int index) {
    if (memberPalette.isEmpty) {
      return accent;
    }
    return memberPalette[index.abs() % memberPalette.length];
  }

  // Status colors for undangan dialogs
  static Color success = Color(0xFF5EA500);
  static Color successLight = Color(0xFFDDECC9);
  static Color dangerRed = Color(0xFFFB2C36);
  static Color dangerRedLight = Color(0xFFFEE5E7);
}
