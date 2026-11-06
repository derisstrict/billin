import 'package:billin/common/c_app_bar.dart';
import 'package:billin/common/c_colors.dart';
import 'package:billin/common/section_heading.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SplitPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: CColors.background,
      appBar: CAppBar("Split Bill"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: BoxBorder.all(
                    color: CColors.border
                  )
                ),
                child: Column(
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: CColors.accent.withAlpha(20),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Icon(Icons.store_outlined,
                            color: CColors.accent,
                            size: 28
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Toko Roti Ceri",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight(700)
                              ),
                            ),
                            Text("Senin, 21 Oktober 2023 | 16.12",
                              style: TextStyle(
                                fontSize: 12,
                                color: CColors.textGray
                              ),
                            )
                          ],
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {}, 
                          icon: Icon(Symbols.edit_square, 
                            weight: 600,
                            color: CColors.accent,
                            size: 20,
                          )
                        )
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      children: [
                        Text("Grand Total",
                        style: TextStyle(
                          fontWeight: FontWeight(500)
                        )
                        ),
                        Spacer(),
                        Text("Rp. 728.000",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight(700)
                          ),
                        )
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: CColors.background,
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Column(
                        spacing: 5,
                        children: [
                          Row(
                            children: [
                              Text("Subtotal"),
                              Spacer(),
                              Text("Rp. 616.000")
                            ],
                          ),
                          Row(
                            children: [
                              Text("Pajak (7%)"),
                              Spacer(),
                              Text("Rp. 43.120")
                            ],
                          ),
                          Row(
                            children: [
                              Text("Layanan (8%)"),
                              Spacer(),
                              Text("Rp. 48.320")
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Symbols.percent_discount,
                                weight: 600,
                                color: CColors.accent,
                                size: 20
                              ),
                              SizedBox(width: 5,),
                              Text("Diskon"),
                              Spacer(),
                              Text("- Rp. 61.600",
                                style: TextStyle(
                                  color: CColors.accent
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ) 
              ),
              SectionHeading("Anggota"),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: BoxBorder.all(
                    color: CColors.border
                  )
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: CColors.accent
                          ),
                          onPressed: () {}, 
                          child: Row(
                            spacing: 5,
                            children: [
                              Icon(Symbols.manage_accounts,
                                weight: 600,
                                size: 20,
                                color: Colors.white,
                              ),
                              Text("Kelola",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white
                                ),
                              )
                            ],
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.person,
                          size: 18,
                        ),
                        Text("3 orang",
                          style: TextStyle(
                            fontSize: 12
                          ),
                        )
                        // TextButton(
                        //   onPressed: () {}, 
                        //   child: Row(
                        //     spacing: 5,
                        //     children: [
                        //       Icon(Symbols.edit_square, 
                        //         weight: 600,
                        //         size: 16,
                        //         color: CColors.accent,
                        //       ),
                        //       Text("Edit",
                        //         style: TextStyle(
                        //           fontSize: 12,
                        //           color: CColors.accent
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(width: 5,),
                        // TextButton(
                        //   onPressed: () {}, 
                        //   child: Row(
                        //     spacing: 5,
                        //     children: [
                        //       Icon(Symbols.delete, 
                        //         weight: 600,
                        //         size: 18,
                        //         color: CColors.danger,
                        //       ),
                        //       Text("Hapus",
                        //         style: TextStyle(
                        //           fontSize: 12,
                        //           color: CColors.danger
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        // ),
                        // IconButton(
                        //   onPressed: () {}, 
                        //   icon: Icon(Symbols.edit_square, 
                        //       weight: 600,
                        //       size: 18,
                        //       color: CColors.accent,
                        //     ),
                        // ),
                        // IconButton(
                        //   onPressed: () {}, 
                        //   icon: Icon(Symbols.delete, 
                        //       weight: 600,
                        //       size: 18,
                        //       color: CColors.danger,
                        //     ),
                        // )
                      ],
                    ),
                    SizedBox(height: 15,),
                    Wrap(
                      spacing: 15,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: BoxBorder.all(
                              color: CColors.accent.withAlpha(50),
                              width: 2,
                            )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: CColors.accent.withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.person,
                                  color: CColors.accent,
                                  size: 16,
                                ),
                              ),
                              Text("Ayu (Anda)",
                                style: TextStyle(
                                  fontWeight: FontWeight(600),
                                  color: CColors.accent
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: BoxBorder.all(
                              color: Color(0XFFA800B7).withAlpha(50),
                            )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Color(0XFFA800B7).withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.person,
                                  color: Color(0XFFA800B7),
                                  size: 16,
                                ),
                              ),
                              Text("Budi",
                                style: TextStyle(
                                  color: Color(0XFFA800B7)
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: BoxBorder.all(
                              color: Color(0XFF5EA500).withAlpha(50),
                            )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Color(0XFF5EA500).withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.person,
                                  color: Color(0XFF5EA500),
                                  size: 16,
                                ),
                              ),
                              Text("Citra",
                                style: TextStyle(
                                  color: Color(0XFF5EA500)
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(height: 10,),
                    // Container(
                    //   padding: EdgeInsets.all(8),
                    //   decoration: BoxDecoration(
                    //     color: CColors.accent,
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Icon(Symbols.manage_accounts,
                    //         color: Colors.white,
                    //         size: 16,
                    //         weight: 600,
                    //       ),
                    //       SizedBox(width: 5,),
                    //       Text("Kelola",
                    //       style: TextStyle(
                    //         color: Colors.white
                    //       ),)
                    //     ],
                    //   ),
                    // )
                  ],
                ),
              ),
              SectionHeading("Makanan (3 item)"),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: BoxBorder.all(
                    color: CColors.border
                  )
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Symbols.spoke,
                          weight: 600,
                          size: 16,
                          color: CColors.textShared,
                        ),
                        SizedBox(width: 5,),
                        Text("Berbagi",
                          style: TextStyle(
                            fontSize: 12,
                            color: CColors.textShared
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.person, size: 16,),
                        SizedBox(width: 5,),
                        Text("3 orang",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Text("1x Salt Bread (Family Size)",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight(600)
                          ),
                        ),
                        Spacer(),
                        Text("Rp. 102.000",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight(600)
                          ),
                        ),
                      ],
                    ),
                    Divider(color: CColors.border,),
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: BoxBorder.all(
                              color: CColors.accent.withAlpha(50),
                            )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: CColors.accent.withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.person,
                                  color: CColors.accent,
                                  size: 14,
                                ),
                              ),
                              Text("Ayu",
                                style: TextStyle(
                                  color: CColors.accent,
                                  fontSize: 12
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: BoxBorder.all(
                              color: Color(0XFFA800B7).withAlpha(50),
                            )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Color(0XFFA800B7).withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.person,
                                  color: Color(0XFFA800B7),
                                  size: 14,
                                ),
                              ),
                              Text("Budi",
                                style: TextStyle(
                                  color: Color(0XFFA800B7),
                                  fontSize: 12
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: BoxBorder.all(
                              color: Color(0XFF5EA500).withAlpha(50),
                            )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Color(0XFF5EA500).withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.person,
                                  color: Color(0XFF5EA500),
                                  size: 14,
                                ),
                              ),
                              Text("Citra",
                                style: TextStyle(
                                  color: Color(0XFF5EA500),
                                  fontSize: 12
                                ),
                              )
                            ],
                          ),
                        ),
                        Spacer(),
                        Text("Rp. 34.000/orang",
                          style: TextStyle(
                            fontSize: 12,
                            color: CColors.textGray
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: BoxBorder.all(
                    color: CColors.border
                  )
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Symbols.groups,
                          weight: 600,
                          size: 16,
                          color: CColors.textEach,
                        ),
                        SizedBox(width: 5,),
                        Text("Masing-masing",
                          style: TextStyle(
                            fontSize: 12,
                            color: CColors.textEach
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.person, size: 16,),
                        SizedBox(width: 5,),
                        Text("2 orang",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Text("2x Nasi Goreng Udang",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight(600)
                          ),
                        ),
                        Spacer(),
                        Text("Rp. 75.000",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight(600)
                          ),
                        ),
                      ],
                    ),
                    Divider(color: CColors.border,),
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: BoxBorder.all(
                              color: CColors.accent.withAlpha(50),
                            )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: CColors.accent.withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.person,
                                  color: CColors.accent,
                                  size: 14,
                                ),
                              ),
                              Text("Ayu",
                                style: TextStyle(
                                  color: CColors.accent,
                                  fontSize: 12
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: BoxBorder.all(
                              color: Color(0XFF5EA500).withAlpha(50),
                            )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Color(0XFF5EA500).withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.person,
                                  color: Color(0XFF5EA500),
                                  size: 14,
                                ),
                              ),
                              Text("Citra",
                                style: TextStyle(
                                  color: Color(0XFF5EA500),
                                  fontSize: 12
                                ),
                              )
                            ],
                          ),
                        ),
                        Spacer(),
                        Text("Rp. 34.000/orang",
                          style: TextStyle(
                            fontSize: 12,
                            color: CColors.textGray
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: BoxBorder.all(
                    color: CColors.border
                  )
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("1x Mie Ayam Bakso Sapi",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight(600)
                          ),
                        ),
                        Spacer(),
                        Text("Rp. 28.000",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight(600)
                          ),
                        ),
                      ],
                    ),
                    Divider(color: CColors.border,),
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: BoxBorder.all(
                              color: Color(0XFFA800B7).withAlpha(50),
                            )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Color(0XFFA800B7).withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.person,
                                  color: Color(0XFFA800B7),
                                  size: 14,
                                ),
                              ),
                              Text("Budi",
                                style: TextStyle(
                                  color: Color(0XFFA800B7),
                                  fontSize: 12
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SectionHeading("Minuman (2 item)"),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: BoxBorder.all(
                    color: CColors.border
                  )
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Symbols.groups,
                          weight: 600,
                          size: 16,
                          color: CColors.textEach,
                        ),
                        SizedBox(width: 5,),
                        Text("Masing-masing",
                          style: TextStyle(
                            fontSize: 12,
                            color: CColors.textEach
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.person, size: 16,),
                        SizedBox(width: 5,),
                        Text("2 orang",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Text("2x Es Kelapa Jeruk",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight(600)
                          ),
                        ),
                        Spacer(),
                        Text("Rp. 56.000",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight(600)
                          ),
                        ),
                      ],
                    ),
                    Divider(color: CColors.border,),
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: BoxBorder.all(
                              color: CColors.accent.withAlpha(50),
                            )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: CColors.accent.withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.person,
                                  color: CColors.accent,
                                  size: 14,
                                ),
                              ),
                              Text("Ayu",
                                style: TextStyle(
                                  color: CColors.accent,
                                  fontSize: 12
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: BoxBorder.all(
                              color: Color(0XFF5EA500).withAlpha(50),
                            )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Color(0XFF5EA500).withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.person,
                                  color: Color(0XFF5EA500),
                                  size: 14,
                                ),
                              ),
                              Text("Citra",
                                style: TextStyle(
                                  color: Color(0XFF5EA500),
                                  fontSize: 12
                                ),
                              )
                            ],
                          ),
                        ),
                        Spacer(),
                        Text("Rp. 28.000/orang",
                          style: TextStyle(
                            fontSize: 12,
                            color: CColors.textGray
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: BoxBorder.all(
                    color: CColors.border
                  )
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("1x Es Campur Tanpa Gula",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight(600)
                          ),
                        ),
                        Spacer(),
                        Text("Rp. 28.000",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight(600)
                          ),
                        ),
                      ],
                    ),
                    Divider(color: CColors.border,),
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: BoxBorder.all(
                              color: Color(0XFFA800B7).withAlpha(50),
                            )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Color(0XFFA800B7).withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.person,
                                  color: Color(0XFFA800B7),
                                  size: 14,
                                ),
                              ),
                              Text("Budi",
                                style: TextStyle(
                                  color: Color(0XFFA800B7),
                                  fontSize: 12
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SectionHeading("Hasil"),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: BoxBorder.all(
                    color: CColors.border
                  )
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Rincian pengeluaran kamu"),
                    SizedBox(height: 10,),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: BoxBorder.all(
                          color: CColors.border
                        )
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Symbols.receipt_long,
                                weight: 600,
                              ),
                            ],
                          ),
                          SizedBox(width: 10,),
                          Expanded(child: 
                          Column(
                            spacing: 5,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Total Pengeluaran",
                                    style: TextStyle(
                                      fontWeight: FontWeight(700)
                                    ),
                                  ),
                                  Spacer(),
                                  Text("Rp. 208.005"), 
                                ],
                              ),
                              Divider(),
                              Row(
                                children: [
                                  Text("Subtotal"),
                                  Spacer(),
                                  Text("Rp. 198.100"),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Pajak (7%)"),
                                  Spacer(),
                                  Text("Rp. 13.867"),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Layanan (8%)"),
                                  Spacer(),
                                  Text("Rp. 15.848"),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Symbols.percent_discount,
                                    weight: 600,
                                    size: 16,
                                    color: CColors.accent,
                                  ),
                                  SizedBox(width: 5,),
                                  Text("Diskon (10%)"),
                                  Spacer(),
                                  Text("- Rp. 19.810",
                                  style: TextStyle(
                                    color: CColors.accent
                                  ),),
                                ],
                              )
                            ],
                          ))
                        ],
                      ) 
                    ),
                    SizedBox(height: 10,),
                    Text("Rincian pengeluaran teman"),
                    SizedBox(height: 10,),
                    Container(
                      padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: BoxBorder.all(
                          color: Color(0XFFA800B7).withAlpha(50),
                        )
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        spacing: 10,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Color(0XFFA800B7).withAlpha(20),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(Icons.person,
                              color: Color(0XFFA800B7),
                              size: 14,
                            ),
                          ),
                          Text("Budi",
                            style: TextStyle(
                              color: Color(0XFFA800B7),
                              fontSize: 12
                            ),
                          ),
                          Spacer(),
                          Text("Rp. 94.000*",
                            style: TextStyle(
                              color: Color(0XFFA800B7)
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: BoxBorder.all(
                          color: Color(0XFF5EA500).withAlpha(50),
                        )
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        spacing: 10,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Color(0XFF5EA500).withAlpha(20),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(Icons.person,
                              color: Color(0XFF5EA500),
                              size: 14,
                            ),
                          ),
                          Text("Citra",
                            style: TextStyle(
                              color: Color(0XFF5EA500),
                              fontSize: 12
                            ),
                          ),
                          Spacer(),
                          Text("Rp. 99.500*",
                            style: TextStyle(
                              color: Color(0XFF5EA500)
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text("*Sudah termasuk pajak, biaya layanan dan diskon.",
                      style: TextStyle(
                        color: CColors.textGray,
                        fontSize: 10
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Symbols.save,
                            weight: 400,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5,),
                          Text("Simpan",
                            style: TextStyle(
                              color: Colors.white
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              )
            ],
          )
        ) 
      ),
    );
  }
}