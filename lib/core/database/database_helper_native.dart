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
      onUpgrade: _onUpgrade,
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
        'is_system': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'airbnb',
        'name': 'Airbnb',
        'color_value': 0xFFE91E63,
        'is_default': 1,
        'is_system': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'whatsapp',
        'name': 'WhatsApp',
        'color_value': 0xFF4CAF50,
        'is_default': 1,
        'is_system': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'website',
        'name': 'Sito Web',
        'color_value': 0xFF9C27B0,
        'is_default': 1,
        'is_system': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'tiktok',
        'name': 'TikTok',
        'color_value': 0xFF212121,
        'is_default': 1,
        'is_system': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final platform in defaultPlatforms) {
      await db.insert(DatabaseSchema.tablePlatforms, platform);
    }
  }

  /// Upgrades the database to a new version.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add payment_status column
      await db.execute(DatabaseSchema.migrationV1ToV2);
    }
    if (oldVersion < 3) {
      // Add is_system column to platforms
      await db.execute(DatabaseSchema.migrationV2ToV3);
      await db.execute(DatabaseSchema.migrationV2ToV3UpdateSystemPlatforms);
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
