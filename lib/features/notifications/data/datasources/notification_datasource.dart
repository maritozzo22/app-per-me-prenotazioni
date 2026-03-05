import 'package:sqflite/sqflite.dart';
import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/core/database/database_schema.dart';
import 'package:app_prenotazioni/features/notifications/data/models/notification_schedule_model.dart';

/// Data source for notification schedules that handles database operations.
///
/// This class provides methods to create, read, update, and delete
/// notification schedules in the database.
class NotificationDatasource {
  final DatabaseHelper _databaseHelper;

  NotificationDatasource(this._databaseHelper);

  /// Creates a new notification schedule in the database.
  ///
  /// Returns the created [NotificationScheduleModel].
  /// Throws [Exception] if the operation fails.
  Future<NotificationScheduleModel> create(NotificationScheduleModel model) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseSchema.tableNotificationSchedules,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return model;
  }

  /// Creates multiple notification schedules in a single transaction.
  ///
  /// Returns all created [NotificationScheduleModel] objects.
  /// Throws [Exception] if the operation fails.
  Future<List<NotificationScheduleModel>> createAll(List<NotificationScheduleModel> models) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();

    for (final model in models) {
      batch.insert(
        DatabaseSchema.tableNotificationSchedules,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    return models;
  }

  /// Gets a notification schedule by its ID.
  ///
  /// Returns the [NotificationScheduleModel] if found, null otherwise.
  Future<NotificationScheduleModel?> getById(String id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseSchema.tableNotificationSchedules,
      where: '${DatabaseSchema.notificationScheduleId} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return NotificationScheduleModel.fromMap(maps.first);
  }

  /// Gets all notification schedules for a specific reservation.
  ///
  /// Returns a list of [NotificationScheduleModel] objects.
  Future<List<NotificationScheduleModel>> getByReservationId(String reservationId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseSchema.tableNotificationSchedules,
      where: '${DatabaseSchema.notificationScheduleReservationId} = ?',
      whereArgs: [reservationId],
      orderBy: '${DatabaseSchema.notificationScheduleScheduledDate} ASC',
    );

    return maps.map((map) => NotificationScheduleModel.fromMap(map)).toList();
  }

  /// Gets all notification schedules that have not been sent yet.
  ///
  /// Returns a list of [NotificationScheduleModel] objects.
  Future<List<NotificationScheduleModel>> getUnsent() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseSchema.tableNotificationSchedules,
      where: '${DatabaseSchema.notificationScheduleIsSent} = ?',
      whereArgs: [0],
      orderBy: '${DatabaseSchema.notificationScheduleScheduledDate} ASC',
    );

    return maps.map((map) => NotificationScheduleModel.fromMap(map)).toList();
  }

  /// Gets all notification schedules scheduled for a specific date range.
  ///
  /// Returns a list of [NotificationScheduleModel] objects.
  Future<List<NotificationScheduleModel>> getByDateRange(DateTime start, DateTime end) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseSchema.tableNotificationSchedules,
      where: '${DatabaseSchema.notificationScheduleScheduledDate} BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: '${DatabaseSchema.notificationScheduleScheduledDate} ASC',
    );

    return maps.map((map) => NotificationScheduleModel.fromMap(map)).toList();
  }

  /// Updates a notification schedule in the database.
  ///
  /// Returns the number of rows affected (1 if successful, 0 otherwise).
  Future<int> update(NotificationScheduleModel model) async {
    final db = await _databaseHelper.database;
    return await db.update(
      DatabaseSchema.tableNotificationSchedules,
      model.toMap(),
      where: '${DatabaseSchema.notificationScheduleId} = ?',
      whereArgs: [model.id],
    );
  }

  /// Marks a notification schedule as sent.
  ///
  /// Returns the number of rows affected (1 if successful, 0 otherwise).
  Future<int> markAsSent(String id) async {
    final db = await _databaseHelper.database;
    return await db.update(
      DatabaseSchema.tableNotificationSchedules,
      {DatabaseSchema.notificationScheduleIsSent: 1},
      where: '${DatabaseSchema.notificationScheduleId} = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a notification schedule from the database.
  ///
  /// Returns the number of rows affected (1 if successful, 0 otherwise).
  Future<int> delete(String id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseSchema.tableNotificationSchedules,
      where: '${DatabaseSchema.notificationScheduleId} = ?',
      whereArgs: [id],
    );
  }

  /// Deletes all notification schedules for a specific reservation.
  ///
  /// Returns the number of rows affected.
  Future<int> deleteByReservationId(String reservationId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseSchema.tableNotificationSchedules,
      where: '${DatabaseSchema.notificationScheduleReservationId} = ?',
      whereArgs: [reservationId],
    );
  }

  /// Gets all notification schedules.
  ///
  /// Returns a list of all [NotificationScheduleModel] objects.
  Future<List<NotificationScheduleModel>> getAll() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseSchema.tableNotificationSchedules,
      orderBy: '${DatabaseSchema.notificationScheduleScheduledDate} ASC',
    );

    return maps.map((map) => NotificationScheduleModel.fromMap(map)).toList();
  }

  /// Counts all unsent notification schedules.
  ///
  /// Returns the count of unsent notifications.
  Future<int> countUnsent() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM ${DatabaseSchema.tableNotificationSchedules}
      WHERE ${DatabaseSchema.notificationScheduleIsSent} = 0
    ''');

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
