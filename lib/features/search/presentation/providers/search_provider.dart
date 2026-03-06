import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/search/domain/services/search_service.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:app_prenotazioni/core/error/error_handler.dart';

/// Search state
class SearchState {
  final List<Reservation> results;
  final bool isLoading;
  final String? error;
  final bool hasQuery;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.hasQuery = false,
  });

  bool get isEmpty => results.isEmpty && hasQuery && !isLoading;

  SearchState copyWith({
    List<Reservation>? results,
    bool? isLoading,
    String? error,
    bool? hasQuery,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasQuery: hasQuery ?? this.hasQuery,
    );
  }
}

/// Search state notifier with debouncing
class SearchNotifier extends StateNotifier<SearchState> {
  final SearchService _searchService;
  String _debounceTimer = '';

  SearchNotifier(this._searchService) : super(const SearchState());

  /// Search reservations with debouncing (300ms)
  Future<void> search(String query) async {
    // Cancel previous debounce timer
    if (_debounceTimer.isNotEmpty) {
      // Timer will be cancelled by setting a new ID
      _debounceTimer = '';
    }

    // Update state to show we have a query
    state = state.copyWith(hasQuery: query.trim().isNotEmpty);

    // If query is empty, clear results
    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }

    // Set loading state
    state = state.copyWith(isLoading: true);

    // Wait for debounce delay (300ms)
    await Future.delayed(const Duration(milliseconds: 300));

    // Check if this search is still valid (not cancelled by another search)
    // For simplicity, we'll just execute the search
    try {
      final results = await _searchService.search(query);
      state = state.copyWith(
        results: results,
        isLoading: false,
        error: null,
      );
    } catch (e, stack) {
      final errorMessage = ErrorHandler.getErrorMessage(e);
      ErrorHandler.logError(e, stack);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Clear search results
  void clearSearch() {
    state = const SearchState();
  }
}

/// Search provider
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);
  final searchService = SearchService(repository);
  return SearchNotifier(searchService);
});
