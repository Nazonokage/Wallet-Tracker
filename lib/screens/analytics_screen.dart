import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction.dart';
import '../utils/formatter.dart';
import '../widgets/particle_background.dart';
import '../widgets/animated_count_text.dart';
import '../widgets/fade_in_slide.dart';

enum AnalyticsDateFilter { allTime, thisMonth, today, custom }

enum ChartType { doughnut, bar }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsDateFilter _dateFilter = AnalyticsDateFilter.allTime;
  ChartType _chartType = ChartType.doughnut;
  DateTimeRange? _customDateRange;
  int _touchedIndex = -1;

  String _categoryLabel(Category category, AppLocalizations l10n) {
    switch (category) {
      case Category.food:
        return l10n.food;
      case Category.commute:
        return l10n.commute;
      case Category.bills:
        return l10n.bills;
      case Category.shopping:
        return l10n.shopping;
      case Category.others:
        return l10n.others;
    }
  }

  Color _categoryColor(Category category) {
    switch (category) {
      case Category.food:
        return const Color(0xFFFF6B6B); // Coral Red
      case Category.commute:
        return const Color(0xFF4ECDC4); // Turquoise Mint
      case Category.bills:
        return const Color(0xFF7C4DFF); // Royal Violet
      case Category.shopping:
        return const Color(0xFFFFB300); // Amber Gold
      case Category.others:
        return const Color(0xFF26A69A); // Teal
    }
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Transaction> _filterExpenses(List<Transaction> allTransactions) {
    final expenses = allTransactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final now = DateTime.now();

    switch (_dateFilter) {
      case AnalyticsDateFilter.today:
        return expenses.where((t) => _isSameDay(t.date, now)).toList();
      case AnalyticsDateFilter.thisMonth:
        return expenses
            .where((t) => t.date.year == now.year && t.date.month == now.month)
            .toList();
      case AnalyticsDateFilter.custom:
        if (_customDateRange == null) return expenses;
        final start = DateTime(_customDateRange!.start.year,
            _customDateRange!.start.month, _customDateRange!.start.day, 0, 0, 0);
        final end = DateTime(_customDateRange!.end.year,
            _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59);
        return expenses
            .where((t) => t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
                t.date.isBefore(end.add(const Duration(seconds: 1))))
            .toList();
      case AnalyticsDateFilter.allTime:
        return expenses;
    }
  }

  Future<void> _pickCustomDateRange(BuildContext context) async {
    final now = DateTime.now();
    final initialRange = _customDateRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialRange,
      helpText: 'Select Date Range or Specific Day',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _dateFilter = AnalyticsDateFilter.custom;
      });
    }
  }

  Future<void> _pickSingleDay(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDateRange?.start ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Select Specific Day',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = DateTimeRange(start: picked, end: picked);
        _dateFilter = AnalyticsDateFilter.custom;
      });
    }
  }

  String _getDateFilterLabel(AppLocalizations l10n) {
    switch (_dateFilter) {
      case AnalyticsDateFilter.today:
        return '${l10n.today} (${DateFormat.MMMd().format(DateTime.now())})';
      case AnalyticsDateFilter.thisMonth:
        return '${l10n.thisMonth} (${DateFormat.MMMM().format(DateTime.now())})';
      case AnalyticsDateFilter.custom:
        if (_customDateRange == null) return l10n.calendar;
        if (_isSameDay(_customDateRange!.start, _customDateRange!.end)) {
          return DateFormat.yMMMd().format(_customDateRange!.start);
        }
        return '${DateFormat.MMMd().format(_customDateRange!.start)} - ${DateFormat.MMMd().format(_customDateRange!.end)}';
      case AnalyticsDateFilter.allTime:
        return l10n.allTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<SettingsProvider>(context).currencySymbol;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analyticsAndTrends, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              _chartType == ChartType.doughnut ? Icons.bar_chart : Icons.pie_chart,
              color: theme.colorScheme.primary,
            ),
            tooltip: _chartType == ChartType.doughnut ? 'Switch to Bar Chart' : 'Switch to Doughnut Chart',
            onPressed: () {
              setState(() {
                _chartType = _chartType == ChartType.doughnut
                    ? ChartType.bar
                    : ChartType.doughnut;
              });
            },
          ),
        ],
      ),
      body: ParticleBackground(
        child: Consumer<TransactionProvider>(
          builder: (ctx, provider, _) {
            final filteredExpenses = _filterExpenses(provider.transactions);

            // Calculate category totals
            final Map<Category, double> categoryTotals = {};
            for (var txn in filteredExpenses) {
              if (txn.category != null) {
                categoryTotals[txn.category!] =
                    (categoryTotals[txn.category!] ?? 0) + txn.amount;
              }
            }
            final totalExpense = categoryTotals.values.fold(0.0, (a, b) => a + b);

            int entryIndex = 0;

            return Column(
              children: [
                const SizedBox(height: 8),

                // Calendar Filter Bar (All Time, Today, This Month, Pick Date)
                FadeInSlide(
                  duration: const Duration(milliseconds: 350),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: Text(l10n.allTime),
                          selected: _dateFilter == AnalyticsDateFilter.allTime,
                          onSelected: (_) => setState(() => _dateFilter = AnalyticsDateFilter.allTime),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(l10n.today),
                          selected: _dateFilter == AnalyticsDateFilter.today,
                          onSelected: (_) => setState(() => _dateFilter = AnalyticsDateFilter.today),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(l10n.thisMonth),
                          selected: _dateFilter == AnalyticsDateFilter.thisMonth,
                          onSelected: (_) => setState(() => _dateFilter = AnalyticsDateFilter.thisMonth),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          avatar: const Icon(Icons.calendar_month, size: 16),
                          label: Text(_dateFilter == AnalyticsDateFilter.custom
                              ? _getDateFilterLabel(l10n)
                              : l10n.calendar),
                          selected: _dateFilter == AnalyticsDateFilter.custom,
                          onSelected: (_) => _showCalendarMenu(context),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Summary Banner (Theme-adaptive with animated count text)
                FadeInSlide(
                  delayMilliseconds: 100,
                  duration: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getDateFilterLabel(l10n),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedCountText(
                                value: totalExpense,
                                prefix: currency,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${filteredExpenses.length} ${l10n.spends}',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (totalExpense == 0)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📊', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noExpensesYet,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.noExpensesPeriod,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Chart Container
                          FadeInSlide(
                            delayMilliseconds: 200,
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: _chartType == ChartType.doughnut
                                    ? _buildDoughnutChart(categoryTotals, totalExpense, currency, theme, l10n)
                                    : _buildBarChart(categoryTotals, currency, theme, l10n),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Category Breakdown List
                          FadeInSlide(
                            delayMilliseconds: 250,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                l10n.categoryBreakdown,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          ...categoryTotals.entries.map((entry) {
                            final category = entry.key;
                            final amount = entry.value;
                            final percentage = (amount / totalExpense);
                            final catColor = _categoryColor(category);
                            final currentIndex = entryIndex++;

                            return FadeInSlide(
                              delayMilliseconds: 300 + (currentIndex * 50),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: catColor.withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            _categoryEmoji(category),
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _categoryLabel(category, l10n),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            AnimatedCountText(
                                              value: amount,
                                              prefix: currency,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              '${(percentage * 100).toStringAsFixed(1)}%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: percentage,
                                        minHeight: 6,
                                        backgroundColor: catColor.withValues(alpha: 0.15),
                                        valueColor: AlwaysStoppedAnimation<Color>(catColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCalendarMenu(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.today, color: theme.colorScheme.primary),
              title: Text(l10n.pickSingleDay),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickSingleDay(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.date_range, color: theme.colorScheme.primary),
              title: Text(l10n.pickCustomDateRange),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickCustomDateRange(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoughnutChart(
    Map<Category, double> categoryTotals,
    double totalExpense,
    String currency,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final sections = <PieChartSectionData>[];
    int index = 0;

    categoryTotals.forEach((category, amount) {
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 55.0 : 45.0;
      final percentage = (amount / totalExpense * 100);

      sections.add(
        PieChartSectionData(
          value: amount,
          color: _categoryColor(category),
          radius: radius,
          showTitle: false,
          badgeWidget: isTouched
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          badgePositionPercentageOffset: .98,
        ),
      );
      index++;
    });

    return SizedBox(
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 4,
              centerSpaceRadius: 65,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _touchedIndex >= 0 && _touchedIndex < categoryTotals.length
                    ? _categoryEmoji(categoryTotals.keys.elementAt(_touchedIndex))
                    : '💸',
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 2),
              Text(
                _touchedIndex >= 0 && _touchedIndex < categoryTotals.length
                    ? '$currency${formatAmount(categoryTotals.values.elementAt(_touchedIndex))}'
                    : '$currency${formatAmount(totalExpense)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _touchedIndex >= 0 && _touchedIndex < categoryTotals.length
                    ? _categoryLabel(categoryTotals.keys.elementAt(_touchedIndex), l10n).toUpperCase()
                    : l10n.totalExpense.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(
    Map<Category, double> categoryTotals,
    String currency,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final entries = categoryTotals.entries.toList();
    double maxVal = 0;
    for (var e in entries) {
      if (e.value > maxVal) maxVal = e.value;
    }
    if (maxVal == 0) maxVal = 100;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.15,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final cat = entries[group.x.toInt()].key;
                return BarTooltipItem(
                  '${_categoryEmoji(cat)} ${_categoryLabel(cat, l10n)}\n$currency${formatAmount(rod.toY)}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _categoryEmoji(entries[index].key),
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(entries.length, (i) {
            final entry = entries[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: _categoryColor(entry.key),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
