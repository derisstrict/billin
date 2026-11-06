import 'package:billin/common/c_colors.dart';
import 'package:billin/common/c_container.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class CardAnggota extends StatelessWidget {
  final String name;
  final String role;

  const CardAnggota({super.key, required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CContainer(
      child: Row(
        spacing: 10,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CColors.accent.withAlpha(50),
              shape: BoxShape.circle
            ),
            child: Icon(Symbols.group,
              weight: 600,
              color: CColors.accent,
              size: 26,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                        style: TextStyle(
                          fontWeight: FontWeight(700)
                        ),
                      ),
                      Text(role,
                        style: TextStyle(
                          color: CColors.textGray,
                          fontSize: 12
                        ),
                      )
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {}, 
                  icon: Icon(Symbols.delete_outline,
                    weight: 600,
                    color: CColors.danger,
                  )
                )
              ],
            )
          )
        ],
      ),
    );
  }
}