import 'package:billin/common/c_colors.dart';
import 'package:flutter/material.dart';

class CContainer extends StatelessWidget {
  final Widget? child;

  const CContainer({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: BoxBorder.all(
          color: CColors.border
        ),
      ),
      child: child,
    );
  }
}