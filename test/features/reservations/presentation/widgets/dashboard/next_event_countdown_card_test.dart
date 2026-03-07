import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/dashboard/next_event_countdown_card.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

void main() {
  group('NextEventCountdownCard', () {
    // Helper to create test reservations
    Reservation createTestReservation({
      required String id,
      required DateTime checkIn,
      required DateTime checkOut,
      String guestName = 'Mario Rossi',
      String roomId = 'room-1',
    }) {
      return Reservation(
        id: id,
        roomId: roomId,
        platformId: 'airbnb',
        guest: Guest(name: guestName),
        checkIn: checkIn,
        checkOut: checkOut,
        paymentStatus: PaymentStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    Widget createTestWidget({
      List<Reservation> upcomingCheckIns = const [],
      List<Reservation> upcomingCheckOuts = const [],
    }) {
      return MaterialApp(
        home: Scaffold(
          body: NextEventCountdownCard(
            upcomingCheckIns: upcomingCheckIns,
            upcomingCheckOuts: upcomingCheckOuts,
          ),
        ),
      );
    }

    testWidgets('displays check-in event correctly', (tester) async {
      // Arrange
      final now = DateTime.now();
      final checkInDate = now.add(const Duration(days: 2));
      final checkOutDate = now.add(const Duration(days: 5));

      final reservations = [
        createTestReservation(
          id: '1',
          checkIn: checkInDate,
          checkOut: checkOutDate,
          guestName: 'Mario Rossi',
          roomId: 'room-1',
        ),
      ];

      // Act
      await tester.pumpWidget(createTestWidget(
        upcomingCheckIns: reservations,
      ));

      // Assert
      expect(find.text('Prossimo Evento'), findsOneWidget);
      expect(find.textContaining('Arrivo tra'), findsOneWidget);
      expect(find.textContaining('Mario Rossi'), findsOneWidget);
      expect(find.textContaining('Stanza 1'), findsOneWidget);
    });

    testWidgets('displays check-out event correctly', (tester) async {
      // Arrange
      final now = DateTime.now();
      final checkInDate = now.subtract(const Duration(days: 2));
      final checkOutDate = now.add(const Duration(days: 1));

      final reservations = [
        createTestReservation(
          id: '1',
          checkIn: checkInDate,
          checkOut: checkOutDate,
          guestName: 'Luca Verdi',
          roomId: 'room-2',
        ),
      ];

      // Act
      await tester.pumpWidget(createTestWidget(
        upcomingCheckOuts: reservations,
      ));

      // Assert
      expect(find.text('Prossimo Evento'), findsOneWidget);
      expect(find.textContaining('Partenza tra'), findsOneWidget);
      expect(find.textContaining('Luca Verdi'), findsOneWidget);
      expect(find.textContaining('Stanza 2'), findsOneWidget);
    });

    testWidgets('shows empty state when no events', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Nessun evento programmato'), findsOneWidget);
      expect(find.byIcon(Icons.event_busy), findsOneWidget);
    });

    testWidgets('picks sooner event when both check-in and check-out exist',
        (tester) async {
      // Arrange
      final now = DateTime.now();

      // Check-in in 3 days
      final checkInReservations = [
        createTestReservation(
          id: '1',
          checkIn: now.add(const Duration(days: 3)),
          checkOut: now.add(const Duration(days: 6)),
          guestName: 'Mario Rossi',
        ),
      ];

      // Check-out in 1 day (sooner)
      final checkOutReservations = [
        createTestReservation(
          id: '2',
          checkIn: now.subtract(const Duration(days: 2)),
          checkOut: now.add(const Duration(days: 1)),
          guestName: 'Luca Verdi',
        ),
      ];

      // Act
      await tester.pumpWidget(createTestWidget(
        upcomingCheckIns: checkInReservations,
        upcomingCheckOuts: checkOutReservations,
      ));

      // Assert - Should show check-out (sooner event)
      expect(find.textContaining('Partenza tra'), findsOneWidget);
      expect(find.textContaining('Luca Verdi'), findsOneWidget);
    });

    testWidgets('formats today events correctly with (Oggi)', (tester) async {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final reservations = [
        createTestReservation(
          id: '1',
          checkIn: today,
          checkOut: today.add(const Duration(days: 3)),
        ),
      ];

      // Act
      await tester.pumpWidget(createTestWidget(
        upcomingCheckIns: reservations,
      ));

      // Assert
      expect(find.textContaining('(Oggi)'), findsOneWidget);
    });

    testWidgets('shows correct icon for check-in event', (tester) async {
      // Arrange
      final now = DateTime.now();
      final reservations = [
        createTestReservation(
          id: '1',
          checkIn: now.add(const Duration(days: 2)),
          checkOut: now.add(const Duration(days: 5)),
        ),
      ];

      // Act
      await tester.pumpWidget(createTestWidget(
        upcomingCheckIns: reservations,
      ));

      // Assert - Should show login icon for check-in
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('shows correct icon for check-out event', (tester) async {
      // Arrange
      final now = DateTime.now();
      final reservations = [
        createTestReservation(
          id: '1',
          checkIn: now.subtract(const Duration(days: 2)),
          checkOut: now.add(const Duration(days: 1)),
        ),
      ];

      // Act
      await tester.pumpWidget(createTestWidget(
        upcomingCheckOuts: reservations,
      ));

      // Assert - Should show logout icon for check-out
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('displays apartment room name correctly', (tester) async {
      // Arrange
      final now = DateTime.now();
      final reservations = [
        createTestReservation(
          id: '1',
          checkIn: now.add(const Duration(days: 2)),
          checkOut: now.add(const Duration(days: 5)),
          roomId: 'apartment',
        ),
      ];

      // Act
      await tester.pumpWidget(createTestWidget(
        upcomingCheckIns: reservations,
      ));

      // Assert
      expect(find.textContaining('Appartamento'), findsOneWidget);
    });

    testWidgets('has correct semantics for accessibility', (tester) async {
      // Arrange
      final now = DateTime.now();
      final reservations = [
        createTestReservation(
          id: '1',
          checkIn: now.add(const Duration(days: 2)),
          checkOut: now.add(const Duration(days: 5)),
        ),
      ];

      // Act
      await tester.pumpWidget(createTestWidget(
        upcomingCheckIns: reservations,
      ));

      // Assert - Should have semantics
      final semantics = tester.getSemantics(find.byType(NextEventCountdownCard));
      expect(semantics, isNotNull);
    });

    testWidgets('card has correct key for testing', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byKey(const Key('next_event_countdown_card')), findsOneWidget);
    });
  });
}
