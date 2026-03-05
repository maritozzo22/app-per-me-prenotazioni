import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_day_cell.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';

void main() {
  group('ReservationDayCell', () {
    testWidgets('renders empty box when no reservations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationDayCell(
              day: DateTime(2024, 6, 15),
              reservations: [],
            ),
          ),
        ),
      );

      // Widget should render SizedBox.shrink()
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('renders colored background for reservation', (tester) async {
      final reservation = Reservation(
        id: '1',
        roomId: 'room-1',
        platformId: 'booking', // Blue color
        guest: Guest(name: 'Mario', phone: null),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 16),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationDayCell(
              day: DateTime(2024, 6, 15),
              reservations: [reservation],
            ),
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays day number correctly', (tester) async {
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
            body: ReservationDayCell(
              day: DateTime(2024, 6, 15),
              reservations: [reservation],
            ),
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget);
    });
  });
}
