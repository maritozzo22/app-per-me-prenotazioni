import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_log.dart';

void main() {
  group('NotificationLog', () {
    test('creates with all fields', () {
      final log = NotificationLog(
        id: 'log-1',
        reservationId: 'res-1',
        guestName: 'John Doe',
        roomLabel: 'Stanza 1',
        daysBefore: 3,
        scheduledTime: DateTime(2026, 3, 5, 9, 0),
        sentAt: DateTime(2026, 3, 5, 9, 0),
        success: true,
      );

      expect(log.id, equals('log-1'));
      expect(log.reservationId, equals('res-1'));
      expect(log.isTest, isFalse);
    });

    test('creates test notification log', () {
      final log = NotificationLog.test(
        id: 'test-1',
        sentAt: DateTime(2026, 3, 8, 10, 0),
      );

      expect(log.isTest, isTrue);
      expect(log.guestName, equals('Test'));
      expect(log.reservationId, isEmpty);
    });

    test('serializes to and from JSON', () {
      final original = NotificationLog(
        id: 'log-1',
        reservationId: 'res-1',
        guestName: 'John Doe',
        roomLabel: 'Stanza 1',
        daysBefore: 3,
        scheduledTime: DateTime(2026, 3, 5, 9, 0),
        sentAt: DateTime(2026, 3, 5, 9, 1),
        success: true,
        isTest: false,
      );

      final json = original.toJson();
      final restored = NotificationLog.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.reservationId, equals(original.reservationId));
      expect(restored.daysBefore, equals(original.daysBefore));
      expect(restored.success, equals(original.success));
      expect(restored.isTest, equals(original.isTest));
    });

    test('daysBeforeLabel formats correctly', () {
      expect(
        NotificationLog(id: '1', reservationId: '', guestName: '', roomLabel: '', daysBefore: 0, scheduledTime: DateTime.now(), sentAt: DateTime.now()).daysBeforeLabel,
        equals('Giorno stesso'),
      );
      expect(
        NotificationLog(id: '1', reservationId: '', guestName: '', roomLabel: '', daysBefore: 1, scheduledTime: DateTime.now(), sentAt: DateTime.now()).daysBeforeLabel,
        equals('1 giorno prima'),
      );
      expect(
        NotificationLog(id: '1', reservationId: '', guestName: '', roomLabel: '', daysBefore: 5, scheduledTime: DateTime.now(), sentAt: DateTime.now()).daysBeforeLabel,
        equals('5 giorni prima'),
      );
      expect(
        NotificationLog.test(id: 'test', sentAt: DateTime.now()).daysBeforeLabel,
        equals('Test'),
      );
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'log-1',
        'scheduled_time': '2026-03-05T09:00:00.000',
        'sent_at': '2026-03-05T09:00:00.000',
      };

      final log = NotificationLog.fromJson(json);

      expect(log.id, equals('log-1'));
      expect(log.reservationId, isEmpty);
      expect(log.guestName, isEmpty);
      expect(log.roomLabel, isEmpty);
      expect(log.daysBefore, equals(0));
      expect(log.success, isFalse);
      expect(log.isTest, isFalse);
    });
  });
}
