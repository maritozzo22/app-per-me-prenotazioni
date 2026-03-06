import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/calendar_page.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
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

  group('CalendarPage', () {
    late MockReservationRepository mockRepository;

    setUp(() {
      mockRepository = MockReservationRepository();
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => []);
    });

    testWidgets('renders calendar page with app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: CalendarPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Calendario Prenotazioni'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      // Use a completer to control when the async operation completes
      final completer = Completer<List<Reservation>>();
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: CalendarPage(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the async operation
      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('shows empty state when no reservations', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: CalendarPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // When there are no reservations, should show empty state
      expect(find.text('Nessun evento'), findsOneWidget);
      expect(find.text('Non ci sono prenotazioni in questo periodo'), findsOneWidget);
    });

    testWidgets('shows info text below calendar when has reservations', (tester) async {
      // Create a sample reservation with current structure
      final now = DateTime.now();
      final reservation = Reservation(
        id: '1',
        roomId: 'room-1',
        platformId: 'airbnb',
        guest: const Guest(name: 'Mario Rossi'),
        checkIn: now.add(const Duration(days: 1)),
        checkOut: now.add(const Duration(days: 3)),
        amount: 300.0,
        paymentStatus: PaymentStatus.received,
        createdAt: now,
        updatedAt: now,
      );

      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => [reservation]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: CalendarPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // When there are reservations, should show calendar with info text
      expect(find.text('Seleziona un giorno per vedere le prenotazioni'), findsOneWidget);
      expect(find.text('Trascina per navigare tra i mesi'), findsOneWidget);
    });

    testWidgets('can pull to refresh', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: CalendarPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Pull down to trigger refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pump();

      // Verify refresh indicator appears
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
