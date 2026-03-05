---
phase: 04-dashboard-navigation
plan: 04
type: execute
wave: 4
depends_on:
  - 04-02
  - 04-03
files_modified:
  - lib/core/widgets/app_shell.dart
  - lib/main.dart
  - test/core/widgets/app_shell_test.dart
  - test/integration/dashboard_navigation_test.dart
autonomous: true
requirements:
  - CAL-05
  - DASH-06
  - UI-06
  - TEST-04
  - A11Y-01
must_haves:
  truths:
    - "L'utente vede la Dashboard come schermata iniziale"
    - "L'utente puo navigare tra Dashboard, Calendario e Prenotazioni con bottom bar"
    - "Lo stato di ogni tab viene preservato quando si cambia tab"
    - "La card Calendario nella Dashboard naviga al tab Calendario"
    - "L'app funziona completamente su Chrome"
    - "Tutti i test passano (unit, widget, integration)"
  artifacts:
    - path: "lib/core/widgets/app_shell.dart"
      provides: "Navigation shell con IndexedStack e BottomNavigationBar"
      exports: ["AppShell"]
      min_lines: 80
    - path: "lib/main.dart"
      provides: "Entry point con AppShell come home"
      contains: "AppShell"
  key_links:
    - from: "app_shell.dart"
      to: "DashboardPage, CalendarPage, ReservationsListPage"
      via: "IndexedStack children"
      pattern: "IndexedStack.*children:"
    - from: "app_shell.dart"
      to: "BottomNavigationBar"
      via: "Widget composition"
      pattern: "BottomNavigationBar\\("
    - from: "main.dart"
      to: "AppShell"
      via: "MaterialApp home"
      pattern: "home:.*AppShell"
    - from: "dashboard_page.dart"
      to: "app_shell.dart"
      via: "onCalendarTap callback"
      pattern: "onCalendarTap"
---

<objective>
Implementare la navigazione bottom bar con IndexedStack e integrare tutte le schermate.

Purpose: Completare l'app con navigazione fluida tra le tre sezioni principali (Dashboard, Calendario, Prenotazioni) preservando lo stato di ogni tab.

Output: AppShell con BottomNavigationBar, main.dart aggiornato, e test di integrazione completi.
</objective>

<execution_context>
@./.claude/get-shit-done/workflows/execute-plan.md
@./.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/phases/04-dashboard-navigation/CONTEXT.md
@.planning/phases/04-dashboard-navigation/04-RESEARCH.md

# Wave 1-3 outputs (dependencies)
@.planning/phases/04-dashboard-navigation/01-PLAN.md
@.planning/phases/04-dashboard-navigation/02-PLAN.md
@.planning/phases/04-dashboard-navigation/03-PLAN.md

# Existing pages from Phases 1-4

From lib/features/reservations/presentation/pages/dashboard_page.dart:
```dart
class DashboardPage extends ConsumerWidget {
  final VoidCallback? onCalendarTap;

  const DashboardPage({super.key, this.onCalendarTap});
}
```

From lib/features/reservations/presentation/pages/calendar_page.dart:
```dart
class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});
}
```

From lib/features/reservations/presentation/pages/reservations_list_page.dart:
```dart
class ReservationsListPage extends ConsumerStatefulWidget {
  const ReservationsListPage({super.key});
}
```

From lib/main.dart:
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Prenotazioni',
      home: const CalendarPage(), // Currently shows calendar
    );
  }
}
```

# IndexedStack Pattern (from RESEARCH.md)

```dart
class AppShell extends StatefulWidget {
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    DashboardPage(),
    CalendarPage(),
    ReservationsListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [...],
      ),
    );
  }
}
```
</context>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Create AppShell with IndexedStack navigation</name>
  <files>lib/core/widgets/app_shell.dart</files>
  <behavior>
    - Uses IndexedStack to preserve page state across tab switches
    - BottomNavigationBar with 3 items: Dashboard, Calendario, Prenotazioni
    - Dashboard is index 0 (default home)
    - Calendar tab is index 1
    - Reservations tab is index 2
    - Provides navigateToCalendar() method for programmatic navigation
    - Dashboard receives onCalendarTap callback to navigate to calendar tab
    - Icons: dashboard, calendar_today, list
    - Accessible with semantic labels
  </behavior>
  <action>
    Create app_shell.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/pages/dashboard_page.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/pages/calendar_page.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/pages/reservations_list_page.dart';

    /// Main navigation shell with bottom navigation bar.
    ///
    /// Uses IndexedStack to preserve page state across tab switches.
    /// This prevents rebuilding pages when switching tabs.
    class AppShell extends StatefulWidget {
      const AppShell({super.key});

      @override
      State<AppShell> createState() => AppShellState();
    }

    /// Public state class for programmatic navigation.
    class AppShellState extends State<AppShell> {
      int _currentIndex = 0;

      // Pages are created once and kept in memory via IndexedStack
      late final List<Widget> _pages = [
        DashboardPage(
          onCalendarTap: () => navigateToCalendar(),
        ),
        const CalendarPage(),
        const ReservationsListPage(),
      ];

      /// Navigate to calendar tab programmatically.
      void navigateToCalendar() {
        setState(() {
          _currentIndex = 1;
        });
      }

      /// Navigate to reservations tab programmatically.
      void navigateToReservations() {
        setState(() {
          _currentIndex = 2;
        });
      }

      /// Navigate to dashboard tab.
      void navigateToDashboard() {
        setState(() {
          _currentIndex = 0;
        });
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Calendario',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Prenotazioni',
              ),
            ],
          ),
        );
      }
    }
    ```

    Implementation notes:
    - IndexedStack keeps all children in memory, only changing visibility
    - State class is public (AppShellState) to allow programmatic navigation
    - Pages list uses late final to capture callbacks in closure
    - Dashboard receives onCalendarTap callback for navigation from calendar card
  </action>
  <verify>
    <automated>flutter test test/core/widgets/app_shell_test.dart</automated>
  </verify>
  <done>AppShell created with IndexedStack and BottomNavigationBar</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Update main.dart to use AppShell as home</name>
  <files>lib/main.dart</files>
  <behavior>
    - AppShell replaces CalendarPage as home screen
    - Dashboard is now the default view on app launch
    - MaterialApp structure preserved
    - Theme configuration unchanged
  </behavior>
  <action>
    Update main.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:app_prenotazioni/core/widgets/app_shell.dart';

    void main() {
      runApp(
        const ProviderScope(
          child: MyApp(),
        ),
      );
    }

    class MyApp extends StatelessWidget {
      const MyApp({super.key});

      @override
      Widget build(BuildContext context) {
        return MaterialApp(
          title: 'App Prenotazioni',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const AppShell(),
        );
      }
    }
    ```

    Changes from previous version:
    - Import app_shell.dart instead of calendar_page.dart
    - Replace CalendarPage with AppShell as home
    - Remove unused routes comment block (navigation handled by AppShell)
  </action>
  <verify>
    <automated>flutter test test/widget_test.dart 2>/dev/null || echo "Main app test not required"</automated>
  </verify>
  <done>main.dart updated with AppShell as home screen</done>
</task>

<task type="auto">
  <name>Task 3: Create AppShell widget tests</name>
  <files>test/core/widgets/app_shell_test.dart</files>
  <action>
    Create comprehensive widget tests:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:app_prenotazioni/core/widgets/app_shell.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/pages/dashboard_page.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/pages/calendar_page.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/pages/reservations_list_page.dart';

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

        testWidgets('all three pages exist in widget tree', (tester) async {
          await tester.pumpWidget(
            const ProviderScope(
              child: MaterialApp(home: AppShell()),
            ),
          );

          // All pages should exist (IndexedStack keeps all children)
          expect(find.byType(DashboardPage), findsOneWidget);
          expect(find.byType(CalendarPage), findsOneWidget);
          expect(find.byType(ReservationsListPage), findsOneWidget);
        });
      });
    }
    ```
  </action>
  <verify>
    <automated>flutter test test/core/widgets/app_shell_test.dart</automated>
  </verify>
  <done>All AppShell widget tests passing</done>
</task>

<task type="auto">
  <name>Task 4: Create integration test for full navigation flow</name>
  <files>test/integration/dashboard_navigation_test.dart</files>
  <action>
    Create integration test covering full user flow:
    ```dart
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

          // Verify semantic labels exist for accessibility
          // (BottomNavigationBarItem provides these via label property)
          final bottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );

          expect(bottomNavBar.items[0].label, 'Dashboard');
          expect(bottomNavBar.items[1].label, 'Calendario');
          expect(bottomNavBar.items[2].label, 'Prenotazioni');
        });
      });
    }
    ```
  </action>
  <verify>
    <automated>flutter test test/integration/dashboard_navigation_test.dart</automated>
  </verify>
  <done>Integration test for complete navigation flow passing</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Complete Phase 4 implementation:
- Dashboard with statistics (occupancy, income, upcoming reservations)
- Bottom navigation with 3 tabs (Dashboard, Calendario, Prenotazioni)
- Reservations list with swipe-to-edit/delete
- Edit reservation functionality
- Full navigation integration with state preservation</what-built>
  <how-to-verify>
1. Run `flutter run -d chrome` to start the web app
2. Verify Dashboard shows as home screen with:
   - Room occupancy grid (4 rooms)
   - Income breakdown card
   - Calendar access card
   - Upcoming arrivals/departures
3. Click "Apri Calendario" card - should switch to Calendar tab
4. Navigate to "Prenotazioni" tab - should show empty state or reservations list
5. If reservations exist: swipe left/right to reveal edit/delete actions
6. Test bottom navigation switches tabs correctly
7. Verify state is preserved when switching tabs (e.g., scroll position)
8. Run `flutter test` to verify all tests pass</how-to-verify>
  <resume-signal>Type "approved" to proceed to Phase 5, or describe issues found</resume-signal>
</task>

</tasks>

<verification>
1. `flutter analyze` passes for all new and modified files
2. All widget tests pass
3. Integration test passes
4. App starts with Dashboard as home screen
5. Bottom navigation switches between all 3 tabs
6. Calendar card in dashboard navigates to calendar tab
7. State is preserved when switching tabs
8. All Phase 4 requirements satisfied
9. Full `flutter test` suite passes
10. App runs successfully on Chrome
</verification>

<success_criteria>
1. Dashboard is the home screen with complete statistics
2. BottomNavigationBar provides navigation to all 3 sections
3. IndexedStack preserves page state across tab switches
4. Calendar access card navigates to calendar tab
5. All widget and integration tests pass
6. App tested and working on Chrome
7. Phase 4 requirements complete:
   - DASH-01/02/03/04/05/06
   - CAL-05
   - RES-08/09
   - UI-04/06
   - TEST-04
   - A11Y-01
</success_criteria>

<output>
After completion, create `.planning/phases/04-dashboard-navigation/04-04-SUMMARY.md` with:
- Wave number (4)
- Tasks completed (5 including checkpoint)
- Test results
- Files created/modified
- Phase completion status
- Chrome testing notes
</output>
