import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/dashboard_statistics_service.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';

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

  DashboardNotifier(this._repository)
      : _statisticsService = DashboardStatisticsService(),
        super(const DashboardState()) {
    loadDashboard();
  }

  /// Load dashboard statistics and room occupancy
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reservations = await _repository.getAllReservations();
      final now = DateTime.now();

      // Calculate statistics
      final statistics = _statisticsService.calculate(
        reservations: reservations,
        currentDate: now,
      );

      // Calculate room occupancy for today
      final roomOccupancy = _statisticsService.getRoomOccupancyToday(
        reservations: reservations,
        currentDate: now,
      );

      state = state.copyWith(
        statistics: statistics,
        roomOccupancy: roomOccupancy,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh dashboard data (call after create/update/delete)
  Future<void> refresh() async {
    await loadDashboard();
  }
}

/// Dashboard provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);
  return DashboardNotifier(repository);
});
