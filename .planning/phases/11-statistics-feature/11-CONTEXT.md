# Phase 11: Statistics Feature - Context

**Created:** 2026-03-07
**Status:** Ready for Planning
**Phase Goal:** Implementare completa feature statistiche con grafici

## User Decisions

### Locked Decisions (from RESEARCH.md)
These decisions are NON-NEGOTIABLE and must be implemented exactly as specified:

| Decision | Context | Implementation |
|----------|---------|----------------|
| FL Chart library | Best Flutter charting library, MIT licensed | Add `fl_chart: ^0.66.0` to pubspec.yaml |
| Freezed for entities | Already used in project for immutability | All new statistics entities use @freezed annotation |
| SQL aggregations | 10x faster than in-Dart filtering | All statistics calculations via SQL GROUP BY |
| 24h cache | Already implemented in Phase 9 | Integrate with existing StatisticsCacheService |
| Platform colors from entity | Consistency across app | Use BookingPlatform.color, not hardcoded values |

### Claude's Discretion
These areas use reasonable defaults:

| Area | Default Choice | Rationale |
|------|---------------|-----------|
| Chart animations | Enabled on initial load only | Prevents scroll jank from continuous animation |
| Empty state handling | "Nessun dato disponibile" message | Prevents crashes with no data |
| Period filter defaults | Current month | Most common use case |
| YoY comparison | Compare same period (YTD) | Fair comparison for incomplete years |

### Deferred Ideas
These are explicitly out of scope for Phase 11:

| Idea | Why Deferred | Future Phase |
|------|--------------|--------------|
| Chart drill-down to reservations | Complex interaction, not MVP | Phase 12+ |
| Export statistics to CSV | Lower priority than reservations export | Phase 14 (optional enhancement) |
| Real-time statistics updates | Cache invalidation sufficient | Future |
| Custom chart theming | Default FL Chart styling adequate | Future |

## Architecture Decisions

### Feature Structure
```
lib/features/statistics/
├── data/
│   ├── repositories/
│   │   └── statistics_repository_impl.dart    # SQL aggregation queries
│   └── services/
│       └── statistics_cache_service_impl.dart # Already exists
├── domain/
│   ├── entities/
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
    │   └── statistics_provider.dart           # NEW
    ├── pages/
    │   └── statistics_page.dart               # Replace placeholder
    └── widgets/
        ├── kpi_card.dart                      # NEW
        ├── period_filter_selector.dart        # NEW
        ├── year_over_year_chart.dart          # NEW
        ├── platform_revenue_chart.dart        # NEW
        ├── monthly_trend_chart.dart           # NEW
        └── platform_bookings_chart.dart       # NEW
```

### Key Technical Decisions

1. **SQL over Dart calculations**
   - Use SQL GROUP BY for aggregations
   - SQLite strftime() for date grouping
   - JULIANDAY() for duration calculations

2. **Freezed pattern for entities**
   - Immutable data classes
   - JSON serialization for caching
   - copyWith for filter updates

3. **Riverpod AsyncNotifier**
   - Built-in loading/error states
   - Easy cache integration
   - Testable state management

4. **FL Chart widgets**
   - Stateless chart widgets
   - Data passed as constructor parameters
   - Empty state handling in each widget

## Dependencies

### Package Dependencies
```yaml
dependencies:
  fl_chart: ^0.66.0        # NEW - Chart rendering
  intl: ^0.19.0            # NEW - Date/number formatting (may already exist)
  # Already present:
  flutter_riverpod: ^2.6.0
  freezed_annotation: ^2.4.1
  shared_preferences: ^2.3.5
  sqflite: ^2.4.2
```

### Code Dependencies
- `StatisticsCacheService` - Already exists (Phase 9)
- `StatisticsCacheServiceImpl` - Already exists (Phase 9)
- `DashboardStatistics` - Already exists, will extend
- `DashboardStatisticsService` - Already exists, will extend
- `BookingPlatform` - For platform colors
- Database service - For SQL queries

## Requirements Mapping

| Req ID | Description | Plan |
|--------|-------------|------|
| STAT-01 | Statistics Domain Layer - Entities with freezed | 11-01 (Wave 1) |
| STAT-02 | Statistics Data Layer - SQL queries for aggregations | 11-02 (Wave 2) |
| STAT-03 | Statistics Presentation Layer - Riverpod providers | 11-03 (Wave 3) |
| STAT-04 | Year-over-Year Comparison BarChart | 11-04 (Wave 4) |
| STAT-05 | Platform Revenue PieChart | 11-04 (Wave 4) |
| STAT-06 | Monthly Trend LineChart | 11-04 (Wave 4) |
| STAT-07 | Platform Bookings BarChart | 11-04 (Wave 4) |
| STAT-08 | FL Chart Integration | 11-01 (Wave 1) |

## Success Metrics

### Functional Requirements
- [ ] All 8 STAT requirements implemented
- [ ] 4 chart widgets render correctly
- [ ] Period filter selector works
- [ ] KPI cards display correct values
- [ ] Cache integration functional
- [ ] All tests passing

### Performance Requirements
- [ ] Statistics load in < 500ms with 1000+ reservations
- [ ] Cache provides instant repeat loads
- [ ] Charts render smoothly (no frame drops)

### Quality Requirements
- [ ] Empty states handled gracefully
- [ ] Error states display user-friendly messages
- [ ] Responsive layout for desktop/mobile
- [ ] Dark mode support

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| SQL query bugs | Comprehensive unit tests with edge cases |
| Chart empty state crashes | Guard clauses in all chart widgets |
| Cache invalidation failures | Hook into existing reservation CRUD |
| Platform color mismatch | Use BookingPlatform entity colors |

## Notes

### Integration Points
1. **StatisticsPage** replaces placeholder from Phase 10
2. **StatisticsCacheService** integration from Phase 9
3. **Navigation** tab already created in Phase 10

### Testing Strategy
- Unit tests for all entities and repository
- Widget tests for all chart widgets
- Integration tests for statistics flow
- Performance tests with 1000+ reservations

### Timeline Estimate
- Wave 1: 1 day (FL Chart + entities)
- Wave 2: 1.5 days (SQL queries + repository)
- Wave 3: 1.5 days (Presentation layer)
- Wave 4: 2 days (Chart widgets)
- Wave 5: 1 day (Integration testing)
- **Total: 5-7 days**
