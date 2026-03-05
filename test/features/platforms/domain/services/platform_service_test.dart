import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/platforms/domain/services/platform_service.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

void main() {
  group('PlatformService', () {
    late List<BookingPlatform> testPlatforms;

    setUp(() {
      testPlatforms = [
        BookingPlatform(
          id: 'booking',
          name: 'Booking',
          color: Colors.blue,
          isDefault: true,
          isSystem: true,
          createdAt: DateTime(2024, 1, 1),
        ),
        BookingPlatform(
          id: 'airbnb',
          name: 'Airbnb',
          color: Colors.red,
          isDefault: true,
          isSystem: true,
          createdAt: DateTime(2024, 1, 1),
        ),
        BookingPlatform(
          id: 'custom1',
          name: 'Custom Platform',
          color: Colors.green,
          isDefault: false,
          isSystem: false,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
    });

    group('validatePlatformName', () {
      test('returns true for unique name', () {
        final result = PlatformService.validatePlatformName(
          'New Platform',
          testPlatforms,
        );
        expect(result, isTrue);
      });

      test('returns false for duplicate name (exact match)', () {
        final result = PlatformService.validatePlatformName(
          'Booking',
          testPlatforms,
        );
        expect(result, isFalse);
      });

      test('returns false for duplicate name (case-insensitive)', () {
        final result = PlatformService.validatePlatformName(
          'booking',
          testPlatforms,
        );
        expect(result, isFalse);
      });

      test('returns false for duplicate name (different case)', () {
        final result = PlatformService.validatePlatformName(
          'AIRBNB',
          testPlatforms,
        );
        expect(result, isFalse);
      });

      test('returns false for duplicate name (with whitespace)', () {
        final result = PlatformService.validatePlatformName(
          '  Booking  ',
          testPlatforms,
        );
        expect(result, isFalse);
      });

      test('returns true when updating same platform with same name', () {
        final result = PlatformService.validatePlatformName(
          'Booking',
          testPlatforms,
          currentPlatformId: 'booking',
        );
        expect(result, isTrue);
      });

      test('returns false when updating to another platform\'s name', () {
        final result = PlatformService.validatePlatformName(
          'Airbnb',
          testPlatforms,
          currentPlatformId: 'booking',
        );
        expect(result, isFalse);
      });
    });

    group('canDeletePlatform', () {
      test('returns true when platform has no reservations', () {
        final result = PlatformService.canDeletePlatform(0);
        expect(result, isTrue);
      });

      test('returns false when platform has reservations', () {
        final result = PlatformService.canDeletePlatform(5);
        expect(result, isFalse);
      });
    });

    group('getSystemPlatforms', () {
      test('returns only system platforms', () {
        final systemPlatforms = PlatformService.getSystemPlatforms(testPlatforms);
        expect(systemPlatforms.length, 2);
        expect(systemPlatforms.every((p) => p.isSystem), isTrue);
      });

      test('returns empty list when no system platforms exist', () {
        final customOnly = testPlatforms.where((p) => !p.isSystem).toList();
        final systemPlatforms = PlatformService.getSystemPlatforms(customOnly);
        expect(systemPlatforms, isEmpty);
      });
    });

    group('getCustomPlatforms', () {
      test('returns only custom platforms', () {
        final customPlatforms = PlatformService.getCustomPlatforms(testPlatforms);
        expect(customPlatforms.length, 1);
        expect(customPlatforms.every((p) => !p.isSystem), isTrue);
      });

      test('returns empty list when no custom platforms exist', () {
        final systemOnly = testPlatforms.where((p) => p.isSystem).toList();
        final customPlatforms = PlatformService.getCustomPlatforms(systemOnly);
        expect(customPlatforms, isEmpty);
      });
    });

    group('isSystemPlatform', () {
      test('returns true for system platform', () {
        final result = PlatformService.isSystemPlatform(testPlatforms[0]);
        expect(result, isTrue);
      });

      test('returns false for custom platform', () {
        final result = PlatformService.isSystemPlatform(testPlatforms[2]);
        expect(result, isFalse);
      });
    });
  });
}
