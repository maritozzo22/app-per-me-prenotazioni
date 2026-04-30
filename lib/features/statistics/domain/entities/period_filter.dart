/// Filter period options for statistics queries.
enum PeriodFilter {
  /// Current month (1st to end of month)
  month,

  /// Last 90 days
  quarter,

  /// Current year (Jan 1 to Dec 31)
  year,

  /// User-defined custom date range
  custom,
}
