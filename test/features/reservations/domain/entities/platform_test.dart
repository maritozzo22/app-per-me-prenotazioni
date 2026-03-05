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
        final platform = BookingPlatform(
          id: 'custom',
          name: 'Custom Platform',
          color: const Color(0xFF123456),
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
