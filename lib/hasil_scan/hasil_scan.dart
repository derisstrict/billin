import 'package:billin/common/c_app_bar.dart';
import 'package:billin/common/c_colors.dart';
import 'package:billin/common/c_container.dart';
import 'package:billin/hasil_scan/item_card.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class HasilScan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: CColors.background,
      appBar: CAppBar("Hasil Scan"),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Stack(
                alignment: AlignmentGeometry.bottomEnd,
                children: [
                  CContainer(
                    child: Column(
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: CColors.accent.withAlpha(50),
                                borderRadius: BorderRadius.circular(10) 
                              ),
                              child: Icon(Icons.store_outlined,
                                size: 34,
                                color: CColors.accent,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Gacoan Jimbaran",
                                  style: TextStyle(
                                    fontWeight: FontWeight(700),
                                    fontSize: 16
                                  ),
                                ),
                                Text("Kamis, 25 November 2025",
                                  style: TextStyle(
                                    fontWeight: FontWeight(400),
                                    fontSize: 14,
                                    color: CColors.textGray
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 15,),
                        Row(
                          children: List.generate(150~/2.5, (index) => Expanded(
                            child: Container(
                              color: index%2==0?Colors.transparent
                              :CColors.border,
                              height: 2,
                            ),)
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Text("Item Terdeteksi (10)",
                            style: TextStyle(
                                fontWeight: FontWeight(600),
                                fontSize: 14,
                                color: CColors.textGray
                              ),
                            ),
                            Spacer(),
                            Text("Subtotal",
                            style: TextStyle(
                                fontWeight: FontWeight(600),
                                fontSize: 14,
                                color: CColors.textGray
                              ),
                            ),
                            SizedBox(width: 45,)
                          ],
                        ),
                        SizedBox(height: 10,),
                        ItemCard(
                          itemName: "Salt Bread", 
                          subtext: "12 porsi x Rp. 14.000", 
                          price: "Rp. 175.000"
                        ),
                        ItemCard(
                          itemName: "Salt Bread", 
                          subtext: "12 porsi x Rp. 14.000", 
                          price: "Rp. 175.000"
                        ),
                        ItemCard(
                          itemName: "Salt Bread", 
                          subtext: "12 porsi x Rp. 14.000", 
                          price: "Rp. 175.000"
                        ),
                        ItemCard(
                          itemName: "Salt Bread", 
                          subtext: "12 porsi x Rp. 14.000", 
                          price: "Rp. 175.000"
                        ),
                        ItemCard(
                          itemName: "Salt Bread", 
                          subtext: "12 porsi x Rp. 14.000", 
                          price: "Rp. 175.000"
                        ),
                        ItemCard(
                          itemName: "Salt Bread", 
                          subtext: "12 porsi x Rp. 14.000", 
                          price: "Rp. 175.000"
                        ),
                        ItemCard(
                          itemName: "Salt Bread", 
                          subtext: "12 porsi x Rp. 14.000", 
                          price: "Rp. 175.000"
                        ),
                        ItemCard(
                          itemName: "Salt Bread", 
                          subtext: "12 porsi x Rp. 14.000", 
                          price: "Rp. 175.000"
                        ),
                        ItemCard(
                          itemName: "Salt Bread", 
                          subtext: "12 porsi x Rp. 14.000", 
                          price: "Rp. 175.000"
                        ),
                        ItemCard(
                          itemName: "Salt Bread", 
                          subtext: "12 porsi x Rp. 14.000", 
                          price: "Rp. 175.000"
                        ),
                        ItemCard(
                          itemName: "Salt Bread", 
                          subtext: "12 porsi x Rp. 14.000", 
                          price: "Rp. 175.000"
                        ),
                        ItemCard(
                          itemName: "Salt Bread", 
                          subtext: "12 porsi x Rp. 14.000", 
                          price: "Rp. 175.000"
                        ),
                        SizedBox(height: 10,),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: CColors.accent.withAlpha(50),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Row(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline,
                                color: CColors.accent,
                                size: 18,
                              ),
                              Text("Tambah Item Manual",
                                style: TextStyle(
                                  color: CColors.accent,
                                  fontSize: 14
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 15,),
                        Row(
                          children: List.generate(150~/2.5, (index) => Expanded(
                            child: Container(
                              color: index%2==0?Colors.transparent
                              :CColors.border,
                              height: 2,
                            ),)
                          ),
                        ),
                        SizedBox(height: 15,),
                        Column(
                          spacing: 5,
                          children: [
                            Row(
                              children: [
                                Text("Subtotal (10 item)"),
                                Spacer(),
                                Text("Rp. 1.000.000",
                                  style: TextStyle(
                                    fontWeight: FontWeight(700)
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text("Pajak (14%)"),
                                Spacer(),
                                Text("Rp. 175.000",
                                  style: TextStyle(
                                    fontWeight: FontWeight(700)
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text("Diskon (8%)"),
                                Spacer(),
                                Text("Rp. 250.000",
                                  style: TextStyle(
                                    fontWeight: FontWeight(700)
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text("Grand Total",
                                  style: TextStyle(
                                    fontWeight: FontWeight(700),
                                    color: CColors.accent
                                  ),
                                ),
                                Spacer(),
                                Text("Rp. 1.500.000",
                                  style: TextStyle(
                                    fontWeight: FontWeight(700),
                                    color: CColors.accent
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 20,)
                      ],
                    ),
                  ),
                  Positioned(
                    top: 32,
                    right: -5,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      height: 100,
                      decoration: BoxDecoration(
                        color: CColors.background,
                        shape: BoxShape.circle,
                        border: BoxBorder.all(
                          color: CColors.border
                        ),
                      ),
                    )
                  ),
                  Positioned(
                    top: 32,
                    left: -5,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      height: 100,
                      decoration: BoxDecoration(
                        color: CColors.background,
                        shape: BoxShape.circle,
                        border: BoxBorder.all(
                          color: CColors.border
                        ),
                      ),
                    )
                  ),
                  Positioned(
                    right: 0,
                    left: 0,
                    bottom: -18,
                    child: Row(
                      children: List.generate(19, (index) => Expanded(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: index%2==0?Colors.transparent
                            :CColors.background,
                            shape: BoxShape.circle,
                            border: BoxBorder.all(
                              color: index%2==0?Colors.transparent
                              :CColors.border
                            ),
                          ),
                        ),)
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15,),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CColors.accent,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Lanjutkan",
                      style: TextStyle(
                        fontWeight: FontWeight(700),
                        color: Colors.white
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}