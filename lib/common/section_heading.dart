import 'package:flutter/material.dart';

class SectionHeading extends StatelessWidget {
  String text;

  SectionHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text(text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight(700)
      ),
    );
  }
}