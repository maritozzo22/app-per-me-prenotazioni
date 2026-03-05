/// Database schema definitions and constants.
class DatabaseSchema {
  DatabaseSchema._();

  static const String name = 'reservations.db';
  static const int version = 2;

  // Table names
  static const String tableRooms = 'rooms';
  static const String tablePlatforms = 'platforms';
  static const String tableReservations = 'reservations';

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
}
