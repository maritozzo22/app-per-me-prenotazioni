import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/platform_dropdown.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

void main() {
  group('PlatformDropdown', () {
    final testPlatforms = BookingPlatform.defaultPlatforms;

    testWidgets('renders all platforms', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformDropdown(
              value: null,
              platforms: testPlatforms,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Tap dropdown to open
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Should show all platforms
      expect(find.text('Booking'), findsWidgets);
      expect(find.text('Airbnb'), findsWidgets);
      expect(find.text('WhatsApp'), findsWidgets);
    });

    testWidgets('calls onChanged when platform selected', (tester) async {
      String? selectedPlatform;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformDropdown(
              value: null,
              platforms: testPlatforms,
              onChanged: (value) => selectedPlatform = value,
            ),
          ),
        ),
      );

      // Tap and select a platform
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Booking').last);
      await tester.pumpAndSettle();

      expect(selectedPlatform, 'booking');
    });
  });
}
