/// Database schema definitions and constants.
class DatabaseSchema {
  DatabaseSchema._();

  static const String name = 'reservations.db';
  static const int version = 6;

  // Table names
  static const String tableRooms = 'rooms';
  static const String tablePlatforms = 'platforms';
  static const String tableReservations = 'reservations';
  static const String tableNotificationSchedules = 'notification_schedules';

  // Room columns
  static const String roomId = 'id';
  static const String roomName = 'name';
  static const String roomType = 'type';
  static const String roomCreatedAt = 'created_at';

  // Platform columns
  static const String platformId = 'id';
  static const String platformName = 'name';
  static const String platformColorValue = 'color_value';
  static const String platformIsDefault = 'is_default';
  static const String platformIsSystem = 'is_system';
  static const String platformCreatedAt = 'created_at';

  // Reservation columns
  static const String reservationId = 'id';
  static const String reservationRoomId = 'room_id';
  static const String reservationPlatformId = 'platform_id';
  static const String reservationGuestName = 'guest_name';
  static const String reservationGuestPhone = 'guest_phone';
  static const String reservationCheckIn = 'check_in';
  static const String reservationCheckOut = 'check_out';
  static const String reservationAmount = 'amount';
  static const String reservationPaymentStatus = 'payment_status';
  static const String reservationNotes = 'notes';
  static const String reservationCreatedAt = 'created_at';
  static const String reservationUpdatedAt = 'updated_at';

  // Notification schedule columns
  static const String notificationScheduleId = 'id';
  static const String notificationScheduleReservationId = 'reservation_id';
  static const String notificationScheduleType = 'notification_type';
  static const String notificationScheduleScheduledDate = 'scheduled_date';
  static const String notificationScheduleIsSent = 'is_sent';
  static const String notificationScheduleCreatedAt = 'created_at';

  /// SQL to create rooms table.
  static const String createRoomsTable = '''
    CREATE TABLE $tableRooms (
      $roomId TEXT PRIMARY KEY,
      $roomName TEXT NOT NULL,
      $roomType TEXT NOT NULL,
      $roomCreatedAt TEXT NOT NULL
    )
  ''';

  /// SQL to create platforms table.
  static const String createPlatformsTable = '''
    CREATE TABLE $tablePlatforms (
      $platformId TEXT PRIMARY KEY,
      $platformName TEXT NOT NULL,
      $platformColorValue INTEGER NOT NULL,
      $platformIsDefault INTEGER NOT NULL DEFAULT 0,
      $platformIsSystem INTEGER NOT NULL DEFAULT 0,
      $platformCreatedAt TEXT NOT NULL
    )
  ''';

  /// SQL to create reservations table.
  static const String createReservationsTable = '''
    CREATE TABLE $tableReservations (
      $reservationId TEXT PRIMARY KEY,
      $reservationRoomId TEXT NOT NULL,
      $reservationPlatformId TEXT NOT NULL,
      $reservationGuestName TEXT NOT NULL,
      $reservationGuestPhone TEXT,
      $reservationCheckIn TEXT NOT NULL,
      $reservationCheckOut TEXT NOT NULL,
      $reservationAmount REAL,
      $reservationPaymentStatus TEXT NOT NULL DEFAULT 'pending',
      $reservationNotes TEXT,
      $reservationCreatedAt TEXT NOT NULL,
      $reservationUpdatedAt TEXT NOT NULL,
      FOREIGN KEY ($reservationRoomId) REFERENCES $tableRooms ($roomId),
      FOREIGN KEY ($reservationPlatformId) REFERENCES $tablePlatforms ($platformId)
    )
  ''';

  /// Migration to add payment_status column (version 1 -> 2).
  static const String migrationV1ToV2 = '''
    ALTER TABLE $tableReservations ADD COLUMN $reservationPaymentStatus TEXT NOT NULL DEFAULT 'pending';
  ''';

  /// Migration to add is_system column to platforms (version 2 -> 3).
  static const String migrationV2ToV3 = '''
    ALTER TABLE $tablePlatforms ADD COLUMN $platformIsSystem INTEGER NOT NULL DEFAULT 0;
  ''';

  /// Migration to mark default platforms as system platforms (version 2 -> 3).
  static const String migrationV2ToV3UpdateSystemPlatforms = '''
    UPDATE $tablePlatforms SET $platformIsSystem = 1 WHERE $platformId IN ('booking', 'airbnb', 'whatsapp', 'website', 'tiktok');
  ''';

  /// SQL to create notification_schedules table (version 3 -> 4).
  static const String createNotificationSchedulesTable = '''
    CREATE TABLE $tableNotificationSchedules (
      $notificationScheduleId TEXT PRIMARY KEY,
      $notificationScheduleReservationId TEXT NOT NULL,
      $notificationScheduleType TEXT NOT NULL,
      $notificationScheduleScheduledDate TEXT NOT NULL,
      $notificationScheduleIsSent INTEGER NOT NULL DEFAULT 0,
      $notificationScheduleCreatedAt TEXT NOT NULL,
      FOREIGN KEY ($notificationScheduleReservationId) REFERENCES $tableReservations ($reservationId) ON DELETE CASCADE
    )
  ''';

  /// SQL to create index on notification_schedules reservation_id (version 3 -> 4).
  static const String createNotificationSchedulesReservationIndex = '''
    CREATE INDEX idx_notification_schedules_reservation ON $tableNotificationSchedules ($notificationScheduleReservationId)
  ''';

  /// SQL to create index on notification_schedules scheduled_date (version 3 -> 4).
  static const String createNotificationSchedulesScheduledDateIndex = '''
    CREATE INDEX idx_notification_scheduled_date ON $tableNotificationSchedules ($notificationScheduleScheduledDate)
  ''';

  /// SQL to create index on notification_schedules is_sent (version 3 -> 4).
  static const String createNotificationSchedulesIsSentIndex = '''
    CREATE INDEX idx_notification_is_sent ON $tableNotificationSchedules ($notificationScheduleIsSent)
  ''';

  /// Migration to add performance indexes for reservations (version 4 -> 5).
  static const String migrationV4ToV5AddCheckInIndex =
      'CREATE INDEX IF NOT EXISTS idx_reservations_check_in ON $tableReservations ($reservationCheckIn)';

  static const String migrationV4ToV5AddCheckOutIndex =
      'CREATE INDEX IF NOT EXISTS idx_reservations_check_out ON $tableReservations ($reservationCheckOut)';

  static const String migrationV4ToV5AddCreatedAtIndex =
      'CREATE INDEX IF NOT EXISTS idx_reservations_created_at ON $tableReservations ($reservationCreatedAt DESC)';

  /// Migration to add additional performance indexes (version 5 -> 6).
  static const String migrationV5ToV6AddPlatformIndex =
      'CREATE INDEX IF NOT EXISTS idx_reservations_platform_id ON $tableReservations ($reservationPlatformId)';

  static const String migrationV5ToV6AddRoomIndex =
      'CREATE INDEX IF NOT EXISTS idx_reservations_room_id ON $tableReservations ($reservationRoomId)';

  static const String migrationV5ToV6AddDateRangeIndex =
      'CREATE INDEX IF NOT EXISTS idx_reservations_date_range ON $tableReservations ($reservationCheckIn, $reservationCheckOut)';
}
