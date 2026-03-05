import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/day_detail_bottom_sheet.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';

void main() {
  // Initialize intl for Italian locale
  setUpAll(() async {
    await initializeDateFormatting('it_IT', null);
    Intl.defaultLocale = 'it_IT';
  });

  group('DayDetailBottomSheet', () {
    testWidgets('displays empty state when no reservations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    DayDetailBottomSheet.show(
                      context,
                      day: DateTime(2024, 6, 15),
                      reservations: [],
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Nessuna prenotazione'), findsOneWidget);
      expect(find.text('Questa data è libera'), findsOneWidget);
    });

    testWidgets('displays reservations list', (tester) async {
      final reservations = [
        Reservation(
          id: '1',
          roomId: 'room-1',
          platformId: 'booking',
          guest: Guest(name: 'Mario Rossi', phone: null),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 16),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    DayDetailBottomSheet.show(
                      context,
                      day: DateTime(2024, 6, 15),
                      reservations: reservations,
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Mario Rossi'), findsOneWidget);
      expect(find.text('Prenotazioni'), findsOneWidget);
    });

    testWidgets('displays date and weekday in header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    DayDetailBottomSheet.show(
                      context,
                      day: DateTime(2024, 6, 15), // Saturday
                      reservations: [],
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.textContaining('sabato'), findsOneWidget); // Saturday in Italian
      expect(find.text('15 giugno 2024'), findsOneWidget);
    });
  });
}
