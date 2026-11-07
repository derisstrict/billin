import 'package:billin/common/c_colors.dart';
import 'package:flutter/material.dart';

class UndanganSalahDialog extends StatelessWidget {
  final VoidCallback? onClose;

  const UndanganSalahDialog({super.key, this.onClose});

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: CColors.dangerRedLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CColors.dangerRed, width: 4),
              ),
              child: Center(
                child: Icon(
                  Icons.close_rounded,
                  color: CColors.dangerRed,
                  size: 36,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          "Split Bill Tidak Ditemukan",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight(700),
            color: CColors.dangerRed,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Link yang anda masukkan tidak dapat ditemukan",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight(400),
            color: CColors.textGray,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 390),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24, 40, 24, 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [_buildHeader()],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: CColors.textGray.withAlpha(128),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<T?> showUndanganSalahDialog<T>(
  BuildContext context, {
  VoidCallback? onClose,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Color(0x66000000),
    builder: (context) => UndanganSalahDialog(onClose: onClose),
  );
}
