import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/features/reservations/data/datasources/local/reservation_local_data_source.dart';
import 'package:app_prenotazioni/features/reservations/data/repositories/reservation_repository_impl.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/statistics/domain/services/statistics_cache_service.dart';
import 'package:app_prenotazioni/features/statistics/data/services/statistics_cache_service_impl.dart';

/// Provider for DatabaseHelper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

/// Provider for ReservationLocalDataSource
final reservationDataSourceProvider = Provider<ReservationLocalDataSource>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return ReservationLocalDataSource(databaseHelper: databaseHelper);
});

/// Provider for StatisticsCacheService (for reservation repository cache invalidation)
final _reservationCacheServiceProvider = Provider<StatisticsCacheService>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return StatisticsCacheServiceImpl(prefsAsync);
});

/// Provider for ReservationRepository
///
/// Includes cache invalidation for statistics when reservations are modified.
final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final dataSource = ref.watch(reservationDataSourceProvider);
  final cacheService = ref.watch(_reservationCacheServiceProvider);
  return ReservationRepositoryImpl(
    dataSource: dataSource,
    cacheService: cacheService,
  );
});

/// Provider for SharedPreferences
///
/// Must be overridden in main.dart with actual SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main.dart with SharedPreferences instance');
});
