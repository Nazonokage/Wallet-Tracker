import 'package:intl/intl.dart';

String formatAmount(double amount) {
  final formatter = NumberFormat('#,##0.00');
  return formatter.format(amount);
}

double? parseAmount(String text) {
  if (text.isEmpty) return null;
  // Remove any non‑digit characters except decimal point
  final cleaned = text.replaceAll(RegExp(r'[^0-9.]'), '');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}
