import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/statistics/presentation/widgets/platform_revenue_chart.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/platform_revenue.dart';

void main() {
  group('PlatformRevenueChart', () {
    testWidgets('renders pie chart with data', (tester) async {
      // Arrange
      final data = [
        PlatformRevenue(
          platformId: 'airbnb',
          platformName: 'Airbnb',
          color: 0xFFFF5A5F,
          totalRevenue: 5000.0,
          bookingCount: 10,
          percentage: 50.0,
        ),
        PlatformRevenue(
          platformId: 'booking',
          platformName: 'Booking',
          color: 0xFF003580,
          totalRevenue: 3000.0,
          bookingCount: 6,
          percentage: 30.0,
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformRevenueChart(data: data),
          ),
        ),
      );

      // Assert
      expect(find.text('Fatturato per Piattaforma'), findsOneWidget);
      expect(find.text('Airbnb'), findsOneWidget);
      expect(find.text('Booking'), findsOneWidget);
    });

    testWidgets('shows empty state when no platforms', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformRevenueChart(data: []),
          ),
        ),
      );

      // Assert
      expect(find.text('Nessun dato disponibile'), findsOneWidget);
      expect(find.byIcon(Icons.pie_chart), findsOneWidget);
    });

    testWidgets('shows empty state when total revenue is zero', (tester) async {
      // Arrange
      final data = [
        PlatformRevenue(
          platformId: 'airbnb',
          platformName: 'Airbnb',
          color: 0xFFFF5A5F,
          totalRevenue: 0.0,
          bookingCount: 0,
          percentage: 0.0,
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformRevenueChart(data: data),
          ),
        ),
      );

      // Assert
      expect(find.text('Nessun dato disponibile'), findsOneWidget);
    });

    testWidgets('legend shows all platforms', (tester) async {
      // Arrange
      final data = [
        PlatformRevenue(
          platformId: 'airbnb',
          platformName: 'Airbnb',
          color: 0xFFFF5A5F,
          totalRevenue: 5000.0,
          bookingCount: 10,
          percentage: 50.0,
        ),
        PlatformRevenue(
          platformId: 'booking',
          platformName: 'Booking.com',
          color: 0xFF003580,
          totalRevenue: 3000.0,
          bookingCount: 6,
          percentage: 30.0,
        ),
        PlatformRevenue(
          platformId: 'whatsapp',
          platformName: 'WhatsApp',
          color: 0xFF25D366,
          totalRevenue: 2000.0,
          bookingCount: 4,
          percentage: 20.0,
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformRevenueChart(data: data),
          ),
        ),
      );

      // Assert
      expect(find.text('Airbnb'), findsOneWidget);
      expect(find.text('Booking.com'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
    });

    testWidgets('renders with custom height', (tester) async {
      // Arrange
      final data = [
        PlatformRevenue(
          platformId: 'airbnb',
          platformName: 'Airbnb',
          color: 0xFFFF5A5F,
          totalRevenue: 5000.0,
          bookingCount: 10,
          percentage: 50.0,
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformRevenueChart(data: data, height: 400),
          ),
        ),
      );

      // Assert - Widget should render without errors
      expect(find.text('Fatturato per Piattaforma'), findsOneWidget);
    });

    testWidgets('filters out platforms with zero revenue', (tester) async {
      // Arrange
      final data = [
        PlatformRevenue(
          platformId: 'airbnb',
          platformName: 'Airbnb',
          color: 0xFFFF5A5F,
          totalRevenue: 5000.0,
          bookingCount: 10,
          percentage: 100.0,
        ),
        PlatformRevenue(
          platformId: 'booking',
          platformName: 'Booking',
          color: 0xFF003580,
          totalRevenue: 0.0,
          bookingCount: 0,
          percentage: 0.0,
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformRevenueChart(data: data),
          ),
        ),
      );

      // Assert - Only Airbnb should appear in legend
      expect(find.text('Airbnb'), findsOneWidget);
      // Booking should not appear because it has zero revenue
      expect(find.text('Booking'), findsNothing);
    });
  });
}
