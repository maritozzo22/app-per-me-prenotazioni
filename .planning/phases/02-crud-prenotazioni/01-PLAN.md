---
phase: 02-crud-prenotazioni
plan: 01
type: execute
wave: 1
depends_on: [01-foundation-data-model]
files_modified:
  - pubspec.yaml
  - lib/features/reservations/domain/entities/reservation.dart
  - lib/features/reservations/domain/value_objects/payment_status.dart
  - lib/features/reservations/data/models/reservation_model.dart
  - lib/core/database/database_schema.dart
  - lib/features/reservations/domain/services/reservation_validation_service.dart
autonomous: true
requirements:
  - RES-04
  - RES-10
must_haves:
  truths:
    - "Payment status enum exists with received/pending values"
    - "Validation service can detect date overlaps"
    - "Apartment blocking logic is implemented"
  artifacts:
    - path: "lib/features/reservations/domain/value_objects/payment_status.dart"
      provides: "Payment status enum for tracking"
      exports: ["PaymentStatus"]
    - path: "lib/features/reservations/domain/services/reservation_validation_service.dart"
      provides: "Business validation logic"
      exports: ["ReservationValidationService", "ValidationResult"]
  key_links:
    - from: "ReservationValidationService"
      to: "ReservationRepository"
      via: "getReservationsForDateRange"
      pattern: "overlap detection"
---

<objective>
Extend data model with payment status and implement validation service for date overlap detection and apartment blocking logic.

Purpose: Establish business rules layer before building UI forms.
Output: Payment status value object, validation service with comprehensive business logic.
</objective>

<execution_context>
@./.claude/get-shit-done/workflows/execute-plan.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/phases/02-crud-prenotazioni/02-CONTEXT.md

## Critical Context from Phase 2 Discussion

### User Decisions Applied
1. **Amount field**: Include payment status toggle (received vs pending)
2. **Validation**: Real-time, inline errors + show conflicting reservation details
3. **Apartment blocking**: Block apartment if ANY room is booked, show which room blocks it

### Existing Code (Phase 1)
- `Reservation` entity has `overlapsWith(DateTime, DateTime)` method
- `Room` entity has `RoomType` enum (singleRoom, entireApartment)
- `ReservationRepository` has `getReservationsForDateRange(start, end)`
- Database schema exists for reservations table

### Technical Decisions
- Use Riverpod for state management (Phase 4+)
- Keep validation in domain layer (clean architecture)
- flutter_form_builder for form handling (later wave)
</context>

<tasks>

<task type="auto">
  <name>Task 1: Add PaymentStatus value object</name>
  <files>lib/features/reservations/domain/value_objects/payment_status.dart</files>
  <action>
Create the PaymentStatus enum for tracking payment state:

```dart
// lib/features/reservations/domain/value_objects/payment_status.dart

/// Payment status for tracking reservation payments.
enum PaymentStatus {
  received('Ricevuto', Icons.check_circle, Colors.green),
  pending('In attesa', Icons.pending, Colors.orange);

  final String label;
  final IconData icon;
  final Color color;

  const PaymentStatus(this.label, this.icon, this.color);
}
```

Add the import for Icons and Colors at the top:
```dart
import 'package:flutter/material.dart';
```
</action>
  <verify>
    <automated>flutter analyze lib/features/reservations/domain/value_objects/</automated>
  </verify>
  <done>
    - PaymentStatus enum created with received/pending values
    - Each status has label, icon, and color for UI display
    - `flutter analyze` passes
  </done>
</task>

<task type="auto">
  <name>Task 2: Update Reservation entity with paymentStatus</name>
  <files>lib/features/reservations/domain/entities/reservation.dart</files>
  <action>
Update the Reservation entity to include payment status:

1. Add import:
```dart
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
```

2. Add paymentStatus field (defaults to pending for new reservations):
```dart
class Reservation {
  final String id;
  final String roomId;
  final String platformId;
  final Guest guest;
  final DateTime checkIn;
  final DateTime checkOut;
  final double? amount;
  final PaymentStatus paymentStatus;  // NEW
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
    this.paymentStatus = PaymentStatus.pending,  // NEW with default
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
```

3. Update equality operator and hashCode to include paymentStatus.
</action>
  <verify>
    <automated>flutter analyze lib/features/reservations/domain/entities/reservation.dart</automated>
  </verify>
  <done>
    - Reservation entity has paymentStatus field
    - Default value is PaymentStatus.pending
    - Equality and hashCode updated
  </done>
</task>

<task type="auto">
  <name>Task 3: Update ReservationModel and database schema</name>
  <files>
    lib/features/reservations/data/models/reservation_model.dart
    lib/core/database/database_schema.dart
    lib/features/reservations/data/datasources/local/reservation_local_data_source.dart
  </files>
  <action>
Update the data layer to support payment status:

1. In `database_schema.dart`, add constant for the new column:
```dart
static const String reservationPaymentStatus = 'payment_status';
```

2. In `database_helper_native.dart` (or equivalent), add column to CREATE TABLE:
```sql
payment_status TEXT NOT NULL DEFAULT 'pending'
```

3. Update `ReservationModel`:
```dart
@freezed
class ReservationModel with _$ReservationModel {
  @JsonSerializable(explicitToJson: true)
  const factory ReservationModel({
    required String id,
    required String roomId,
    required String platformId,
    required GuestModel guest,
    required DateTime checkIn,
    required DateTime checkOut,
    double? amount,
    @Default(PaymentStatus.pending) PaymentStatus paymentStatus,  // NEW
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ReservationModel;
}
```

4. Add JSON converter for PaymentStatus enum (create `payment_status_converter.dart`):
```dart
class PaymentStatusConverter implements JsonConverter<PaymentStatus, String> {
  const PaymentStatusConverter();

  @override
  PaymentStatus fromJson(String json) =>
      PaymentStatus.values.firstWhere((e) => e.name == json, orElse: () => PaymentStatus.pending);

  @override
  String toJson(PaymentStatus object) => object.name;
}
```

5. Update `ReservationLocalDataSource` to map the new field.

Note: Increment database version and add migration for existing databases.
</action>
  <verify>
    <automated>flutter pub run build_runner build --delete-conflicting-outputs && flutter analyze</automated>
  </verify>
  <done>
    - Database schema updated with payment_status column
    - ReservationModel includes paymentStatus with JSON serialization
    - PaymentStatusConverter handles enum <-> string conversion
    - Local data source maps payment status correctly
    - Database version incremented with migration
  </done>
</task>

<task type="auto">
  <name>Task 4: Create ValidationResult and ReservationValidationService</name>
  <files>
    lib/features/reservations/domain/services/reservation_validation_service.dart
    lib/features/reservations/domain/services/validation_result.dart
  </files>
  <action>
Create the validation service with business rules:

```dart
// lib/features/reservations/domain/services/validation_result.dart

/// Result of a validation check.
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final Map<String, dynamic>? details;

  const ValidationResult.success()
      : isValid = true,
        errorMessage = null,
        details = null;

  const ValidationResult.failure(this.errorMessage, {this.details})
      : isValid = false;

  bool get isInvalid => !isValid;
}

/// Specific validation errors for reservations.
enum ReservationValidationError {
  checkOutBeforeCheckIn,
  dateOverlap,
  apartmentBlocked,
  apartmentBlocksRooms,
}
```

```dart
// lib/features/reservations/domain/services/reservation_validation_service.dart

import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'validation_result.dart';

/// Service for validating reservation business rules.
class ReservationValidationService {
  final ReservationRepository _repository;

  ReservationValidationService(this._repository);

  /// Validates check-out is after check-in.
  ValidationResult validateDates(DateTime checkIn, DateTime checkOut) {
    if (!checkOut.isAfter(checkIn)) {
      return const ValidationResult.failure(
        'La data di check-out deve essere successiva al check-in',
      );
    }
    return const ValidationResult.success();
  }

  /// Checks if a room is available for the given date range.
  Future<ValidationResult> checkRoomAvailability({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    String? excludeReservationId,
  }) async {
    final existing = await _repository.getReservationsForDateRange(checkIn, checkOut);

    // Filter by room and exclude current reservation if editing
    final conflicting = existing.where((r) =>
      r.roomId == roomId &&
      r.id != excludeReservationId &&
      r.overlapsWith(checkIn, checkOut)
    ).toList();

    if (conflicting.isNotEmpty) {
      final conflict = conflicting.first;
      return ValidationResult.failure(
        'Sovrapposizione date: ${conflict.roomId} già prenotata da ${conflict.guest.name} '
        '(${_formatDateRange(conflict.checkIn, conflict.checkOut)})',
        details: {'conflictingReservation': conflict},
      );
    }

    return const ValidationResult.success();
  }

  /// Checks if apartment can be booked (no individual rooms booked).
  Future<ValidationResult> checkApartmentAvailability({
    required DateTime checkIn,
    required DateTime checkOut,
    String? excludeReservationId,
  }) async {
    const apartmentRoomIds = ['room-1', 'room-2', 'room-3'];
    final existing = await _repository.getReservationsForDateRange(checkIn, checkOut);

    // Find any room that conflicts
    for (final room in apartmentRoomIds) {
      final conflicting = existing.where((r) =>
        r.roomId == room &&
        r.id != excludeReservationId &&
        r.overlapsWith(checkIn, checkOut)
      ).toList();

      if (conflicting.isNotEmpty) {
        final conflict = conflicting.first;
        return ValidationResult.failure(
          'Appartamento non disponibile: ${_getRoomName(room)} occupata '
          '${_formatDateRange(conflict.checkIn, conflict.checkOut)}',
          details: {
            'blockingRoom': room,
            'blockingReservation': conflict,
          },
        );
      }
    }

    return const ValidationResult.success();
  }

  /// Validates that booking apartment won't conflict with existing room bookings.
  /// Call this when user tries to book the apartment.
  Future<ValidationResult> validateApartmentBooking({
    required DateTime checkIn,
    required DateTime checkOut,
    String? excludeReservationId,
  }) async {
    return checkApartmentAvailability(
      checkIn: checkIn,
      checkOut: checkOut,
      excludeReservationId: excludeReservationId,
    );
  }

  /// Checks if booking a room conflicts with an existing apartment booking.
  Future<ValidationResult> checkRoomAgainstApartment({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    String? excludeReservationId,
  }) async {
    final existing = await _repository.getReservationsForDateRange(checkIn, checkOut);

    // Check if apartment is booked for these dates
    final apartmentConflict = existing.where((r) =>
      r.roomId == 'apartment' &&
      r.id != excludeReservationId &&
      r.overlapsWith(checkIn, checkOut)
    ).toList();

    if (apartmentConflict.isNotEmpty) {
      final conflict = apartmentConflict.first;
      return ValidationResult.failure(
        'Stanza non disponibile: Appartamento Intero prenotato '
        '${_formatDateRange(conflict.checkIn, conflict.checkOut)}',
        details: {'blockingReservation': conflict},
      );
    }

    return const ValidationResult.success();
  }

  /// Full validation for a new or updated reservation.
  Future<ValidationResult> validateReservation({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    String? excludeReservationId,
  }) async {
    // 1. Check dates
    final dateResult = validateDates(checkIn, checkOut);
    if (dateResult.isInvalid) return dateResult;

    // 2. Check room availability (including apartment logic)
    if (roomId == 'apartment') {
      final apartmentResult = await validateApartmentBooking(
        checkIn: checkIn,
        checkOut: checkOut,
        excludeReservationId: excludeReservationId,
      );
      if (apartmentResult.isInvalid) return apartmentResult;
    } else {
      // Check room availability
      final roomResult = await checkRoomAvailability(
        roomId: roomId,
        checkIn: checkIn,
        checkOut: checkOut,
        excludeReservationId: excludeReservationId,
      );
      if (roomResult.isInvalid) return roomResult;

      // Check against apartment booking
      final apartmentResult = await checkRoomAgainstApartment(
        roomId: roomId,
        checkIn: checkIn,
        checkOut: checkOut,
        excludeReservationId: excludeReservationId,
      );
      if (apartmentResult.isInvalid) return apartmentResult;
    }

    return const ValidationResult.success();
  }

  String _formatDateRange(DateTime start, DateTime end) {
    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }

  String _getRoomName(String roomId) {
    switch (roomId) {
      case 'room-1': return 'Stanza 1';
      case 'room-2': return 'Stanza 2';
      case 'room-3': return 'Stanza 3';
      default: return roomId;
    }
  }
}
```
</action>
  <verify>
    <automated>flutter analyze lib/features/reservations/domain/services/</automated>
  </verify>
  <done>
    - ValidationResult class created for validation results
    - ReservationValidationService with all business rules
    - Date validation (check-out > check-in)
    - Room availability checking
    - Apartment blocking logic (both directions)
    - Clear Italian error messages with details
  </done>
</task>

<task type="auto">
  <name>Task 5: Write unit tests for validation service</name>
  <files>
    test/features/reservations/domain/services/reservation_validation_service_test.dart
    test/features/reservations/domain/value_objects/payment_status_test.dart
  </files>
  <action>
Create comprehensive unit tests for the new validation logic:

```dart
// test/features/reservations/domain/services/reservation_validation_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/reservation_validation_service.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  late ReservationValidationService service;
  late MockReservationRepository mockRepository;

  setUp(() {
    mockRepository = MockReservationRepository();
    service = ReservationValidationService(mockRepository);
  });

  group('validateDates', () {
    test('should return success when check-out is after check-in', () {
      final result = service.validateDates(
        DateTime(2024, 6, 15),
        DateTime(2024, 6, 18),
      );
      expect(result.isValid, isTrue);
    });

    test('should return failure when check-out equals check-in', () {
      final result = service.validateDates(
        DateTime(2024, 6, 15),
        DateTime(2024, 6, 15),
      );
      expect(result.isInvalid, isTrue);
      expect(result.errorMessage, contains('check-out deve essere successiva'));
    });

    test('should return failure when check-out is before check-in', () {
      final result = service.validateDates(
        DateTime(2024, 6, 18),
        DateTime(2024, 6, 15),
      );
      expect(result.isInvalid, isTrue);
    });
  });

  group('checkRoomAvailability', () {
    test('should return success when no conflicting reservations', () async {
      when(() => mockRepository.getReservationsForDateRange(any(), any()))
          .thenAnswer((_) async => []);

      final result = await service.checkRoomAvailability(
        roomId: 'room-1',
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
      );

      expect(result.isValid, isTrue);
    });

    test('should return failure with details when overlap exists', () async {
      final existingReservation = Reservation(
        id: 'existing-id',
        roomId: 'room-1',
        platformId: 'booking',
        guest: const Guest(name: 'Mario Rossi'),
        checkIn: DateTime(2024, 6, 16),
        checkOut: DateTime(2024, 6, 20),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      when(() => mockRepository.getReservationsForDateRange(any(), any()))
          .thenAnswer((_) async => [existingReservation]);

      final result = await service.checkRoomAvailability(
        roomId: 'room-1',
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
      );

      expect(result.isInvalid, isTrue);
      expect(result.errorMessage, contains('Sovrapposizione'));
      expect(result.errorMessage, contains('Mario Rossi'));
      expect(result.details, isNotNull);
    });

    test('should allow same-day turnaround (check-out = next check-in)', () async {
      final existingReservation = Reservation(
        id: 'existing-id',
        roomId: 'room-1',
        platformId: 'booking',
        guest: const Guest(name: 'Mario Rossi'),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      when(() => mockRepository.getReservationsForDateRange(any(), any()))
          .thenAnswer((_) async => [existingReservation]);

      // New reservation starts on the day existing one ends
      final result = await service.checkRoomAvailability(
        roomId: 'room-1',
        checkIn: DateTime(2024, 6, 18),  // Same day as existing check-out
        checkOut: DateTime(2024, 6, 20),
      );

      expect(result.isValid, isTrue);
    });
  });

  group('checkApartmentAvailability', () {
    test('should return success when no rooms are booked', () async {
      when(() => mockRepository.getReservationsForDateRange(any(), any()))
          .thenAnswer((_) async => []);

      final result = await service.checkApartmentAvailability(
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
      );

      expect(result.isValid, isTrue);
    });

    test('should return failure with room name when room 2 is booked', () async {
      final existingReservation = Reservation(
        id: 'existing-id',
        roomId: 'room-2',
        platformId: 'booking',
        guest: const Guest(name: 'Luigi Verdi'),
        checkIn: DateTime(2024, 6, 16),
        checkOut: DateTime(2024, 6, 20),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      when(() => mockRepository.getReservationsForDateRange(any(), any()))
          .thenAnswer((_) async => [existingReservation]);

      final result = await service.checkApartmentAvailability(
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
      );

      expect(result.isInvalid, isTrue);
      expect(result.errorMessage, contains('Stanza 2'));
      expect(result.details?['blockingRoom'], 'room-2');
    });
  });

  group('checkRoomAgainstApartment', () {
    test('should return failure when apartment is booked for those dates', () async {
      final apartmentReservation = Reservation(
        id: 'apartment-id',
        roomId: 'apartment',
        platformId: 'airbnb',
        guest: const Guest(name: 'Family Smith'),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 20),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      when(() => mockRepository.getReservationsForDateRange(any(), any()))
          .thenAnswer((_) async => [apartmentReservation]);

      final result = await service.checkRoomAgainstApartment(
        roomId: 'room-1',
        checkIn: DateTime(2024, 6, 16),
        checkOut: DateTime(2024, 6, 18),
      );

      expect(result.isInvalid, isTrue);
      expect(result.errorMessage, contains('Appartamento Intero'));
    });
  });
}
```

Also update existing reservation_test.dart to include payment status.
</action>
  <verify>
    <automated>flutter test test/features/reservations/domain/services/</automated>
  </verify>
  <done>
    - Unit tests for date validation pass
    - Unit tests for room availability pass
    - Unit tests for apartment blocking pass
    - Tests verify error messages contain correct details
    - Same-day turnaround (adjacent dates) allowed
  </done>
</task>

</tasks>

<verification>
- [ ] PaymentStatus enum exists with received/pending values
- [ ] Reservation entity has paymentStatus field
- [ ] ReservationModel serializes/deserializes payment status
- [ ] Database schema updated with payment_status column
- [ ] ReservationValidationService implements all business rules
- [ ] All unit tests pass
</verification>

<success_criteria>
1. Payment status can be tracked for reservations
2. Validation service detects date overlaps correctly
3. Apartment blocking works in both directions (room blocks apartment, apartment blocks rooms)
4. Error messages are in Italian with useful details
5. Same-day turnaround is allowed (adjacent reservations OK)
</success_criteria>

<output>
After completion, create `.planning/phases/02-crud-prenotazioni/01-01-SUMMARY.md`
</output>
