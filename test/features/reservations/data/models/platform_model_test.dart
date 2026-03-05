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
      expect(json['isDefault'], true);
      expect(json['createdAt'], testDateTime.toIso8601String());
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'booking',
        'name': 'Booking',
        'colorValue': testColorValue,
        'isDefault': true,
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
        'isDefault': false,
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
