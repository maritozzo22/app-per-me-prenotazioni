---
phase: 11-statistics-feature
plan: 04
subsystem: statistics-presentation
tags: [fl-chart, widgets, visualization, charts]
requires:
  - 11-01 (entities)
  - 11-02 (data layer)
  - 11-03 (presentation providers)
provides:
  - YearOverYearChart widget
  - PlatformRevenueChart widget
  - MonthlyTrendChart widget
  - PlatformBookingsChart widget
  - Integrated statistics page with 4 charts
affects:
  - statistics_page.dart
tech-stack:
  added:
    - fl_chart widgets (BarChart, PieChart, LineChart)
  patterns:
    - Stateless chart widgets
    - Empty state handling
    - Responsive layout with LayoutBuilder
key-files:
  created:
    - lib/features/statistics/presentation/widgets/year_over_year_chart.dart
    - lib/features/statistics/presentation/widgets/platform_revenue_chart.dart
    - lib/features/statistics/presentation/widgets/monthly_trend_chart.dart
    - lib/features/statistics/presentation/widgets/platform_bookings_chart.dart
    - test/features/statistics/presentation/widgets/year_over_year_chart_test.dart
    - test/features/statistics/presentation/widgets/platform_revenue_chart_test.dart
    - test/features/statistics/presentation/widgets/monthly_trend_chart_test.dart
    - test/features/statistics/presentation/widgets/platform_bookings_chart_test.dart
  modified:
    - lib/features/statistics/presentation/pages/statistics_page.dart
    - test/features/statistics/presentation/pages/statistics_page_test.dart
decisions:
  - FL Chart for all chart visualizations
  - Platform colors from entity (Color(platform.color))
  - Empty state handling with "Nessun dato disponibile" message
  - Responsive layout for PlatformRevenue and PlatformBookings (side-by-side on wide screens)
  - Curved line for MonthlyTrendChart
  - Sorted bars by booking count for PlatformBookingsChart
metrics:
  duration: 20 minutes
  completed: 2026-03-08
  tasks: 5
  tests: 25 new widget tests + 4 new page tests
  files: 10 (4 widgets, 4 test files, 2 modified)
---

# Phase 11 Plan 04: Chart Widgets Summary

## One-Liner

Implemented 4 chart widgets using FL Chart library for statistics visualization with responsive layout and empty state handling.

## What Was Built

### 1. YearOverYearChart Widget
- **Type**: Grouped bar chart (BarChart)
- **Purpose**: Compare revenue across 2 years, 12 months each
- **Features**:
  - 24 bars (12 months x 2 years)
  - Blue bars for year1, orange bars for year2
  - Legend showing both years
  - Tooltips on tap showing year and revenue
  - X-axis: Italian month labels (Gen, Feb, Mar, etc.)
  - Y-axis: Euro values
  - Empty state: "Dati insufficienti per il confronto"

### 2. PlatformRevenueChart Widget
- **Type**: Pie chart (PieChart)
- **Purpose**: Show revenue distribution across platforms
- **Features**:
  - Percentage labels on each section
  - Platform colors from entity (Color(platform.color))
  - Legend with platform names
  - Center hole for modern look
  - Filters out platforms with zero revenue
  - Empty state: "Nessun dato disponibile"

### 3. MonthlyTrendChart Widget
- **Type**: Curved line chart (LineChart)
- **Purpose**: Show revenue trend over time
- **Features**:
  - Curved line with data points
  - Gradient fill below the line
  - X-axis: Month labels from data
  - Y-axis: Euro values with compact formatting
  - Tooltips showing month and revenue
  - Empty state: "Nessun dato disponibile"

### 4. PlatformBookingsChart Widget
- **Type**: Bar chart (BarChart)
- **Purpose**: Show booking counts per platform
- **Features**:
  - Sorted by booking count (descending)
  - Platform colors from entity
  - Tooltips showing platform name and count
  - X-axis: Platform names
  - Y-axis: Booking count
  - Empty state: "Nessun dato disponibile"

### 5. StatisticsPage Integration
- Updated charts section from placeholder to actual charts
- Responsive layout using LayoutBuilder
- Side-by-side layout for PlatformRevenue and PlatformBookings on wide screens (>600px)
- All charts wrapped in Card widgets with padding
- Section title changed from "Grafici" to "Analisi"

## Files Created

| File | Lines | Purpose |
|------|-------|---------|
| `year_over_year_chart.dart` | 192 | YoY comparison bar chart |
| `platform_revenue_chart.dart` | 143 | Platform breakdown pie chart |
| `monthly_trend_chart.dart` | 172 | Monthly trend line chart |
| `platform_bookings_chart.dart` | 137 | Platform bookings bar chart |
| `year_over_year_chart_test.dart` | 133 | 6 widget tests |
| `platform_revenue_chart_test.dart` | 147 | 6 widget tests |
| `monthly_trend_chart_test.dart` | 116 | 7 widget tests |
| `platform_bookings_chart_test.dart` | 130 | 6 widget tests |

## Tests

### New Tests: 29 total
- YearOverYearChart: 6 tests
- PlatformRevenueChart: 6 tests
- MonthlyTrendChart: 7 tests
- PlatformBookingsChart: 6 tests
- StatisticsPage (new): 4 tests

### All Tests Passing
```
test/features/statistics/presentation/ - 58 tests passed
```

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed month label test assertion**
- **Found during:** Task 3 (MonthlyTrendChart tests)
- **Issue:** Test expected `findsOneWidget` but FL Chart renders multiple copies of labels
- **Fix:** Changed to `findsWidgets` assertion
- **Files modified:** `monthly_trend_chart_test.dart`

**2. [Rule 2 - Deprecation] Replaced deprecated withOpacity**
- **Found during:** Analyzer check
- **Issue:** `Color.withOpacity` is deprecated in favor of `withValues`
- **Fix:** Replaced `withOpacity(0.5)` with `withValues(alpha: 0.5)`
- **Files modified:** All 4 chart widgets
- **Commit:** 26d1c3c

## Commits

| Hash | Message |
|------|---------|
| `ccdfe4e` | feat(11-04): implement YearOverYearChart widget |
| `a004bab` | feat(11-04): implement PlatformRevenueChart widget |
| `7d4bdfb` | feat(11-04): implement MonthlyTrendChart widget |
| `843975a` | feat(11-04): implement PlatformBookingsChart widget |
| `9e3eb04` | feat(11-04): integrate all 4 charts into StatisticsPage |
| `26d1c3c` | fix(11-04): replace deprecated withOpacity with withValues |

## Success Criteria Status

- [x] YearOverYearChart with grouped bars (2 years, 12 months)
- [x] PlatformRevenueChart with pie visualization
- [x] MonthlyTrendChart with curved line
- [x] PlatformBookingsChart with sorted bars
- [x] All charts handle empty data gracefully
- [x] All charts use platform colors from entity
- [x] All charts have tooltips on tap/hover
- [x] StatisticsPage shows all 4 charts
- [x] Responsive layout (side-by-side on wide screens)
- [x] All widget tests passing (29 tests)
- [x] No analyzer errors

## Requirements Completed

| Req ID | Description | Status |
|--------|-------------|--------|
| STAT-04 | Year-over-Year Comparison BarChart | DONE |
| STAT-05 | Platform Revenue PieChart | DONE |
| STAT-06 | Monthly Trend LineChart | DONE |
| STAT-07 | Platform Bookings BarChart | DONE |

## Next Steps

- Plan 11-05: Integration testing and performance verification

## Self-Check: PASSED

- All 4 chart widget files created and found
- All 6 commits verified in git history
- SUMMARY.md created at correct location
- All tests passing (58 tests)
- No analyzer errors
