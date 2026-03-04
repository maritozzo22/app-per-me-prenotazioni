# Phase 1: Foundation & Data Model - Research

**Researched:** 2026-03-04
**Domain:** Flutter cross-platform data layer, SQLite, Repository pattern
**Confidence:** HIGH

## Summary

Phase 1 establishes the foundational architecture for a Flutter reservations management app targeting Web (Chrome) and Android platforms. The core challenge is implementing a cross-platform SQLite data layer that works reliably on both web and native platforms while maintaining clean architecture principles.

**Critical Finding:** `sqflite_common_ffi_web` is **experimental and NOT recommended for production**. For web support, we need to use a different approach: either use IndexedDB directly via `idb_shim` package, or accept that sqflite on web is limited and use `shared_preferences` for configuration while using IndexedDB via a wrapper for reservations.

**Primary recommendation:** Use `sqflite` for Android with `idb_shim` or `indexed_db` for web storage, implementing a platform-aware repository pattern that abstracts the storage mechanism. Alternatively, use Hive which has better cross-platform support including web.

## User Constraints (from PROJECT.md)

### Locked Decisions
- Flutter 3.38.9+ (Dart 3.10.8+) for cross-platform web+Android from single codebase
- Web-first development: test on Chrome first, then optimize for Android
- SQLite local database (but see critical finding above about web limitations)
- TDD methodology: write tests before implementation
- Platform colors locked: Booking(blue), Airbnb(red/pink), WhatsApp(green), Website(purple), TikTok(black/dark gray)

### Claude's Discretion
- Specific package versions within constraints
- Repository pattern implementation details
- Data model field types and validation approach
- Test organization and structure

### Deferred Ideas (OUT OF SCOPE)
- Cloud synchronization
- Multi-user authentication
- API integration with Booking/Airbnb

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| ROOM-01 | 4 room types: Stanza 1, 2, 3, Appartamento Intero | Room enum/entity model with type field |
| PLAT-01 | Booking = Blue | Platform enum with color mapping |
| PLAT-02 | Airbnb = Pink/Red | Platform enum with color mapping |
| PLAT-03 | WhatsApp = Green | Platform enum with color mapping |
| PLAT-04 | Website = Purple | Platform enum with color mapping |
| PLAT-05 | TikTok = Black/Dark Gray | Platform enum with color mapping |
| DATA-01 | Local storage of reservation data | SQLite/IndexedDB via repository pattern |
| DATA-02 | Local storage of platform/color config | Platform entity with color field, stored in DB |
| DATA-03 | Data persistence between sessions | Database files persist automatically |
| DATA-04 | SQLite for Android | sqflite package - stable and production-ready |
| DATA-05 | IndexedDB for Web | idb_shim or sqflite_common_ffi_web (experimental) |
| TEST-01 | Unit tests for all data models | Flutter test framework with mocktail |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| sqflite | ^2.4.2 | SQLite database for Android | Official recommendation, stable, production-ready |
| path | ^1.8.3 | Cross-platform path handling | Required for database file paths |
| uuid | ^4.5.0 | Unique ID generation | Better than auto-increment for sync-ready design |

### Data Models (Code Generation)
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| freezed | ^2.5.2 | Immutable data models | All entities and DTOs |
| freezed_annotation | ^2.4.1 | Annotations for freezed | Paired with freezed |
| json_serializable | ^6.8.0 | JSON serialization | Database storage, API-ready |
| json_annotation | ^4.9.0 | Annotations for json_serializable | Paired with json_serializable |
| build_runner | ^2.4.9 | Code generation runner | Development only |

### Testing
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| flutter_test | SDK | Core testing framework | All test types |
| mocktail | ^1.0.0 | Mocking library | Repository, service tests |

### Web Storage (CRITICAL DECISION NEEDED)
| Library | Version | Purpose | Status |
|---------|---------|---------|--------|
| idb_shim | ^2.6.0 | IndexedDB wrapper | Recommended for web |
| sqflite_common_ffi_web | ^0.4.0 | SQLite on web via WASM | **EXPERIMENTAL - not for production** |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| sqflite + idb_shim | Hive | Simpler, but less query flexibility; Hive has excellent web support |
| freezed + json_serializable | Manual models | More boilerplate, no immutability guarantees |
| mocktail | mockito | mocktail has simpler API, better null safety |

**Installation:**
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.4.2
  path: ^1.8.3
  uuid: ^4.5.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  # For web support (choose one):
  # Option A: idb_shim for IndexedDB
  idb_shim: ^2.6.0
  # Option B: Hive (alternative - simpler)
  # hive: ^2.2.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  mocktail: ^1.0.0
```

## Architecture Patterns

### Recommended Project Structure
```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart      # App-wide constants
│   ├── database/
│   │   ├── database_helper.dart    # SQLite/IndexedDB setup
│   │   └── database_schema.dart    # Table definitions
│   ├── errors/
│   │   ├── exceptions.dart         # Custom exceptions
│   │   └── failures.dart           # Failure types
│   └── utils/
│       └── date_utils.dart         # Date handling utilities
│
├── features/
│   └── reservations/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── local/
│       │   │   │   ├── reservation_local_data_source.dart
│       │   │   │   └── platform_local_data_source.dart
│       │   │   └── reservation_data_source.dart  # Abstract interface
│       │   ├── models/
│       │   │   ├── reservation_model.dart
│       │   │   ├── reservation_model.freezed.dart
│       │   │   ├── reservation_model.g.dart
│       │   │   ├── room_model.dart
│       │   │   ├── platform_model.dart
│       │   │   └── guest_model.dart
│       │   └── repositories/
│       │       └── reservation_repository_impl.dart
│       │
│       └── domain/
│           ├── entities/
│           │   ├── reservation.dart
│           │   ├── room.dart
│           │   ├── platform.dart
│           │   └── guest.dart
│           └── repositories/
│               └── reservation_repository.dart  # Abstract interface
│
├── di/
│   └── injection.dart              # Dependency injection setup
│
└── main.dart                       # Entry point

test/
├── features/
│   └── reservations/
│       ├── data/
│       │   ├── models/
│       │   │   ├── reservation_model_test.dart
│       │   │   ├── room_model_test.dart
│       │   │   ├── platform_model_test.dart
│       │   │   └── guest_model_test.dart
│       │   └── repositories/
│       │       └── reservation_repository_impl_test.dart
│       └── domain/
│           └── entities/
│               ├── reservation_test.dart
│               ├── room_test.dart
│               └── platform_test.dart
│
└── core/
    └── database/
        └── database_helper_test.dart
```

### Pattern 1: Repository Pattern with Platform Abstraction

**What:** Abstract data storage behind repository interfaces, with implementations that handle platform-specific storage.

**When to use:** Always - this is core architecture for cross-platform apps.

**Example:**
```dart
// domain/repositories/reservation_repository.dart
abstract class ReservationRepository {
  Future<List<Reservation>> getAllReservations();
  Future<Reservation?> getReservationById(String id);
  Future<void> saveReservation(Reservation reservation);
  Future<void> deleteReservation(String id);
  Future<List<Reservation>> getReservationsForDateRange(
    DateTime start,
    DateTime end,
  );
}

// domain/entities/reservation.dart
class Reservation {
  final String id;
  final String roomId;
  final String platformId;
  final Guest guest;
  final DateTime checkIn;
  final DateTime checkOut;
  final double? amount;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reservation({
    required this.id,
    required this.roomId,
    required this.platformId,
    required this.guest,
    required this.checkIn,
    required this.checkOut,
    this.amount,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Business logic methods
  bool overlapsWith(DateTime otherStart, DateTime otherEnd) {
    return checkIn.isBefore(otherEnd) && checkOut.isAfter(otherStart);
  }

  int get numberOfNights => checkOut.difference(checkIn).inDays;
}
```

### Pattern 2: Freezed Data Models with JSON Serialization

**What:** Use freezed for immutable models with automatic copyWith, equality, and JSON serialization.

**Example:**
```dart
// data/models/reservation_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation_model.freezed.dart';
part 'reservation_model.g.dart';

@freezed
class ReservationModel with _$ReservationModel {
  const factory ReservationModel({
    required String id,
    required String roomId,
    required String platformId,
    required GuestModel guest,
    required DateTime checkIn,
    required DateTime checkOut,
    double? amount,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ReservationModel;

  factory ReservationModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationModelFromJson(json);
}

// Extension to convert between model and entity
extension ReservationModelX on ReservationModel {
  Reservation toEntity() => Reservation(
    id: id,
    roomId: roomId,
    platformId: platformId,
    guest: guest.toEntity(),
    checkIn: checkIn,
    checkOut: checkOut,
    amount: amount,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
```

### Pattern 3: Platform-Aware Database Helper

**What:** Conditional database initialization based on platform.

**Example:**
```dart
// core/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'reservations.db';
  static const int _databaseVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // Web: Use idb_shim or accept sqflite_common_ffi_web limitations
      // For production, recommend using idb_shim with IndexedDB
      throw UnimplementedError('Web database initialization required');
    } else {
      // Android/iOS: Use sqflite
      final path = join(await getDatabasesPath(), _databaseName);
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE rooms (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE platforms (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reservations (
        id TEXT PRIMARY KEY,
        room_id TEXT NOT NULL,
        platform_id TEXT NOT NULL,
        guest_name TEXT NOT NULL,
        guest_phone TEXT,
        check_in TEXT NOT NULL,
        check_out TEXT NOT NULL,
        amount REAL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (room_id) REFERENCES rooms (id),
        FOREIGN KEY (platform_id) REFERENCES platforms (id)
      )
    ''');

    // Insert default platforms
    await _insertDefaultPlatforms(db);
  }

  Future<void> _insertDefaultPlatforms(Database db) async {
    final defaultPlatforms = [
      {'id': 'booking', 'name': 'Booking', 'color_value': 0xFF2196F3, 'is_default': 1},
      {'id': 'airbnb', 'name': 'Airbnb', 'color_value': 0xFFE91E63, 'is_default': 1},
      {'id': 'whatsapp', 'name': 'WhatsApp', 'color_value': 0xFF4CAF50, 'is_default': 1},
      {'id': 'website', 'name': 'Sito Web', 'color_value': 0xFF9C27B0, 'is_default': 1},
      {'id': 'tiktok', 'name': 'TikTok', 'color_value': 0xFF212121, 'is_default': 1},
    ];

    for (final platform in defaultPlatforms) {
      await db.insert('platforms', {
        ...platform,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}
```

### Anti-Patterns to Avoid

- **Putting business logic in widgets:** Extract to domain layer entities or use cases
- **Direct database access from UI:** Always go through repository
- **Using dynamic types:** Strong typing catches errors at compile time
- **Ignoring web platform limitations:** sqflite_common_ffi_web is NOT production-ready
- **Mutable state in models:** Use freezed for immutability

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Immutable models with equality | Manual `==` and `hashCode` | freezed | Boilerplate-free, copyWith, pattern matching |
| JSON serialization | Manual `fromJson`/`toJson` | json_serializable | Type-safe, less error-prone |
| Unique IDs | Custom ID generation | uuid package | RFC-compliant, collision-resistant |
| Date handling | Custom date operations | Dart's built-in DateTime | Well-tested, timezone-aware |
| Database migrations | Manual SQL versioning | sqflite's version system | Built-in migration support |

**Key insight:** Data layer code is deceptively complex - edge cases, null handling, and type conversions create bugs. Use established libraries.

## Common Pitfalls

### Pitfall 1: SQLite Web Support Assumption
**What goes wrong:** Developers assume sqflite works on web just like native platforms.
**Why it happens:** Package documentation mentions web support but doesn't clearly warn about experimental status.
**How to avoid:** Use idb_shim for IndexedDB on web, or use Hive which has better cross-platform support.
**Warning signs:** Database operations fail silently on web, performance issues, data corruption.

### Pitfall 2: DateTime Storage Without Timezone
**What goes wrong:** Dates stored without timezone info cause issues with check-in/check-out logic.
**Why it happens:** SQLite doesn't have native datetime type, developers use strings incorrectly.
**How to avoid:** Store as ISO8601 strings, parse consistently, use UTC for storage, local for display.
**Warning signs:** Off-by-one-day errors, DST-related bugs.

### Pitfall 3: Missing Database Schema Versioning
**What goes wrong:** App crashes when database schema changes between versions.
**Why it happens:** Forgetting to implement onUpgrade in database helper.
**How to avoid:** Always implement onUpgrade, test migrations with real data.
**Warning signs:** Crashes after app update, missing or corrupted data.

### Pitfall 4: Foreign Key Constraints Not Enforced
**What goes wrong:** Orphaned reservations when rooms or platforms are deleted.
**Why it happens:** SQLite doesn't enforce FK constraints by default.
**How to avoid:** Enable FK enforcement: `await db.execute('PRAGMA foreign_keys = ON');`
**Warning signs:** Data integrity issues, crashes when loading related data.

### Pitfall 5: Not Handling Database Path Correctly
**What goes wrong:** Database file not found or permission denied errors.
**Why it happens:** Different platforms have different file system conventions.
**How to avoid:** Use `getDatabasesPath()` from sqflite, `path` package for joining paths.
**Warning signs:** Works in debug but fails in release, platform-specific crashes.

## Code Examples

### Room Entity and Model

```dart
// domain/entities/room.dart
enum RoomType { singleRoom, entireApartment }

class Room {
  final String id;
  final String name;
  final RoomType type;
  final DateTime createdAt;

  const Room({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
  });

  // Predefined rooms for this app
  static const List<Room> defaultRooms = [
    Room(
      id: 'room-1',
      name: 'Stanza 1',
      type: RoomType.singleRoom,
      createdAt: DateTime(2024, 1, 1),
    ),
    Room(
      id: 'room-2',
      name: 'Stanza 2',
      type: RoomType.singleRoom,
      createdAt: DateTime(2024, 1, 1),
    ),
    Room(
      id: 'room-3',
      name: 'Stanza 3',
      type: RoomType.singleRoom,
      createdAt: DateTime(2024, 1, 1),
    ),
    Room(
      id: 'apartment',
      name: 'Appartamento Intero',
      type: RoomType.entireApartment,
      createdAt: DateTime(2024, 1, 1),
    ),
  ];
}

// data/models/room_model.dart
@freezed
class RoomModel with _$RoomModel {
  const factory RoomModel({
    required String id,
    required String name,
    required String type,
    required DateTime createdAt,
  }) = _RoomModel;

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);
}

extension RoomModelX on RoomModel {
  Room toEntity() => Room(
    id: id,
    name: name,
    type: type == 'entireApartment'
        ? RoomType.entireApartment
        : RoomType.singleRoom,
    createdAt: createdAt,
  );
}
```

### Platform Entity with Colors

```dart
// domain/entities/platform.dart
import 'package:flutter/material.dart';

class BookingPlatform {
  final String id;
  final String name;
  final Color color;
  final bool isDefault;
  final DateTime createdAt;

  const BookingPlatform({
    required this.id,
    required this.name,
    required this.color,
    this.isDefault = false,
    required this.createdAt,
  });

  // Default platforms with locked colors
  static const List<BookingPlatform> defaultPlatforms = [
    BookingPlatform(
      id: 'booking',
      name: 'Booking',
      color: Color(0xFF2196F3), // Blue
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    ),
    BookingPlatform(
      id: 'airbnb',
      name: 'Airbnb',
      color: Color(0xFFE91E63), // Pink/Red
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    ),
    BookingPlatform(
      id: 'whatsapp',
      name: 'WhatsApp',
      color: Color(0xFF4CAF50), // Green
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    ),
    BookingPlatform(
      id: 'website',
      name: 'Sito Web',
      color: Color(0xFF9C27B0), // Purple
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    ),
    BookingPlatform(
      id: 'tiktok',
      name: 'TikTok',
      color: Color(0xFF212121), // Black/Dark Gray
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    ),
  ];
}
```

### Unit Test Example for Reservation Model

```dart
// test/features/reservations/data/models/reservation_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/features/reservations/data/models/reservation_model.dart';
import 'package:your_app/features/reservations/domain/entities/reservation.dart';

void main() {
  group('ReservationModel', () {
    test('should serialize to JSON correctly', () {
      final reservation = ReservationModel(
        id: 'test-id',
        roomId: 'room-1',
        platformId: 'booking',
        guest: GuestModel(name: 'Mario Rossi', phone: '+39123456789'),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
        amount: 150.00,
        notes: 'Late arrival',
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      final json = reservation.toJson();

      expect(json['id'], 'test-id');
      expect(json['roomId'], 'room-1');
      expect(json['amount'], 150.00);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'roomId': 'room-1',
        'platformId': 'booking',
        'guest': {'name': 'Mario Rossi', 'phone': '+39123456789'},
        'checkIn': '2024-06-15T00:00:00.000Z',
        'checkOut': '2024-06-18T00:00:00.000Z',
        'amount': 150.00,
        'notes': 'Late arrival',
        'createdAt': '2024-06-01T00:00:00.000Z',
        'updatedAt': '2024-06-01T00:00:00.000Z',
      };

      final reservation = ReservationModel.fromJson(json);

      expect(reservation.id, 'test-id');
      expect(reservation.roomId, 'room-1');
      expect(reservation.guest.name, 'Mario Rossi');
    });
  });

  group('Reservation Entity', () {
    test('should calculate number of nights correctly', () {
      final reservation = Reservation(
        id: 'test-id',
        roomId: 'room-1',
        platformId: 'booking',
        guest: Guest(name: 'Test', phone: null),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      expect(reservation.numberOfNights, 3);
    });

    test('should detect overlapping date ranges', () {
      final reservation = Reservation(
        id: 'test-id',
        roomId: 'room-1',
        platformId: 'booking',
        guest: Guest(name: 'Test', phone: null),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 20),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      // Overlapping range
      expect(
        reservation.overlapsWith(
          DateTime(2024, 6, 18),
          DateTime(2024, 6, 22),
        ),
        isTrue,
      );

      // Non-overlapping range (after)
      expect(
        reservation.overlapsWith(
          DateTime(2024, 6, 20),
          DateTime(2024, 6, 25),
        ),
        isFalse,
      );

      // Non-overlapping range (before)
      expect(
        reservation.overlapsWith(
          DateTime(2024, 6, 10),
          DateTime(2024, 6, 15),
        ),
        isFalse,
      );
    });
  });
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Mutable models with manual equality | freezed immutable models | 2020+ | Less bugs, better testing |
| Mocktio | mocktail | 2022+ | Simpler API, better null safety |
| Platform-specific code in widgets | Repository pattern | 2019+ | Testability, maintainability |
| sqflite for all platforms | Platform-aware storage | 2024+ | Web reliability |

**Deprecated/outdated:**
- sqflite_common_ffi_web for production: Experimental, use idb_shim or Hive instead
- SharedPreferences for complex data: Use only for simple key-value, not reservations

## Open Questions

1. **Web Database Strategy**
   - What we know: sqflite_common_ffi_web is experimental and not recommended for production
   - What's unclear: Whether to use idb_shim (IndexedDB wrapper) or Hive for web storage
   - Recommendation: Start with Hive for simpler cross-platform support, or implement dual-path storage (sqflite for Android, idb_shim for web)

2. **State Management Choice**
   - What we know: Need state management for later phases
   - What's unclear: Which library to use (Riverpod, Bloc, Provider)
   - Recommendation: Defer to Phase 2, but consider Riverpod for its type safety and testability

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK) |
| Config file | None - Flutter SDK built-in |
| Quick run command | `flutter test test/features/reservations/data/models/` |
| Full suite command | `flutter test --coverage` |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| ROOM-01 | 4 room types defined | unit | `flutter test test/features/reservations/domain/entities/room_test.dart` | Wave 0 |
| PLAT-01 | Booking = Blue | unit | `flutter test test/features/reservations/domain/entities/platform_test.dart` | Wave 0 |
| PLAT-02 | Airbnb = Pink/Red | unit | `flutter test test/features/reservations/domain/entities/platform_test.dart` | Wave 0 |
| PLAT-03 | WhatsApp = Green | unit | `flutter test test/features/reservations/domain/entities/platform_test.dart` | Wave 0 |
| PLAT-04 | Website = Purple | unit | `flutter test test/features/reservations/domain/entities/platform_test.dart` | Wave 0 |
| PLAT-05 | TikTok = Black/Dark Gray | unit | `flutter test test/features/reservations/domain/entities/platform_test.dart` | Wave 0 |
| DATA-01 | Local storage reservations | unit | `flutter test test/features/reservations/data/repositories/` | Wave 0 |
| DATA-02 | Local storage platform/colors | unit | `flutter test test/features/reservations/data/repositories/` | Wave 0 |
| DATA-03 | Data persistence | integration | `flutter test test/integration/` | Wave 0 |
| DATA-04 | SQLite Android | unit | `flutter test test/core/database/` | Wave 0 |
| DATA-05 | IndexedDB Web | unit | `flutter test test/core/database/` | Wave 0 |
| TEST-01 | Unit tests for models | unit | `flutter test test/features/reservations/data/models/` | Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/features/reservations/data/models/` (models only, ~5s)
- **Per wave merge:** `flutter test` (all tests, ~30s)
- **Phase gate:** `flutter test --coverage` with >80% coverage for data layer

### Wave 0 Gaps
- [ ] `test/features/reservations/data/models/reservation_model_test.dart` - covers reservation JSON serialization
- [ ] `test/features/reservations/data/models/room_model_test.dart` - covers room model
- [ ] `test/features/reservations/data/models/platform_model_test.dart` - covers platform model with colors
- [ ] `test/features/reservations/data/models/guest_model_test.dart` - covers guest model
- [ ] `test/features/reservations/domain/entities/reservation_test.dart` - covers business logic (overlap detection, night calculation)
- [ ] `test/features/reservations/domain/entities/room_test.dart` - covers room entity and defaults
- [ ] `test/features/reservations/domain/entities/platform_test.dart` - covers platform colors
- [ ] `test/core/database/database_helper_test.dart` - covers database initialization
- [ ] `test/features/reservations/data/repositories/reservation_repository_impl_test.dart` - covers repository with mocked data source

## Sources

### Primary (HIGH confidence)
- [sqflite official documentation](https://pub.dev/packages/sqflite) - Package capabilities, platform support
- [freezed documentation](https://pub.dev/packages/freezed) - Code generation patterns
- [Flutter Clean Architecture 2025](https://blog.csdn.net/weixin_63843758/article/details/155938163) - Modern folder structure

### Secondary (MEDIUM confidence)
- [Flutter sqflite 2.4.2 guide](https://m.blog.csdn.net/2501_93396617/article/details/156064410) - Platform support details
- [Flutter Repository Pattern](https://blog.csdn.net/gitblog_00907/article/details/150850044) - Data layer architecture
- [Flutter TDD Guide](https://m.blog.csdn.net/gitblog_00205/article/details/152245933) - Testing patterns
- [Freezed + json_serializable](https://m.blog.csdn.net/wulong756273/article/details/156573838) - Model code generation

### Tertiary (LOW confidence)
- sqflite_common_ffi_web experimental status - Multiple sources confirm experimental, not for production

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Well-documented packages, stable versions
- Architecture: HIGH - Clean architecture patterns are well-established in Flutter community
- Pitfalls: MEDIUM - Web storage limitation is documented but specific solutions vary
- Testing: HIGH - Flutter test framework is mature and well-documented

**Research date:** 2026-03-04
**Valid until:** 30 days - Flutter packages are relatively stable, but web storage solutions may evolve
