---
phase: 01-foundation-data-model
plan: 04
type: tdd
wave: 4
depends_on: [03]
files_modified:
  - lib/core/database/database_helper.dart
  - lib/core/database/database_helper_native.dart
  - lib/core/database/database_helper_web.dart
  - lib/core/database/database_schema.dart
  - lib/features/reservations/data/datasources/reservation_data_source.dart
  - lib/features/reservations/data/datasources/local/reservation_local_data_source.dart
  - lib/features/reservations/data/repositories/reservation_repository_impl.dart
  - lib/features/reservations/domain/repositories/reservation_repository.dart
  - test/core/database/database_helper_test.dart
  - test/features/reservations/data/datasources/reservation_local_data_source_test.dart
  - test/features/reservations/data/repositories/reservation_repository_impl_test.dart
autonomous: true
requirements:
  - DATA-01
  - DATA-02
  - DATA-03
  - DATA-04
  - DATA-05
  - TEST-01
must_haves:
  truths:
    - "Database initializes correctly on first run"
    - "Default platforms are inserted on database creation"
    - "Default rooms are inserted on database creation"
    - "Reservations can be saved to database"
    - "Reservations can be retrieved from database"
    - "Reservations can be deleted from database"
    - "Repository abstracts database implementation details"
    - "Web platform uses idb_shim for IndexedDB storage"
    - "Android/native platform uses sqflite for SQLite storage"
  artifacts:
    - path: "lib/core/database/database_helper.dart"
      provides: "Platform-aware database factory (conditional export)"
      exports: ["DatabaseHelper"]
    - path: "lib/core/database/database_helper_native.dart"
      provides: "SQLite implementation for Android/native using sqflite"
      exports: ["DatabaseHelper"]
    - path: "lib/core/database/database_helper_web.dart"
      provides: "IndexedDB implementation for web using idb_shim"
      exports: ["DatabaseHelper"]
    - path: "lib/features/reservations/domain/repositories/reservation_repository.dart"
      provides: "Repository interface for data access"
      exports: ["ReservationRepository"]
    - path: "lib/features/reservations/data/repositories/reservation_repository_impl.dart"
      provides: "Repository implementation with platform-aware storage"
      exports: ["ReservationRepositoryImpl"]
  key_links:
    - from: "ReservationRepositoryImpl"
      to: "ReservationLocalDataSource"
      via: "constructor injection"
      pattern: "final.*DataSource"
    - from: "ReservationLocalDataSource"
      to: "DatabaseHelper"
      via: "database getter"
      pattern: "database\\."
---

<objective>
Implement database layer with repository pattern for cross-platform storage (Android + Web).

Purpose: Create the data persistence layer using sqflite for Android and idb_shim for web, abstracted behind a repository pattern with a unified DatabaseHelper interface.
Output: DatabaseHelper (with platform-specific implementations), local data source, and repository implementation with unit tests.
</objective>

<execution_context>
@./.claude/get-shit-done/workflows/execute-plan.md
@./.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md
@.planning/phases/01-foundation-data-model/01-RESEARCH.md

## Interfaces from Data Models (Plan 03)

```dart
// From lib/features/reservations/data/models/room_model.dart
class RoomModel {
  final String id;
  final String name;
  final String type;
  final DateTime createdAt;
  factory RoomModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

// From lib/features/reservations/data/models/platform_model.dart
class PlatformModel {
  final String id;
  final String name;
  final int colorValue;
  final bool isDefault;
  final DateTime createdAt;
  factory PlatformModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

// From lib/features/reservations/data/models/reservation_model.dart
class ReservationModel {
  final String id;
  final String roomId;
  final String platformId;
  final GuestModel guest;
  final DateTime checkIn;
  final DateTime checkOut;
  final double? amount;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  factory ReservationModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

## Platform Colors (for default data)
- Booking: 0xFF2196F3 (Blue)
- Airbnb: 0xFFE91E63 (Pink)
- WhatsApp: 0xFF4CAF50 (Green)
- Website: 0xFF9C27B0 (Purple)
- TikTok: 0xFF212121 (Black)

## Cross-Platform Database Strategy

The app uses a **conditional export** pattern to provide platform-specific database implementations:

1. **database_helper.dart** - Abstract interface that all platforms use
2. **database_helper_native.dart** - sqflite implementation for Android/iOS/desktop
3. **database_helper_web.dart** - idb_shim implementation for web

The main `database_helper.dart` uses conditional imports to select the correct implementation at compile time.
</context>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Write tests for DatabaseHelper</name>
  <files>test/core/database/database_helper_test.dart, lib/core/database/database_helper.dart, lib/core/database/database_helper_native.dart, lib/core/database/database_helper_web.dart, lib/core/database/database_schema.dart</files>
  <behavior>
    - Test 1: Database initializes without errors
    - Test 2: Database has correct version
    - Test 3: Tables are created on initialization
    - Test 4: Default platforms are inserted on creation
    - Test 5: Default rooms are inserted on creation
    - Test 6: Foreign key constraints are enabled (native only)
  </behavior>
  <action>
RED PHASE: Create test file first

**CRITICAL:** Tests require `sqflite_common_ffi` (added in Plan 01) to run on desktop platforms. The test file must initialize the FFI database factory before tests run.

Create test/core/database/database_helper_test.dart:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/core/database/database_schema.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // CRITICAL: Initialize sqflite FFI for desktop testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper', () {
    late DatabaseHelper databaseHelper;

    setUp(() {
      databaseHelper = DatabaseHelper.forTesting();
    });

    tearDown(() async {
      await databaseHelper.close();
    });

    test('should initialize database without errors', () async {
      final db = await databaseHelper.database;

      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    test('should have correct database version', () async {
      final db = await databaseHelper.database;

      expect(db.version, DatabaseSchema.version);
    });

    test('should create rooms table', () async {
      final db = await databaseHelper.database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='rooms'",
      );

      expect(tables, isNotEmpty);
    });

    test('should create platforms table', () async {
      final db = await databaseHelper.database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='platforms'",
      );

      expect(tables, isNotEmpty);
    });

    test('should create reservations table', () async {
      final db = await databaseHelper.database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='reservations'",
      );

      expect(tables, isNotEmpty);
    });

    test('should insert default platforms on creation', () async {
      final db = await databaseHelper.database;

      final platforms = await db.query('platforms');

      expect(platforms.length, 5);
      expect(platforms.any((p) => p['id'] == 'booking'), isTrue);
      expect(platforms.any((p) => p['id'] == 'airbnb'), isTrue);
      expect(platforms.any((p) => p['id'] == 'whatsapp'), isTrue);
      expect(platforms.any((p) => p['id'] == 'website'), isTrue);
      expect(platforms.any((p) => p['id'] == 'tiktok'), isTrue);
    });

    test('should insert default rooms on creation', () async {
      final db = await databaseHelper.database;

      final rooms = await db.query('rooms');

      expect(rooms.length, 4);
      expect(rooms.any((r) => r['id'] == 'room-1'), isTrue);
      expect(rooms.any((r) => r['id'] == 'room-2'), isTrue);
      expect(rooms.any((r) => r['id'] == 'room-3'), isTrue);
      expect(rooms.any((r) => r['id'] == 'apartment'), isTrue);
    });

    test('should have Booking platform with blue color', () async {
      final db = await databaseHelper.database;

      final platforms = await db.query(
        'platforms',
        where: 'id = ?',
        whereArgs: ['booking'],
      );

      expect(platforms, isNotEmpty);
      expect(platforms.first['color_value'], 0xFF2196F3);
    });

    test('should close database successfully', () async {
      await databaseHelper.database;
      await databaseHelper.close();

      // After close, accessing database should create a new instance
      final db = await databaseHelper.database;
      expect(db.isOpen, isTrue);
    });
  });
}
```

GREEN PHASE: Implement the database layer

Create lib/core/database/database_schema.dart:

```dart
/// Database schema definitions and constants.
class DatabaseSchema {
  DatabaseSchema._();

  static const String name = 'reservations.db';
  static const int version = 1;

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
      $reservationNotes TEXT,
      $reservationCreatedAt TEXT NOT NULL,
      $reservationUpdatedAt TEXT NOT NULL,
      FOREIGN KEY ($reservationRoomId) REFERENCES $tableRooms ($roomId),
      FOREIGN KEY ($reservationPlatformId) REFERENCES $tablePlatforms ($platformId)
    )
  ''';
}
```

Create lib/core/database/database_helper_native.dart (sqflite implementation for Android/native):

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_prenotazioni/core/database/database_schema.dart';

/// Native database helper using sqflite for Android/iOS/desktop platforms.
///
/// This implementation is used on all platforms except web.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  /// Constructor for testing with isolated database instance.
  factory DatabaseHelper.forTesting() => DatabaseHelper._internal();

  Database? _database;

  /// Gets the database instance, initializing if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), DatabaseSchema.name);

    return await openDatabase(
      path,
      version: DatabaseSchema.version,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  /// Configures the database after opening.
  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Creates all tables and inserts default data.
  Future<void> _onCreate(Database db, int version) async {
    // Create tables
    await db.execute(DatabaseSchema.createRoomsTable);
    await db.execute(DatabaseSchema.createPlatformsTable);
    await db.execute(DatabaseSchema.createReservationsTable);

    // Insert default data
    await _insertDefaultRooms(db);
    await _insertDefaultPlatforms(db);
  }

  Future<void> _insertDefaultRooms(Database db) async {
    final defaultRooms = [
      {
        'id': 'room-1',
        'name': 'Stanza 1',
        'type': 'singleRoom',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'room-2',
        'name': 'Stanza 2',
        'type': 'singleRoom',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'room-3',
        'name': 'Stanza 3',
        'type': 'singleRoom',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'apartment',
        'name': 'Appartamento Intero',
        'type': 'entireApartment',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final room in defaultRooms) {
      await db.insert(DatabaseSchema.tableRooms, room);
    }
  }

  Future<void> _insertDefaultPlatforms(Database db) async {
    final defaultPlatforms = [
      {
        'id': 'booking',
        'name': 'Booking',
        'color_value': 0xFF2196F3,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'airbnb',
        'name': 'Airbnb',
        'color_value': 0xFFE91E63,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'whatsapp',
        'name': 'WhatsApp',
        'color_value': 0xFF4CAF50,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'website',
        'name': 'Sito Web',
        'color_value': 0xFF9C27B0,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'tiktok',
        'name': 'TikTok',
        'color_value': 0xFF212121,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final platform in defaultPlatforms) {
      await db.insert(DatabaseSchema.tablePlatforms, platform);
    }
  }

  /// Closes the database connection.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
```

Create lib/core/database/database_helper_web.dart (idb_shim implementation for web):

```dart
import 'package:idb_shim/idb_shim.dart';
import 'package:app_prenotazioni/core/database/database_schema.dart';

/// Web database helper using idb_shim for IndexedDB storage.
///
/// This implementation is used only on web platforms.
/// Note: IndexedDB is a NoSQL store, so we emulate SQL table behavior
/// using object stores with the same schema structure.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  /// Constructor for testing with isolated database instance.
  factory DatabaseHelper.forTesting() => DatabaseHelper._internal();

  Database? _database;

  /// Gets the database instance, initializing if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final idbFactory = getIdbFactory();
    if (idbFactory == null) {
      throw UnsupportedError('IndexedDB is not supported on this platform');
    }

    return await idbFactory.open(
      DatabaseSchema.name,
      version: DatabaseSchema.version,
      onUpgradeNeeded: _onUpgradeNeeded,
    );
  }

  /// Creates all object stores and inserts default data.
  void _onUpgradeNeeded(VersionChangeEvent event) {
    final db = event.database;

    // Create rooms object store
    if (!db.objectStoreNames.contains(DatabaseSchema.tableRooms)) {
      db.createObjectStore(DatabaseSchema.tableRooms, keyPath: DatabaseSchema.roomId);
    }

    // Create platforms object store
    if (!db.objectStoreNames.contains(DatabaseSchema.tablePlatforms)) {
      db.createObjectStore(DatabaseSchema.tablePlatforms, keyPath: DatabaseSchema.platformId);
    }

    // Create reservations object store
    if (!db.objectStoreNames.contains(DatabaseSchema.tableReservations)) {
      db.createObjectStore(DatabaseSchema.tableReservations, keyPath: DatabaseSchema.reservationId);
    }

    // Insert default data on initial creation
    _insertDefaultData(db);
  }

  void _insertDefaultData(Database db) {
    _insertDefaultRooms(db);
    _insertDefaultPlatforms(db);
  }

  void _insertDefaultRooms(Database db) {
    final transaction = db.transaction(DatabaseSchema.tableRooms, 'readwrite');
    final store = transaction.objectStore(DatabaseSchema.tableRooms);

    final defaultRooms = [
      {
        'id': 'room-1',
        'name': 'Stanza 1',
        'type': 'singleRoom',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'room-2',
        'name': 'Stanza 2',
        'type': 'singleRoom',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'room-3',
        'name': 'Stanza 3',
        'type': 'singleRoom',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'apartment',
        'name': 'Appartamento Intero',
        'type': 'entireApartment',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final room in defaultRooms) {
      store.put(room);
    }
  }

  void _insertDefaultPlatforms(Database db) {
    final transaction = db.transaction(DatabaseSchema.tablePlatforms, 'readwrite');
    final store = transaction.objectStore(DatabaseSchema.tablePlatforms);

    final defaultPlatforms = [
      {
        'id': 'booking',
        'name': 'Booking',
        'color_value': 0xFF2196F3,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'airbnb',
        'name': 'Airbnb',
        'color_value': 0xFFE91E63,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'whatsapp',
        'name': 'WhatsApp',
        'color_value': 0xFF4CAF50,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'website',
        'name': 'Sito Web',
        'color_value': 0xFF9C27B0,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'tiktok',
        'name': 'TikTok',
        'color_value': 0xFF212121,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final platform in defaultPlatforms) {
      store.put(platform);
    }
  }

  /// Closes the database connection.
  Future<void> close() async {
    if (_database != null) {
      _database!.close();
      _database = null;
    }
  }
}
```

Create lib/core/database/database_helper.dart (conditional export):

```dart
/// Platform-aware database helper.
///
/// This file conditionally exports the correct implementation based on platform:
/// - Native (Android/iOS/desktop): Uses sqflite for SQLite
/// - Web: Uses idb_shim for IndexedDB
///
/// Both implementations share the same interface, allowing the rest of the
/// application to use DatabaseHelper without platform-specific code.
export 'database_helper_stub.dart'
    if (dart.library.io) 'database_helper_native.dart'
    if (dart.library.js) 'database_helper_web.dart';
```

Create lib/core/database/database_helper_stub.dart (for dart analyzer):

```dart
/// Stub implementation for dart analyzer.
///
/// This file is never actually used at runtime - it exists only to satisfy
/// the dart analyzer. The actual implementation is selected via conditional
/// exports in database_helper.dart.
///
/// The real implementations are:
/// - database_helper_native.dart for Android/iOS/desktop (sqflite)
/// - database_helper_web.dart for web (idb_shim)
class DatabaseHelper {
  DatabaseHelper._internal();
  factory DatabaseHelper() => throw UnimplementedError();
  factory DatabaseHelper.forTesting() => throw UnimplementedError();

  Future<dynamic> get database => throw UnimplementedError();
  Future<void> close() => throw UnimplementedError();
}
```

Run tests: `flutter test test/core/database/database_helper_test.dart`

**Note:** Tests use `sqflite_common_ffi` (added in Plan 01 dev_dependencies) which provides a native SQLite implementation for desktop testing.
</action>
  <verify>
    <automated>flutter test test/core/database/database_helper_test.dart</automated>
  </verify>
  <done>
    - DatabaseHelper creates database with 3 tables and default data
    - Platform-specific implementations: sqflite for native, idb_shim for web
    - sqflite_common_ffi used for desktop testing
    - Foreign key constraints enabled (native)
    - All 10 tests pass
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Write tests for ReservationLocalDataSource</name>
  <files>test/features/reservations/data/datasources/reservation_local_data_source_test.dart, lib/features/reservations/data/datasources/reservation_data_source.dart, lib/features/reservations/data/datasources/local/reservation_local_data_source.dart</files>
  <behavior>
    - Test 1: getAllReservations returns empty list when no data
    - Test 2: saveReservation stores reservation correctly
    - Test 3: getAllReservations returns saved reservations
    - Test 4: getReservationById returns correct reservation
    - Test 5: deleteReservation removes reservation
    - Test 6: getReservationsForDateRange returns correct reservations
    - Test 7: getAllPlatforms returns default platforms
    - Test 8: getAllRooms returns default rooms
  </behavior>
  <action>
RED PHASE: Create test file first

Create test/features/reservations/data/datasources/reservation_local_data_source_test.dart:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/features/reservations/data/datasources/local/reservation_local_data_source.dart';
import 'package:app_prenotazioni/features/reservations/data/models/reservation_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/guest_model.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}
class MockDatabase extends Mock implements Database {}

void main() {
  late ReservationLocalDataSource dataSource;
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDb;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDb = MockDatabase();
    dataSource = ReservationLocalDataSource(databaseHelper: mockDbHelper);

    when(() => mockDbHelper.database).thenAnswer((_) async => mockDb);
  });

  group('ReservationLocalDataSource', () {
    final testReservation = ReservationModel(
      id: 'res-1',
      roomId: 'room-1',
      platformId: 'booking',
      guest: const GuestModel(name: 'Mario Rossi', phone: '+39123456789'),
      checkIn: DateTime(2024, 6, 20),
      checkOut: DateTime(2024, 6, 25),
      amount: 500.00,
      notes: 'Late arrival',
      createdAt: DateTime(2024, 6, 1),
      updatedAt: DateTime(2024, 6, 1),
    );

    group('getAllReservations', () {
      test('should return empty list when no reservations exist', () async {
        when(() => mockDb.query('reservations')).thenAnswer((_) async => []);

        final result = await dataSource.getAllReservations();

        expect(result, isEmpty);
        verify(() => mockDb.query('reservations')).called(1);
      });

      test('should return list of reservations', () async {
        when(() => mockDb.query('reservations')).thenAnswer((_) async => [
              {
                'id': 'res-1',
                'room_id': 'room-1',
                'platform_id': 'booking',
                'guest_name': 'Mario Rossi',
                'guest_phone': '+39123456789',
                'check_in': '2024-06-20T00:00:00.000Z',
                'check_out': '2024-06-25T00:00:00.000Z',
                'amount': 500.00,
                'notes': 'Late arrival',
                'created_at': '2024-06-01T00:00:00.000Z',
                'updated_at': '2024-06-01T00:00:00.000Z',
              }
            ]);

        final result = await dataSource.getAllReservations();

        expect(result.length, 1);
        expect(result.first.id, 'res-1');
        expect(result.first.roomId, 'room-1');
      });
    });

    group('saveReservation', () {
      test('should insert reservation into database', () async {
        when(() => mockDb.insert('reservations', any()))
            .thenAnswer((_) async => 1);

        await dataSource.saveReservation(testReservation);

        verify(() => mockDb.insert('reservations', any())).called(1);
      });
    });

    group('getReservationById', () {
      test('should return reservation when found', () async {
        when(() => mockDb.query(
              'reservations',
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
            )).thenAnswer((_) async => [
              {
                'id': 'res-1',
                'room_id': 'room-1',
                'platform_id': 'booking',
                'guest_name': 'Mario Rossi',
                'guest_phone': '+39123456789',
                'check_in': '2024-06-20T00:00:00.000Z',
                'check_out': '2024-06-25T00:00:00.000Z',
                'amount': 500.00,
                'notes': 'Late arrival',
                'created_at': '2024-06-01T00:00:00.000Z',
                'updated_at': '2024-06-01T00:00:00.000Z',
              }
            ]);

        final result = await dataSource.getReservationById('res-1');

        expect(result, isNotNull);
        expect(result!.id, 'res-1');
      });

      test('should return null when not found', () async {
        when(() => mockDb.query(
              'reservations',
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
            )).thenAnswer((_) async => []);

        final result = await dataSource.getReservationById('nonexistent');

        expect(result, isNull);
      });
    });

    group('deleteReservation', () {
      test('should delete reservation from database', () async {
        when(() => mockDb.delete(
              'reservations',
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
            )).thenAnswer((_) async => 1);

        await dataSource.deleteReservation('res-1');

        verify(() => mockDb.delete(
              'reservations',
              where: 'id = ?',
              whereArgs: ['res-1'],
            )).called(1);
      });
    });

    group('getReservationsForDateRange', () {
      test('should return reservations in date range', () async {
        when(() => mockDb.query(
              'reservations',
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
            )).thenAnswer((_) async => [
              {
                'id': 'res-1',
                'room_id': 'room-1',
                'platform_id': 'booking',
                'guest_name': 'Mario Rossi',
                'guest_phone': null,
                'check_in': '2024-06-20T00:00:00.000Z',
                'check_out': '2024-06-25T00:00:00.000Z',
                'amount': null,
                'notes': null,
                'created_at': '2024-06-01T00:00:00.000Z',
                'updated_at': '2024-06-01T00:00:00.000Z',
              }
            ]);

        final result = await dataSource.getReservationsForDateRange(
          DateTime(2024, 6, 15),
          DateTime(2024, 6, 30),
        );

        expect(result.length, 1);
      });
    });

    group('getAllPlatforms', () {
      test('should return all platforms', () async {
        when(() => mockDb.query('platforms'))
            .thenAnswer((_) async => [
                  {'id': 'booking', 'name': 'Booking', 'color_value': 0xFF2196F3, 'is_default': 1, 'created_at': '2024-01-01T00:00:00.000Z'},
                ]);

        final result = await dataSource.getAllPlatforms();

        expect(result, isNotEmpty);
      });
    });

    group('getAllRooms', () {
      test('should return all rooms', () async {
        when(() => mockDb.query('rooms'))
            .thenAnswer((_) async => [
                  {'id': 'room-1', 'name': 'Stanza 1', 'type': 'singleRoom', 'created_at': '2024-01-01T00:00:00.000Z'},
                ]);

        final result = await dataSource.getAllRooms();

        expect(result, isNotEmpty);
      });
    });
  });
}
```

GREEN PHASE: Implement the data source

Create lib/features/reservations/data/datasources/reservation_data_source.dart:

```dart
import 'package:app_prenotazioni/features/reservations/data/models/reservation_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/room_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/platform_model.dart';

/// Abstract interface for reservation data operations.
abstract class ReservationDataSource {
  Future<List<ReservationModel>> getAllReservations();
  Future<ReservationModel?> getReservationById(String id);
  Future<void> saveReservation(ReservationModel reservation);
  Future<void> deleteReservation(String id);
  Future<List<ReservationModel>> getReservationsForDateRange(
    DateTime start,
    DateTime end,
  );
  Future<List<RoomModel>> getAllRooms();
  Future<List<PlatformModel>> getAllPlatforms();
}
```

Create lib/features/reservations/data/datasources/local/reservation_local_data_source.dart:

```dart
import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/core/database/database_schema.dart';
import 'package:app_prenotazioni/features/reservations/data/datasources/reservation_data_source.dart';
import 'package:app_prenotazioni/features/reservations/data/models/reservation_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/room_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/platform_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/guest_model.dart';

/// Local data source implementation using SQLite.
class ReservationLocalDataSource implements ReservationDataSource {
  final DatabaseHelper _databaseHelper;

  ReservationLocalDataSource({
    required DatabaseHelper databaseHelper,
  }) : _databaseHelper = databaseHelper;

  @override
  Future<List<ReservationModel>> getAllReservations() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(DatabaseSchema.tableReservations);

    return maps.map((map) => _mapToReservationModel(map)).toList();
  }

  @override
  Future<ReservationModel?> getReservationById(String id) async {
    final db = await _databaseHelper.database;
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
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseSchema.tableReservations,
      _reservationToMap(reservation),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteReservation(String id) async {
    final db = await _databaseHelper.database;
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
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseSchema.tableReservations,
      where: '${DatabaseSchema.reservationCheckIn} < ? AND ${DatabaseSchema.reservationCheckOut} > ?',
      whereArgs: [end.toIso8601String(), start.toIso8601String()],
    );

    return maps.map((map) => _mapToReservationModel(map)).toList();
  }

  @override
  Future<List<RoomModel>> getAllRooms() async {
    final db = await _databaseHelper.database;
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
    final db = await _databaseHelper.database;
    final maps = await db.query(DatabaseSchema.tablePlatforms);

    return maps.map((map) => PlatformModel(
      id: map[DatabaseSchema.platformId] as String,
      name: map[DatabaseSchema.platformName] as String,
      colorValue: map[DatabaseSchema.platformColorValue] as int,
      isDefault: map[DatabaseSchema.platformIsDefault] == 1,
      createdAt: DateTime.parse(map[DatabaseSchema.platformCreatedAt] as String),
    )).toList();
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
      DatabaseSchema.reservationNotes: reservation.notes,
      DatabaseSchema.reservationCreatedAt: reservation.createdAt.toIso8601String(),
      DatabaseSchema.reservationUpdatedAt: reservation.updatedAt.toIso8601String(),
    };
  }
}
```

Run tests: `flutter test test/features/reservations/data/datasources/reservation_local_data_source_test.dart`
</action>
  <verify>
    <automated>flutter test test/features/reservations/data/datasources/reservation_local_data_source_test.dart</automated>
  </verify>
  <done>
    - ReservationDataSource interface created
    - ReservationLocalDataSource implements all CRUD operations
    - Date range query works correctly
    - All 10 tests pass
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: Write tests for ReservationRepository</name>
  <files>test/features/reservations/data/repositories/reservation_repository_impl_test.dart, lib/features/reservations/domain/repositories/reservation_repository.dart, lib/features/reservations/data/repositories/reservation_repository_impl.dart</files>
  <behavior>
    - Test 1: getAllReservations returns domain entities
    - Test 2: getReservationById returns domain entity
    - Test 3: saveReservation works correctly
    - Test 4: deleteReservation works correctly
    - Test 5: getReservationsForDateRange returns overlapping reservations
    - Test 6: getAllPlatforms returns domain entities
    - Test 7: getAllRooms returns domain entities
  </behavior>
  <action>
RED PHASE: Create test file first

Create test/features/reservations/data/repositories/reservation_repository_impl_test.dart:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_prenotazioni/features/reservations/data/datasources/reservation_data_source.dart';
import 'package:app_prenotazioni/features/reservations/data/repositories/reservation_repository_impl.dart';
import 'package:app_prenotazioni/features/reservations/data/models/reservation_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/room_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/platform_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/guest_model.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

class MockReservationDataSource extends Mock implements ReservationDataSource {}

void main() {
  late ReservationRepositoryImpl repository;
  late MockReservationDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockReservationDataSource();
    repository = ReservationRepositoryImpl(dataSource: mockDataSource);
  });

  group('ReservationRepositoryImpl', () {
    final testReservationModel = ReservationModel(
      id: 'res-1',
      roomId: 'room-1',
      platformId: 'booking',
      guest: const GuestModel(name: 'Mario Rossi', phone: '+39123456789'),
      checkIn: DateTime(2024, 6, 20),
      checkOut: DateTime(2024, 6, 25),
      amount: 500.00,
      notes: 'Late arrival',
      createdAt: DateTime(2024, 6, 1),
      updatedAt: DateTime(2024, 6, 1),
    );

    final testRoomModel = RoomModel(
      id: 'room-1',
      name: 'Stanza 1',
      type: 'singleRoom',
      createdAt: DateTime(2024, 1, 1),
    );

    final testPlatformModel = PlatformModel(
      id: 'booking',
      name: 'Booking',
      colorValue: 0xFF2196F3,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    );

    group('getAllReservations', () {
      test('should return list of Reservation entities', () async {
        when(() => mockDataSource.getAllReservations())
            .thenAnswer((_) async => [testReservationModel]);

        final result = await repository.getAllReservations();

        expect(result.length, 1);
        expect(result.first, isA<Reservation>());
        expect(result.first.id, 'res-1');
        expect(result.first.roomId, 'room-1');
        verify(() => mockDataSource.getAllReservations()).called(1);
      });

      test('should return empty list when no reservations', () async {
        when(() => mockDataSource.getAllReservations())
            .thenAnswer((_) async => []);

        final result = await repository.getAllReservations();

        expect(result, isEmpty);
      });
    });

    group('getReservationById', () {
      test('should return Reservation entity when found', () async {
        when(() => mockDataSource.getReservationById('res-1'))
            .thenAnswer((_) async => testReservationModel);

        final result = await repository.getReservationById('res-1');

        expect(result, isNotNull);
        expect(result!.id, 'res-1');
      });

      test('should return null when not found', () async {
        when(() => mockDataSource.getReservationById('nonexistent'))
            .thenAnswer((_) async => null);

        final result = await repository.getReservationById('nonexistent');

        expect(result, isNull);
      });
    });

    group('saveReservation', () {
      test('should call dataSource with correct model', () async {
        final entity = testReservationModel.toEntity();

        when(() => mockDataSource.saveReservation(any()))
            .thenAnswer((_) async {});

        await repository.saveReservation(entity);

        verify(() => mockDataSource.saveReservation(any())).called(1);
      });
    });

    group('deleteReservation', () {
      test('should call dataSource with correct id', () async {
        when(() => mockDataSource.deleteReservation('res-1'))
            .thenAnswer((_) async {});

        await repository.deleteReservation('res-1');

        verify(() => mockDataSource.deleteReservation('res-1')).called(1);
      });
    });

    group('getReservationsForDateRange', () {
      test('should return reservations overlapping with date range', () async {
        when(() => mockDataSource.getReservationsForDateRange(
              any(),
              any(),
            )).thenAnswer((_) async => [testReservationModel]);

        final result = await repository.getReservationsForDateRange(
          DateTime(2024, 6, 15),
          DateTime(2024, 6, 30),
        );

        expect(result.length, 1);
        expect(result.first, isA<Reservation>());
      });
    });

    group('getAllRooms', () {
      test('should return list of Room entities', () async {
        when(() => mockDataSource.getAllRooms())
            .thenAnswer((_) async => [testRoomModel]);

        final result = await repository.getAllRooms();

        expect(result.length, 1);
        expect(result.first, isA<Room>());
        expect(result.first.id, 'room-1');
      });
    });

    group('getAllPlatforms', () {
      test('should return list of BookingPlatform entities', () async {
        when(() => mockDataSource.getAllPlatforms())
            .thenAnswer((_) async => [testPlatformModel]);

        final result = await repository.getAllPlatforms();

        expect(result.length, 1);
        expect(result.first, isA<BookingPlatform>());
        expect(result.first.id, 'booking');
      });
    });
  });
}
```

GREEN PHASE: Implement the repository

Create lib/features/reservations/domain/repositories/reservation_repository.dart:

```dart
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

/// Repository interface for reservation data access.
abstract class ReservationRepository {
  /// Gets all reservations.
  Future<List<Reservation>> getAllReservations();

  /// Gets a reservation by ID.
  Future<Reservation?> getReservationById(String id);

  /// Saves a reservation (insert or update).
  Future<void> saveReservation(Reservation reservation);

  /// Deletes a reservation by ID.
  Future<void> deleteReservation(String id);

  /// Gets reservations that overlap with a date range.
  Future<List<Reservation>> getReservationsForDateRange(
    DateTime start,
    DateTime end,
  );

  /// Gets all rooms.
  Future<List<Room>> getAllRooms();

  /// Gets all platforms.
  Future<List<BookingPlatform>> getAllPlatforms();
}
```

Create lib/features/reservations/data/repositories/reservation_repository_impl.dart:

```dart
import 'package:app_prenotazioni/features/reservations/data/datasources/reservation_data_source.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';

/// Implementation of ReservationRepository using local data source.
class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationDataSource _dataSource;

  ReservationRepositoryImpl({
    required ReservationDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<Reservation>> getAllReservations() async {
    final models = await _dataSource.getAllReservations();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Reservation?> getReservationById(String id) async {
    final model = await _dataSource.getReservationById(id);
    return model?.toEntity();
  }

  @override
  Future<void> saveReservation(Reservation reservation) async {
    await _dataSource.saveReservation(reservation.toModel());
  }

  @override
  Future<void> deleteReservation(String id) async {
    await _dataSource.deleteReservation(id);
  }

  @override
  Future<List<Reservation>> getReservationsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final models = await _dataSource.getReservationsForDateRange(start, end);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Room>> getAllRooms() async {
    final models = await _dataSource.getAllRooms();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<BookingPlatform>> getAllPlatforms() async {
    final models = await _dataSource.getAllPlatforms();
    return models.map((model) => model.toEntity()).toList();
  }
}
```

Run tests: `flutter test test/features/reservations/data/repositories/reservation_repository_impl_test.dart`
</action>
  <verify>
    <automated>flutter test test/features/reservations/data/repositories/reservation_repository_impl_test.dart</automated>
  </verify>
  <done>
    - ReservationRepository interface created in domain layer
    - ReservationRepositoryImpl converts between models and entities
    - All repository methods delegate to data source correctly
    - All 9 tests pass
  </done>
</task>

</tasks>

<verification>
- [ ] All database tests pass: `flutter test test/core/database/`
- [ ] All data source tests pass: `flutter test test/features/reservations/data/datasources/`
- [ ] All repository tests pass: `flutter test test/features/reservations/data/repositories/`
- [ ] Full test suite passes: `flutter test`
</verification>

<success_criteria>
1. DatabaseHelper creates database with 3 tables and default data
2. Platform-specific implementations: sqflite for native, idb_shim for web
3. sqflite_common_ffi used for desktop testing (from Plan 01 dev_dependencies)
4. ReservationLocalDataSource implements all CRUD operations
5. ReservationRepository abstracts data layer from domain layer
6. All 29+ unit tests pass
7. Foreign key constraints enabled for data integrity (native)
</success_criteria>

<output>
After completion, create `.planning/phases/01-foundation-data-model/01-04-SUMMARY.md`
</output>
