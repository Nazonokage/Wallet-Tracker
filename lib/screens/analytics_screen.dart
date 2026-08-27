import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<SettingsProvider>(context).currencySymbol;
    return Consumer<TransactionProvider>(
      builder: (ctx, provider, _) {
        final expenses = provider.transactions
            .where((t) => t.type == TransactionType.expense)
            .toList();
        final Map<Category, double> categoryTotals = {};
        for (var txn in expenses) {
          if (txn.category != null) {
            categoryTotals[txn.category!] =
                (categoryTotals[txn.category!] ?? 0) + txn.amount;
          }
        }
        final totalExpense = categoryTotals.values.fold(0.0, (a, b) => a + b);
        if (totalExpense == 0) {
          return const Center(
            child: Text('No expenses yet to show analytics.'),
          );
        }

        final colors = [
          Colors.orange,
          Colors.blue,
          Colors.purple,
          Colors.pink,
          Colors.grey,
        ];
        final sections = <PieChartSectionData>[];
        int index = 0;
        categoryTotals.forEach((category, amount) {
          final percentage = (amount / totalExpense * 100);
          sections.add(
            PieChartSectionData(
              value: amount,
              title: '${percentage.toStringAsFixed(0)}%',
              color: colors[index % colors.length],
              radius: 50,
            ),
          );
          index++;
        });

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Spending by Category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(sections: sections),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: categoryTotals.keys.length,
                  itemBuilder: (ctx, i) {
                    final category = categoryTotals.keys.elementAt(i);
                    final amount = categoryTotals[category]!;
                    final percentage = (amount / totalExpense * 100);
                    return ListTile(
                      leading: Text(
                        _categoryEmoji(category),
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(category.toString().split('.').last),
                      trailing: Text(
                        '$currency${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _categoryEmoji(Category category) {
    switch (category) {
      case Category.food:
        return '🍔';
      case Category.commute:
        return '🚌';
      case Category.bills:
        return '📄';
      case Category.shopping:
        return '🛍️';
      case Category.others:
        return '📦';
    }
  }
}
