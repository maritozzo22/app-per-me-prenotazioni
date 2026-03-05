import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/features/reservations/data/datasources/local/reservation_local_data_source.dart';
import 'package:app_prenotazioni/features/reservations/data/repositories/reservation_repository_impl.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';

/// Provider for DatabaseHelper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

/// Provider for ReservationLocalDataSource
final reservationDataSourceProvider = Provider<ReservationLocalDataSource>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return ReservationLocalDataSource(databaseHelper: databaseHelper);
});

/// Provider for ReservationRepository
final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final dataSource = ref.watch(reservationDataSourceProvider);
  return ReservationRepositoryImpl(dataSource: dataSource);
});
