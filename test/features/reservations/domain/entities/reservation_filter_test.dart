import 'package:app_prenotazioni/features/reservations/domain/entities/reservation_filter.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReservationFilter', () {
    group('construction', () {
      test('should create filter with all null values', () {
        const filter = ReservationFilter();

        expect(filter.platformId, isNull);
        expect(filter.roomId, isNull);
        expect(filter.startDate, isNull);
        expect(filter.endDate, isNull);
        expect(filter.paymentStatus, isNull);
      });

      test('should create filter with specific values', () {
        final startDate = DateTime(2026, 3, 1);
        final endDate = DateTime(2026, 3, 31);
        const paymentStatus = PaymentStatus.received;

        const filter = ReservationFilter(
          platformId: 'platform-123',
          roomId: 'room-456',
          startDate: null,
          endDate: null,
          paymentStatus: paymentStatus,
        );

        expect(filter.platformId, equals('platform-123'));
        expect(filter.roomId, equals('room-456'));
        expect(filter.paymentStatus, equals(paymentStatus));
      });
    });

    group('isEmpty', () {
      test('should return true when all filters are null', () {
        const filter = ReservationFilter();

        expect(filter.isEmpty, isTrue);
      });

      test('should return false when any filter is set', () {
        const filter = ReservationFilter(platformId: 'platform-123');

        expect(filter.isEmpty, isFalse);
      });
    });

    group('serialization', () {
      test('should convert to map with only non-null values', () {
        final startDate = DateTime(2026, 3, 1);
        final endDate = DateTime(2026, 3, 31);
        const paymentStatus = PaymentStatus.received;

        final filter = ReservationFilter(
          platformId: 'platform-123',
          roomId: null,
          startDate: startDate,
          endDate: endDate,
          paymentStatus: paymentStatus,
        );

        final map = filter.toMap();

        expect(map['platformId'], equals('platform-123'));
        expect(map.containsKey('roomId'), isFalse);
        expect(map['startDate'], equals(startDate.toIso8601String()));
        expect(map['endDate'], equals(endDate.toIso8601String()));
        expect(map['paymentStatus'], equals('received'));
      });

      test('should convert empty filter to empty map', () {
        const filter = ReservationFilter();

        final map = filter.toMap();

        expect(map, isEmpty);
      });

      test('should deserialize from map', () {
        final startDate = DateTime(2026, 3, 1);
        final endDate = DateTime(2026, 3, 31);
        final map = {
          'platformId': 'platform-123',
          'roomId': 'room-456',
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'paymentStatus': 'received',
        };

        final filter = ReservationFilter.fromMap(map);

        expect(filter.platformId, equals('platform-123'));
        expect(filter.roomId, equals('room-456'));
        expect(filter.startDate, equals(startDate));
        expect(filter.endDate, equals(endDate));
        expect(filter.paymentStatus, equals(PaymentStatus.received));
      });

      test('should deserialize from map with null values', () {
        const map = <String, dynamic>{};

        final filter = ReservationFilter.fromMap(map);

        expect(filter.platformId, isNull);
        expect(filter.roomId, isNull);
        expect(filter.startDate, isNull);
        expect(filter.endDate, isNull);
        expect(filter.paymentStatus, isNull);
      });

      test('should round-trip through serialization', () {
        final startDate = DateTime(2026, 3, 1);
        final endDate = DateTime(2026, 3, 31);
        final originalFilter = ReservationFilter(
          platformId: 'platform-123',
          roomId: 'room-456',
          startDate: startDate,
          endDate: endDate,
          paymentStatus: PaymentStatus.received,
        );

        final map = originalFilter.toMap();
        final restoredFilter = ReservationFilter.fromMap(map);

        expect(restoredFilter.platformId, equals(originalFilter.platformId));
        expect(restoredFilter.roomId, equals(originalFilter.roomId));
        expect(restoredFilter.startDate, equals(originalFilter.startDate));
        expect(restoredFilter.endDate, equals(originalFilter.endDate));
        expect(restoredFilter.paymentStatus, equals(originalFilter.paymentStatus));
      });
    });
  });
}
