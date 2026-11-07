import 'package:billin/common/c_colors.dart';
import 'package:billin/undangan/undangan_benar.dart';
import 'package:billin/undangan/undangan_salah.dart';
import 'package:flutter/material.dart';

class TesBeranda extends StatelessWidget {
  const TesBeranda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CColors.background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  showUndanganBenarDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Tes Undangan Benar',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight(600)),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showUndanganSalahDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CColors.dangerRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Tes Undangan Salah',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight(600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
