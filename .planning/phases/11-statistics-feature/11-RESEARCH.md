# Phase 11: Statistics Feature - Research

**Researched:** 2026-03-07
**Domain:** Flutter charts (FL Chart), statistics data modeling, SQL aggregations, Riverpod state management
**Confidence:** HIGH

## Summary

Phase 11 implements a comprehensive statistics feature using FL Chart library for visualizations, freezed for immutable data models, and SQL-based aggregations for performance. The implementation builds on existing infrastructure: `DashboardStatisticsService`, `StatisticsCacheService`, and the Clean Architecture pattern established in the codebase.

**Primary recommendation:** Use FL Chart 0.66.0+ with grouped BarChart for YoY comparison, PieChart for platform breakdown, and LineChart for monthly trends. Extend the existing `DashboardStatistics` entity with new statistics-specific models using freezed pattern.

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| STAT-01 | Statistics Domain Layer - Entities with freezed | Section: Standard Stack (freezed), Section: Architecture Patterns |
| STAT-02 | Statistics Data Layer - SQL queries for aggregations | Section: SQL Query Templates |
| STAT-03 | Statistics Presentation Layer - Riverpod providers | Section: Architecture Patterns (Riverpod) |
| STAT-04 | Year-over-Year Comparison BarChart | Section: FL Chart API (BarChart grouped) |
| STAT-05 | Platform Revenue PieChart | Section: FL Chart API (PieChart) |
| STAT-06 | Monthly Trend LineChart | Section: FL Chart API (LineChart) |
| STAT-07 | Platform Bookings BarChart | Section: FL Chart API (BarChart simple) |
| STAT-08 | FL Chart Integration | Section: Standard Stack (fl_chart) |

</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| fl_chart | ^0.66.0 | Chart rendering (Bar, Pie, Line) | Best Flutter charting library, well-maintained, supports animations and interactions |
| freezed | ^2.5.0 | Immutable data models with code generation | Already used in project for ReservationModel, ensures immutability |
| freezed_annotation | ^2.4.0 | Annotations for freezed | Required companion package |
| flutter_riverpod | ^2.6.0 | State management | Already used throughout app for async state |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| shared_preferences | ^2.2.0 | Statistics caching | Already used by StatisticsCacheServiceImpl |
| sqflite | ^2.3.0 | SQL aggregations | Existing database layer |
| intl | ^0.19.0 | Date/number formatting | For chart labels and KPI display |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| fl_chart | syncfusion_flutter_charts | Syncfusion is commercial, fl_chart is MIT licensed |
| fl_chart | charts_flutter | charts_flutter is Google's but deprecated since 2021 |
| freezed | json_serializable alone | Freezed provides immutability, copyWith, pattern matching |

**Installation:**
```yaml
# pubspec.yaml additions
dependencies:
  fl_chart: ^0.66.0
  intl: ^0.19.0

dev_dependencies:
  # Already present but verify versions
  freezed: ^2.5.0
  freezed_annotation: ^2.4.0
  build_runner: ^2.4.0
```

## Architecture Patterns

### Recommended Project Structure
```
lib/features/statistics/
├── data/
│   ├── repositories/
│   │   └── statistics_repository_impl.dart    # SQL aggregation queries
│   └── services/
│       └── statistics_cache_service_impl.dart # Already exists
├── domain/
│   ├── entities/
│   │   ├── dashboard_statistics.dart          # Already exists (extend)
│   │   ├── platform_revenue.dart              # NEW
│   │   ├── monthly_revenue.dart               # NEW
│   │   ├── year_over_year_comparison.dart     # NEW
│   │   └── statistics_filter.dart             # NEW
│   ├── repositories/
│   │   └── statistics_repository.dart         # NEW interface
│   └── services/
│       └── statistics_cache_service.dart      # Already exists
└── presentation/
    ├── providers/
    │   └── statistics_provider.dart           # Riverpod state
    ├── pages/
    │   └── statistics_page.dart               # Already exists (replace placeholder)
    └── widgets/
        ├── kpi_card.dart                      # Revenue, occupancy, etc.
        ├── year_over_year_chart.dart          # STAT-04
        ├── platform_revenue_chart.dart        # STAT-05
        ├── monthly_trend_chart.dart           # STAT-06
        └── platform_bookings_chart.dart       # STAT-07
```

### Pattern 1: Freezed Entity Model
**What:** Immutable data classes with JSON serialization using freezed annotation
**When to use:** All new domain entities for statistics
**Example:**
```dart
// Source: Project pattern from reservation_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'platform_revenue.freezed.dart';
part 'platform_revenue.g.dart';

@freezed
class PlatformRevenue with _$PlatformRevenue {
  const factory PlatformRevenue({
    required String platformId,
    required String platformName,
    required int color, // ARGB color value
    required double totalRevenue,
    required int bookingCount,
    required double percentage,
  }) = _PlatformRevenue;

  factory PlatformRevenue.fromJson(Map<String, dynamic> json) =>
      _$PlatformRevenueFromJson(json);
}
```

### Pattern 2: Riverpod Async Provider
**What:** State management for async statistics data with loading/error states
**When to use:** Statistics page data fetching
**Example:**
```dart
// Source: Project Riverpod pattern
import 'package:flutter_riverpod/flutter_riverpod.dart';

final statisticsProvider = AsyncNotifierProvider<StatisticsNotifier, StatisticsState>(
  StatisticsNotifier.new,
);

class StatisticsNotifier extends AsyncNotifier<StatisticsState> {
  @override
  Future<StatisticsState> build() async {
    final filter = ref.watch(statisticsFilterProvider);
    final repository = ref.watch(statisticsRepositoryProvider);
    return await repository.getStatistics(filter);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final filter = ref.read(statisticsFilterProvider);
      return ref.read(statisticsRepositoryProvider).getStatistics(filter);
    });
  }
}
```

### Pattern 3: Cache Integration
**What:** 24-hour cache with forced refresh capability
**When to use:** Statistics data that doesn't need real-time updates
**Example:**
```dart
// Source: Existing statistics_cache_service_impl.dart pattern
Future<DashboardStatistics> getStatistics(StatisticsFilter filter) async {
  // Check cache first
  final cached = await _cacheService.getCachedStatistics();
  if (cached != null && _isCacheApplicable(cached, filter)) {
    return cached;
  }

  // Calculate fresh statistics
  final statistics = await _calculateStatistics(filter);

  // Cache for future use
  await _cacheService.setCachedStatistics(statistics);

  return statistics;
}
```

### Anti-Patterns to Avoid
- **Calculating in Dart instead of SQL:** Filtering/aggregating 1000+ reservations in Dart is slow; use SQL GROUP BY
- **No cache invalidation:** Cache must be invalidated when reservations are added/modified/deleted
- **Ignoring timezone:** Date calculations should use local timezone consistently
- **Hardcoded platform colors:** Use the Platform entity colors, not hardcoded values

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Chart rendering | Custom CustomPainter | fl_chart | Handles animations, tooltips, touch interactions, edge cases |
| Date range calculations | Manual DateTime math | DateTime methods with helper functions | Timezone, leap years, month boundaries are tricky |
| State management | StatefulWidget with setState | Riverpod AsyncNotifier | Built-in loading/error states, easier testing |
| JSON serialization | Manual fromJson/toJson | freezed + json_serializable | Type-safe, less boilerplate, copyWith support |

**Key insight:** Chart rendering has many edge cases (axis scaling, tooltip positioning, touch handling) that fl_chart already solves. Custom implementations often have bugs on edge cases.

## Common Pitfalls

### Pitfall 1: SQL Date Range Query Off-by-One
**What goes wrong:** Reservations on boundary dates are incorrectly included/excluded
**Why it happens:** SQL date comparisons often miss time components or timezone issues
**How to avoid:** Use date normalization (set time to 00:00:00 for start, 23:59:59 for end)
**Warning signs:** Monthly totals don't match manual calculation
```sql
-- WRONG: May miss reservations on the boundary dates
WHERE check_in BETWEEN '2025-01-01' AND '2025-01-31'

-- CORRECT: Include full day ranges
WHERE check_in >= '2025-01-01 00:00:00' AND check_in <= '2025-01-31 23:59:59'
```

### Pitfall 2: PieChart Empty State
**What goes wrong:** App crashes or shows error when no revenue data exists
**Why it happens:** PieChart requires at least one section with value > 0
**How to avoid:** Check for empty data before rendering, show placeholder message
**Warning signs:** Crash when filtering to period with no bookings
```dart
// Safe PieChart rendering
if (platformRevenues.isEmpty || totalRevenue == 0) {
  return const Center(child: Text('Nessun dato disponibile'));
}
return PieChart(PieChartData(sections: sections));
```

### Pitfall 3: Chart Animation Jank
**What goes wrong:** Charts cause frame drops during animation
**Why it happens:** Complex charts with many data points animate on every rebuild
**How to avoid:** Use `swapAnimationDuration: Duration.zero` for data updates, animate only on initial load
**Warning signs:** Scrolling statistics page feels laggy

### Pitfall 4: Platform Color Mismatch
**What goes wrong:** Chart colors don't match platform colors elsewhere in app
**Why it happens:** Hardcoding colors instead of using Platform entity
**How to avoid:** Pass platform color from entity to chart
**Warning signs:** Booking appears blue in calendar but different blue in chart
```dart
// Platform colors from existing platform.dart
// Booking: Color(0xFF2196F3) - Blue
// Airbnb: Color(0xFFE91E63) - Pink
// WhatsApp: Color(0xFF4CAF50) - Green
// Website: Color(0xFF9C27B0) - Purple
// TikTok: Color(0xFF212121) - Black
```

## FL Chart API Reference

### PieChart (STAT-05: Platform Revenue Breakdown)
**Source:** https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/pie_chart.md

```dart
import 'package:fl_chart/fl_chart.dart';

class PlatformRevenueChart extends StatelessWidget {
  final List<PlatformRevenue> data;

  @override
  Widget build(BuildContext context) {
    final totalRevenue = data.fold<double>(0, (sum, p) => sum + p.totalRevenue);

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: data.map((platform) {
            final percentage = (platform.totalRevenue / totalRevenue) * 100;
            return PieChartSectionData(
              color: Color(platform.color),
              value: platform.totalRevenue,
              title: '${percentage.toStringAsFixed(1)}%',
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
```

**Key Properties:**
- `sections`: List of `PieChartSectionData` (each slice)
- `centerSpaceRadius`: Empty circle in center (set to 0 for solid pie)
- `sectionsSpace`: Gap between sections
- `touchData`: Handle tap/hover for tooltips

### LineChart (STAT-06: Monthly Revenue Trend)
**Source:** https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/line_chart.md

```dart
import 'package:fl_chart/fl_chart.dart';

class MonthlyTrendChart extends StatelessWidget {
  final List<MonthlyRevenue> data;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 500, // €500 grid lines
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text('€${value.toInt()}');
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final months = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu',
                                  'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];
                  return Text(months[value.toInt() % 12]);
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.revenue);
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Key Properties:**
- `lineBarsData`: List of `LineChartBarData` (multiple lines possible for comparison)
- `isCurved`: Smooth bezier curves vs straight lines
- `spots`: List of `FlSpot(x, y)` data points
- `dotData`: Show/hide data point dots
- `belowBarData`: Gradient fill under line

### BarChart - Simple (STAT-07: Platform Bookings Count)
**Source:** https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/bar_chart.md

```dart
import 'package:fl_chart/fl_chart.dart';

class PlatformBookingsChart extends StatelessWidget {
  final List<PlatformRevenue> data;

  @override
  Widget build(BuildContext context) {
    // Sort by booking count descending
    final sorted = List.of(data)..sort((a, b) => b.bookingCount.compareTo(a.bookingCount));

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: sorted.first.bookingCount.toDouble() * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${sorted[group.x.toInt()].platformName}\n${rod.toY.toInt()} prenotazioni',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      sorted[value.toInt()].platformName,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: sorted.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.bookingCount.toDouble(),
                  color: Color(e.value.color),
                  width: 22,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
```

### BarChart - Grouped (STAT-04: Year-over-Year Comparison)
**Source:** https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/bar_chart.md

```dart
import 'package:fl_chart/fl_chart.dart';

class YearOverYearChart extends StatelessWidget {
  final YearOverYearComparison data; // Contains year1 and year2 monthly data

  @override
  Widget build(BuildContext context) {
    final maxY = data.maxRevenue * 1.2; // 20% headroom

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final year = rodIndex == 0 ? data.year1 : data.year2;
                return BarTooltipItem(
                  '$year\n€${rod.toY.toStringAsFixed(0)}',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final months = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu',
                                  'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];
                  return Text(months[value.toInt()]);
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) => Text('€${value.toInt()}'),
              ),
            ),
          ),
          barGroups: List.generate(12, (monthIndex) {
            return BarChartGroupData(
              x: monthIndex,
              barRods: [
                // Year 1 bar (e.g., 2024)
                BarChartRodData(
                  toY: data.year1Monthly[monthIndex],
                  color: Colors.blue,
                  width: 16,
                ),
                // Year 2 bar (e.g., 2025)
                BarChartRodData(
                  toY: data.year2Monthly[monthIndex],
                  color: Colors.orange,
                  width: 16,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
```

**Grouped BarChart Key:**
- `BarChartGroupData.x`: Month index (0-11)
- `barRods`: List of bars per group (2 for YoY comparison)
- Each `BarChartRodData` represents one year's data for that month

## SQL Query Templates

### Platform Revenue Breakdown
```sql
-- Source: SQLite aggregation pattern
SELECT
  p.id as platformId,
  p.name as platformName,
  p.color as color,
  COALESCE(SUM(r.amount), 0) as totalRevenue,
  COUNT(r.id) as bookingCount
FROM platforms p
LEFT JOIN reservations r ON p.id = r.platform_id
  AND r.check_in >= ? -- start date
  AND r.check_in <= ? -- end date
  AND r.payment_status = 'received' -- or include pending
GROUP BY p.id, p.name, p.color
ORDER BY totalRevenue DESC;
```

### Monthly Revenue Trend
```sql
-- Source: SQLite monthly aggregation
SELECT
  strftime('%Y-%m', check_in) as month,
  SUM(amount) as revenue,
  COUNT(id) as bookingCount
FROM reservations
WHERE check_in >= ? -- start of period
  AND check_in <= ? -- end of period
  AND payment_status = 'received'
GROUP BY strftime('%Y-%m', check_in)
ORDER BY month ASC;
```

### Year-over-Year Comparison
```sql
-- Source: SQLite year comparison
SELECT
  strftime('%m', check_in) as month,
  strftime('%Y', check_in) as year,
  SUM(amount) as revenue
FROM reservations
WHERE strftime('%Y', check_in) IN (?, ?) -- e.g., '2024', '2025'
  AND payment_status = 'received'
GROUP BY strftime('%Y-%m', check_in)
ORDER BY month, year;
```

### Occupancy Rate Calculation
```sql
-- Source: Based on existing DashboardStatisticsService pattern
-- Calculate days occupied per room in period
SELECT
  room_id,
  SUM(
    JULIANDAY(MIN(check_out, ?)) - JULIANDAY(MAX(check_in, ?))
  ) as occupied_days
FROM reservations
WHERE check_out >= ? -- period start
  AND check_in <= ? -- period end
GROUP BY room_id;

-- Then in Dart:
// occupancy_rate = total_occupied_days / (num_rooms * days_in_period)
```

### Average Stay Duration
```sql
-- Source: SQLite average calculation
SELECT
  AVG(JULIANDAY(check_out) - JULIANDAY(check_in)) as avg_stay_days
FROM reservations
WHERE check_in >= ? -- period start
  AND check_in <= ? -- period end;
```

## Integration with Existing Cache Service

### Cache Strategy
```dart
// Extend existing StatisticsCacheServiceImpl pattern
class StatisticsCacheServiceImpl implements StatisticsCacheService {
  static const _statisticsKey = 'cached_statistics';
  static const _timestampKey = 'cached_statistics_timestamp';
  static const _filterKey = 'cached_statistics_filter';
  static const _cacheDuration = Duration(hours: 24);

  // NEW: Cache includes filter for validity check
  Future<void> setCachedStatistics(
    DashboardStatistics statistics,
    StatisticsFilter filter,
  ) async {
    await _prefs.setString(_statisticsKey, jsonEncode(statistics.toJson()));
    await _prefs.setString(_timestampKey, DateTime.now().toIso8601String());
    await _prefs.setString(_filterKey, jsonEncode(filter.toJson()));
  }

  // NEW: Check if cache applies to requested filter
  Future<bool> isCacheApplicable(StatisticsFilter requestedFilter) async {
    final cachedFilterJson = _prefs.getString(_filterKey);
    if (cachedFilterJson == null) return false;

    final cachedFilter = StatisticsFilter.fromJson(jsonDecode(cachedFilterJson));
    return cachedFilter == requestedFilter;
  }
}
```

### Cache Invalidation Hook
```dart
// Invalidate cache when reservations change
// Add to ReservationRepositoryImpl or ReservationBloc
Future<void> saveReservation(Reservation reservation) async {
  await _dataSource.saveReservation(reservation.toModel());
  // Invalidate statistics cache
  await _statisticsCacheService.invalidateCache();
}
```

## Data Model Design

### StatisticsFilter Entity
```dart
@freezed
class StatisticsFilter with _$StatisticsFilter {
  const factory StatisticsFilter({
    @Default(PeriodFilter.month) PeriodFilter period,
    DateTime? customStartDate,
    DateTime? customEndDate,
    @Default(true) bool includePending,
  }) = _StatisticsFilter;

  factory StatisticsFilter.fromJson(Map<String, dynamic> json) =>
      _$StatisticsFilterFromJson(json);
}

enum PeriodFilter {
  month,    // Current month
  quarter,  // Last 90 days
  year,     // Current year
  custom,   // User-defined range
}
```

### Extended DashboardStatistics
```dart
// Extend existing DashboardStatistics with new fields
class DashboardStatistics {
  // Existing fields...
  final int occupiedRoomsToday;
  final int totalRooms;
  final double monthlyIncomeReceived;
  final double monthlyIncomePending;
  final List<Reservation> upcomingCheckIns;
  final List<Reservation> upcomingCheckOuts;

  // NEW fields for Phase 11
  final double averageStayDuration;
  final double occupancyRate;
  final int totalGuests;
  final List<PlatformRevenue> platformBreakdown;
  final List<MonthlyRevenue> monthlyTrend;
  final YearOverYearComparison? yearOverYear;
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| In-Dart filtering | SQL WHERE clauses | Phase 9 (PERF-02) | 10x faster with large datasets |
| No caching | 24h cache with invalidation | Phase 9 (PERF-05) | Instant repeat loads |
| Simple list | Paginated with filters | Phase 9 (PERF-01) | Handles 1000+ reservations |

**Deprecated/outdated:**
- `charts_flutter`: Deprecated by Google in 2021, use fl_chart instead
- `charts_painter`: Less maintained, fl_chart has better community support

## Open Questions

1. **Should we include pending payments in statistics?**
   - What we know: Current dashboard shows both received and pending
   - What's unclear: User preference for statistics (conservative vs optimistic)
   - Recommendation: Default to received only, add toggle for including pending

2. **How to handle year-over-year with incomplete current year?**
   - What we know: Current year has partial data
   - What's unclear: Should we compare year-to-date or full year?
   - Recommendation: Compare same period (e.g., Jan-Mar 2024 vs Jan-Mar 2025)

3. **Chart interaction depth?**
   - What we know: FL Chart supports tap/hover tooltips
   - What's unclear: Do we need drill-down to reservation list?
   - Recommendation: Phase 11: Tooltips only; drill-down is Phase 12+ if requested

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (built-in) |
| Config file | `flutter_test_config.dart` |
| Quick run command | `flutter test test/features/statistics/ --reporter compact` |
| Full suite command | `flutter test` |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| STAT-01 | Freezed entity creation | unit | `flutter test test/features/statistics/domain/entities/` | Wave 0 |
| STAT-02 | SQL aggregation queries | unit | `flutter test test/features/statistics/data/repositories/` | Wave 0 |
| STAT-03 | Provider state management | unit | `flutter test test/features/statistics/presentation/providers/` | Wave 0 |
| STAT-04 | YoY BarChart renders | widget | `flutter test test/features/statistics/presentation/widgets/year_over_year_chart_test.dart` | Wave 0 |
| STAT-05 | PieChart renders | widget | `flutter test test/features/statistics/presentation/widgets/platform_revenue_chart_test.dart` | Wave 0 |
| STAT-06 | LineChart renders | widget | `flutter test test/features/statistics/presentation/widgets/monthly_trend_chart_test.dart` | Wave 0 |
| STAT-07 | Bookings BarChart renders | widget | `flutter test test/features/statistics/presentation/widgets/platform_bookings_chart_test.dart` | Wave 0 |
| STAT-08 | FL Chart package integration | integration | `flutter test integration_test/statistics_test.dart` | Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/features/statistics/ --reporter compact`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/features/statistics/domain/entities/platform_revenue_test.dart` - covers STAT-01
- [ ] `test/features/statistics/domain/entities/monthly_revenue_test.dart` - covers STAT-01
- [ ] `test/features/statistics/domain/entities/statistics_filter_test.dart` - covers STAT-01
- [ ] `test/features/statistics/data/repositories/statistics_repository_impl_test.dart` - covers STAT-02
- [ ] `test/features/statistics/presentation/providers/statistics_provider_test.dart` - covers STAT-03
- [ ] `test/features/statistics/presentation/widgets/` - all chart widget tests
- [ ] `integration_test/statistics_test.dart` - end-to-end statistics flow

## Sources

### Primary (HIGH confidence)
- FL Chart GitHub Documentation - https://github.com/imaNNeo/fl_chart/tree/main/repo_files/documentations
- Project existing code: `reservation_model.dart` (freezed pattern)
- Project existing code: `dashboard_statistics_service.dart` (statistics calculation)
- Project existing code: `statistics_cache_service_impl.dart` (caching pattern)
- Project existing code: `platform.dart` (platform colors)

### Secondary (MEDIUM confidence)
- FL Chart pub.dev - https://pub.dev/packages/fl_chart
- SQLite Date Functions - https://www.sqlite.org/lang_datefunc.html

### Tertiary (LOW confidence)
- None - all core information verified from primary sources

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - fl_chart is well-documented, freezed pattern already established in project
- Architecture: HIGH - Clean Architecture pattern already established, Riverpod providers exist
- Pitfalls: HIGH - Common chart pitfalls well-documented in FL Chart issues
- SQL queries: HIGH - SQLite patterns are standard, existing database service provides foundation

**Research date:** 2026-03-07
**Valid until:** 2026-04-07 (30 days - stable library versions)
