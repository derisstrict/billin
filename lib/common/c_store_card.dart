import 'package:billin/common/c_colors.dart';
import 'package:billin/common/c_icon_box.dart';
import 'package:flutter/material.dart';

class CStoreCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  const CStoreCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 12,
            children: [
              leading ??
                  CIconBox(
                    icon: Icons.store_outlined,
                    iconColor: CColors.accent,
                    backgroundColor: CColors.accent.withAlpha(45),
                    size: 52,
                    borderRadius: 12,
                  ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight(700),
                        color: CColors.text,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight(400),
                        color: CColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (child != null) ...[
            SizedBox(height: 16,),
            child!,
          ],
        ],
      ),
    );
  }
}
