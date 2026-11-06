import 'package:billin/common/c_app_bar.dart';
import 'package:billin/common/c_colors.dart';
import 'package:billin/common/c_container.dart';
import 'package:billin/common/section_heading.dart';
import 'package:billin/list_anggota/card_anggota.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ListAnggota extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: CColors.background,
      appBar: CAppBar("Anggota"), 
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CContainer(
                child: Column(
                  spacing: 15,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: CColors.accent.withAlpha(50),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Icon(Icons.link,
                            color: CColors.accent,
                            size: 26,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Undang Melalui Link",
                              style: TextStyle(
                                fontWeight: FontWeight(700),
                                fontSize: 16
                              ),
                            ),
                            Text("Kirim link ke teman anda untuk bergabung",
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
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CColors.background,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        children: [
                          Text("www.linkundanganmakan.com"),
                          Spacer(),
                          Icon(Icons.copy,
                            color: CColors.textGray,
                            size: 18,
                          )
                        ],
                      ),
                    )
                  ],
                )
              ),
              SizedBox(height: 10,),
              CContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 15,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: CColors.accent.withAlpha(50),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Icon(Symbols.group_add,
                            color: CColors.accent,
                            size: 26,
                            weight: 600,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tambah Anggota Manual",
                              style: TextStyle(
                                fontWeight: FontWeight(700),
                                fontSize: 16
                              ),
                            ),
                            Text("Tammbahkan anggota secara manual",
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
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: CColors.background,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Row(
                              children: [
                                Text("Masukkan nama anggota",
                                  style: TextStyle(
                                    color: CColors.textGray
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: CColors.accent,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Row(
                            children: [
                              Text("Tambah",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ) 
                  ],
                )
              ),
              SizedBox(height: 10,),
              SectionHeading("Anggota Terdaftar"),
              Row(
                spacing: 5,
                children: [
                  Icon(Icons.info_outline,
                    size: 16,
                    color: CColors.textGray,
                  ),
                  Text("Semua anggota yang terdaftar sudah dapat memilih item",
                    style: TextStyle(
                      fontSize: 12,
                      color: CColors.textGray
                    ),
                  )
                ],
              ),
              SizedBox(height: 10,),
              Column(
                spacing: 5,
                children: [
                  CardAnggota(name: "Melissa (Anda)", role: "Pembuat"),
                  CardAnggota(name: "Natalia", role: "Anggota"),
                  CardAnggota(name: "Layla Miya", role: "Anggota"),
                  CardAnggota(name: "Agus Mino", role: "Anggota"),
                  CardAnggota(name: "Pharsa Dewi", role: "Anggota"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}