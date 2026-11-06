import 'package:billin/common/c_colors.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String itemName;
  final String subtext;
  final String price;

  const ItemCard({super.key, 
  required this.itemName, 
  required this.subtext, 
  required this.price
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(itemName,
                  style: TextStyle(
                    fontWeight: FontWeight(600),
                    fontSize: 14,
                  ),
                ),
                Text(subtext,
                  style: TextStyle(
                    fontWeight: FontWeight(400),
                    fontSize: 12,
                    color: CColors.textGray
                  ),
                )
              ],
            ),
            Spacer(),
            Text(price,
              style: TextStyle(
                fontWeight: FontWeight(600),
                fontSize: 14,
              ),
            ),
            IconButton(
              onPressed: () {}, 
              icon: Icon(Icons.edit_outlined,
                size: 20,
                color: CColors.textGray,
              )
            )
          ],
        ),
        Divider(color: CColors.border,)
      ],
    );
  }
}