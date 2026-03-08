import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:app_prenotazioni/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:app_prenotazioni/features/statistics/domain/services/statistics_cache_service.dart';
import 'package:app_prenotazioni/features/statistics/data/services/statistics_cache_service_impl.dart';
import 'package:app_prenotazioni/core/providers/shared_preferences_provider.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/dashboard_statistics_service.dart';

/// Provider for DatabaseHelper instance.
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

/// Repository provider for statistics data access.
final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepositoryImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  );
});

/// Cache service provider for statistics.
///
/// Note: This uses the existing StatisticsCacheService from Phase 9,
/// which caches DashboardStatistics. For AggregateStatistics caching,
/// the provider handles it internally.
final statisticsCacheServiceProvider = Provider<StatisticsCacheService>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);

  return prefsAsync.when(
    data: (prefs) => StatisticsCacheServiceImpl(prefs),
    loading: () => _NullStatisticsCacheService(),
    error: (_, __) => _NullStatisticsCacheService(),
  );
});

/// Null object pattern for cache service when SharedPreferences is not ready.
class _NullStatisticsCacheService implements StatisticsCacheService {
  @override
  Future<DashboardStatistics?> getCachedStatistics() async => null;

  @override
  Future<void> setCachedStatistics(DashboardStatistics statistics) async {}

  @override
  Future<void> invalidateCache() async {}

  @override
  Future<bool> isCacheValid() async => false;
}
