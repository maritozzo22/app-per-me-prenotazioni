import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation_filter.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/core/error/error_handler.dart';
import 'reservation_provider.dart';

/// State for reservation list with infinite scroll.
class ReservationListState {
  final List<Reservation> reservations;
  final ReservationFilter activeFilter;
  final int currentPage;
  final int totalCount;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  const ReservationListState({
    this.reservations = const [],
    this.activeFilter = const ReservationFilter(),
    this.currentPage = 0,
    this.totalCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  /// Returns true if there are more pages available.
  bool get hasMore => reservations.length < totalCount;

  /// Creates a copy with optionally updated fields.
  ReservationListState copyWith({
    List<Reservation>? reservations,
    ReservationFilter? activeFilter,
    int? currentPage,
    int? totalCount,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return ReservationListState(
      reservations: reservations ?? this.reservations,
      activeFilter: activeFilter ?? this.activeFilter,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }
}

/// Notifier for managing reservation list with infinite scroll and filtering.
class ReservationListNotifier extends StateNotifier<ReservationListState> {
  final ReservationRepository _repository;
  final SharedPreferences _prefs;
  static const _pageSize = 20;
  static const _filterKey = 'reservation_filter';

  ReservationListNotifier(this._repository, this._prefs)
      : super(const ReservationListState()) {
    _loadSavedFilter();
  }

  /// Loads saved filter from SharedPreferences.
  Future<void> _loadSavedFilter() async {
    final filterJson = _prefs.getString(_filterKey);
    if (filterJson != null) {
      try {
        final filterMap = jsonDecode(filterJson) as Map<String, dynamic>;
        state = state.copyWith(
          activeFilter: ReservationFilter.fromMap(filterMap),
        );
      } catch (e) {
        // Invalid filter data, ignore
      }
    }
  }

  /// Saves filter to SharedPreferences.
  Future<void> _saveFilter(ReservationFilter filter) async {
    final filterJson = jsonEncode(filter.toMap());
    await _prefs.setString(_filterKey, filterJson);
  }

  /// Loads initial page (page 1) with current filter.
  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.getReservationsFiltered(
        filter: state.activeFilter,
        page: 1,
        pageSize: _pageSize,
      );
      state = state.copyWith(
        reservations: result.items,
        currentPage: 1,
        totalCount: result.totalCount,
        isLoading: false,
      );
    } catch (e, stack) {
      ErrorHandler.logError(e, stack);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Loads next page and appends to existing list.
  Future<void> loadMore() async {
    // Don't load if already loading or no more data
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final result = await _repository.getReservationsFiltered(
        filter: state.activeFilter,
        page: nextPage,
        pageSize: _pageSize,
      );
      state = state.copyWith(
        reservations: [...state.reservations, ...result.items],
        currentPage: nextPage,
        isLoadingMore: false,
      );
    } catch (e, stack) {
      ErrorHandler.logError(e, stack);
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Applies new filter and reloads from page 1.
  Future<void> applyFilter(ReservationFilter filter) async {
    await _saveFilter(filter);
    state = state.copyWith(
      activeFilter: filter,
      reservations: [],
      currentPage: 0,
    );
    await loadInitial();
  }

  /// Clears all filters and reloads.
  Future<void> clearFilter() async {
    await applyFilter(const ReservationFilter());
  }
}

/// Provider for reservation list with infinite scroll and filtering.
final reservationListProvider =
    StateNotifierProvider<ReservationListNotifier, ReservationListState>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return ReservationListNotifier(repository, prefs);
});
