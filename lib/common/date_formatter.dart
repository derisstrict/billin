import 'package:intl/intl.dart';

const _indonesianLocale = 'id_ID';
const _englishLocale = 'en_US';

/// Matches a trailing time (with optional Indonesian "pukul"/"jam" prefix and
/// timezone suffix), e.g. `25/11/2025 14:30`, `25/11/2025 pukul 14.30 WIB`.
final _timeSuffix = RegExp(
  r'[\s,]+(?:(?:pukul|jam)\s*)?\d{1,2}[:.]\d{2}(?:[:.]\d{2})?(?:\s*[A-Za-z]{2,5})?\s*$',
  caseSensitive: false,
);

/// Patterns that contain month names or day names, so they need locale data.
const _namedDatePatterns = <String>[
  'EEEE, d MMMM yyyy',
  'EEEE, d MMM yyyy',
  'd MMMM yyyy',
  'd MMM yyyy',
  'MMMM d, yyyy',
  'MMM d, yyyy',
];

/// Numeric-only date patterns, ordered from most to least common on receipts.
const _numericDatePatterns = <String>[
  'dd/MM/yyyy',
  'dd-MM-yyyy',
  'dd.MM.yyyy',
  'd/M/yyyy',
  'd-M-yyyy',
  'd.M.yyyy',
  'yyyy/MM/dd',
  'yyyy-MM-dd',
  'yyyy.MM.dd',
  'dd/MM/yy',
  'dd-MM-yy',
  'dd.MM.yy',
  'd/M/yy',
  'd-M-yy',
  'd.M.yy',
];

/// Parses the various date formats a vision model may return.
///
/// Returns `null` when the value cannot be interpreted as a date.
DateTime? parseReceiptDate(String? raw) {
  if (raw == null) {
    return null;
  }

  var value = raw.trim();
  if (value.isEmpty) {
    return null;
  }

  // Keep the literal date part of an ISO value, so a timezone offset near
  // midnight cannot shift the receipt to the previous/next day.
  final isoDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
  if (isoDate != null) {
    final year = int.parse(isoDate.group(1)!);
    final month = int.parse(isoDate.group(2)!);
    final day = int.parse(isoDate.group(3)!);
    final parsed = DateTime(year, month, day);
    if (parsed.year == year && parsed.month == month && parsed.day == day) {
      return parsed;
    }
  }

  // Handles other ISO forms, including embedded times/timezones.
  final iso = DateTime.tryParse(value);
  if (iso != null) {
    return DateTime(iso.year, iso.month, iso.day);
  }

  value = value.replaceFirst(_timeSuffix, '').trim();
  value = value.replaceAll(RegExp(r'[.,;]+$'), '').trim();
  if (value.isEmpty) {
    return null;
  }

  for (final locale in const [_indonesianLocale, _englishLocale]) {
    for (final pattern in _namedDatePatterns) {
      final parsed = _tryParse(value, pattern, locale);
      if (parsed != null) {
        return parsed;
      }
    }
  }

  for (final pattern in _numericDatePatterns) {
    final parsed = _tryParse(value, pattern, _indonesianLocale);
    if (parsed != null) {
      return parsed;
    }
  }

  return null;
}

/// Formats a receipt date as `Selasa, 25 November 2025`.
///
/// If the date cannot be parsed, the original string is returned unchanged so
/// the UI never loses information.
String formatReceiptDate(String? raw) {
  final parsed = parseReceiptDate(raw);
  if (parsed == null) {
    return raw?.trim() ?? '';
  }

  return DateFormat('EEEE, d MMMM yyyy', _indonesianLocale).format(parsed);
}

DateTime? _tryParse(String value, String pattern, String locale) {
  try {
    final parsed = DateFormat(pattern, locale).parseStrict(value);
    return DateTime(parsed.year, parsed.month, parsed.day);
  } on FormatException {
    return null;
  }
}
