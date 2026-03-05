import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/main.dart';
import 'package:app_prenotazioni/core/widgets/app_shell.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/dashboard_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/calendar_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/reservations_list_page.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  group('Dashboard Navigation Integration', () {
    late MockReservationRepository mockRepository;

    setUp(() {
      mockRepository = MockReservationRepository();
      registerFallbackValue(Reservation(
        id: 'test',
        roomId: 'room-1',
        platformId: 'booking',
        guest: const Guest(name: 'Test', phone: null),
        checkIn: DateTime(2024, 1, 1),
        checkOut: DateTime(2024, 1, 2),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));
    });

    testWidgets('complete navigation flow works', (tester) async {
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

      await tester.pumpAndSettle();

      // 1. App starts with Dashboard
      expect(find.byType(DashboardPage), findsOneWidget);
      expect(find.text('Dashboard'), findsWidgets);

      // 2. Navigate to Calendar via bottom nav
      await tester.tap(find.text('Calendario'));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsOneWidget);

      // 3. Navigate to Reservations via bottom nav
      await tester.tap(find.text('Prenotazioni'));
      await tester.pumpAndSettle();
      expect(find.byType(ReservationsListPage), findsOneWidget);

      // 4. Navigate back to Dashboard
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('calendar card navigates to calendar tab', (tester) async {
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => []);

      final shellKey = GlobalKey<AppShellState>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: AppShell(key: shellKey),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we start on Dashboard
      expect(find.byType(DashboardPage), findsOneWidget);

      // Trigger programmatic navigation (simulates calendar card tap)
      shellKey.currentState!.navigateToCalendar();
      await tester.pumpAndSettle();

      // Should now be on Calendar tab
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('bottom nav highlights current tab', (tester) async {
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

      await tester.pumpAndSettle();

      // Find bottom nav bar
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      // Dashboard should be selected initially
      expect(bottomNavBar.currentIndex, 0);

      // Tap calendar
      await tester.tap(find.text('Calendario'));
      await tester.pumpAndSettle();

      // Calendar should now be selected
      final updatedNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(updatedNavBar.currentIndex, 1);
    });

    testWidgets('all tabs are accessible', (tester) async {
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

      await tester.pumpAndSettle();

      // All navigation items should be tappable
      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Calendario'), findsWidgets);
      expect(find.text('Prenotazioni'), findsWidgets);
      expect(find.text('Piattaforme'), findsWidgets);

      // Verify semantic labels exist for accessibility
      // (BottomNavigationBarItem provides these via label property)
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      expect(bottomNavBar.items[0].label, 'Dashboard');
      expect(bottomNavBar.items[1].label, 'Calendario');
      expect(bottomNavBar.items[2].label, 'Prenotazioni');
      expect(bottomNavBar.items[3].label, 'Piattaforme');
    });
  });
}
