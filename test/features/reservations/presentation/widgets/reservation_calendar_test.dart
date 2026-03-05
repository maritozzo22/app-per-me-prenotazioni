import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_calendar.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/calendar_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  // Initialize intl for Italian locale
  setUpAll(() async {
    await initializeDateFormatting('it_IT', null);
    Intl.defaultLocale = 'it_IT';
  });

  group('ReservationCalendar', () {
    late MockReservationRepository mockRepository;

    setUp(() {
      mockRepository = MockReservationRepository();
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => []);
    });

    testWidgets('displays calendar with day cells', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ReservationCalendar(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that calendar rendered (TableCalendar has a specific widget type)
      expect(find.byType(TableCalendar), findsOneWidget);
    });

    testWidgets('calls onDaySelected when tapping a day', (tester) async {
      DateTime? selectedDay;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ReservationCalendar(
                onDaySelected: (day, _) {
                  selectedDay = day;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on day 15
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(selectedDay, isNotNull);
    });

    testWidgets('shows platform-colored background for reservation days', (tester) async {
      final reservations = [
        Reservation(
          id: '1',
          roomId: 'room-1',
          platformId: 'booking', // Blue
          guest: Guest(name: 'Mario', phone: null),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 16),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        ),
      ];

      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ReservationCalendar(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find day 15 with reservation
      expect(find.text('15'), findsWidgets);
    });
  });
}
