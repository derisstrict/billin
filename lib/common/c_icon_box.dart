import 'package:flutter/material.dart';

class CIconBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double size;
  final double borderRadius;

  const CIconBox({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.size = 48,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(icon,
          color: iconColor,
          size: size * 0.6,
        ),
      ),
    );
  }
}
