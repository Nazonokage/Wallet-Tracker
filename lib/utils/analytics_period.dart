enum AnalyticsDateFilter { allTime, thisMonth, today, thisWeek, custom }

/// Half-open local calendar periods. Weeks start on Monday, like the dashboard.
({DateTime? start, DateTime? end}) analyticsPeriod(
  AnalyticsDateFilter filter,
  DateTime now, {
  DateTime? customStart,
  DateTime? customEnd,
}) {
  switch (filter) {
    case AnalyticsDateFilter.today:
      return (
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day + 1),
      );
    case AnalyticsDateFilter.thisWeek:
      final start = DateTime(now.year, now.month, now.day - now.weekday + 1);
      return (
        start: start,
        end: DateTime(start.year, start.month, start.day + 7),
      );
    case AnalyticsDateFilter.thisMonth:
      return (
        start: DateTime(now.year, now.month),
        end: DateTime(now.year, now.month + 1),
      );
    case AnalyticsDateFilter.custom:
      return (
        start: customStart == null
            ? null
            : DateTime(customStart.year, customStart.month, customStart.day),
        end: customEnd == null
            ? null
            : DateTime(customEnd.year, customEnd.month, customEnd.day + 1),
      );
    case AnalyticsDateFilter.allTime:
      return (start: null, end: null);
  }
}
