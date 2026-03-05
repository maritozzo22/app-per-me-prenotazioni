import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/calendar_page.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
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

    testWidgets('shows info text below calendar', (tester) async {
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
