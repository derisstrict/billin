import 'package:billin/common/c_colors.dart';
import 'package:billin/common/c_container.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class CardAnggota extends StatelessWidget {
  final String name;
  final String role;
  final int colorIndex;
  final VoidCallback? onDelete;

  const CardAnggota({
    super.key,
    required this.name,
    required this.role,
    this.colorIndex = 0,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = CColors.memberColor(colorIndex);

    return CContainer(
      child: Row(
        spacing: 10,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Icon(Symbols.group, weight: 600, color: color, size: 26),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        role,
                        style: TextStyle(color: CColors.textGray, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Symbols.delete_outline,
                      weight: 600,
                      color: CColors.danger,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
