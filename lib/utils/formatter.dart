import 'package:intl/intl.dart';

final _amountFormats = <String, NumberFormat>{};

String formatAmount(double amount) => (_amountFormats.putIfAbsent(
  Intl.getCurrentLocale(),
  () => NumberFormat('#,##0.00'),
)).format(amount);

double? parseAmount(String text) {
  if (text.isEmpty) return null;
  // Remove any non‑digit characters except decimal point
  final cleaned = text.replaceAll(RegExp(r'[^0-9.]'), '');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}
