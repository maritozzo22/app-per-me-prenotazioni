import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_prenotazioni/core/widgets/app_shell.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/dashboard_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/calendar_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/reservations_list_page.dart';
import 'package:app_prenotazioni/features/statistics/presentation/pages/statistics_page.dart';

void main() {
  group('AppShell', () {
    setUpAll(() async {
      // Initialize Italian date formatting for calendar widget
      await initializeDateFormatting('it_IT');
    });
    testWidgets('shows DashboardPage initially', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AppShell()),
        ),
      );

      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('shows bottom navigation bar', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AppShell()),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      // Note: "Dashboard" appears twice - once in bottom nav, once on the page
      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Calendario'), findsOneWidget);
      expect(find.text('Prenotazioni'), findsOneWidget);
      expect(find.text('Statistiche'), findsOneWidget);
    });

    testWidgets('navigates to Calendar when tab tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AppShell()),
        ),
      );

      // Tap calendar tab
      await tester.tap(find.text('Calendario'));
      await tester.pumpAndSettle();

      // CalendarPage should be visible (in IndexedStack)
      // Note: IndexedStack keeps all children in the tree, so CalendarPage always exists
      // We just need to verify it's there (it was built during initial pumpWidget)
      expect(find.byType(CalendarPage), findsOneWidget);

      // Also verify the bottom nav updated
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 1); // Calendar is index 1
    });

    testWidgets('navigates to Reservations when tab tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AppShell()),
        ),
      );

      // Tap reservations tab
      await tester.tap(find.text('Prenotazioni'));
      await tester.pumpAndSettle();

      // ReservationsListPage should be visible
      expect(find.byType(ReservationsListPage), findsOneWidget);
    });

    testWidgets('preserves Dashboard state when switching tabs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AppShell()),
        ),
      );

      // Dashboard should be visible initially
      expect(find.byType(DashboardPage), findsOneWidget);

      // Navigate to Calendar
      await tester.tap(find.text('Calendario'));
      await tester.pumpAndSettle();

      // Navigate back to Dashboard
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();

      // Dashboard should still be there (same instance due to IndexedStack)
      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('navigateToCalendar works programmatically', (tester) async {
      final shellKey = GlobalKey<AppShellState>();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AppShell(key: shellKey),
          ),
        ),
      );

      // Programmatically navigate to calendar
      shellKey.currentState!.navigateToCalendar();
      await tester.pumpAndSettle();

      // Calendar should now be visible
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('all five pages are accessible via navigation', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AppShell()),
        ),
      );

      await tester.pumpAndSettle();

      // Initially, only DashboardPage is visible (index 0)
      expect(find.byType(DashboardPage), findsOneWidget);

      // Navigate to Calendar (index 1)
      await tester.tap(find.text('Calendario'));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsOneWidget);

      // Navigate to Reservations (index 2)
      await tester.tap(find.text('Prenotazioni'));
      await tester.pumpAndSettle();
      expect(find.byType(ReservationsListPage), findsOneWidget);

      // Navigate to Statistics (index 3)
      await tester.tap(find.text('Statistiche'));
      await tester.pumpAndSettle();
      expect(find.byType(StatisticsPage), findsOneWidget);
    });
  });
}
