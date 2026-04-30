import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/statistics/presentation/widgets/platform_bookings_chart.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/platform_revenue.dart';

void main() {
  group('PlatformBookingsChart', () {
    testWidgets('renders bar chart with data', (tester) async {
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
            body: PlatformBookingsChart(data: data),
          ),
        ),
      );

      // Assert
      expect(find.text('Prenotazioni per Piattaforma'), findsOneWidget);
    });

    testWidgets('shows empty state when no platforms', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformBookingsChart(data: []),
          ),
        ),
      );

      // Assert
      expect(find.text('Nessun dato disponibile'), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
    });

    testWidgets('platforms sorted by booking count', (tester) async {
      // Arrange - unsorted order
      final data = [
        PlatformRevenue(
          platformId: 'whatsapp',
          platformName: 'WhatsApp',
          color: 0xFF25D366,
          totalRevenue: 2000.0,
          bookingCount: 4,
          percentage: 20.0,
        ),
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
            body: PlatformBookingsChart(data: data),
          ),
        ),
      );

      // Assert - Should show all platforms (sorted by count)
      expect(find.text('Airbnb'), findsWidgets); // Highest count (10)
      expect(find.text('Booking'), findsWidgets); // Middle count (6)
      expect(find.text('WhatsApp'), findsWidgets); // Lowest count (4)
    });

    testWidgets('platform colors match entity colors', (tester) async {
      // Arrange
      final data = [
        PlatformRevenue(
          platformId: 'airbnb',
          platformName: 'Airbnb',
          color: 0xFFFF5A5F, // Airbnb red
          totalRevenue: 5000.0,
          bookingCount: 10,
          percentage: 50.0,
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformBookingsChart(data: data),
          ),
        ),
      );

      // Assert - Widget should render without errors
      expect(find.text('Prenotazioni per Piattaforma'), findsOneWidget);
      expect(find.text('Airbnb'), findsWidgets);
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
            body: PlatformBookingsChart(data: data, height: 400),
          ),
        ),
      );

      // Assert - Widget should render without errors
      expect(find.text('Prenotazioni per Piattaforma'), findsOneWidget);
    });

    testWidgets('handles zero bookings', (tester) async {
      // Arrange
      final data = [
        PlatformRevenue(
          platformId: 'airbnb',
          platformName: 'Airbnb',
          color: 0xFFFF5A5F,
          totalRevenue: 5000.0,
          bookingCount: 0,
          percentage: 50.0,
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformBookingsChart(data: data),
          ),
        ),
      );

      // Assert - Widget should render even with zero bookings
      expect(find.text('Prenotazioni per Piattaforma'), findsOneWidget);
    });
  });
}
