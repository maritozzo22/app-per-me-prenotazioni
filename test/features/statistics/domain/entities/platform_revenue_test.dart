import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/platform_revenue.dart';

void main() {
  group('PlatformRevenue', () {
    group('entity creation', () {
      test('stores all required fields', () {
        final revenue = PlatformRevenue(
          platformId: 'airbnb-123',
          platformName: 'Airbnb',
          color: 0xFFFF5A5F, // Airbnb pink
          totalRevenue: 15000.50,
          bookingCount: 12,
          percentage: 45.5,
        );

        expect(revenue.platformId, 'airbnb-123');
        expect(revenue.platformName, 'Airbnb');
        expect(revenue.color, 0xFFFF5A5F);
        expect(revenue.totalRevenue, 15000.50);
        expect(revenue.bookingCount, 12);
        expect(revenue.percentage, 45.5);
      });

      test('handles zero values correctly', () {
        final revenue = PlatformRevenue(
          platformId: 'empty',
          platformName: 'No Bookings',
          color: 0xFF000000,
          totalRevenue: 0,
          bookingCount: 0,
          percentage: 0,
        );

        expect(revenue.totalRevenue, 0);
        expect(revenue.bookingCount, 0);
        expect(revenue.percentage, 0);
      });
    });

    group('JSON serialization', () {
      test('fromJson/toJson round-trips correctly', () {
        final revenue = PlatformRevenue(
          platformId: 'booking-456',
          platformName: 'Booking.com',
          color: 0xFF003580, // Booking blue
          totalRevenue: 25000.75,
          bookingCount: 25,
          percentage: 55.5,
        );

        final json = revenue.toJson();
        final restored = PlatformRevenue.fromJson(json);

        expect(restored.platformId, revenue.platformId);
        expect(restored.platformName, revenue.platformName);
        expect(restored.color, revenue.color);
        expect(restored.totalRevenue, revenue.totalRevenue);
        expect(restored.bookingCount, revenue.bookingCount);
        expect(restored.percentage, revenue.percentage);
      });

      test('color is stored as int (ARGB value)', () {
        final revenue = PlatformRevenue(
          platformId: 'test',
          platformName: 'Test',
          color: 0xFF4285F4, // Google blue
          totalRevenue: 1000,
          bookingCount: 5,
          percentage: 100,
        );

        final json = revenue.toJson();
        expect(json['color'], isA<int>());
        expect(json['color'], 0xFF4285F4);
      });
    });
  });
}
