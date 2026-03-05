import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_prenotazioni/main.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  // Initialize intl for Italian locale
  setUpAll(() async {
    await initializeDateFormatting('it_IT', null);
    Intl.defaultLocale = 'it_IT';
  });

  testWidgets('App loads and displays CalendarPage', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final mockRepository = MockReservationRepository();
    when(() => mockRepository.getAllReservations())
        .thenAnswer((_) async => []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reservationRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the calendar page title is displayed.
    expect(find.text('Calendario Prenotazioni'), findsOneWidget);

    // Verify that the info text is displayed.
    expect(find.text('Seleziona un giorno per vedere le prenotazioni'), findsOneWidget);
    expect(find.text('Trascina per navigare tra i mesi'), findsOneWidget);
  });
}
