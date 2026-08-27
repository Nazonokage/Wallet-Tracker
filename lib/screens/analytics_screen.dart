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
    final theme = Theme.of(context);

    return SafeArea(
      child: Consumer<TransactionProvider>(
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

          // Empty state – centered
          if (totalExpense == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📊', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'No expenses yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some expenses to see analytics',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          // Color palette – "Others" gets grey
          final colors = [
            Colors.orange.shade400,
            Colors.blue.shade400,
            Colors.purple.shade400,
            Colors.pink.shade400,
            Colors.grey.shade500,
          ];

          final sections = <PieChartSectionData>[];
          int index = 0;
          categoryTotals.forEach((category, amount) {
            final percentage = (amount / totalExpense * 100);
            sections.add(
              PieChartSectionData(
                value: amount,
                title:
                    percentage > 8 ? '${percentage.toStringAsFixed(0)}%' : '',
                color: colors[index % colors.length],
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                // ✅ removed badgePosition – it doesn't exist
              ),
            );
            index++;
          });

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header with emoji
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📈', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Text(
                      'Spending Breakdown',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: $currency${totalExpense.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Pie chart – centered with proper constraints
                Container(
                  height: 280,
                  width: 280,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3), // ✅ fixed deprecation
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        pieTouchData: PieTouchData(
                          enabled: false,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Legend list with better styling
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4), // ✅ fixed deprecation
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: categoryTotals.keys.length,
                      itemBuilder: (ctx, i) {
                        final category = categoryTotals.keys.elementAt(i);
                        final amount = categoryTotals[category]!;
                        final percentage = (amount / totalExpense * 100);
                        final color = colors[i % colors.length];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                      alpha: 0.04), // ✅ fixed deprecation
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              title: Text(
                                '${_categoryEmoji(category)} ${category.toString().split('.').last}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              trailing: Text(
                                '$currency${amount.toStringAsFixed(2)}  (${percentage.toStringAsFixed(1)}%)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
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
