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
      expect(json['guest'], isA<Map<String, dynamic>>());
      expect(json['guest']['name'], 'Mario Rossi');
      expect(json['guest']['phone'], '+39123456789');
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
