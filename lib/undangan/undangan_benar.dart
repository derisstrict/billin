import 'package:billin/common/c_colors.dart';
import 'package:billin/common/c_icon_box.dart';
import 'package:billin/common/c_store_card.dart';
import 'package:flutter/material.dart';

class UndanganBenarDialog extends StatelessWidget {
  final VoidCallback? onJoin;
  final VoidCallback? onClose;

  const UndanganBenarDialog({super.key, this.onJoin, this.onClose});

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: CColors.successLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CColors.success, width: 4),
              ),
              child: Center(
                child: Icon(
                  Icons.check_rounded,
                  color: CColors.success,
                  size: 36,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          "Split Bill Ditemukan",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight(700),
            color: CColors.success,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Bergabung untuk membagi tagihan belanja anda bersama teman-teman",
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
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 18),
                    Divider(color: CColors.border, height: 1),
                    SizedBox(height: 18),
                    CStoreCard(
                      title: "Tan-panama Coffe",
                      subtitle: "Dibuat oleh Melinda",
                      leading: CIconBox(
                        icon: Icons.store_outlined,
                        iconColor: CColors.accent,
                        backgroundColor: CColors.accent.withAlpha(45),
                        size: 52,
                        borderRadius: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ringkasan Item",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight(700),
                              color: CColors.text,
                            ),
                          ),
                          SizedBox(height: 8),
                          _RingkasanRow(
                            label: "Subtotal (10 item)",
                            amount: "Rp120.000.000",
                          ),
                          _RingkasanRow(
                            label: "Pajak (4%)",
                            amount: "Rp120.000.000",
                          ),
                          _RingkasanRow(
                            label: "Diskon (6%)",
                            amount: "Rp120.000.000",
                          ),
                          Divider(color: CColors.border, height: 14),
                          _RingkasanRow(
                            label: "Grand Total",
                            amount: "Rp120.000.000",
                            isBold: true,
                            color: CColors.accent,
                          ),
                          SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(child: _AvatarStack()),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: onJoin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CColors.accent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  "Bergabung Sekarang",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight(600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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

Future<T?> showUndanganBenarDialog<T>(
  BuildContext context, {
  VoidCallback? onJoin,
  VoidCallback? onClose,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Color(0x66000000),
    builder: (context) => UndanganBenarDialog(onJoin: onJoin, onClose: onClose),
  );
}

class _RingkasanRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isBold;
  final Color? color;

  const _RingkasanRow({
    required this.label,
    required this.amount,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? CColors.text;
    final fontWeight = isBold ? FontWeight(700) : FontWeight(400);
    final nominalWeight = isBold ? FontWeight(700) : FontWeight(500);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: nominalWeight,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  static const double size = 28;
  static const int avatarCount = 2;

  const _AvatarStack();

  @override
  Widget build(BuildContext context) {
    final List<Widget> avatars = [];

    for (int i = 0; i < avatarCount; i++) {
      avatars.add(
        _buildAvatarCircle(
          child: Icon(
            Icons.person,
            size: size * 0.65,
            color: Color(0xFF9E9E9E),
          ),
        ),
      );
    }

    avatars.add(
      _buildAvatarCircle(
        child: Text(
          "2+",
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight(600),
            color: Color(0xFF757575),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < avatars.length; i++)
              Align(
                widthFactor: i == avatars.length - 1 ? 1.0 : 0.72,
                child: avatars[i],
              ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          "Ayu Dewi dan 3 orang lainnya",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            color: CColors.textGray,
            fontWeight: FontWeight(400),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarCircle({required Widget child}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(child: child),
    );
  }
}
