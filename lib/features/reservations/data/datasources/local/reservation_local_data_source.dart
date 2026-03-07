import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/core/database/database_schema.dart';
import 'package:app_prenotazioni/features/reservations/data/datasources/reservation_data_source.dart';
import 'package:app_prenotazioni/features/reservations/data/models/reservation_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/room_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/platform_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/guest_model.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite/sqflite.dart' show Sqflite;

/// Local data source implementation using SQLite.
class ReservationLocalDataSource implements ReservationDataSource {
  final DatabaseHelper _databaseHelper;

  ReservationLocalDataSource({
    required DatabaseHelper databaseHelper,
  }) : _databaseHelper = databaseHelper;

  @override
  Future<List<ReservationModel>> getAllReservations() async {
    final db = await _databaseHelper.database as Database;
    final maps = await db.query(
      DatabaseSchema.tableReservations,
      orderBy: '${DatabaseSchema.reservationCreatedAt} DESC',
    );

    return maps.map((map) => _mapToReservationModel(map)).toList();
  }

  @override
  Future<ReservationModel?> getReservationById(String id) async {
    final db = await _databaseHelper.database as Database;
    final maps = await db.query(
      DatabaseSchema.tableReservations,
      where: '${DatabaseSchema.reservationId} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _mapToReservationModel(maps.first);
  }

  @override
  Future<void> saveReservation(ReservationModel reservation) async {
    final db = await _databaseHelper.database as Database;
    await db.insert(
      DatabaseSchema.tableReservations,
      _reservationToMap(reservation),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteReservation(String id) async {
    final db = await _databaseHelper.database as Database;
    await db.delete(
      DatabaseSchema.tableReservations,
      where: '${DatabaseSchema.reservationId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<ReservationModel>> getReservationsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _databaseHelper.database as Database;
    final maps = await db.query(
      DatabaseSchema.tableReservations,
      where: '''
        ${DatabaseSchema.reservationCheckIn} <= ? AND
        ${DatabaseSchema.reservationCheckOut} >= ?
      ''',
      whereArgs: [end.toIso8601String(), start.toIso8601String()],
      orderBy: '${DatabaseSchema.reservationCheckIn} ASC',
    );

    return maps.map((map) => _mapToReservationModel(map)).toList();
  }

  @override
  Future<List<RoomModel>> getAllRooms() async {
    final db = await _databaseHelper.database as Database;
    final maps = await db.query(DatabaseSchema.tableRooms);

    return maps.map((map) => RoomModel(
      id: map[DatabaseSchema.roomId] as String,
      name: map[DatabaseSchema.roomName] as String,
      type: map[DatabaseSchema.roomType] as String,
      createdAt: DateTime.parse(map[DatabaseSchema.roomCreatedAt] as String),
    )).toList();
  }

  @override
  Future<List<PlatformModel>> getAllPlatforms() async {
    final db = await _databaseHelper.database as Database;
    final maps = await db.query(DatabaseSchema.tablePlatforms);

    return maps.map((map) => PlatformModel(
      id: map[DatabaseSchema.platformId] as String,
      name: map[DatabaseSchema.platformName] as String,
      colorValue: map[DatabaseSchema.platformColorValue] as int,
      isDefault: map[DatabaseSchema.platformIsDefault] == 1,
      createdAt: DateTime.parse(map[DatabaseSchema.platformCreatedAt] as String),
    )).toList();
  }

  @override
  Future<void> insertReservationsBatch(List<ReservationModel> reservations) async {
    final db = await _databaseHelper.database as Database;
    final batch = db.batch();
    for (final reservation in reservations) {
      batch.insert(
        DatabaseSchema.tableReservations,
        _reservationToMap(reservation),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<ReservationModel>> getReservationsPaginated(int limit, int offset) async {
    final db = await _databaseHelper.database as Database;
    final maps = await db.rawQuery(
      'SELECT * FROM ${DatabaseSchema.tableReservations} '
      'ORDER BY ${DatabaseSchema.reservationCreatedAt} DESC '
      'LIMIT ? OFFSET ?',
      [limit, offset],
    );
    return maps.map((map) => _mapToReservationModel(map)).toList();
  }

  @override
  Future<int> getTotalReservationsCount() async {
    final db = await _databaseHelper.database as Database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseSchema.tableReservations}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Maps a database row to ReservationModel.
  ReservationModel _mapToReservationModel(Map<String, dynamic> map) {
    return ReservationModel(
      id: map[DatabaseSchema.reservationId] as String,
      roomId: map[DatabaseSchema.reservationRoomId] as String,
      platformId: map[DatabaseSchema.reservationPlatformId] as String,
      guest: GuestModel(
        name: map[DatabaseSchema.reservationGuestName] as String,
        phone: map[DatabaseSchema.reservationGuestPhone] as String?,
      ),
      checkIn: DateTime.parse(map[DatabaseSchema.reservationCheckIn] as String),
      checkOut: DateTime.parse(map[DatabaseSchema.reservationCheckOut] as String),
      amount: map[DatabaseSchema.reservationAmount] as double?,
      paymentStatus: map[DatabaseSchema.reservationPaymentStatus] != null
          ? PaymentStatus.values.firstWhere(
              (e) => e.name == map[DatabaseSchema.reservationPaymentStatus],
              orElse: () => PaymentStatus.pending,
            )
          : PaymentStatus.pending,
      notes: map[DatabaseSchema.reservationNotes] as String?,
      createdAt: DateTime.parse(map[DatabaseSchema.reservationCreatedAt] as String),
      updatedAt: DateTime.parse(map[DatabaseSchema.reservationUpdatedAt] as String),
    );
  }

  /// Maps ReservationModel to database row.
  Map<String, dynamic> _reservationToMap(ReservationModel reservation) {
    return {
      DatabaseSchema.reservationId: reservation.id,
      DatabaseSchema.reservationRoomId: reservation.roomId,
      DatabaseSchema.reservationPlatformId: reservation.platformId,
      DatabaseSchema.reservationGuestName: reservation.guest.name,
      DatabaseSchema.reservationGuestPhone: reservation.guest.phone,
      DatabaseSchema.reservationCheckIn: reservation.checkIn.toIso8601String(),
      DatabaseSchema.reservationCheckOut: reservation.checkOut.toIso8601String(),
      DatabaseSchema.reservationAmount: reservation.amount,
      DatabaseSchema.reservationPaymentStatus: reservation.paymentStatus.name,
      DatabaseSchema.reservationNotes: reservation.notes,
      DatabaseSchema.reservationCreatedAt: reservation.createdAt.toIso8601String(),
      DatabaseSchema.reservationUpdatedAt: reservation.updatedAt.toIso8601String(),
    };
  }
}
