import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_prenotazioni/features/statistics/domain/services/statistics_cache_service.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/dashboard_statistics_service.dart';

/// Implementation of StatisticsCacheService using SharedPreferences.
class StatisticsCacheServiceImpl implements StatisticsCacheService {
  final SharedPreferences _prefs;
  static const _statisticsKey = 'cached_statistics';
  static const _timestampKey = 'cached_statistics_timestamp';
  static const _cacheDuration = Duration(hours: 24);

  StatisticsCacheServiceImpl(this._prefs);

  @override
  Future<DashboardStatistics?> getCachedStatistics() async {
    if (!await isCacheValid()) return null;

    final jsonString = _prefs.getString(_statisticsKey);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return DashboardStatistics.fromJson(json);
    } catch (e) {
      // Invalid JSON, clear cache
      await invalidateCache();
      return null;
    }
  }

  @override
  Future<void> setCachedStatistics(DashboardStatistics statistics) async {
    final jsonString = jsonEncode(statistics.toJson());
    final timestamp = DateTime.now().toIso8601String();

    await _prefs.setString(_statisticsKey, jsonString);
    await _prefs.setString(_timestampKey, timestamp);
  }

  @override
  Future<void> invalidateCache() async {
    await _prefs.remove(_statisticsKey);
    await _prefs.remove(_timestampKey);
  }

  @override
  Future<bool> isCacheValid() async {
    final timestampString = _prefs.getString(_timestampKey);
    if (timestampString == null) return false;

    try {
      final timestamp = DateTime.parse(timestampString);
      final now = DateTime.now();
      final age = now.difference(timestamp);

      return age < _cacheDuration;
    } catch (e) {
      return false;
    }
  }
}
