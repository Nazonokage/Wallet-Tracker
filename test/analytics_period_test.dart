import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/utils/analytics_period.dart';

void main() {
  test('Today is bounded by local midnights', () {
    final period = analyticsPeriod(
      AnalyticsDateFilter.today,
      DateTime(2026, 11, 2, 15, 10),
    );
    expect(period.start, DateTime(2026, 11, 2));
    expect(period.end, DateTime(2026, 11, 3));
  });
  test('This week runs Monday through Sunday, excluding next Monday', () {
    for (var day = 2; day <= 8; day++) {
      final period = analyticsPeriod(
        AnalyticsDateFilter.thisWeek,
        DateTime(2026, 11, day, 23, 59),
      );
      expect(period.start, DateTime(2026, 11, 2));
      expect(period.end, DateTime(2026, 11, 9));
    }
  });
  test('Week boundaries handle a year change', () {
    final period = analyticsPeriod(
      AnalyticsDateFilter.thisWeek,
      DateTime(2027, 1, 1),
    );
    expect(period.start, DateTime(2026, 12, 28));
    expect(period.end, DateTime(2027, 1, 4));
  });
}
