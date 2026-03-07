import 'package:app_prenotazioni/features/reservations/domain/services/dashboard_statistics_service.dart';

/// Service for caching dashboard statistics.
abstract class StatisticsCacheService {
  /// Get cached statistics if valid (within TTL).
  Future<DashboardStatistics?> getCachedStatistics();

  /// Cache statistics with current timestamp.
  Future<void> setCachedStatistics(DashboardStatistics statistics);

  /// Invalidate cache (clear stored data).
  Future<void> invalidateCache();

  /// Check if cache is valid (within 24h TTL).
  Future<bool> isCacheValid();
}
