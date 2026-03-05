---
phase: 01-foundation-data-model
plan: 02
type: tdd
wave: 2
depends_on: [01]
files_modified:
  - lib/features/reservations/domain/entities/room.dart
  - lib/features/reservations/domain/entities/platform.dart
  - lib/features/reservations/domain/entities/guest.dart
  - lib/features/reservations/domain/entities/reservation.dart
  - test/features/reservations/domain/entities/room_test.dart
  - test/features/reservations/domain/entities/platform_test.dart
  - test/features/reservations/domain/entities/guest_test.dart
  - test/features/reservations/domain/entities/reservation_test.dart
autonomous: true
requirements:
  - ROOM-01
  - PLAT-01
  - PLAT-02
  - PLAT-03
  - PLAT-04
  - PLAT-05
  - TEST-01
must_haves:
  truths:
    - "4 room types are defined: Stanza 1, Stanza 2, Stanza 3, Appartamento Intero"
    - "5 platforms are defined with correct colors"
    - "Booking platform has blue color (0xFF2196F3)"
    - "Airbnb platform has pink color (0xFFE91E63)"
    - "WhatsApp platform has green color (0xFF4CAF50)"
    - "Website platform has purple color (0xFF9C27B0)"
    - "TikTok platform has black color (0xFF212121)"
    - "Reservation can detect date overlaps"
    - "Reservation calculates number of nights correctly"
  artifacts:
    - path: "lib/features/reservations/domain/entities/room.dart"
      provides: "Room entity with 4 predefined types"
      exports: ["Room", "RoomType"]
    - path: "lib/features/reservations/domain/entities/platform.dart"
      provides: "Platform entity with 5 predefined platforms and colors"
      exports: ["BookingPlatform"]
    - path: "lib/features/reservations/domain/entities/guest.dart"
      provides: "Guest entity"
      exports: ["Guest"]
    - path: "lib/features/reservations/domain/entities/reservation.dart"
      provides: "Reservation entity with business logic"
      exports: ["Reservation"]
  key_links:
    - from: "Reservation"
      to: "Room"
      via: "roomId reference"
      pattern: "roomId.*String"
    - from: "Reservation"
      to: "BookingPlatform"
      via: "platformId reference"
      pattern: "platformId.*String"
---

<objective>
Define domain entities with business logic following TDD methodology.

Purpose: Create the core business entities that represent the domain model. These are pure Dart classes with no external dependencies.
Output: Domain entities (Room, Platform, Guest, Reservation) with comprehensive unit tests.
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

## Locked Colors from Requirements

| Platform | Color Value | Color Name |
|----------|-------------|------------|
| Booking | 0xFF2196F3 | Blue |
| Airbnb | 0xFFE91E63 | Pink/Red |
| WhatsApp | 0xFF4CAF50 | Green |
| Website | 0xFF9C27B0 | Purple |
| TikTok | 0xFF212121 | Black/Dark Gray |

## Room Types (ROOM-01)

1. Stanza 1 (single room)
2. Stanza 2 (single room)
3. Stanza 3 (single room)
4. Appartamento Intero (entire apartment - blocks all rooms)
</context>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Write tests for Room entity</name>
  <files>test/features/reservations/domain/entities/room_test.dart, lib/features/reservations/domain/entities/room.dart</files>
  <behavior>
    - Test 1: Room has id, name, type, and createdAt fields
    - Test 2: RoomType enum has singleRoom and entireApartment values
    - Test 3: defaultRooms contains exactly 4 rooms
    - Test 4: Stanza 1, 2, 3 have type singleRoom
    - Test 5: Appartamento Intero has type entireApartment
    - Test 6: Each default room has correct id and name
  </behavior>
  <action>
RED PHASE: Create test file first

Create test/features/reservations/domain/entities/room_test.dart:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';

void main() {
  group('Room', () {
    group('RoomType', () {
      test('should have singleRoom and entireApartment values', () {
        expect(RoomType.values, contains(RoomType.singleRoom));
        expect(RoomType.values, contains(RoomType.entireApartment));
        expect(RoomType.values.length, 2);
      });
    });

    group('defaultRooms', () {
      test('should contain exactly 4 rooms', () {
        expect(Room.defaultRooms.length, 4);
      });

      test('Stanza 1 should have correct properties', () {
        final room = Room.defaultRooms.firstWhere((r) => r.id == 'room-1');
        expect(room.name, 'Stanza 1');
        expect(room.type, RoomType.singleRoom);
      });

      test('Stanza 2 should have correct properties', () {
        final room = Room.defaultRooms.firstWhere((r) => r.id == 'room-2');
        expect(room.name, 'Stanza 2');
        expect(room.type, RoomType.singleRoom);
      });

      test('Stanza 3 should have correct properties', () {
        final room = Room.defaultRooms.firstWhere((r) => r.id == 'room-3');
        expect(room.name, 'Stanza 3');
        expect(room.type, RoomType.singleRoom);
      });

      test('Appartamento Intero should have correct properties', () {
        final room = Room.defaultRooms.firstWhere((r) => r.id == 'apartment');
        expect(room.name, 'Appartamento Intero');
        expect(room.type, RoomType.entireApartment);
      });

      test('all rooms should have unique ids', () {
        final ids = Room.defaultRooms.map((r) => r.id).toList();
        expect(ids.toSet().length, ids.length);
      });
    });

    group('Room entity', () {
      test('should create a room with all required fields', () {
        final room = Room(
          id: 'test-id',
          name: 'Test Room',
          type: RoomType.singleRoom,
          createdAt: DateTime(2024, 1, 1),
        );

        expect(room.id, 'test-id');
        expect(room.name, 'Test Room');
        expect(room.type, RoomType.singleRoom);
        expect(room.createdAt, DateTime(2024, 1, 1));
      });
    });
  });
}
```

GREEN PHASE: Implement the entity

Create lib/features/reservations/domain/entities/room.dart:

```dart
/// Types of rooms available in the property.
enum RoomType {
  singleRoom,
  entireApartment,
}

/// Represents a bookable room in the property.
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

  /// Predefined rooms for this app (ROOM-01).
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
```

Run tests: `flutter test test/features/reservations/domain/entities/room_test.dart`
</action>
  <verify>
    <automated>flutter test test/features/reservations/domain/entities/room_test.dart</automated>
  </verify>
  <done>
    - Room entity created with id, name, type, createdAt fields
    - RoomType enum has singleRoom and entireApartment
    - 4 default rooms defined (Stanza 1, 2, 3, Appartamento Intero)
    - All 7 tests pass
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Write tests for Platform entity</name>
  <files>test/features/reservations/domain/entities/platform_test.dart, lib/features/reservations/domain/entities/platform.dart</files>
  <behavior>
    - Test 1: Platform has id, name, color, isDefault, createdAt fields
    - Test 2: defaultPlatforms contains exactly 5 platforms
    - Test 3: Booking has blue color (0xFF2196F3)
    - Test 4: Airbnb has pink color (0xFFE91E63)
    - Test 5: WhatsApp has green color (0xFF4CAF50)
    - Test 6: Website has purple color (0xFF9C27B0)
    - Test 7: TikTok has black color (0xFF212121)
    - Test 8: All default platforms have isDefault = true
  </behavior>
  <action>
RED PHASE: Create test file first

Create test/features/reservations/domain/entities/platform_test.dart:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

void main() {
  group('BookingPlatform', () {
    group('defaultPlatforms', () {
      test('should contain exactly 5 platforms', () {
        expect(BookingPlatform.defaultPlatforms.length, 5);
      });

      test('all default platforms should have isDefault = true', () {
        for (final platform in BookingPlatform.defaultPlatforms) {
          expect(platform.isDefault, isTrue,
              reason: '${platform.name} should be a default platform');
        }
      });

      test('Booking should have blue color (PLAT-01)', () {
        final platform = BookingPlatform.defaultPlatforms
            .firstWhere((p) => p.id == 'booking');
        expect(platform.name, 'Booking');
        expect(platform.color, const Color(0xFF2196F3));
      });

      test('Airbnb should have pink/red color (PLAT-02)', () {
        final platform = BookingPlatform.defaultPlatforms
            .firstWhere((p) => p.id == 'airbnb');
        expect(platform.name, 'Airbnb');
        expect(platform.color, const Color(0xFFE91E63));
      });

      test('WhatsApp should have green color (PLAT-03)', () {
        final platform = BookingPlatform.defaultPlatforms
            .firstWhere((p) => p.id == 'whatsapp');
        expect(platform.name, 'WhatsApp');
        expect(platform.color, const Color(0xFF4CAF50));
      });

      test('Website should have purple color (PLAT-04)', () {
        final platform = BookingPlatform.defaultPlatforms
            .firstWhere((p) => p.id == 'website');
        expect(platform.name, 'Sito Web');
        expect(platform.color, const Color(0xFF9C27B0));
      });

      test('TikTok should have black/dark gray color (PLAT-05)', () {
        final platform = BookingPlatform.defaultPlatforms
            .firstWhere((p) => p.id == 'tiktok');
        expect(platform.name, 'TikTok');
        expect(platform.color, const Color(0xFF212121));
      });

      test('all platforms should have unique ids', () {
        final ids = BookingPlatform.defaultPlatforms.map((p) => p.id).toList();
        expect(ids.toSet().length, ids.length);
      });
    });

    group('BookingPlatform entity', () {
      test('should create a platform with all required fields', () {
        const platform = BookingPlatform(
          id: 'custom',
          name: 'Custom Platform',
          color: Color(0xFF123456),
          isDefault: false,
          createdAt: DateTime(2024, 1, 1),
        );

        expect(platform.id, 'custom');
        expect(platform.name, 'Custom Platform');
        expect(platform.color, const Color(0xFF123456));
        expect(platform.isDefault, false);
        expect(platform.createdAt, DateTime(2024, 1, 1));
      });
    });
  });
}
```

GREEN PHASE: Implement the entity

Create lib/features/reservations/domain/entities/platform.dart:

```dart
import 'package:flutter/material.dart';

/// Represents a booking platform with its associated color.
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

  /// Default platforms with locked colors (PLAT-01 to PLAT-05).
  static const List<BookingPlatform> defaultPlatforms = [
    BookingPlatform(
      id: 'booking',
      name: 'Booking',
      color: Color(0xFF2196F3), // Blue (PLAT-01)
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    ),
    BookingPlatform(
      id: 'airbnb',
      name: 'Airbnb',
      color: Color(0xFFE91E63), // Pink/Red (PLAT-02)
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    ),
    BookingPlatform(
      id: 'whatsapp',
      name: 'WhatsApp',
      color: Color(0xFF4CAF50), // Green (PLAT-03)
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    ),
    BookingPlatform(
      id: 'website',
      name: 'Sito Web',
      color: Color(0xFF9C27B0), // Purple (PLAT-04)
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    ),
    BookingPlatform(
      id: 'tiktok',
      name: 'TikTok',
      color: Color(0xFF212121), // Black/Dark Gray (PLAT-05)
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    ),
  ];
}
```

Run tests: `flutter test test/features/reservations/domain/entities/platform_test.dart`
</action>
  <verify>
    <automated>flutter test test/features/reservations/domain/entities/platform_test.dart</automated>
  </verify>
  <done>
    - BookingPlatform entity created with id, name, color, isDefault, createdAt
    - 5 default platforms with locked colors defined
    - All 9 tests pass
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: Write tests for Guest entity</name>
  <files>test/features/reservations/domain/entities/guest_test.dart, lib/features/reservations/domain/entities/guest.dart</files>
  <behavior>
    - Test 1: Guest has name and optional phone fields
    - Test 2: Guest can be created with name only
    - Test 3: Guest can be created with name and phone
    - Test 4: Two guests with same data are equal
  </behavior>
  <action>
RED PHASE: Create test file first

Create test/features/reservations/domain/entities/guest_test.dart:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';

void main() {
  group('Guest', () {
    test('should create a guest with name only', () {
      const guest = Guest(name: 'Mario Rossi');

      expect(guest.name, 'Mario Rossi');
      expect(guest.phone, isNull);
    });

    test('should create a guest with name and phone', () {
      const guest = Guest(name: 'Mario Rossi', phone: '+39123456789');

      expect(guest.name, 'Mario Rossi');
      expect(guest.phone, '+39123456789');
    });

    test('should support equality', () {
      const guest1 = Guest(name: 'Mario Rossi', phone: '+39123456789');
      const guest2 = Guest(name: 'Mario Rossi', phone: '+39123456789');
      const guest3 = Guest(name: 'Giuseppe Verdi', phone: '+39123456789');

      expect(guest1, equals(guest2));
      expect(guest1, isNot(equals(guest3)));
    });

    test('should have readable toString', () {
      const guest = Guest(name: 'Mario Rossi', phone: '+39123456789');

      expect(guest.toString(), contains('Mario Rossi'));
    });
  });
}
```

GREEN PHASE: Implement the entity

Create lib/features/reservations/domain/entities/guest.dart:

```dart
/// Represents a guest making a reservation.
class Guest {
  final String name;
  final String? phone;

  const Guest({
    required this.name,
    this.phone,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Guest &&
        other.name == name &&
        other.phone == phone;
  }

  @override
  int get hashCode => Object.hash(name, phone);

  @override
  String toString() => 'Guest(name: $name, phone: $phone)';
}
```

Run tests: `flutter test test/features/reservations/domain/entities/guest_test.dart`
</action>
  <verify>
    <automated>flutter test test/features/reservations/domain/entities/guest_test.dart</automated>
  </verify>
  <done>
    - Guest entity created with name and optional phone
    - Equality implemented correctly
    - All 4 tests pass
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 4: Write tests for Reservation entity with business logic</name>
  <files>test/features/reservations/domain/entities/reservation_test.dart, lib/features/reservations/domain/entities/reservation.dart</files>
  <behavior>
    - Test 1: Reservation has all required fields
    - Test 2: numberOfNights calculates correctly (3 nights between June 15-18)
    - Test 3: overlapsWith detects overlapping ranges correctly
    - Test 4: overlapsWith returns false for adjacent dates (check-out day can be next check-in)
    - Test 5: overlapsWith returns false for ranges before and after
    - Test 6: Two reservations with same data are equal
  </behavior>
  <action>
RED PHASE: Create test file first

Create test/features/reservations/domain/entities/reservation_test.dart:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';

void main() {
  group('Reservation', () {
    late Reservation testReservation;

    setUp(() {
      testReservation = Reservation(
        id: 'test-id',
        roomId: 'room-1',
        platformId: 'booking',
        guest: const Guest(name: 'Mario Rossi', phone: '+39123456789'),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
        amount: 150.00,
        notes: 'Late arrival',
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );
    });

    group('fields', () {
      test('should have all required fields', () {
        expect(testReservation.id, 'test-id');
        expect(testReservation.roomId, 'room-1');
        expect(testReservation.platformId, 'booking');
        expect(testReservation.guest.name, 'Mario Rossi');
        expect(testReservation.checkIn, DateTime(2024, 6, 15));
        expect(testReservation.checkOut, DateTime(2024, 6, 18));
        expect(testReservation.amount, 150.00);
        expect(testReservation.notes, 'Late arrival');
        expect(testReservation.createdAt, DateTime(2024, 6, 1));
        expect(testReservation.updatedAt, DateTime(2024, 6, 1));
      });

      test('should allow null amount and notes', () {
        final reservation = Reservation(
          id: 'test-id',
          roomId: 'room-1',
          platformId: 'booking',
          guest: const Guest(name: 'Test'),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 18),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        expect(reservation.amount, isNull);
        expect(reservation.notes, isNull);
      });
    });

    group('numberOfNights', () {
      test('should calculate 3 nights for June 15-18', () {
        expect(testReservation.numberOfNights, 3);
      });

      test('should calculate 1 night for same-day check-in and next-day check-out', () {
        final reservation = Reservation(
          id: 'test-id',
          roomId: 'room-1',
          platformId: 'booking',
          guest: const Guest(name: 'Test'),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 16),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        expect(reservation.numberOfNights, 1);
      });

      test('should calculate 7 nights for a week stay', () {
        final reservation = Reservation(
          id: 'test-id',
          roomId: 'room-1',
          platformId: 'booking',
          guest: const Guest(name: 'Test'),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 22),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        expect(reservation.numberOfNights, 7);
      });
    });

    group('overlapsWith', () {
      test('should return true for overlapping range (partial overlap)', () {
        // Test reservation: June 15-18
        // Overlapping: June 17-20
        expect(
          testReservation.overlapsWith(
            DateTime(2024, 6, 17),
            DateTime(2024, 6, 20),
          ),
          isTrue,
        );
      });

      test('should return true for completely contained range', () {
        // Test reservation: June 15-18
        // Contained: June 16-17
        expect(
          testReservation.overlapsWith(
            DateTime(2024, 6, 16),
            DateTime(2024, 6, 17),
          ),
          isTrue,
        );
      });

      test('should return true for range that contains reservation', () {
        // Test reservation: June 15-18
        // Containing: June 14-19
        expect(
          testReservation.overlapsWith(
            DateTime(2024, 6, 14),
            DateTime(2024, 6, 19),
          ),
          isTrue,
        );
      });

      test('should return false for adjacent range after (check-out day can be next check-in)', () {
        // Test reservation: June 15-18
        // Adjacent after: June 18-20
        expect(
          testReservation.overlapsWith(
            DateTime(2024, 6, 18),
            DateTime(2024, 6, 20),
          ),
          isFalse,
        );
      });

      test('should return false for adjacent range before (check-in day can be previous check-out)', () {
        // Test reservation: June 15-18
        // Adjacent before: June 13-15
        expect(
          testReservation.overlapsWith(
            DateTime(2024, 6, 13),
            DateTime(2024, 6, 15),
          ),
          isFalse,
        );
      });

      test('should return false for range completely before', () {
        // Test reservation: June 15-18
        // Before: June 10-14
        expect(
          testReservation.overlapsWith(
            DateTime(2024, 6, 10),
            DateTime(2024, 6, 14),
          ),
          isFalse,
        );
      });

      test('should return false for range completely after', () {
        // Test reservation: June 15-18
        // After: June 20-25
        expect(
          testReservation.overlapsWith(
            DateTime(2024, 6, 20),
            DateTime(2024, 6, 25),
          ),
          isFalse,
        );
      });
    });

    group('equality', () {
      test('should support equality', () {
        final reservation1 = Reservation(
          id: 'test-id',
          roomId: 'room-1',
          platformId: 'booking',
          guest: const Guest(name: 'Mario Rossi'),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 18),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        final reservation2 = Reservation(
          id: 'test-id',
          roomId: 'room-1',
          platformId: 'booking',
          guest: const Guest(name: 'Mario Rossi'),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 18),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        expect(reservation1, equals(reservation2));
      });
    });
  });
}
```

GREEN PHASE: Implement the entity

Create lib/features/reservations/domain/entities/reservation.dart:

```dart
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';

/// Represents a reservation for a room.
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

  /// Calculates the number of nights for this reservation.
  int get numberOfNights => checkOut.difference(checkIn).inDays;

  /// Checks if this reservation overlaps with a given date range.
  ///
  /// Returns true if there is any overlap between the reservation dates
  /// and the provided range. Note: Adjacent dates (where check-out equals
  /// the provided start, or check-in equals the provided end) do NOT
  /// count as overlapping, allowing same-day turnarounds.
  bool overlapsWith(DateTime otherStart, DateTime otherEnd) {
    // A reservation overlaps if:
    // checkIn < otherEnd AND checkOut > otherStart
    // This allows adjacent reservations (check-out = otherStart is OK)
    return checkIn.isBefore(otherEnd) && checkOut.isAfter(otherStart);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reservation &&
        other.id == id &&
        other.roomId == roomId &&
        other.platformId == platformId &&
        other.guest == guest &&
        other.checkIn == checkIn &&
        other.checkOut == checkOut &&
        other.amount == amount &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        roomId,
        platformId,
        guest,
        checkIn,
        checkOut,
        amount,
        notes,
        createdAt,
        updatedAt,
      );
}
```

Run tests: `flutter test test/features/reservations/domain/entities/reservation_test.dart`
</action>
  <verify>
    <automated>flutter test test/features/reservations/domain/entities/reservation_test.dart</automated>
  </verify>
  <done>
    - Reservation entity created with all required fields
    - numberOfNights calculates correctly
    - overlapsWith detects overlaps correctly (allowing same-day turnarounds)
    - All 14 tests pass
  </done>
</task>

</tasks>

<verification>
- [ ] All domain entity tests pass: `flutter test test/features/reservations/domain/entities/`
- [ ] Room entity with 4 predefined rooms
- [ ] BookingPlatform entity with 5 predefined platforms and correct colors
- [ ] Guest entity with name and optional phone
- [ ] Reservation entity with business logic (numberOfNights, overlapsWith)
</verification>

<success_criteria>
1. All 4 domain entities defined (Room, BookingPlatform, Guest, Reservation)
2. Room has 4 predefined types matching ROOM-01
3. Platform colors match PLAT-01 through PLAT-05 exactly
4. Reservation.overlapsWith correctly handles edge cases
5. All unit tests pass (34+ tests total)
</success_criteria>

<output>
After completion, create `.planning/phases/01-foundation-data-model/01-02-SUMMARY.md`
</output>
