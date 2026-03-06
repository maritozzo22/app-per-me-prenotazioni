import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/calendar_service.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';

/// Calendar state
class CalendarState {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<Reservation>> reservationsByDate;
  final bool isLoading;
  final String? error;

  const CalendarState({
    required this.focusedDay,
    this.selectedDay,
    required this.reservationsByDate,
    this.isLoading = false,
    this.error,
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    Map<DateTime, List<Reservation>>? reservationsByDate,
    bool? isLoading,
    String? error,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      reservationsByDate: reservationsByDate ?? this.reservationsByDate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarState &&
        other.focusedDay == focusedDay &&
        other.selectedDay == selectedDay &&
        other.isLoading == isLoading &&
        other.error == error &&
        _mapEquals(other.reservationsByDate, reservationsByDate);
  }

  @override
  int get hashCode => Object.hash(focusedDay, selectedDay, isLoading, error);

  bool _mapEquals(Map<dynamic, dynamic> a, Map<dynamic, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final aList = a[key] as List;
      final bList = b[key] as List;
      if (aList.length != bList.length) return false;
    }
    return true;
  }
}

/// State notifier for calendar
class CalendarNotifier extends StateNotifier<CalendarState> {
  final ReservationRepository _repository;
  final CalendarService _calendarService;

  CalendarNotifier(this._repository)
      : _calendarService = CalendarService(),
        super(CalendarState(
              focusedDay: DateTime.now(),
              selectedDay: null,
              reservationsByDate: {},
              isLoading: true,
            )) {
    loadReservations();
  }

  /// Load all reservations and group them by date
  Future<void> loadReservations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reservations = await _repository.getAllReservations();
      final reservationsByDate = _calendarService.groupReservationsByDate(reservations);
      state = state.copyWith(
        reservationsByDate: reservationsByDate,
        isLoading: false,
      );
    } catch (e, stack) {
      // Log error for debugging
      print('Error loading reservations: $e');
      print('Stack trace: $stack');

      // Set error state with user-friendly message
      state = state.copyWith(
        isLoading: false,
        error: 'Impossibile caricare le prenotazioni. Riprova.',
      );
    }
  }

  /// Retry loading reservations
  Future<void> retry() async {
    await loadReservations();
  }

  /// Select a specific day
  void selectDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  /// Change the focused month
  void changeMonth(DateTime focusedDay) {
    state = state.copyWith(focusedDay: focusedDay);
  }

  /// Refresh reservations (call after create/update/delete)
  Future<void> refresh() async {
    await loadReservations();
  }
}

/// Calendar provider
final calendarProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);
  return CalendarNotifier(repository);
});
