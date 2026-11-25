import 'package:billin/model/receipt.dart';

/// Reconciles the item totals against the receipt's own subtotal and grand
/// total. A mismatch usually means the model missed an item discount, an item,
/// or a tax/service/discount line.
class ReceiptValidation {
  ReceiptValidation._({
    required this.hasItems,
    required this.itemsSubtotal,
    required this.subtotal,
    required this.expectedGrandTotal,
    required this.grandTotal,
    required this.grandTotalDifference,
    required this.subtotalDifference,
  });

  factory ReceiptValidation.fromReceipt(ReceiptData receipt) {
    final itemsSubtotal = receipt.items.fold<int>(
      0,
      (sum, item) => sum + item.total,
    );
    final expectedGrandTotal =
        itemsSubtotal + receipt.tax + receipt.serviceCharge - receipt.discounts;

    return ReceiptValidation._(
      hasItems: receipt.items.isNotEmpty,
      itemsSubtotal: itemsSubtotal,
      subtotal: receipt.subtotal,
      expectedGrandTotal: expectedGrandTotal,
      grandTotal: receipt.grandTotal,
      grandTotalDifference: expectedGrandTotal - receipt.grandTotal,
      subtotalDifference: itemsSubtotal - receipt.subtotal.round(),
    );
  }

  /// Ignore tiny differences caused by rounding percentages.
  static const int tolerance = 1;

  final bool hasItems;
  final int itemsSubtotal;
  final num subtotal;
  final int expectedGrandTotal;
  final int grandTotal;
  final int grandTotalDifference;
  final int subtotalDifference;

  bool get hasGrandTotalMismatch =>
      hasItems && grandTotalDifference.abs() > tolerance;

  bool get hasSubtotalMismatch =>
      hasItems && subtotal > 0 && subtotalDifference.abs() > tolerance;

  bool get hasMismatch => hasGrandTotalMismatch || hasSubtotalMismatch;

  /// The difference for the strongest failing check. The UI displays its
  /// absolute value.
  int get primaryDifference =>
      hasGrandTotalMismatch ? grandTotalDifference : subtotalDifference;
}
