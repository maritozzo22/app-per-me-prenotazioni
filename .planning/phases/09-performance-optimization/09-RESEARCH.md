# Phase 9: Performance Optimization - Research

**Researched:** 2026-03-07
**Domain:** Flutter performance optimization, SQLite pagination, caching strategies, lazy loading patterns
**Confidence:** HIGH

## Summary

Phase 9 focuses on optimizing the Flutter reservations app to handle 1000+ reservations without performance degradation. The current implementation loads all reservations into memory at once, which works well for ~100 reservations but will cause UI lag and memory issues at scale.

**Critical Finding:** The most impactful optimizations are: (1) SQL-based pagination with LIMIT/OFFSET for the reservations list, (2) SQL-based filtering instead of Dart-side filtering, (3) calendar month lazy loading with debouncing, and (4) statistics caching with 24-hour TTL and automatic invalidation.

**Primary recommendation:** Implement pagination at the database layer using `LIMIT` and `OFFSET` in SQL queries, add SQL WHERE clauses for filters (date range, platform, room, payment status), lazy-load calendar months with debounced queries, and cache statistics in SharedPreferences with timestamp-based invalidation.

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| PERF-01 | Lazy loading reservation list (20 items initial, infinite scroll) | SQL LIMIT/OFFSET pagination, ListView.builder with scroll detection |
| PERF-02 | Intelligent period filters (SQL-based, not Dart filtering) | SQL WHERE clauses for date ranges, FilterChip UI, SharedPreferences for persistence |
| PERF-03 | Calendar optimization (load visible month + adjacent) | Date range queries with debouncing, lazy loading on month change |
| PERF-04 | Database index optimization | Composite indexes on frequently queried columns, EXPLAIN QUERY PLAN verification |
| PERF-05 | Statistics caching (24h TTL with invalidation) | SharedPreferences caching with timestamp, automatic invalidation on data changes |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| sqflite | ^2.4.2 (already in use) | SQL pagination and filtering | Native performance, already integrated, LIMIT/OFFSET support |
| shared_preferences | ^2.3.5 (already in use) | Statistics cache storage | Lightweight key-value store, cross-platform, already in use for settings |
| flutter_riverpod | ^2.6.0 (already in use) | State management for pagination | Async value handling, loading states, already established pattern |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| collection | any (built-in) | Efficient list operations | For in-memory filtering if needed, equality comparisons |
| debounce_throttle | optional | Debouncing calendar queries | Alternative to custom Timer implementation |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| LIMIT/OFFSET pagination | Cursor-based pagination (keyset) | Cursor-based is more efficient for large offsets but requires stable sort order; LIMIT/OFFSET is simpler for MVP |
| SharedPreferences cache | SQLite cache table | SQLite is more structured but SharedPreferences is faster for simple key-value cache |
| Manual debounce Timer | debounce_throttle package | Package provides cleaner API but adds dependency for simple use case |

**Installation:**
```yaml
# No new packages required - all dependencies already in pubspec.yaml
# Optional enhancement:
dependencies:
  debounce_throttle: ^2.0.0  # For cleaner debounce API (optional)
```

## Architecture Patterns

### Recommended Project Structure
```
lib/
├── features/
│   └── reservations/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── local/
│       │   │       └── reservation_local_data_source.dart  # Enhanced: pagination methods
│       │   └── repositories/
│       │       └── reservation_repository_impl.dart         # Enhanced: pagination support
│       ├── domain/
│       │   ├── repositories/
│       │   │   └── reservation_repository.dart              # Enhanced: pagination interface
│       │   └── entities/
│       │       └── reservation_filter.dart                  # NEW: Filter entity
│       │   └── value_objects/
│       │       └── paginated_result.dart                    # NEW: Pagination wrapper
│       └── presentation/
│           ├── providers/
│           │   ├── paginated_reservations_provider.dart     # NEW: Pagination state
│           │   └── statistics_cache_provider.dart           # NEW: Cache management
│           └── widgets/
│               └── filter_sheet.dart                        # NEW: Filter UI
├── core/
│   └── services/
│       └── statistics_cache_service.dart                    # NEW: Cache service
```

### Pattern 1: SQL-Based Pagination with LIMIT/OFFSET

**What:** Add pagination methods to data source using SQL LIMIT and OFFSET clauses.

**When to use:** For PERF-01 - lazy loading reservations list.

**Example:**
```dart
// domain/value_objects/paginated_result.dart
class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int pageSize;
  final int currentPage;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.pageSize,
    required this.currentPage,
  }) : hasMore = items.length == pageSize;

  int get offset => currentPage * pageSize;
}

// domain/repositories/reservation_repository.dart
abstract class ReservationRepository {
  // Existing methods...
  Future<List<Reservation>> getAllReservations();

  // NEW: Paginated method
  Future<PaginatedResult<Reservation>> getReservationsPaginated({
    required int limit,
    required int offset,
    ReservationFilter? filter,
  });

  // NEW: Count method for filter results
  Future<int> getReservationsCount({ReservationFilter? filter});
}

// data/datasources/local/reservation_local_data_source.dart
@override
Future<PaginatedResult<ReservationModel>> getReservationsPaginated({
  required int limit,
  required int offset,
  ReservationFilter? filter,
}) async {
  final db = await _databaseHelper.database as Database;

  // Build WHERE clause from filter
  String? whereClause;
  List<dynamic>? whereArgs;

  if (filter != null) {
    final conditions = <String>[];
    whereArgs = [];

    if (filter.startDate != null && filter.endDate != null) {
      conditions.add('${DatabaseSchema.reservationCheckIn} >= ?');
      conditions.add('${DatabaseSchema.reservationCheckIn} <= ?');
      whereArgs.add(filter.startDate!.toIso8601String());
      whereArgs.add(filter.endDate!.toIso8601String());
    }

    if (filter.platformId != null) {
      conditions.add('${DatabaseSchema.reservationPlatformId} = ?');
      whereArgs.add(filter.platformId);
    }

    if (filter.roomId != null) {
      conditions.add('${DatabaseSchema.reservationRoomId} = ?');
      whereArgs.add(filter.roomId);
    }

    if (filter.paymentStatus != null) {
      conditions.add('${DatabaseSchema.reservationPaymentStatus} = ?');
      whereArgs.add(filter.paymentStatus!.name);
    }

    if (conditions.isNotEmpty) {
      whereClause = conditions.join(' AND ');
    }
  }

  // Get total count
  final countResult = await db.rawQuery(
    'SELECT COUNT(*) as count FROM ${DatabaseSchema.tableReservations}'
    '${whereClause != null ? ' WHERE $whereClause' : ''}',
    whereArgs,
  );
  final totalCount = Sqflite.firstIntValue(countResult) ?? 0;

  // Get paginated results
  final maps = await db.query(
    DatabaseSchema.tableReservations,
    where: whereClause,
    whereArgs: whereArgs,
    orderBy: '${DatabaseSchema.reservationCheckIn} ASC',
    limit: limit,
    offset: offset,
  );

  final items = maps.map((map) => _mapToReservationModel(map)).toList();

  return PaginatedResult(
    items: items,
    totalCount: totalCount,
    pageSize: limit,
    currentPage: offset ~/ limit,
  );
}
```

### Pattern 2: Infinite Scroll with ScrollController

**What:** Use ScrollController to detect when user scrolls near bottom and trigger loadMore.

**When to use:** For PERF-01 - triggering pagination.

**Example:**
```dart
// presentation/providers/paginated_reservations_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginatedReservationsState {
  final List<Reservation> reservations;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const PaginatedReservationsState({
    this.reservations = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
  });

  PaginatedReservationsState copyWith({
    List<Reservation>? reservations,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return PaginatedReservationsState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
    );
  }
}

class PaginatedReservationsNotifier
    extends StateNotifier<PaginatedReservationsState> {
  final ReservationRepository _repository;
  static const int pageSize = 20;

  ReservationFilter? _currentFilter;

  PaginatedReservationsNotifier(this._repository)
      : super(const PaginatedReservationsState()) {
    loadInitial();
  }

  Future<void> loadInitial({ReservationFilter? filter}) async {
    _currentFilter = filter;
    state = const PaginatedReservationsState(isLoading: true);

    try {
      final result = await _repository.getReservationsPaginated(
        limit: pageSize,
        offset: 0,
        filter: filter,
      );

      state = PaginatedReservationsState(
        reservations: result.items,
        hasMore: result.hasMore,
        currentPage: 0,
      );
    } catch (e) {
      state = PaginatedReservationsState(error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final result = await _repository.getReservationsPaginated(
        limit: pageSize,
        offset: nextPage * pageSize,
        filter: _currentFilter,
      );

      state = PaginatedReservationsState(
        reservations: [...state.reservations, ...result.items],
        hasMore: result.hasMore,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadInitial(filter: _currentFilter);
  }

  void updateFilter(ReservationFilter? filter) {
    loadInitial(filter: filter);
  }
}

final paginatedReservationsProvider = StateNotifierProvider<
    PaginatedReservationsNotifier, PaginatedReservationsState>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);
  return PaginatedReservationsNotifier(repository);
});

// presentation/pages/reservations_list_page.dart
class _ReservationsListPageState extends ConsumerState<ReservationsListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when 80% scrolled
      ref.read(paginatedReservationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paginatedReservationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Prenotazioni')),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),
          // Result count
          if (!state.isLoading && state.reservations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${state.reservations.length} di ${state.totalCount} prenotazioni',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          // List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.reservations.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.reservations.length) {
                  // Loading indicator at bottom
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final reservation = state.reservations[index];
                return ReservationListTile(
                  reservation: reservation,
                  onEdit: () => _navigateToEdit(reservation),
                  onDelete: () => _deleteReservation(reservation),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### Pattern 3: SQL-Based Filtering

**What:** Build dynamic SQL WHERE clauses based on filter criteria instead of filtering in Dart.

**When to use:** For PERF-02 - intelligent period filters.

**Example:**
```dart
// domain/entities/reservation_filter.dart
class ReservationFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? platformId;
  final String? roomId;
  final PaymentStatus? paymentStatus;

  const ReservationFilter({
    this.startDate,
    this.endDate,
    this.platformId,
    this.roomId,
    this.paymentStatus,
  });

  ReservationFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? platformId,
    String? roomId,
    PaymentStatus? paymentStatus,
  }) {
    return ReservationFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      platformId: platformId ?? this.platformId,
      roomId: roomId ?? this.roomId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  bool get isEmpty =>
      startDate == null &&
      endDate == null &&
      platformId == null &&
      roomId == null &&
      paymentStatus == null;

  // Predefined filter presets
  static ReservationFilter futureOnly() => ReservationFilter(
        startDate: DateTime.now(),
      );

  static ReservationFilter last30Days() => ReservationFilter(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );

  static ReservationFilter last90Days() => ReservationFilter(
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now(),
      );

  static ReservationFilter year2025() => ReservationFilter(
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
      );

  static ReservationFilter year2024() => ReservationFilter(
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
      );
}

// presentation/widgets/filter_sheet.dart
class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(paginatedReservationsProvider).filter;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtri', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // Period filters
          Text('Periodo', style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Future'),
                selected: currentFilter == ReservationFilter.futureOnly(),
                onSelected: (_) => _applyFilter(
                    context, ref, ReservationFilter.futureOnly()),
              ),
              FilterChip(
                label: const Text('Ultimi 30 giorni'),
                selected: currentFilter == ReservationFilter.last30Days(),
                onSelected: (_) =>
                    _applyFilter(context, ref, ReservationFilter.last30Days()),
              ),
              FilterChip(
                label: const Text('Ultimi 90 giorni'),
                selected: currentFilter == ReservationFilter.last90Days(),
                onSelected: (_) =>
                    _applyFilter(context, ref, ReservationFilter.last90Days()),
              ),
              FilterChip(
                label: const Text('2025'),
                selected: currentFilter == ReservationFilter.year2025(),
                onSelected: (_) =>
                    _applyFilter(context, ref, ReservationFilter.year2025()),
              ),
              FilterChip(
                label: const Text('2024'),
                selected: currentFilter == ReservationFilter.year2024(),
                onSelected: (_) =>
                    _applyFilter(context, ref, ReservationFilter.year2024()),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Platform filter
          Text('Piattaforma', style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: 8,
            children: BookingPlatform.defaultPlatforms.map((platform) {
              return FilterChip(
                label: Text(platform.name),
                selected: currentFilter?.platformId == platform.id,
                onSelected: (_) => _applyFilter(
                  context,
                  ref,
                  currentFilter?.copyWith(platformId: platform.id) ??
                      ReservationFilter(platformId: platform.id),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Room filter
          Text('Camera', style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: 8,
            children: Room.defaultRooms.map((room) {
              return FilterChip(
                label: Text(room.name),
                selected: currentFilter?.roomId == room.id,
                onSelected: (_) => _applyFilter(
                  context,
                  ref,
                  currentFilter?.copyWith(roomId: room.id) ??
                      ReservationFilter(roomId: room.id),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Payment status filter
          Text('Stato Pagamento',
              style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: 8,
            children: PaymentStatus.values.map((status) {
              return FilterChip(
                label: Text(status.label),
                selected: currentFilter?.paymentStatus == status,
                onSelected: (_) => _applyFilter(
                  context,
                  ref,
                  currentFilter?.copyWith(paymentStatus: status) ??
                      ReservationFilter(paymentStatus: status),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => _applyFilter(context, ref, null),
                child: const Text('Cancella filtri'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Applica'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyFilter(
      BuildContext context, WidgetRef ref, ReservationFilter? filter) {
    ref.read(paginatedReservationsProvider.notifier).updateFilter(filter);
    // Save to SharedPreferences for persistence
    _saveFilterToPrefs(filter);
  }

  Future<void> _saveFilterToPrefs(ReservationFilter? filter) async {
    final prefs = await SharedPreferences.getInstance();
    if (filter == null) {
      await prefs.remove('reservation_filter');
    } else {
      // Serialize filter to JSON
      final json = {
        if (filter.startDate != null)
          'startDate': filter.startDate!.toIso8601String(),
        if (filter.endDate != null)
          'endDate': filter.endDate!.toIso8601String(),
        if (filter.platformId != null) 'platformId': filter.platformId,
        if (filter.roomId != null) 'roomId': filter.roomId,
        if (filter.paymentStatus != null)
          'paymentStatus': filter.paymentStatus!.name,
      };
      await prefs.setString('reservation_filter', jsonEncode(json));
    }
  }
}
```

### Pattern 4: Calendar Lazy Loading with Debouncing

**What:** Load only the visible month plus previous/next month, debouncing rapid month changes.

**When to use:** For PERF-03 - calendar optimization.

**Example:**
```dart
// presentation/providers/calendar_provider.dart
class CalendarNotifier extends StateNotifier<CalendarState> {
  final ReservationRepository _repository;
  Timer? _debounceTimer;

  CalendarNotifier(this._repository)
      : super(CalendarState(
          focusedDay: DateTime.now(),
          reservationsByDate: {},
        )) {
    _loadVisibleMonths(DateTime.now());
  }

  /// Load reservations for visible month + previous/next month
  Future<void> _loadVisibleMonths(DateTime focusedDay) async {
    state = state.copyWith(isLoading: true);

    try {
      // Calculate range: previous month to next month
      final start = DateTime(focusedDay.year, focusedDay.month - 1, 1);
      final end = DateTime(focusedDay.year, focusedDay.month + 2, 0);

      final reservations = await _repository.getReservationsForDateRange(
        start,
        end,
      );

      final reservationsByDate = _groupReservationsByDate(reservations);

      state = state.copyWith(
        reservationsByDate: reservationsByDate,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
    }
  }

  /// Debounced month change handler
  void onPageChanged(DateTime focusedDay) {
    state = state.copyWith(focusedDay: focusedDay);

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Debounce: wait 300ms before loading
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _loadVisibleMonths(focusedDay);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ... rest of the methods remain the same
}

// presentation/pages/calendar_page.dart
TableCalendar(
  firstDay: DateTime.utc(2020, 1, 1),
  lastDay: DateTime.utc(2030, 12, 31),
  focusedDay: calendarState.focusedDay,
  onPageChanged: (focusedDay) {
    // Trigger debounced loading
    ref.read(calendarProvider.notifier).onPageChanged(focusedDay);
  },
  // ... rest of calendar configuration
)
```

### Pattern 5: Statistics Caching with TTL

**What:** Cache statistics results in SharedPreferences with 24-hour TTL and automatic invalidation.

**When to use:** For PERF-05 - statistics caching.

**Example:**
```dart
// core/services/statistics_cache_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StatisticsCacheService {
  static const String _cacheKeyPrefix = 'stats_cache_';
  static const Duration cacheTTL = Duration(hours: 24);

  Future<DashboardStatistics?> getCachedStatistics(String cacheKey) async {
    final prefs = await SharedPreferences.getInstance();
    final fullKey = '$_cacheKeyPrefix$cacheKey';

    final jsonString = prefs.getString(fullKey);
    if (jsonString == null) return null;

    try {
      final cacheData = jsonDecode(jsonString) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(cacheData['cachedAt'] as String);
      final now = DateTime.now();

      // Check if cache is still valid
      if (now.difference(cachedAt) < cacheTTL) {
        return DashboardStatistics.fromJson(
          cacheData['data'] as Map<String, dynamic>,
        );
      } else {
        // Cache expired, remove it
        await prefs.remove(fullKey);
        return null;
      }
    } catch (e) {
      // Invalid cache data, remove it
      await prefs.remove(fullKey);
      return null;
    }
  }

  Future<void> cacheStatistics(
    String cacheKey,
    DashboardStatistics statistics,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final fullKey = '$_cacheKeyPrefix$cacheKey';

    final cacheData = {
      'cachedAt': DateTime.now().toIso8601String(),
      'data': statistics.toJson(),
    };

    await prefs.setString(fullKey, jsonEncode(cacheData));
  }

  Future<void> invalidateCache(String cacheKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_cacheKeyPrefix$cacheKey');
  }

  Future<void> invalidateAllCaches() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_cacheKeyPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  Future<DateTime?> getCacheTimestamp(String cacheKey) async {
    final prefs = await SharedPreferences.getInstance();
    final fullKey = '$_cacheKeyPrefix$cacheKey';

    final jsonString = prefs.getString(fullKey);
    if (jsonString == null) return null;

    try {
      final cacheData = jsonDecode(jsonString) as Map<String, dynamic>;
      return DateTime.parse(cacheData['cachedAt'] as String);
    } catch (e) {
      return null;
    }
  }
}

// presentation/providers/dashboard_provider.dart
class DashboardNotifier extends StateNotifier<DashboardState> {
  final ReservationRepository _repository;
  final StatisticsCacheService _cacheService;

  DashboardNotifier(this._repository, this._cacheService)
      : super(const DashboardState()) {
    loadStatistics();
  }

  Future<void> loadStatistics({bool forceRefresh = false}) async {
    final now = DateTime.now();
    final cacheKey = 'dashboard_${now.year}_${now.month}';

    // Check cache first (unless force refresh)
    if (!forceRefresh) {
      final cached = await _cacheService.getCachedStatistics(cacheKey);
      if (cached != null) {
        final timestamp = await _cacheService.getCacheTimestamp(cacheKey);
        state = DashboardState(
          statistics: cached,
          cacheTimestamp: timestamp,
          isFromCache: true,
        );
        return;
      }
    }

    // Cache miss or force refresh - calculate fresh
    state = state.copyWith(isLoading: true);

    try {
      final statistics = await _calculateStatistics();
      await _cacheService.cacheStatistics(cacheKey, statistics);

      final timestamp = await _cacheService.getCacheTimestamp(cacheKey);
      state = DashboardState(
        statistics: statistics,
        cacheTimestamp: timestamp,
        isFromCache: false,
      );
    } catch (e) {
      state = DashboardState(error: e.toString());
    }
  }

  Future<DashboardStatistics> _calculateStatistics() async {
    // ... existing calculation logic
  }

  /// Called when reservation is added/modified/deleted
  Future<void> invalidateCache() async {
    await _cacheService.invalidateAllCaches();
    await loadStatistics(forceRefresh: true);
  }
}

// presentation/pages/dashboard_page.dart
Widget build(BuildContext context) {
  final state = ref.watch(dashboardProvider);

  return Scaffold(
    appBar: AppBar(
      title: const Text('Dashboard'),
      actions: [
        if (state.isFromCache)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(dashboardProvider.notifier).loadStatistics(
                    forceRefresh: true,
                  );
            },
            tooltip: 'Aggiorna statistiche',
          ),
      ],
    ),
    body: Column(
      children: [
        if (state.cacheTimestamp != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Ultimo aggiornamento: ${DateFormat('d MMM yyyy, HH:mm', 'it_IT').format(state.cacheTimestamp!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        // ... rest of dashboard UI
      ],
    ),
  );
}
```

### Anti-Patterns to Avoid

- **Loading all reservations in memory:** Current implementation loads all 1000+ reservations into a List. Use pagination instead.
- **Dart-side filtering:** Filtering in Dart after loading all data defeats the purpose of pagination. Always filter in SQL.
- **No debouncing on calendar:** Swiping through multiple months triggers multiple database queries. Debounce to 300ms.
- **Hardcoded cache TTL:** Don't hardcode "24 hours" in multiple places. Define as constant in service.
- **Never invalidating cache:** Cache must be invalidated when reservations change (add/edit/delete).
- **Ignoring offset performance:** Large offsets (>1000) can be slow. Consider cursor-based pagination for very large datasets.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Pagination state | Manual list management with ScrollController | Riverpod StateNotifier + PaginatedResult | Cleaner state management, better testability, built-in loading states |
| Debouncing | Custom Timer logic in multiple places | Timer with cancellation or debounce_throttle package | Reusable, tested, cleaner API |
| Cache TTL | Manual timestamp comparison in every provider | StatisticsCacheService with TTL logic | Centralized logic, easier to change TTL, automatic cleanup |
| Filter serialization | Manual string building | jsonEncode/jsonDecode | Type-safe, handles null values correctly |
| Scroll detection | Manual pixel calculations | ScrollController.position.maxScrollExtent * 0.8 | Standard pattern, handles dynamic content height |

**Key insight:** Pagination and caching are complex enough to warrant dedicated services. Don't scatter this logic across UI components.

## Common Pitfalls

### Pitfall 1: Large OFFSET Performance Degradation
**What goes wrong:** OFFSET 900 LIMIT 20 scans through 900 rows before returning 20, making late pages slow.
**Why it happens:** SQLite must read and skip all preceding rows to reach the offset.
**How to avoid:** For datasets >5000 items, consider cursor-based pagination using WHERE id > lastId LIMIT 20 instead of OFFSET.
**Warning signs:** Page load time increases linearly with page number.

### Pitfall 2: Cache Never Invalidated
**What goes wrong:** Statistics show outdated data even after adding/modifying reservations.
**Why it happens:** Cache is saved but never cleared when underlying data changes.
**How to avoid:** Call `invalidateCache()` in repository's save/delete methods, or use observer pattern.
**Warning signs:** Dashboard shows wrong totals, users confused why changes don't appear.

### Pitfall 3: Filter Chip State Not Persisted
**What goes wrong:** User sets filters, navigates away, returns - filters are reset.
**Why it happens:** Filter state only stored in memory, not persisted.
**How to avoid:** Save filter to SharedPreferences when applied, restore on provider initialization.
**Warning signs:** Users frustrated having to re-apply filters repeatedly.

### Pitfall 4: Calendar Loads All Historical Data
**What goes wrong:** Calendar loads 3+ years of reservations on initial load, causing lag.
**Why it happens:** `getReservationsForDateRange` called with very wide range or no range limit.
**How to avoid:** Only load visible month + previous/next month (±1 month window).
**Warning signs:** Calendar takes >1s to load on initial render.

### Pitfall 5: Debounce Timer Memory Leak
**What goes wrong:** Timer continues running after widget disposed, causing memory leaks.
**Why it happens:** Timer not cancelled in dispose() method.
**How to avoid:** Always cancel timer in dispose() method of StateNotifier or StatefulWidget.
**Warning signs:** Memory usage grows over time, errors about disposed state.

### Pitfall 6: Missing Composite Index
**What goes wrong:** Queries filtering by both date AND platform are slow despite individual indexes.
**Why it happens:** SQLite can't efficiently use two separate indexes for one query.
**How to avoid:** Create composite index on (check_in, platform_id) if frequently filtered together.
**Warning signs:** Query with multiple filters slower than expected, EXPLAIN QUERY PLAN shows table scan.

## Code Examples

### Complete Pagination Implementation

```dart
// domain/value_objects/paginated_result.dart
class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int pageSize;
  final int currentPage;

  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.pageSize,
    required this.currentPage,
  });

  bool get hasMore => items.length == pageSize;
  int get offset => currentPage * pageSize;
}

// domain/entities/reservation_filter.dart
class ReservationFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? platformId;
  final String? roomId;
  final PaymentStatus? paymentStatus;

  const ReservationFilter({
    this.startDate,
    this.endDate,
    this.platformId,
    this.roomId,
    this.paymentStatus,
  });

  bool get isEmpty =>
      startDate == null &&
      endDate == null &&
      platformId == null &&
      roomId == null &&
      paymentStatus == null;

  Map<String, dynamic> toJson() => {
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        if (platformId != null) 'platformId': platformId,
        if (roomId != null) 'roomId': roomId,
        if (paymentStatus != null) 'paymentStatus': paymentStatus!.name,
      };

  factory ReservationFilter.fromJson(Map<String, dynamic> json) {
    return ReservationFilter(
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      platformId: json['platformId'] as String?,
      roomId: json['roomId'] as String?,
      paymentStatus: json['paymentStatus'] != null
          ? PaymentStatus.values.firstWhere(
              (e) => e.name == json['paymentStatus'],
            )
          : null,
    );
  }

  ReservationFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? platformId,
    String? roomId,
    PaymentStatus? paymentStatus,
  }) {
    return ReservationFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      platformId: platformId ?? this.platformId,
      roomId: roomId ?? this.roomId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}
```

### Database Migration for Composite Indexes

```dart
// core/database/database_schema.dart
class DatabaseSchema {
  static const int version = 6; // Increment from 5 to 6

  // ... existing schema ...

  /// Migration to add composite indexes (version 5 -> 6)
  static const String migrationV5ToV6AddCompositeIndexes = '''
    -- Composite index for date range + platform queries
    CREATE INDEX IF NOT EXISTS idx_reservations_checkin_platform
    ON $tableReservations ($reservationCheckIn, $reservationPlatformId);

    -- Composite index for date range + room queries
    CREATE INDEX IF NOT EXISTS idx_reservations_checkin_room
    ON $tableReservations ($reservationCheckIn, $reservationRoomId);

    -- Index on payment_status for filtering
    CREATE INDEX IF NOT EXISTS idx_reservations_payment_status
    ON $tableReservations ($reservationPaymentStatus);

    -- Index on platform_id for platform filtering
    CREATE INDEX IF NOT EXISTS idx_reservations_platform_id
    ON $tableReservations ($reservationPlatformId);

    -- Index on room_id for room filtering
    CREATE INDEX IF NOT EXISTS idx_reservations_room_id
    ON $tableReservations ($reservationRoomId);
  ''';
}

// core/database/database_helper_native.dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute(DatabaseSchema.migrationV1ToV2);
  }
  if (oldVersion < 3) {
    await db.execute(DatabaseSchema.migrationV2ToV3);
    await db.execute(DatabaseSchema.migrationV2ToV3UpdateSystemPlatforms);
  }
  if (oldVersion < 4) {
    await db.execute(DatabaseSchema.createNotificationSchedulesTable);
    await db.execute(DatabaseSchema.createNotificationSchedulesReservationIndex);
    await db.execute(DatabaseSchema.createNotificationSchedulesScheduledDateIndex);
    await db.execute(DatabaseSchema.createNotificationSchedulesIsSentIndex);
  }
  if (oldVersion < 5) {
    await db.execute(DatabaseSchema.migrationV4ToV5AddIndexes);
  }
  if (oldVersion < 6) {
    await db.execute(DatabaseSchema.migrationV5ToV6AddCompositeIndexes);
  }
}
```

### Performance Test Data Generator

```dart
// test/performance/test_data_generator.dart
import 'package:uuid/uuid.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';

class TestDataGenerator {
  static final _uuid = Uuid();
  static final _random = Random();

  static List<Reservation> generateReservations(int count) {
    final reservations = <Reservation>[];
    final platforms = ['booking', 'airbnb', 'whatsapp', 'website', 'tiktok'];
    final rooms = ['room-1', 'room-2', 'room-3', 'apartment'];
    final guestNames = [
      'Mario Rossi',
      'Giuseppe Verdi',
      'Anna Bianchi',
      'Luca Neri',
      'Maria Colombo',
      // ... add more names
    ];

    for (int i = 0; i < count; i++) {
      // Generate random date within last 3 years
      final checkIn = DateTime.now().subtract(
        Duration(days: _random.nextInt(1095)), // 3 years
      );
      final checkOut = checkIn.add(
        Duration(days: _random.nextInt(14) + 1), // 1-14 days
      );

      reservations.add(
        Reservation(
          id: _uuid.v4(),
          roomId: rooms[_random.nextInt(rooms.length)],
          platformId: platforms[_random.nextInt(platforms.length)],
          guest: Guest(
            name: guestNames[_random.nextInt(guestNames.length)],
            phone: '+39 ${_random.nextInt(1000000000).toString().padLeft(10, '0')}',
          ),
          checkIn: checkIn,
          checkOut: checkOut,
          amount: (_random.nextInt(500) + 50).toDouble(),
          paymentStatus: PaymentStatus.values[_random.nextInt(3)],
          notes: _random.nextBool() ? 'Note di test' : null,
          createdAt: checkIn.subtract(const Duration(days: 30)),
          updatedAt: checkIn,
        ),
      );
    }

    return reservations;
  }
}

// test/performance/pagination_performance_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/data/datasources/local/reservation_local_data_source.dart';

void main() {
  group('Pagination Performance', () {
    late ReservationLocalDataSource dataSource;

    setUpAll(() async {
      dataSource = ReservationLocalDataSource(
        databaseHelper: DatabaseHelper.forTesting(),
      );

      // Generate and insert 1000 test reservations
      final testData = TestDataGenerator.generateReservations(1000);
      await dataSource.insertReservationsBatch(testData);
    });

    test('first page loads in <100ms', () async {
      final stopwatch = Stopwatch()..start();

      final result = await dataSource.getReservationsPaginated(
        limit: 20,
        offset: 0,
      );

      stopwatch.stop();

      expect(result.items.length, 20);
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('page 50 (offset 980) loads in <200ms', () async {
      final stopwatch = Stopwatch()..start();

      final result = await dataSource.getReservationsPaginated(
        limit: 20,
        offset: 980,
      );

      stopwatch.stop();

      expect(result.items.length, 20);
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    test('filtered query uses index (check EXPLAIN QUERY PLAN)', () async {
      final db = await dataSource._databaseHelper.database as Database;

      final plan = await db.rawQuery('''
        EXPLAIN QUERY PLAN
        SELECT * FROM reservations
        WHERE check_in >= '2025-01-01' AND platform_id = 'booking'
        ORDER BY check_in ASC
        LIMIT 20
      ''');

      // Verify index is used
      final planString = plan.toString();
      expect(planString, contains('INDEX'));
      expect(planString, contains('idx_reservations_checkin_platform'));
    });
  });
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Load all data into memory | SQL pagination (LIMIT/OFFSET) | Standard for 10+ years | 50-100x memory reduction, instant initial load |
| Dart-side filtering | SQL WHERE clauses | Standard for 10+ years | 10-50x performance improvement for filtered queries |
| No caching | 24h TTL cache with invalidation | Standard for 5+ years | Instant dashboard load for cached data |
| Single-column indexes | Composite indexes for multi-column queries | Standard for 10+ years | 5-10x query speedup for complex filters |
| Load all calendar data | Lazy load visible month + adjacent | Standard for 5+ years | 10-20x reduction in calendar data loaded |

**Deprecated/outdated:**
- Loading entire dataset into memory - unacceptable for 1000+ items
- Filtering in application code - database is optimized for this
- No caching for expensive calculations - wastes CPU and user time
- Debounce implementation in UI layer - belongs in business logic

## Open Questions

1. **Cursor-based vs OFFSET pagination**
   - What we know: OFFSET gets slow with large offsets (1000+)
   - What's unclear: Whether we'll ever have >5000 reservations
   - Recommendation: Start with LIMIT/OFFSET (simpler, works well up to 2000 items). Migrate to cursor-based if needed.

2. **Cache storage location**
   - What we know: SharedPreferences is fast for small key-value data
   - What's unclear: Whether cache should be in SQLite table instead
   - Recommendation: Use SharedPreferences for cache (faster for simple lookups). SQLite table adds complexity without benefit for this use case.

3. **Debounce duration**
   - What we know: 300ms is standard for user interactions
   - What's unclear: Whether this is optimal for calendar swiping
   - Recommendation: Start with 300ms. Adjust based on testing - could go as low as 150ms for snappier feel.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK) |
| Config file | None - Flutter SDK built-in |
| Quick run command | `flutter test test/performance/` |
| Full suite command | `flutter test --coverage` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| PERF-01 | Paginated list loads 20 items | unit | `flutter test test/features/reservations/data/datasources/pagination_test.dart` | Wave 0 |
| PERF-01 | Infinite scroll triggers loadMore | widget | `flutter test test/features/reservations/presentation/widgets/infinite_scroll_test.dart` | Wave 0 |
| PERF-02 | Filters use SQL WHERE clauses | unit | `flutter test test/features/reservations/data/datasources/filter_test.dart` | Wave 0 |
| PERF-02 | Filters persist in SharedPreferences | unit | `flutter test test/features/reservations/presentation/providers/filter_persistence_test.dart` | Wave 0 |
| PERF-03 | Calendar loads only ±1 month | unit | `flutter test test/features/reservations/presentation/providers/calendar_lazy_loading_test.dart` | Wave 0 |
| PERF-03 | Calendar queries debounced | unit | `flutter test test/features/reservations/presentation/providers/calendar_debounce_test.dart` | Wave 0 |
| PERF-04 | Indexes exist on queried columns | integration | `flutter test test/performance/database_indexes_test.dart` | Wave 0 |
| PERF-04 | Queries use indexes (EXPLAIN) | integration | `flutter test test/performance/query_plan_test.dart` | Wave 0 |
| PERF-05 | Cache respects 24h TTL | unit | `flutter test test/core/services/statistics_cache_service_test.dart` | Wave 0 |
| PERF-05 | Cache invalidates on data change | integration | `flutter test test/integration/cache_invalidation_test.dart` | Wave 0 |
| TEST-10 | Performance test with 1000+ reservations | performance | `flutter test test/performance/pagination_performance_test.dart` | Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/features/reservations/data/datasources/` (data layer tests, ~5s)
- **Per wave merge:** `flutter test test/performance/` (performance tests, ~15s)
- **Phase gate:** Full performance test suite passing with 1000+ reservations, all queries <200ms

### Wave 0 Gaps
- [ ] `test/features/reservations/domain/value_objects/paginated_result_test.dart` — pagination result entity tests
- [ ] `test/features/reservations/domain/entities/reservation_filter_test.dart` — filter entity tests
- [ ] `test/features/reservations/data/datasources/pagination_test.dart` — data source pagination tests
- [ ] `test/features/reservations/data/datasources/filter_test.dart` — SQL filter tests
- [ ] `test/features/reservations/presentation/providers/paginated_reservations_provider_test.dart` — pagination provider tests
- [ ] `test/features/reservations/presentation/providers/statistics_cache_provider_test.dart` — cache provider tests
- [ ] `test/features/reservations/presentation/widgets/infinite_scroll_test.dart` — infinite scroll widget tests
- [ ] `test/features/reservations/presentation/widgets/filter_sheet_test.dart` — filter UI tests
- [ ] `test/features/reservations/presentation/providers/calendar_lazy_loading_test.dart` — calendar lazy loading tests
- [ ] `test/features/reservations/presentation/providers/calendar_debounce_test.dart` — calendar debounce tests
- [ ] `test/core/services/statistics_cache_service_test.dart` — cache service tests
- [ ] `test/performance/database_indexes_test.dart` — index verification tests
- [ ] `test/performance/query_plan_test.dart` — EXPLAIN QUERY PLAN tests
- [ ] `test/performance/pagination_performance_test.dart` — performance benchmarks with 1000+ reservations
- [ ] `test/performance/test_data_generator.dart` — synthetic data generation utility
- [ ] `test/integration/cache_invalidation_test.dart` — cache invalidation on data change

## Sources

### Primary (HIGH confidence)
- SQLite Documentation - LIMIT and OFFSET clauses - Official SQLite query syntax
- SQLite Query Planning - Index usage and optimization - Official SQLite optimization guide
- Flutter ListView.builder documentation - Infinite scroll patterns - Official Flutter widget catalog
- SharedPreferences API reference - Key-value storage - Official Flutter package documentation
- Flutter Performance Best Practices - Official Flutter documentation on performance optimization

### Secondary (MEDIUM confidence)
- SQL Pagination Best Practices - Established patterns for LIMIT/OFFSET pagination
- Debouncing and Throttling in Flutter - Timer-based debouncing patterns
- Flutter Riverpod AsyncValue - Async state management patterns
- SQLite Indexing Strategies - Composite indexes for multi-column queries

### Tertiary (LOW confidence)
- Cursor-based pagination alternatives - May be needed for very large datasets (>5000 items)
- Third-party caching packages - SharedPreferences sufficient for this use case

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - All packages already in use, SQL pagination is well-established pattern
- Architecture: HIGH - Riverpod StateNotifier pattern established, pagination and caching are straightforward extensions
- Performance: HIGH - LIMIT/OFFSET and SQL filtering are proven optimization techniques with predictable performance
- Pitfalls: HIGH - Common mistakes (no invalidation, large offsets) are well-documented

**Research date:** 2026-03-07
**Valid until:** 90 days - SQL optimization patterns are stable, Flutter patterns may evolve
