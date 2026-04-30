import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/statistics_filter.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/aggregate_statistics.dart';
import 'package:app_prenotazioni/core/providers/statistics_providers.dart';

/// Filter state for statistics queries.
///
/// This provider holds the current filter settings that determine
/// which statistics are displayed.
final statisticsFilterProvider = StateProvider<StatisticsFilter>((ref) {
  return const StatisticsFilter();
});

/// Statistics data state with async loading.
///
/// Uses AsyncNotifier pattern for built-in loading/error states.
/// Integrates with cache service for instant repeat loads.
final statisticsProvider =
    AsyncNotifierProvider<StatisticsNotifier, AggregateStatistics?>(
  StatisticsNotifier.new,
);

/// Notifier for managing statistics state.
class StatisticsNotifier extends AsyncNotifier<AggregateStatistics?> {
  @override
  Future<AggregateStatistics?> build() async {
    final filter = ref.read(statisticsFilterProvider);
    final repository = ref.read(statisticsRepositoryProvider);

    // Fetch statistics from repository
    // Cache integration is handled via the existing StatisticsCacheService
    // in the repository layer
    return await repository.getStatistics(filter);
  }

  /// Refresh statistics data (invalidates cache and fetches fresh data).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final filter = ref.read(statisticsFilterProvider);
      final repository = ref.read(statisticsRepositoryProvider);
      final cacheService = ref.read(statisticsCacheServiceProvider);

      // Invalidate cache before fetching fresh data
      await cacheService.invalidateCache();

      // Fetch fresh data
      return repository.getStatistics(filter);
    });
  }

  /// Update filter and reload statistics.
  Future<void> updateFilter(StatisticsFilter newFilter) async {
    // Update the filter
    ref.read(statisticsFilterProvider.notifier).state = newFilter;

    // Trigger refresh with new filter
    await refresh();
  }
}
