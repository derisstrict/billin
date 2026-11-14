import 'package:billin/common/date_formatter.dart';

class ReceiptItem {
  final int id;
  final String name;
  final num qty;
  final int price;
  final int total;

  const ReceiptItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.price,
    required this.total,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    final qty = _asNum(json['qty'], fallback: 1);
    final price = _asInt(json['price']);
    final rawTotal = json['total'];
    final total = rawTotal == null ? (qty * price).round() : _asInt(rawTotal);

    return ReceiptItem(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      qty: qty,
      price: price,
      total: total,
    );
  }

  String get qtyLabel {
    if (qty == qty.truncate()) {
      return qty.toInt().toString();
    }
    return qty.toString();
  }
}

class ReceiptData {
  final String merchantName;
  final String date;
  final List<ReceiptItem> items;
  final num subtotal;
  final int tax;
  final int serviceCharge;
  final int discounts;
  final int grandTotal;

  const ReceiptData({
    required this.merchantName,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.serviceCharge,
    required this.discounts,
    required this.grandTotal,
  });

  factory ReceiptData.fromJson(Map<String, dynamic> json) {
    final items = <ReceiptItem>[];
    final rawItems = json['items'];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          items.add(ReceiptItem.fromJson(item));
        } else if (item is Map) {
          items.add(ReceiptItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final subtotal = json['subtotal'] == null
        ? items.fold<num>(0, (sum, item) => sum + item.total)
        : _asNum(json['subtotal']);
    final tax = _asInt(json['tax']);
    final serviceCharge = _asInt(json['service_charge']);
    final discounts = _asInt(json['discounts']);
    final rawGrandTotal = json['grand_total'];
    final grandTotal = rawGrandTotal == null
        ? (subtotal + tax + serviceCharge - discounts).round()
        : _asInt(rawGrandTotal);

    return ReceiptData(
      merchantName: _asString(json['merchant_name']),
      date: _asString(json['date']),
      items: items,
      subtotal: subtotal,
      tax: tax,
      serviceCharge: serviceCharge,
      discounts: discounts,
      grandTotal: grandTotal,
    );
  }

  /// Placeholder shown before the first scan. Mirrors the old hardcoded page.
  factory ReceiptData.demo() {
    final items = List<ReceiptItem>.generate(
      10,
      (index) => ReceiptItem(
        id: index + 1,
        name: 'Salt Bread',
        qty: 12,
        price: 14000,
        total: 168000,
      ),
    );

    return ReceiptData(
      merchantName: 'Gacoan Jimbaran',
      date: '2025-11-25',
      items: items,
      subtotal: 1680000,
      tax: 168000,
      serviceCharge: 84000,
      discounts: 84000,
      grandTotal: 1848000,
    );
  }

  String get dateLabel => formatReceiptDate(date);
}

String _asString(dynamic value) {
  if (value is String) {
    return value.trim();
  }
  if (value == null) {
    return '';
  }
  return value.toString().trim();
}

num _asNum(dynamic value, {num fallback = 0}) {
  if (value is num) {
    return value;
  }
  if (value is! String) {
    return fallback;
  }

  var text = value.trim().replaceAll(RegExp(r'[^0-9.,\-]'), '');
  if (text.isEmpty) {
    return fallback;
  }

  final hasComma = text.contains(',');
  final hasDot = text.contains('.');
  if (hasComma && hasDot) {
    // Indonesian format: dots are thousands, commas are decimals.
    text = text.replaceAll('.', '').replaceAll(',', '.');
  } else if (hasComma) {
    text = text.replaceAll(',', '.');
  } else if (hasDot && RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(text)) {
    // `14.000` -> `14000`, not `14.0`.
    text = text.replaceAll('.', '');
  }

  return num.tryParse(text) ?? fallback;
}

int _asInt(dynamic value) => _asNum(value).round();
