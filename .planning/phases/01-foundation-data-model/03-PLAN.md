---
phase: 01-foundation-data-model
plan: 03
type: tdd
wave: 3
depends_on: [02]
files_modified:
  - lib/features/reservations/data/models/room_model.dart
  - lib/features/reservations/data/models/room_model.freezed.dart
  - lib/features/reservations/data/models/room_model.g.dart
  - lib/features/reservations/data/models/platform_model.dart
  - lib/features/reservations/data/models/platform_model.freezed.dart
  - lib/features/reservations/data/models/platform_model.g.dart
  - lib/features/reservations/data/models/guest_model.dart
  - lib/features/reservations/data/models/guest_model.freezed.dart
  - lib/features/reservations/data/models/guest_model.g.dart
  - lib/features/reservations/data/models/reservation_model.dart
  - lib/features/reservations/data/models/reservation_model.freezed.dart
  - lib/features/reservations/data/models/reservation_model.g.dart
  - test/features/reservations/data/models/room_model_test.dart
  - test/features/reservations/data/models/platform_model_test.dart
  - test/features/reservations/data/models/guest_model_test.dart
  - test/features/reservations/data/models/reservation_model_test.dart
autonomous: true
requirements:
  - DATA-01
  - DATA-02
  - DATA-03
  - TEST-01
must_haves:
  truths:
    - "Data models can be serialized to JSON"
    - "Data models can be deserialized from JSON"
    - "Data models convert to domain entities correctly"
    - "DateTime fields are stored as ISO8601 strings"
    - "Color values are stored as integers"
  artifacts:
    - path: "lib/features/reservations/data/models/room_model.dart"
      provides: "Room data model with JSON serialization"
      exports: ["RoomModel"]
    - path: "lib/features/reservations/data/models/platform_model.dart"
      provides: "Platform data model with color as integer"
      exports: ["PlatformModel"]
    - path: "lib/features/reservations/data/models/guest_model.dart"
      provides: "Guest data model"
      exports: ["GuestModel"]
    - path: "lib/features/reservations/data/models/reservation_model.dart"
      provides: "Reservation data model with JSON serialization"
      exports: ["ReservationModel"]
  key_links:
    - from: "ReservationModel"
      to: "Reservation (entity)"
      via: "toEntity() extension"
      pattern: "toEntity"
    - from: "PlatformModel"
      to: "BookingPlatform (entity)"
      via: "toEntity() extension"
      pattern: "toEntity"
---

<objective>
Create freezed data models with JSON serialization for database storage.

Purpose: Provide immutable data models that can be serialized to/from JSON for SQLite/IndexedDB storage, with conversions to domain entities.
Output: Data models (RoomModel, PlatformModel, GuestModel, ReservationModel) with freezed code generation and unit tests.
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

## Interfaces from Domain Entities (Plan 02)

```dart
// From lib/features/reservations/domain/entities/room.dart
enum RoomType { singleRoom, entireApartment }
class Room {
  final String id;
  final String name;
  final RoomType type;
  final DateTime createdAt;
  static const List<Room> defaultRooms = [...];
}

// From lib/features/reservations/domain/entities/platform.dart
class BookingPlatform {
  final String id;
  final String name;
  final Color color;
  final bool isDefault;
  final DateTime createdAt;
  static const List<BookingPlatform> defaultPlatforms = [...];
}

// From lib/features/reservations/domain/entities/guest.dart
class Guest {
  final String name;
  final String? phone;
}

// From lib/features/reservations/domain/entities/reservation.dart
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
  int get numberOfNights;
  bool overlapsWith(DateTime otherStart, DateTime otherEnd);
}
```

## Database Storage Conventions
- DateTime stored as ISO8601 strings (e.g., "2024-06-15T00:00:00.000Z")
- Color stored as integer color value (e.g., 0xFF2196F3)
- RoomType stored as string enum value
</context>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Write tests for RoomModel</name>
  <files>test/features/reservations/data/models/room_model_test.dart, lib/features/reservations/data/models/room_model.dart</files>
  <behavior>
    - Test 1: RoomModel serializes to JSON correctly
    - Test 2: RoomModel deserializes from JSON correctly
    - Test 3: RoomModel converts to Room entity correctly
    - Test 4: RoomType is stored as string in JSON
  </behavior>
  <action>
RED PHASE: Create test file first

Create test/features/reservations/data/models/room_model_test.dart:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/data/models/room_model.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';

void main() {
  group('RoomModel', () {
    final testDateTime = DateTime(2024, 6, 15, 10, 30);

    test('should serialize to JSON correctly', () {
      final model = RoomModel(
        id: 'room-1',
        name: 'Stanza 1',
        type: 'singleRoom',
        createdAt: testDateTime,
      );

      final json = model.toJson();

      expect(json['id'], 'room-1');
      expect(json['name'], 'Stanza 1');
      expect(json['type'], 'singleRoom');
      expect(json['createdAt'], testDateTime.toIso8601String());
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'room-1',
        'name': 'Stanza 1',
        'type': 'singleRoom',
        'createdAt': testDateTime.toIso8601String(),
      };

      final model = RoomModel.fromJson(json);

      expect(model.id, 'room-1');
      expect(model.name, 'Stanza 1');
      expect(model.type, 'singleRoom');
      expect(model.createdAt, testDateTime);
    });

    test('should convert to Room entity correctly for singleRoom', () {
      final model = RoomModel(
        id: 'room-1',
        name: 'Stanza 1',
        type: 'singleRoom',
        createdAt: testDateTime,
      );

      final entity = model.toEntity();

      expect(entity.id, 'room-1');
      expect(entity.name, 'Stanza 1');
      expect(entity.type, RoomType.singleRoom);
      expect(entity.createdAt, testDateTime);
    });

    test('should convert to Room entity correctly for entireApartment', () {
      final model = RoomModel(
        id: 'apartment',
        name: 'Appartamento Intero',
        type: 'entireApartment',
        createdAt: testDateTime,
      );

      final entity = model.toEntity();

      expect(entity.id, 'apartment');
      expect(entity.name, 'Appartamento Intero');
      expect(entity.type, RoomType.entireApartment);
      expect(entity.createdAt, testDateTime);
    });

    test('should handle round-trip serialization', () {
      final original = RoomModel(
        id: 'room-2',
        name: 'Stanza 2',
        type: 'singleRoom',
        createdAt: testDateTime,
      );

      final json = original.toJson();
      final restored = RoomModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.type, original.type);
      expect(restored.createdAt, original.createdAt);
    });
  });
}
```

GREEN PHASE: Implement the model

Create lib/features/reservations/data/models/room_model.dart:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';

part 'room_model.freezed.dart';
part 'room_model.g.dart';

/// Data model for Room with JSON serialization.
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

/// Extension to convert RoomModel to domain entity.
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

/// Extension to create RoomModel from domain entity.
extension RoomX on Room {
  RoomModel toModel() => RoomModel(
        id: id,
        name: name,
        type: type == RoomType.entireApartment
            ? 'entireApartment'
            : 'singleRoom',
        createdAt: createdAt,
      );
}
```

Run code generation:
```
flutter pub run build_runner build --delete-conflicting-outputs
```

Run tests: `flutter test test/features/reservations/data/models/room_model_test.dart`
</action>
  <verify>
    <automated>flutter pub run build_runner build --delete-conflicting-outputs && flutter test test/features/reservations/data/models/room_model_test.dart</automated>
  </verify>
  <done>
    - RoomModel created with freezed
    - JSON serialization works correctly
    - toEntity() converts to Room correctly
    - All 5 tests pass
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Write tests for PlatformModel</name>
  <files>test/features/reservations/data/models/platform_model_test.dart, lib/features/reservations/data/models/platform_model.dart</files>
  <behavior>
    - Test 1: PlatformModel serializes to JSON correctly
    - Test 2: PlatformModel deserializes from JSON correctly
    - Test 3: PlatformModel converts to BookingPlatform entity correctly
    - Test 4: Color is stored as integer in JSON
    - Test 5: isDefault defaults to false when not provided
  </behavior>
  <action>
RED PHASE: Create test file first

Create test/features/reservations/data/models/platform_model_test.dart:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/data/models/platform_model.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

void main() {
  group('PlatformModel', () {
    final testDateTime = DateTime(2024, 6, 15, 10, 30);
    const testColorValue = 0xFF2196F3;

    test('should serialize to JSON correctly', () {
      final model = PlatformModel(
        id: 'booking',
        name: 'Booking',
        colorValue: testColorValue,
        isDefault: true,
        createdAt: testDateTime,
      );

      final json = model.toJson();

      expect(json['id'], 'booking');
      expect(json['name'], 'Booking');
      expect(json['colorValue'], testColorValue);
      expect(json['isDefault'], 1); // Stored as integer (0 or 1)
      expect(json['createdAt'], testDateTime.toIso8601String());
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'booking',
        'name': 'Booking',
        'colorValue': testColorValue,
        'isDefault': 1,
        'createdAt': testDateTime.toIso8601String(),
      };

      final model = PlatformModel.fromJson(json);

      expect(model.id, 'booking');
      expect(model.name, 'Booking');
      expect(model.colorValue, testColorValue);
      expect(model.isDefault, isTrue);
      expect(model.createdAt, testDateTime);
    });

    test('should convert to BookingPlatform entity correctly', () {
      final model = PlatformModel(
        id: 'booking',
        name: 'Booking',
        colorValue: testColorValue,
        isDefault: true,
        createdAt: testDateTime,
      );

      final entity = model.toEntity();

      expect(entity.id, 'booking');
      expect(entity.name, 'Booking');
      expect(entity.color, const Color(testColorValue));
      expect(entity.isDefault, isTrue);
      expect(entity.createdAt, testDateTime);
    });

    test('should handle isDefault as false', () {
      final json = {
        'id': 'custom',
        'name': 'Custom',
        'colorValue': 0xFF123456,
        'isDefault': 0,
        'createdAt': testDateTime.toIso8601String(),
      };

      final model = PlatformModel.fromJson(json);

      expect(model.isDefault, isFalse);
    });

    test('should handle round-trip serialization', () {
      final original = PlatformModel(
        id: 'airbnb',
        name: 'Airbnb',
        colorValue: 0xFFE91E63,
        isDefault: true,
        createdAt: testDateTime,
      );

      final json = original.toJson();
      final restored = PlatformModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.colorValue, original.colorValue);
      expect(restored.isDefault, original.isDefault);
      expect(restored.createdAt, original.createdAt);
    });
  });
}
```

GREEN PHASE: Implement the model

Create lib/features/reservations/data/models/platform_model.dart:

```dart
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

part 'platform_model.freezed.dart';
part 'platform_model.g.dart';

/// Data model for BookingPlatform with JSON serialization.
/// Color is stored as an integer value.
@freezed
class PlatformModel with _$PlatformModel {
  const factory PlatformModel({
    required String id,
    required String name,
    required int colorValue,
    @Default(false) bool isDefault,
    required DateTime createdAt,
  }) = _PlatformModel;

  factory PlatformModel.fromJson(Map<String, dynamic> json) =>
      _$PlatformModelFromJson(json);
}

/// Extension to convert PlatformModel to domain entity.
extension PlatformModelX on PlatformModel {
  BookingPlatform toEntity() => BookingPlatform(
        id: id,
        name: name,
        color: Color(colorValue),
        isDefault: isDefault,
        createdAt: createdAt,
      );
}

/// Extension to create PlatformModel from domain entity.
extension BookingPlatformX on BookingPlatform {
  PlatformModel toModel() => PlatformModel(
        id: id,
        name: name,
        colorValue: color.value,
        isDefault: isDefault,
        createdAt: createdAt,
      );
}
```

Run code generation:
```
flutter pub run build_runner build --delete-conflicting-outputs
```

Run tests: `flutter test test/features/reservations/data/models/platform_model_test.dart`
</action>
  <verify>
    <automated>flutter pub run build_runner build --delete-conflicting-outputs && flutter test test/features/reservations/data/models/platform_model_test.dart</automated>
  </verify>
  <done>
    - PlatformModel created with freezed
    - Color stored as integer (colorValue)
    - isDefault handled correctly
    - toEntity() converts to BookingPlatform correctly
    - All 5 tests pass
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: Write tests for GuestModel</name>
  <files>test/features/reservations/data/models/guest_model_test.dart, lib/features/reservations/data/models/guest_model.dart</files>
  <behavior>
    - Test 1: GuestModel serializes to JSON correctly
    - Test 2: GuestModel deserializes from JSON correctly
    - Test 3: GuestModel converts to Guest entity correctly
    - Test 4: Null phone is handled correctly
  </behavior>
  <action>
RED PHASE: Create test file first

Create test/features/reservations/data/models/guest_model_test.dart:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/data/models/guest_model.dart';

void main() {
  group('GuestModel', () {
    test('should serialize to JSON correctly with phone', () {
      const model = GuestModel(name: 'Mario Rossi', phone: '+39123456789');

      final json = model.toJson();

      expect(json['name'], 'Mario Rossi');
      expect(json['phone'], '+39123456789');
    });

    test('should serialize to JSON correctly without phone', () {
      const model = GuestModel(name: 'Mario Rossi');

      final json = model.toJson();

      expect(json['name'], 'Mario Rossi');
      expect(json['phone'], isNull);
    });

    test('should deserialize from JSON correctly with phone', () {
      final json = {
        'name': 'Mario Rossi',
        'phone': '+39123456789',
      };

      final model = GuestModel.fromJson(json);

      expect(model.name, 'Mario Rossi');
      expect(model.phone, '+39123456789');
    });

    test('should deserialize from JSON correctly without phone', () {
      final json = {
        'name': 'Mario Rossi',
        'phone': null,
      };

      final model = GuestModel.fromJson(json);

      expect(model.name, 'Mario Rossi');
      expect(model.phone, isNull);
    });

    test('should convert to Guest entity correctly', () {
      const model = GuestModel(name: 'Mario Rossi', phone: '+39123456789');

      final entity = model.toEntity();

      expect(entity.name, 'Mario Rossi');
      expect(entity.phone, '+39123456789');
    });

    test('should handle round-trip serialization', () {
      const original = GuestModel(name: 'Mario Rossi', phone: '+39123456789');

      final json = original.toJson();
      final restored = GuestModel.fromJson(json);

      expect(restored.name, original.name);
      expect(restored.phone, original.phone);
    });
  });
}
```

GREEN PHASE: Implement the model

Create lib/features/reservations/data/models/guest_model.dart:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';

part 'guest_model.freezed.dart';
part 'guest_model.g.dart';

/// Data model for Guest with JSON serialization.
@freezed
class GuestModel with _$GuestModel {
  const factory GuestModel({
    required String name,
    String? phone,
  }) = _GuestModel;

  factory GuestModel.fromJson(Map<String, dynamic> json) =>
      _$GuestModelFromJson(json);
}

/// Extension to convert GuestModel to domain entity.
extension GuestModelX on GuestModel {
  Guest toEntity() => Guest(name: name, phone: phone);
}

/// Extension to create GuestModel from domain entity.
extension GuestX on Guest {
  GuestModel toModel() => GuestModel(name: name, phone: phone);
}
```

Run code generation:
```
flutter pub run build_runner build --delete-conflicting-outputs
```

Run tests: `flutter test test/features/reservations/data/models/guest_model_test.dart`
</action>
  <verify>
    <automated>flutter pub run build_runner build --delete-conflicting-outputs && flutter test test/features/reservations/data/models/guest_model_test.dart</automated>
  </verify>
  <done>
    - GuestModel created with freezed
    - Null phone handled correctly
    - toEntity() converts to Guest correctly
    - All 6 tests pass
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 4: Write tests for ReservationModel</name>
  <files>test/features/reservations/data/models/reservation_model_test.dart, lib/features/reservations/data/models/reservation_model.dart</files>
  <behavior>
    - Test 1: ReservationModel serializes to JSON correctly
    - Test 2: ReservationModel deserializes from JSON correctly
    - Test 3: ReservationModel converts to Reservation entity correctly
    - Test 4: DateTime fields are stored as ISO8601 strings
    - Test 5: Null fields (amount, notes) are handled correctly
    - Test 6: Guest is serialized as nested object
  </behavior>
  <action>
RED PHASE: Create test file first

Create test/features/reservations/data/models/reservation_model_test.dart:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/data/models/reservation_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/guest_model.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';

void main() {
  group('ReservationModel', () {
    final testDateTime = DateTime(2024, 6, 15, 10, 30);
    final checkIn = DateTime(2024, 6, 20);
    final checkOut = DateTime(2024, 6, 25);

    test('should serialize to JSON correctly with all fields', () {
      final model = ReservationModel(
        id: 'res-1',
        roomId: 'room-1',
        platformId: 'booking',
        guest: const GuestModel(name: 'Mario Rossi', phone: '+39123456789'),
        checkIn: checkIn,
        checkOut: checkOut,
        amount: 500.00,
        notes: 'Late arrival',
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      final json = model.toJson();

      expect(json['id'], 'res-1');
      expect(json['roomId'], 'room-1');
      expect(json['platformId'], 'booking');
      expect(json['guest'], isA<Map>());
      expect(json['guest']['name'], 'Mario Rossi');
      expect(json['checkIn'], checkIn.toIso8601String());
      expect(json['checkOut'], checkOut.toIso8601String());
      expect(json['amount'], 500.00);
      expect(json['notes'], 'Late arrival');
      expect(json['createdAt'], testDateTime.toIso8601String());
      expect(json['updatedAt'], testDateTime.toIso8601String());
    });

    test('should serialize to JSON correctly with null fields', () {
      final model = ReservationModel(
        id: 'res-1',
        roomId: 'room-1',
        platformId: 'booking',
        guest: const GuestModel(name: 'Mario Rossi'),
        checkIn: checkIn,
        checkOut: checkOut,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      final json = model.toJson();

      expect(json['amount'], isNull);
      expect(json['notes'], isNull);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'res-1',
        'roomId': 'room-1',
        'platformId': 'booking',
        'guest': {'name': 'Mario Rossi', 'phone': '+39123456789'},
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
        'amount': 500.00,
        'notes': 'Late arrival',
        'createdAt': testDateTime.toIso8601String(),
        'updatedAt': testDateTime.toIso8601String(),
      };

      final model = ReservationModel.fromJson(json);

      expect(model.id, 'res-1');
      expect(model.roomId, 'room-1');
      expect(model.platformId, 'booking');
      expect(model.guest.name, 'Mario Rossi');
      expect(model.guest.phone, '+39123456789');
      expect(model.checkIn, checkIn);
      expect(model.checkOut, checkOut);
      expect(model.amount, 500.00);
      expect(model.notes, 'Late arrival');
      expect(model.createdAt, testDateTime);
      expect(model.updatedAt, testDateTime);
    });

    test('should convert to Reservation entity correctly', () {
      final model = ReservationModel(
        id: 'res-1',
        roomId: 'room-1',
        platformId: 'booking',
        guest: const GuestModel(name: 'Mario Rossi', phone: '+39123456789'),
        checkIn: checkIn,
        checkOut: checkOut,
        amount: 500.00,
        notes: 'Late arrival',
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      final entity = model.toEntity();

      expect(entity.id, 'res-1');
      expect(entity.roomId, 'room-1');
      expect(entity.platformId, 'booking');
      expect(entity.guest.name, 'Mario Rossi');
      expect(entity.guest.phone, '+39123456789');
      expect(entity.checkIn, checkIn);
      expect(entity.checkOut, checkOut);
      expect(entity.amount, 500.00);
      expect(entity.notes, 'Late arrival');
      expect(entity.createdAt, testDateTime);
      expect(entity.updatedAt, testDateTime);
    });

    test('should handle round-trip serialization', () {
      final original = ReservationModel(
        id: 'res-1',
        roomId: 'room-1',
        platformId: 'booking',
        guest: const GuestModel(name: 'Mario Rossi', phone: '+39123456789'),
        checkIn: checkIn,
        checkOut: checkOut,
        amount: 500.00,
        notes: 'Late arrival',
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      final json = original.toJson();
      final restored = ReservationModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.roomId, original.roomId);
      expect(restored.platformId, original.platformId);
      expect(restored.guest.name, original.guest.name);
      expect(restored.guest.phone, original.guest.phone);
      expect(restored.checkIn, original.checkIn);
      expect(restored.checkOut, original.checkOut);
      expect(restored.amount, original.amount);
      expect(restored.notes, original.notes);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
    });

    test('should handle null fields in round-trip', () {
      final original = ReservationModel(
        id: 'res-1',
        roomId: 'room-1',
        platformId: 'booking',
        guest: const GuestModel(name: 'Mario Rossi'),
        checkIn: checkIn,
        checkOut: checkOut,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      final json = original.toJson();
      final restored = ReservationModel.fromJson(json);

      expect(restored.amount, isNull);
      expect(restored.notes, isNull);
      expect(restored.guest.phone, isNull);
    });
  });
}
```

GREEN PHASE: Implement the model

Create lib/features/reservations/data/models/reservation_model.dart:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_prenotazioni/features/reservations/data/models/guest_model.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';

part 'reservation_model.freezed.dart';
part 'reservation_model.g.dart';

/// Data model for Reservation with JSON serialization.
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

/// Extension to convert ReservationModel to domain entity.
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

/// Extension to create ReservationModel from domain entity.
extension ReservationX on Reservation {
  ReservationModel toModel() => ReservationModel(
        id: id,
        roomId: roomId,
        platformId: platformId,
        guest: guest.toModel(),
        checkIn: checkIn,
        checkOut: checkOut,
        amount: amount,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
```

Run code generation:
```
flutter pub run build_runner build --delete-conflicting-outputs
```

Run tests: `flutter test test/features/reservations/data/models/reservation_model_test.dart`
</action>
  <verify>
    <automated>flutter pub run build_runner build --delete-conflicting-outputs && flutter test test/features/reservations/data/models/reservation_model_test.dart</automated>
  </verify>
  <done>
    - ReservationModel created with freezed
    - DateTime fields stored as ISO8601
    - Nested GuestModel serialized correctly
    - Null fields handled correctly
    - toEntity() converts to Reservation correctly
    - All 6 tests pass
  </done>
</task>

</tasks>

<verification>
- [ ] Run code generation: `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] All data model tests pass: `flutter test test/features/reservations/data/models/`
- [ ] Generated files (.freezed.dart, .g.dart) exist for all models
</verification>

<success_criteria>
1. All 4 data models created with freezed and JSON serialization
2. DateTime fields stored as ISO8601 strings
3. Color stored as integer value
4. All models have toEntity() extensions for conversion to domain entities
5. All 22+ unit tests pass
</success_criteria>

<output>
After completion, create `.planning/phases/01-foundation-data-model/01-03-SUMMARY.md`
</output>
