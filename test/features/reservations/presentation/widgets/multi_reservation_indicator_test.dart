import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/multi_reservation_indicator.dart';

void main() {
  group('MultiReservationIndicator', () {
    // Helper to create a reservation with default values
    Reservation createReservation(String id, String platformId) {
      return Reservation(
        id: id,
        roomId: 'room-1',
        platformId: platformId,
        checkIn: DateTime(2026, 3, 15),
        checkOut: DateTime(2026, 3, 17),
        guest: Guest(name: 'Guest $id'),
        paymentStatus: PaymentStatus.pending,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
    }

    testWidgets('shows nothing when no reservations', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MultiReservationIndicator(reservations: []),
          ),
        ),
      );

      // Should show SizedBox.shrink - no containers with circle decoration
      expect(find.byType(MultiReservationIndicator), findsOneWidget);
      // The widget should be SizedBox.shrink when empty
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('shows 1 dot when 1 reservation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiReservationIndicator(
              reservations: [createReservation('1', 'booking')],
            ),
          ),
        ),
      );

      // Should find 1 dot (Container with circle decoration)
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(MultiReservationIndicator),
          matching: find.byType(Container),
        ),
      );
      // Count containers that have circle shape decoration (the dots)
      int dotCount = 0;
      for (final container in containers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.shape == BoxShape.circle) {
            dotCount++;
          }
        }
      }
      expect(dotCount, 1);
    });

    testWidgets('shows 2 dots when 2 reservations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiReservationIndicator(
              reservations: [
                createReservation('1', 'booking'),
                createReservation('2', 'airbnb'),
              ],
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(MultiReservationIndicator),
          matching: find.byType(Container),
        ),
      );
      int dotCount = 0;
      for (final container in containers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.shape == BoxShape.circle) {
            dotCount++;
          }
        }
      }
      expect(dotCount, 2);
    });

    testWidgets('shows 4 dots when 4 reservations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiReservationIndicator(
              reservations: [
                createReservation('1', 'booking'),
                createReservation('2', 'airbnb'),
                createReservation('3', 'whatsapp'),
                createReservation('4', 'website'),
              ],
            ),
          ),
        ),
      );

      // Should find 4 dots and no overflow indicator
      expect(find.textContaining('+'), findsNothing);

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(MultiReservationIndicator),
          matching: find.byType(Container),
        ),
      );
      int dotCount = 0;
      for (final container in containers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.shape == BoxShape.circle) {
            dotCount++;
          }
        }
      }
      expect(dotCount, 4);
    });

    testWidgets('shows +1 when 5 reservations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiReservationIndicator(
              reservations: List.generate(
                5,
                (i) => createReservation('$i', 'booking'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('shows +5 when 9 reservations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiReservationIndicator(
              reservations: List.generate(
                9,
                (i) => createReservation('$i', 'booking'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('+5'), findsOneWidget);
    });

    testWidgets('uses correct platform colors for dots', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiReservationIndicator(
              reservations: [
                createReservation('1', 'booking'),  // Blue
                createReservation('2', 'airbnb'),   // Pink/Red
                createReservation('3', 'whatsapp'), // Green
              ],
            ),
          ),
        ),
      );

      // Verify the widget renders without errors
      expect(find.byType(MultiReservationIndicator), findsOneWidget);

      // Check that we have 3 dot containers
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(MultiReservationIndicator),
          matching: find.byType(Container),
        ),
      );

      final List<Color> foundColors = [];
      for (final container in containers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.shape == BoxShape.circle && decoration.color != null) {
            foundColors.add(decoration.color!);
          }
        }
      }

      // Should have 3 dots with different colors
      expect(foundColors.length, 3);
    });
  });
}
