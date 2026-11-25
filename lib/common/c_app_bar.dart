import 'package:billin/common/c_colors.dart';
import 'package:flutter/material.dart';

class CAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CAppBar(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AppBar(
      backgroundColor: CColors.accent,
      foregroundColor: Colors.white,
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight(600),
        ),
      ),
      shape: Border(bottom: BorderSide(color: CColors.border)),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
