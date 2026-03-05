import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';

/// Platform state
class PlatformState {
  final List<BookingPlatform> platforms;
  final bool isLoading;
  final String? error;

  const PlatformState({
    this.platforms = const [],
    this.isLoading = false,
    this.error,
  });

  PlatformState copyWith({
    List<BookingPlatform>? platforms,
    bool? isLoading,
    String? error,
  }) {
    return PlatformState(
      platforms: platforms ?? this.platforms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Platform state notifier
class PlatformNotifier extends StateNotifier<PlatformState> {
  final ReservationRepository _repository;

  PlatformNotifier(this._repository) : super(const PlatformState()) {
    loadPlatforms();
  }

  /// Load all platforms
  Future<void> loadPlatforms() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final platforms = await _repository.getAllPlatforms();
      state = state.copyWith(platforms: platforms, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add a new platform
  Future<void> addPlatform(BookingPlatform platform) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // For now, we'll just reload the list
      // In a full implementation, we'd have a dedicated platform repository
      await loadPlatforms();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update an existing platform
  Future<void> updatePlatform(BookingPlatform platform) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // For now, we'll just reload the list
      // In a full implementation, we'd have a dedicated platform repository
      await loadPlatforms();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Delete a platform
  Future<void> deletePlatform(String platformId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // For now, we'll just reload the list
      // In a full implementation, we'd have a dedicated platform repository
      await loadPlatforms();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// Platform provider
final platformProvider = StateNotifierProvider<PlatformNotifier, PlatformState>((ref) {
  // This will need to be provided from the app
  throw UnimplementedError('PlatformProvider not implemented');
});
