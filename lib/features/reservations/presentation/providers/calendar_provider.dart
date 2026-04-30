import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/calendar_service.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:app_prenotazioni/core/error/error_handler.dart';
import 'package:app_prenotazioni/core/utils/debouncer.dart';

/// Calendar state
class CalendarState {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<Reservation>> reservationsByDate;
  final Set<DateTime> loadedMonths;
  final bool isLoading;
  final String? error;

  const CalendarState({
    required this.focusedDay,
    this.selectedDay,
    required this.reservationsByDate,
    this.loadedMonths = const {},
    this.isLoading = false,
    this.error,
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    Map<DateTime, List<Reservation>>? reservationsByDate,
    Set<DateTime>? loadedMonths,
    bool? isLoading,
    String? error,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      reservationsByDate: reservationsByDate ?? this.reservationsByDate,
      loadedMonths: loadedMonths ?? this.loadedMonths,
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
        _mapEquals(other.reservationsByDate, reservationsByDate) &&
        _setEquals(other.loadedMonths, loadedMonths);
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

  bool _setEquals(Set<dynamic> a, Set<dynamic> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}

/// State notifier for calendar
class CalendarNotifier extends StateNotifier<CalendarState> {
  final ReservationRepository _repository;
  final CalendarService _calendarService;
  final Debouncer _loadDebouncer = Debouncer(delay: Duration(milliseconds: 300));

  CalendarNotifier(this._repository)
      : _calendarService = CalendarService(),
        super(CalendarState(
          focusedDay: DateTime.now(),
          selectedDay: null,
          reservationsByDate: {},
          loadedMonths: {},
          isLoading: true,
        )) {
    _loadInitialMonthRange();
  }

  /// Load initial month range (current month + 1 before + 1 after)
  Future<void> _loadInitialMonthRange() async {
    final focusedMonth = DateTime(state.focusedDay.year, state.focusedDay.month);
    await _loadMonthRange(focusedMonth);
  }

  /// Load reservations for a month range (centerMonth ± 1 month)
  Future<void> _loadMonthRange(DateTime centerMonth) async {
    // Load centerMonth + 1 month before + 1 month after
    final start = DateTime(centerMonth.year, centerMonth.month - 1, 1);
    final end = DateTime(centerMonth.year, centerMonth.month + 2, 0); // Last day of month after next

    state = state.copyWith(isLoading: true, error: null);
    try {
      final reservations = await _repository.getReservationsForDateRange(start, end);
      final newReservationsByDate = _calendarService.groupReservationsByDate(reservations);

      // Merge with existing reservations (keep other months)
      final mergedReservations = Map<DateTime, List<Reservation>>.from(state.reservationsByDate);
      mergedReservations.addAll(newReservationsByDate);

      // Track loaded months
      final newLoadedMonths = Set<DateTime>.from(state.loadedMonths)
        ..add(DateTime(centerMonth.year, centerMonth.month - 1))
        ..add(centerMonth)
        ..add(DateTime(centerMonth.year, centerMonth.month + 1));

      state = state.copyWith(
        reservationsByDate: mergedReservations,
        loadedMonths: newLoadedMonths,
        isLoading: false,
      );
    } catch (e, stack) {
      final errorMessage = ErrorHandler.getErrorMessage(e);
      ErrorHandler.logError(e, stack);
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  /// Load all reservations and group them by date (legacy method for compatibility)
  Future<void> loadReservations() async {
    await _loadInitialMonthRange();
  }

  /// Retry loading reservations
  Future<void> retry() async {
    await _loadInitialMonthRange();
  }

  /// Select a day
  void selectDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  /// Change the focused month (with lazy loading)
  void changeMonth(DateTime focusedDay) {
    state = state.copyWith(focusedDay: focusedDay);

    final newMonth = DateTime(focusedDay.year, focusedDay.month);

    // Check if month is already loaded
    if (!state.loadedMonths.contains(newMonth)) {
      // Debounce the load to prevent rapid-fire queries during swipe
      _loadDebouncer(() {
        _loadMonthRange(newMonth);
      });
    }
  }

  /// Refresh reservations (clear cache and reload)
  Future<void> refresh() async {
    // Clear loaded months and reload current range
    state = state.copyWith(loadedMonths: {}, reservationsByDate: {});
    await _loadInitialMonthRange();
  }

  @override
  void dispose() {
    _loadDebouncer.dispose();
    super.dispose();
  }
}

/// Calendar provider
final calendarProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);
  return CalendarNotifier(repository);
});
