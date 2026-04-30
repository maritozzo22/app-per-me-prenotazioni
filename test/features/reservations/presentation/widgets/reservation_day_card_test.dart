import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_day_card.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

void main() {
  // Initialize intl for Italian locale
  setUpAll(() async {
    await initializeDateFormatting('it_IT', null);
    Intl.defaultLocale = 'it_IT';
  });

  group('ReservationDayCard', () {
    testWidgets('displays guest name', (tester) async {
      final reservation = Reservation(
        id: '1',
        roomId: Room.defaultRooms.first.id,
        platformId: 'booking',
        guest: Guest(name: 'Mario Rossi', phone: null),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 16),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationDayCard(reservation: reservation),
          ),
        ),
      );

      expect(find.text('Mario Rossi'), findsOneWidget);
    });

    testWidgets('displays platform name and room', (tester) async {
      final reservation = Reservation(
        id: '1',
        roomId: 'room-1',
        platformId: 'booking',
        guest: Guest(name: 'Mario', phone: null),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 16),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationDayCard(reservation: reservation),
          ),
        ),
      );

      expect(find.text('Booking'), findsOneWidget);
      expect(find.text('Stanza 1'), findsOneWidget);
    });

    testWidgets('displays payment status', (tester) async {
      final reservation = Reservation(
        id: '1',
        roomId: 'room-1',
        platformId: 'booking',
        guest: Guest(name: 'Mario', phone: null),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 16),
        paymentStatus: PaymentStatus.received,
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationDayCard(reservation: reservation),
          ),
        ),
      );

      expect(find.text('Pagato'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    group('onTap callback', () {
      testWidgets('card accepts onTap callback parameter', (tester) async {
        bool tapped = false;
        final reservation = Reservation(
          id: '1',
          roomId: 'room-1',
          platformId: 'booking',
          guest: Guest(name: 'Test Guest', phone: null),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 16),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservationDayCard(
                reservation: reservation,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        // Widget should render without errors
        expect(find.text('Test Guest'), findsOneWidget);
        expect(tapped, isFalse);
      });

      testWidgets('onTap is called when card is tapped', (tester) async {
        bool tapped = false;
        final reservation = Reservation(
          id: '1',
          roomId: 'room-1',
          platformId: 'booking',
          guest: Guest(name: 'Tappable Guest', phone: null),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 16),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservationDayCard(
                reservation: reservation,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        // Tap the card (guest name is part of the card)
        await tester.tap(find.text('Tappable Guest'));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      });

      testWidgets('card is wrapped with InkWell when onTap is provided', (tester) async {
        final reservation = Reservation(
          id: '1',
          roomId: 'room-1',
          platformId: 'booking',
          guest: Guest(name: 'InkWell Guest', phone: null),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 16),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservationDayCard(
                reservation: reservation,
                onTap: () {},
              ),
            ),
          ),
        );

        // Should find InkWell widget
        expect(find.byType(InkWell), findsOneWidget);
      });

      testWidgets('card is NOT wrapped with InkWell when onTap is null', (tester) async {
        final reservation = Reservation(
          id: '1',
          roomId: 'room-1',
          platformId: 'booking',
          guest: Guest(name: 'No Tap Guest', phone: null),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 16),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReservationDayCard(
                reservation: reservation,
              ),
            ),
          ),
        );

        // Should NOT find InkWell widget
        expect(find.byType(InkWell), findsNothing);
      });
    });
  });
}
