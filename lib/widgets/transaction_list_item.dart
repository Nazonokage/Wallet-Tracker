import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/settings_provider.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction txn;

  const TransactionListItem({
    super.key,
    required this.txn,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = txn.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final currency = Provider.of<SettingsProvider>(context).currencySymbol;
    return ListTile(
      leading: Text(txn.categoryEmoji, style: const TextStyle(fontSize: 24)),
      title: Text(txn.remark ?? (isIncome ? 'Income' : 'Expense')),
      subtitle: Text(txn.date.toString().split(' ')[0]),
      trailing: Text(
        '${isIncome ? '+' : '-'} $currency${txn.amount.toStringAsFixed(2)}',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
