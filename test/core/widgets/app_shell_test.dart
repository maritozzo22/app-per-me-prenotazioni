import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/core/widgets/app_shell.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/dashboard_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/calendar_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/reservations_list_page.dart';
import 'package:app_prenotazioni/features/platforms/presentation/pages/platforms_list_page.dart';

void main() {
  group('AppShell', () {
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
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Calendario'), findsOneWidget);
      expect(find.text('Prenotazioni'), findsOneWidget);
      expect(find.text('Piattaforme'), findsOneWidget);
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
      expect(find.byType(CalendarPage), findsOneWidget);
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

    testWidgets('all four pages exist in widget tree', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AppShell()),
        ),
      );

      // All pages should exist (IndexedStack keeps all children)
      expect(find.byType(DashboardPage), findsOneWidget);
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(find.byType(ReservationsListPage), findsOneWidget);
      expect(find.byType(PlatformsListPage), findsOneWidget);
    });
  });
}
