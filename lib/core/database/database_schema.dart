/// Database schema definitions and constants.
class DatabaseSchema {
  DatabaseSchema._();

  static const String name = 'reservations.db';
  static const int version = 8;

  // Table names
  static const String tableRooms = 'rooms';
  static const String tablePlatforms = 'platforms';
  static const String tableReservations = 'reservations';
  static const String tableNotificationSchedules = 'notification_schedules';
  static const String tableNotificationSettings = 'notification_settings';
  static const String tableNotificationLogs = 'notification_logs';
  static const String tableInventoryItems = 'inventory_items';
  static const String tableInventoryMovements = 'inventory_movements';

  // Inventory columns
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

  // Notification settings columns
  static const String notificationSettingsId = 'id';
  static const String notificationSettingsEnabled = 'enabled';
  static const String notificationSettingsDaysBefore = 'days_before';
  static const String notificationSettingsHour = 'notification_hour';
  static const String notificationSettingsMinute = 'notification_minute';
  static const String notificationSettingsUpdatedAt = 'updated_at';

  // Notification log columns
  static const String notificationLogId = 'id';
  static const String notificationLogReservationId = 'reservation_id';
  static const String notificationLogGuestName = 'guest_name';
  static const String notificationLogRoomLabel = 'room_label';
  static const String notificationLogDaysBefore = 'days_before';
  static const String notificationLogScheduledTime = 'scheduled_time';
  static const String notificationLogSentAt = 'sent_at';
  static const String notificationLogSuccess = 'success';
  static const String notificationLogErrorMessage = 'error_message';
  static const String notificationLogIsTest = 'is_test';

  // Inventory item columns
  static const String inventoryItemId = 'id';
  static const String inventoryItemName = 'name';
  static const String inventoryItemCategory = 'category';
  static const String inventoryItemQuantity = 'quantity';
  static const String inventoryItemExpiryDate = 'expiry_date';
  static const String inventoryItemNotes = 'notes';
  static const String inventoryItemCreatedAt = 'created_at';
  static const String inventoryItemUpdatedAt = 'updated_at';

  // Inventory movement columns
  static const String inventoryMovementId = 'id';
  static const String inventoryMovementItemId = 'item_id';
  static const String inventoryMovementDelta = 'quantity_delta';
  static const String inventoryMovementDate = 'movement_date';
  static const String inventoryMovementCreatedAt = 'created_at';

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

  /// SQL to create notification_settings table (version 6 -> 7).
  static const String createNotificationSettingsTable = '''
    CREATE TABLE IF NOT EXISTS $tableNotificationSettings (
      $notificationSettingsId INTEGER PRIMARY KEY CHECK ($notificationSettingsId = 1),
      $notificationSettingsEnabled INTEGER NOT NULL DEFAULT 1,
      $notificationSettingsDaysBefore TEXT NOT NULL DEFAULT '[5,3,2,1,0]',
      $notificationSettingsHour INTEGER NOT NULL DEFAULT 9,
      $notificationSettingsMinute INTEGER NOT NULL DEFAULT 0,
      $notificationSettingsUpdatedAt TEXT NOT NULL
    )
  ''';

  /// SQL to create notification_logs table (version 6 -> 7).
  static const String createNotificationLogsTable = '''
    CREATE TABLE IF NOT EXISTS $tableNotificationLogs (
      $notificationLogId TEXT PRIMARY KEY,
      $notificationLogReservationId TEXT,
      $notificationLogGuestName TEXT,
      $notificationLogRoomLabel TEXT,
      $notificationLogDaysBefore INTEGER NOT NULL DEFAULT 0,
      $notificationLogScheduledTime TEXT NOT NULL,
      $notificationLogSentAt TEXT NOT NULL,
      $notificationLogSuccess INTEGER NOT NULL DEFAULT 1,
      $notificationLogErrorMessage TEXT,
      $notificationLogIsTest INTEGER NOT NULL DEFAULT 0
    )
  ''';

  /// SQL to create index on notification_logs sent_at (version 6 -> 7).
  static const String createNotificationLogsSentAtIndex =
      'CREATE INDEX IF NOT EXISTS idx_notification_logs_sent_at ON $tableNotificationLogs ($notificationLogSentAt DESC)';

  /// SQL to create inventory_items table (version 7 -> 8).
  static const String createInventoryItemsTable = '''
    CREATE TABLE IF NOT EXISTS $tableInventoryItems (
      $inventoryItemId TEXT PRIMARY KEY,
      $inventoryItemName TEXT NOT NULL,
      $inventoryItemCategory TEXT NOT NULL,
      $inventoryItemQuantity INTEGER NOT NULL DEFAULT 0,
      $inventoryItemExpiryDate TEXT,
      $inventoryItemNotes TEXT,
      $inventoryItemCreatedAt TEXT NOT NULL,
      $inventoryItemUpdatedAt TEXT
    )
  ''';

  /// SQL to create inventory_movements table (version 7 -> 8).
  static const String createInventoryMovementsTable = '''
    CREATE TABLE IF NOT EXISTS $tableInventoryMovements (
      $inventoryMovementId TEXT PRIMARY KEY,
      $inventoryMovementItemId TEXT NOT NULL,
      $inventoryMovementDelta INTEGER NOT NULL,
      $inventoryMovementDate TEXT NOT NULL,
      $inventoryMovementCreatedAt TEXT NOT NULL,
      FOREIGN KEY ($inventoryMovementItemId) REFERENCES $tableInventoryItems ($inventoryItemId) ON DELETE CASCADE
    )
  ''';

  /// SQL to create index on inventory_items expiry_date (version 7 -> 8).
  static const String createInventoryItemsExpiryDateIndex =
      'CREATE INDEX IF NOT EXISTS idx_inventory_expiry_date ON $tableInventoryItems ($inventoryItemExpiryDate)';

  /// SQL to create index on inventory_movements item_id (version 7 -> 8).
  static const String createInventoryMovementsItemIndex =
      'CREATE INDEX IF NOT EXISTS idx_inventory_movements_item ON $tableInventoryMovements ($inventoryMovementItemId, $inventoryMovementDate DESC)';
}
