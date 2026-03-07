import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/dashboard_statistics_service.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:app_prenotazioni/features/statistics/domain/services/statistics_cache_service.dart';
import 'package:app_prenotazioni/features/statistics/data/services/statistics_cache_service_impl.dart';
import 'package:app_prenotazioni/core/error/error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for StatisticsCacheService.
final statisticsCacheServiceProvider = Provider<StatisticsCacheService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StatisticsCacheServiceImpl(prefs);
});

/// Dashboard state
class DashboardState {
  final DashboardStatistics? statistics;
  final Map<String, Reservation?> roomOccupancy;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.statistics,
    this.roomOccupancy = const {},
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    DashboardStatistics? statistics,
    Map<String, Reservation?>? roomOccupancy,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      statistics: statistics ?? this.statistics,
      roomOccupancy: roomOccupancy ?? this.roomOccupancy,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// State notifier for dashboard
class DashboardNotifier extends StateNotifier<DashboardState> {
  final ReservationRepository _repository;
  final DashboardStatisticsService _statisticsService;
  final StatisticsCacheService _cacheService;

  DashboardNotifier(this._repository, this._cacheService)
      : _statisticsService = DashboardStatisticsService(),
        super(const DashboardState()) {
    loadDashboard();
  }

  /// Load dashboard statistics (from cache if valid)
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Try to load from cache first
      final cachedStats = await _cacheService.getCachedStatistics();

      if (cachedStats != null) {
        // Use cached statistics
        final reservations = await _repository.getAllReservations();
        final now = DateTime.now();
        final roomOccupancy = _statisticsService.getRoomOccupancyToday(
          reservations: reservations,
          currentDate: now,
        );

        state = state.copyWith(
          statistics: cachedStats,
          roomOccupancy: roomOccupancy,
          isLoading: false,
        );
        return;
      }

      // Cache miss or expired - recalculate
      await _recalculateAndCache();
    } catch (e, stack) {
      final errorMessage = ErrorHandler.getErrorMessage(e);
      ErrorHandler.logError(e, stack);
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> _recalculateAndCache() async {
    final reservations = await _repository.getAllReservations();
    final now = DateTime.now();

    final statistics = _statisticsService.calculate(
      reservations: reservations,
      currentDate: now,
    );

    final roomOccupancy = _statisticsService.getRoomOccupancyToday(
      reservations: reservations,
      currentDate: now,
    );

    // Cache the statistics for future loads
    await _cacheService.setCachedStatistics(statistics);

    state = state.copyWith(
      statistics: statistics,
      roomOccupancy: roomOccupancy,
      isLoading: false,
    );
  }

  /// Refresh dashboard data (invalidate cache and recalculate)
  Future<void> refresh() async {
    await _cacheService.invalidateCache();
    await loadDashboard();
  }
}

/// Dashboard provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);
  final cacheService = ref.watch(statisticsCacheServiceProvider);
  return DashboardNotifier(repository, cacheService);
});
