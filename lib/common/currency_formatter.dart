/// Formats a number as Indonesian rupiah, e.g. `175000` -> `Rp. 175.000`.
String formatRupiah(num value) {
  final rounded = value.round();
  final sign = rounded < 0 ? '-' : '';
  final digits = rounded.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    if (i > 0 && remaining % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }

  return '${sign}Rp. $buffer';
}
