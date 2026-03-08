import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_settings.dart';

void main() {
  group('NotificationSettings', () {
    test('creates with default values', () {
      final settings = NotificationSettings.defaults();

      expect(settings.enabled, isTrue);
      expect(settings.daysBeforeCheckIn, equals({5, 3, 2, 1, 0}));
      expect(settings.notificationHour, equals(9));
      expect(settings.notificationMinute, equals(0));
    });

    test('copyWith replaces specified fields', () {
      final original = NotificationSettings.defaults();
      final updated = original.copyWith(
        enabled: false,
        notificationHour: 10,
      );

      expect(updated.enabled, isFalse);
      expect(updated.notificationHour, equals(10));
      expect(updated.daysBeforeCheckIn, equals(original.daysBeforeCheckIn));
    });

    test('serializes to and from JSON', () {
      final original = NotificationSettings(
        enabled: false,
        daysBeforeCheckIn: {5, 2, 0},
        notificationHour: 10,
        notificationMinute: 30,
        updatedAt: DateTime(2026, 3, 8, 12, 0),
      );

      final json = original.toJson();
      final restored = NotificationSettings.fromJson(json);

      expect(restored.enabled, equals(original.enabled));
      expect(restored.daysBeforeCheckIn, equals(original.daysBeforeCheckIn));
      expect(restored.notificationHour, equals(original.notificationHour));
      expect(restored.notificationMinute, equals(original.notificationMinute));
    });

    test('notificationTimeString formats correctly', () {
      final settings = NotificationSettings(
        notificationHour: 9,
        notificationMinute: 5,
        updatedAt: DateTime.now(),
      );

      expect(settings.notificationTimeString, equals('09:05'));
    });

    test('isDayEnabled checks day membership', () {
      final settings = NotificationSettings(
        daysBeforeCheckIn: {5, 2, 0},
        updatedAt: DateTime.now(),
      );

      expect(settings.isDayEnabled(5), isTrue);
      expect(settings.isDayEnabled(3), isFalse);
      expect(settings.isDayEnabled(0), isTrue);
    });

    test('equality works correctly', () {
      final settings1 = NotificationSettings(
        enabled: true,
        daysBeforeCheckIn: {5, 3, 2, 1, 0},
        notificationHour: 9,
        notificationMinute: 0,
        updatedAt: DateTime(2026, 3, 8),
      );

      final settings2 = NotificationSettings(
        enabled: true,
        daysBeforeCheckIn: {5, 3, 2, 1, 0},
        notificationHour: 9,
        notificationMinute: 0,
        updatedAt: DateTime(2026, 3, 8),
      );

      expect(settings1, equals(settings2));
    });

    test('availableDays contains expected values', () {
      expect(NotificationSettings.availableDays, equals([5, 3, 2, 1, 0]));
    });
  });
}
