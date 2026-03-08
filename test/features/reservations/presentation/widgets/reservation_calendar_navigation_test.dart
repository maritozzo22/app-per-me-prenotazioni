import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/day_detail_bottom_sheet.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_day_card.dart';

void main() {
  // Initialize intl for Italian locale
  setUpAll(() async {
    await initializeDateFormatting('it_IT', null);
    Intl.defaultLocale = 'it_IT';
  });

  group('Calendar Navigation Flow', () {
    testWidgets('DayDetailBottomSheet passes tap callback to cards', (tester) async {
      Reservation? tappedReservation;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  DayDetailBottomSheet.show(
                    context,
                    day: DateTime(2026, 3, 15),
                    reservations: [
                      Reservation(
                        id: 'test-1',
                        roomId: 'room-1',
                        platformId: 'booking',
                        checkIn: DateTime(2026, 3, 15),
                        checkOut: DateTime(2026, 3, 17),
                        guest: const Guest(name: 'Test Guest'),
                        paymentStatus: PaymentStatus.pending,
                        createdAt: DateTime(2026, 3, 1),
                        updatedAt: DateTime(2026, 3, 1),
                      ),
                    ],
                    onReservationTap: (reservation) {
                      tappedReservation = reservation;
                    },
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Find and tap the reservation card
      expect(find.text('Test Guest'), findsOneWidget);
      await tester.tap(find.text('Test Guest'));
      await tester.pumpAndSettle();

      expect(tappedReservation, isNotNull);
      expect(tappedReservation!.id, 'test-1');
    });

    testWidgets('ReservationDayCard is tappable when onTap provided', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationDayCard(
              reservation: Reservation(
                id: 'test-1',
                roomId: 'room-1',
                platformId: 'booking',
                checkIn: DateTime(2026, 3, 15),
                checkOut: DateTime(2026, 3, 17),
                guest: const Guest(name: 'Test Guest'),
                paymentStatus: PaymentStatus.pending,
                createdAt: DateTime(2026, 3, 1),
                updatedAt: DateTime(2026, 3, 1),
              ),
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Guest'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('DayDetailBottomSheet shows empty state when no reservations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  DayDetailBottomSheet.show(
                    context,
                    day: DateTime(2026, 3, 15),
                    reservations: [],
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Verify empty state is shown
      expect(find.text('Nessuna prenotazione'), findsOneWidget);
    });

    testWidgets('Multiple reservations all have tap callbacks', (tester) async {
      final List<String> tappedIds = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  DayDetailBottomSheet.show(
                    context,
                    day: DateTime(2026, 3, 15),
                    reservations: [
                      Reservation(
                        id: 'res-1',
                        roomId: 'room-1',
                        platformId: 'booking',
                        checkIn: DateTime(2026, 3, 15),
                        checkOut: DateTime(2026, 3, 17),
                        guest: const Guest(name: 'Guest One'),
                        paymentStatus: PaymentStatus.pending,
                        createdAt: DateTime(2026, 3, 1),
                        updatedAt: DateTime(2026, 3, 1),
                      ),
                      Reservation(
                        id: 'res-2',
                        roomId: 'room-2',
                        platformId: 'airbnb',
                        checkIn: DateTime(2026, 3, 15),
                        checkOut: DateTime(2026, 3, 18),
                        guest: const Guest(name: 'Guest Two'),
                        paymentStatus: PaymentStatus.received,
                        createdAt: DateTime(2026, 3, 1),
                        updatedAt: DateTime(2026, 3, 1),
                      ),
                    ],
                    onReservationTap: (reservation) {
                      tappedIds.add(reservation.id);
                    },
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Tap first reservation
      expect(find.text('Guest One'), findsOneWidget);
      await tester.tap(find.text('Guest One'));
      await tester.pumpAndSettle();

      expect(tappedIds, contains('res-1'));
    });
  });
}
