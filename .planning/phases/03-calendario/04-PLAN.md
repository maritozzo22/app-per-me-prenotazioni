---
phase: 03-calendario
plan: 04
type: execute
wave: 4
depends_on: ["03-calendario-03"]
files_modified:
  - lib/features/reservations/presentation/pages/calendar_page.dart
  - lib/main.dart
  - test/features/reservations/presentation/pages/calendar_page_test.dart
  - test/integration/calendar_integration_test.dart
autonomous: true
requirements:
  - CAL-01
  - CAL-02
  - CAL-03
  - CAL-04
  - CAL-05
  - PLAT-07
  - UI-01
  - UI-02
  - TEST-03
must_haves:
  truths:
    - "La pagina calendario è accessibile come route principale o tramite navigation"
    - "Il calendario mostra tutti i mesi navigabili (prev/next)"
    - "Tutti i widget funzionano correttamente insieme"
    - "L'app funziona su browser web (Chrome)"
    - "L'app funziona su Android emulator o device"
    - "Tutti i test (unit, widget, integration) passano"
    - "Il calendario si aggiorna dopo CRUD operations (refresh())"
  artifacts:
    - path: "lib/features/reservations/presentation/pages/calendar_page.dart"
      provides: "Pagina calendario completa"
      exports: ["CalendarPage"]
      min_lines: 80
    - path: "test/features/reservations/presentation/pages/calendar_page_test.dart"
      provides: "Widget tests per pagina calendario"
      min_lines: 60
    - path: "test/integration/calendar_integration_test.dart"
      provides: "Integration test per flusso completo"
      min_lines: 100
    - path: "lib/main.dart"
      provides: "App entry point con calendar route"
      contains: "CalendarPage"
  key_links:
    - from: "CalendarPage"
      to: "calendarProvider"
      via: "ConsumerWidget ref.watch"
      pattern: "ref.watch(calendarProvider)"
    - from: "CalendarPage"
      to: "ReservationCalendar"
      via: "Widget composition"
      pattern: "ReservationCalendar(onDaySelected: ...)"
    - from: "CalendarPage"
      to: "DayDetailBottomSheet"
      via: "ReservationCalendar callback"
      pattern: "onDaySelected shows bottom sheet"
    - from: "main.dart"
      to: "CalendarPage"
      via: "Route definition"
      pattern: "routes: {'/': (context) => CalendarPage()"
---

<objective>
Creare la pagina calendario completa e testare l'integrazione su web e Android.

Purpose: Assemblare tutti i componenti calendario in una pagina completa, configurare l'app entry point, e verificare il funzionamento su web e Android con test completi.

Output: App funzionante con calendario accessibile, tutti i test passanti, verifica su web e Android.
</objective>

<execution_context>
@./.claude/get-shit-done/workflows/execute-plan.md
@./.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/phases/03-calendario/03-RESEARCH.md
@.planning/phases/03-calendario/03-03-PLAN-SUMMARY.md

# From Wave 3 - Complete calendar components
- ReservationCalendar: Calendar widget with platform colors
- DayDetailBottomSheet: Bottom sheet for day details
- ReservationDayCard: Card displaying reservation info
- CalendarProvider: State management

# From Phase 1 & 2 - App structure
- main.dart exists with ProviderScope
- Repository pattern established
- Database layer functional

# From Research - Integration pattern
```dart
class CalendarPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Calendario Prenotazioni')),
      body: calendarState.isLoading
          ? Center(child: CircularProgressIndicator())
          : ReservationCalendar(...),
    );
  }
}
```
</context>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Create CalendarPage</name>
  <files>lib/features/reservations/presentation/pages/calendar_page.dart</files>
  <behavior>
    - ConsumerWidget that watches calendarProvider
    - Shows loading indicator while reservations load
    - Displays ReservationCalendar as main content
    - AppBar with title "Calendario Prenotazioni"
    - Optional: FAB to create new reservation (for Phase 4)
    - Handles error states gracefully
    - Responsive layout
  </behavior>
  <action>
    Create calendar_page.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/providers/calendar_provider.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_calendar.dart';

    /// Calendar page showing monthly reservation view.
    class CalendarPage extends ConsumerWidget {
      const CalendarPage({super.key});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final calendarState = ref.watch(calendarProvider);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Calendario Prenotazioni'),
            elevation: 2,
          ),
          body: RefreshIndicator(
            onRefresh: () {
              return ref.read(calendarProvider.notifier).refresh();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Calendar widget
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: calendarState.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ReservationCalendar(
                            onDaySelected: (selectedDay, focusedDay) {
                              // Bottom sheet is shown automatically by ReservationCalendar
                            },
                            onPageChanged: () {
                              // Month changed - could load more data if needed
                            },
                          ),
                  ),

                  // Info section below calendar
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Seleziona un giorno per vedere le prenotazioni',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Trascina per navigare tra i mesi',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    ```

    Implementation notes:
    - Use RefreshIndicator for pull-to-refresh functionality
    - Responsive layout using MediaQuery
    - Calendar takes 70% of screen height
    - Info section explains how to use the calendar
    - Loading state shown while reservations load
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/pages/calendar_page_test.dart</automated>
  </verify>
  <done>CalendarPage created with refresh indicator and info section</done>
</task>

<task type="auto">
  <name>Task 2: Update main.dart to use CalendarPage</name>
  <files>lib/main.dart</files>
  <action>
    Update main.dart to set CalendarPage as the home route:

    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/pages/calendar_page.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';

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
          home: const CalendarPage(),
          // Optional: Add routes for future navigation
          // routes: {
          //   '/': (context) => const CalendarPage(),
          //   '/reservations': (context) => const ReservationsListPage(),
          // },
        );
      }
    }
    ```

    Implementation notes:
    - Keep ProviderScope from Phase 1
    - Set CalendarPage as home
    - Use Material 3 design
    - Disable debug banner for cleaner UI
    - Add comment for future routes (Phase 4)
  </action>
  <verify>
    <automated>flutter run -d chrome --web-port=8080 (manual check: calendar loads)</automated>
  </verify>
  <done>App launches with CalendarPage as home screen</done>
</task>

<task type="auto">
  <name>Task 3: Create widget tests for CalendarPage</name>
  <files>test/features/reservations/presentation/pages/calendar_page_test.dart</files>
  <action>
    Create calendar_page_test.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/pages/calendar_page.dart';
    import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/providers/calendar_provider.dart';
    import 'package:mocktail/mocktail.dart';

    class MockReservationRepository extends Mock implements ReservationRepository {}

    void main() {
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
          // Delay the repository response
          when(() => mockRepository.getAllReservations()).thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return [];
          });

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
    ```

    Run tests:
    ```bash
    flutter test test/features/reservations/presentation/pages/calendar_page_test.dart
    ```
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/pages/calendar_page_test.dart</automated>
  </verify>
  <done>All CalendarPage widget tests passing</done>
</task>

<task type="auto">
  <name>Task 4: Create integration test for calendar flow</name>
  <files>test/integration/calendar_integration_test.dart</files>
  <action>
    Create calendar_integration_test.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:app_prenotazioni/main.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
    import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
    import 'package:mocktail/mocktail.dart';

    class MockReservationRepository extends Mock implements ReservationRepository {}

    void main() {
      group('Calendar Integration Test', () {
        late MockReservationRepository mockRepository;

        setUp(() {
          mockRepository = MockReservationRepository();
        });

        testWidgets('complete calendar flow: load -> view -> select day -> show details', (tester) async {
          // Setup test data
          final testReservations = [
            Reservation(
              id: '1',
              roomId: 'room-1',
              platformId: 'booking',
              guest: Guest(name: 'Mario Rossi', phone: '+39 123 456 7890'),
              checkIn: DateTime(2024, 6, 15),
              checkOut: DateTime(2024, 6, 18),
              amount: 150.0,
              createdAt: DateTime(2024, 6, 1),
              updatedAt: DateTime(2024, 6, 1),
            ),
            Reservation(
              id: '2',
              roomId: 'room-2',
              platformId: 'airbnb',
              guest: Guest(name: 'Luca Verdi', phone: null),
              checkIn: DateTime(2024, 6, 15),
              checkOut: DateTime(2024, 6, 17),
              amount: 120.0,
              createdAt: DateTime(2024, 6, 1),
              updatedAt: DateTime(2024, 6, 1),
            ),
          ];

          when(() => mockRepository.getAllReservations())
              .thenAnswer((_) async => testReservations);

          // Launch app
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                reservationRepositoryProvider.overrideWithValue(mockRepository),
              ],
              child: const MyApp(),
            ),
          );

          await tester.pumpAndSettle();

          // Step 1: Verify calendar page is loaded
          expect(find.text('Calendario Prenotazioni'), findsOneWidget);

          // Step 2: Verify calendar displays (look for weekday labels in Italian)
          expect(find.text('Lun'), findsOneWidget);
          expect(find.text('Mar'), findsOneWidget);

          // Step 3: Tap on day 15 (which has reservations)
          await tester.tap(find.text('15'));
          await tester.pumpAndSettle();

          // Step 4: Verify bottom sheet appears
          expect(find.text('Prenotazioni'), findsOneWidget);

          // Step 5: Verify both reservations are shown
          expect(find.text('Mario Rossi'), findsOneWidget);
          expect(find.text('Luca Verdi'), findsOneWidget);

          // Step 6: Verify reservation details
          expect(find.text('Booking'), findsOneWidget);
          expect(find.text('Airbnb'), findsOneWidget);
          expect(find.text('Stanza 1'), findsOneWidget);
          expect(find.text('Stanza 2'), findsOneWidget);

          // Step 7: Dismiss bottom sheet
          await tester.drag(find.byType(DraggableScrollableSheet), const Offset(0, 500));
          await tester.pumpAndSettle();

          // Verify bottom sheet is dismissed
          expect(find.text('Mario Rossi'), findsNothing);
        });

        testWidgets('displays empty state for day without reservations', (tester) async {
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

          // Tap on a day (no reservations)
          await tester.tap(find.text('20'));
          await tester.pumpAndSettle();

          // Verify empty state message
          expect(find.text('Nessuna prenotazione'), findsOneWidget);
          expect(find.text('Questa data è libera'), findsOneWidget);
        });

        testWidgets('navigates between months', (tester) async {
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

          // Tap next month button
          await tester.tap(find.byIcon(Icons.chevron_right));
          await tester.pumpAndSettle();

          // Calendar should still be visible
          expect(find.text('Lun'), findsOneWidget);

          // Tap previous month button
          await tester.tap(find.byIcon(Icons.chevron_left));
          await tester.pumpAndSettle();

          expect(find.text('Lun'), findsOneWidget);
        });

        testWidgets('refreshes data on pull-to-refresh', (tester) async {
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

          // Pull to refresh
          await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
          await tester.pump();

          // Verify getAllReservations was called again
          verify(() => mockRepository.getAllReservations()).called(2);
        });
      });
    }
    ```

    Run integration test:
    ```bash
    flutter test test/integration/calendar_integration_test.dart
    ```
  </action>
  <verify>
    <automated>flutter test test/integration/calendar_integration_test.dart</automated>
  </verify>
  <done>Integration test passes for complete calendar flow</done>
</task>

<task type="checkpoint:human-verify">
  <name>Task 5: Manual testing on web (Chrome)</name>
  <files>N/A (manual testing)</files>
  <action>
    Run the app on Chrome web browser and verify:

    1. Launch app:
       ```bash
       flutter run -d chrome --web-port=8080
       ```

    2. Test calendar functionality:
       - Calendar loads and displays current month
       - Weekday labels are in Italian (Lun, Mar, Mer...)
       - Week starts on Monday
       - Navigate to previous/next month using arrows
       - Swipe gestures work (drag left/right)

    3. Test day selection:
       - Tap on a day with reservations → bottom sheet appears
       - Tap on a day without reservations → empty state appears
       - Bottom sheet shows correct date in Italian
       - Bottom sheet can be dismissed by tapping outside or dragging

    4. Test visual elements:
       - Days with reservations have platform-colored backgrounds
       - Multiple reservations show colored dots (max 3)
       - Platform colors match BookingPlatform.defaultPlatforms
       - Payment status icons display correctly
       - Room names display correctly

    5. Test responsive design:
       - Resize browser window (desktop vs mobile width)
       - Calendar scales appropriately
       - Bottom sheet remains usable on narrow screens

    6. Test pull-to-refresh:
       - Pull down on calendar to refresh
       - Loading indicator shows briefly
       - Calendar updates with any data changes

    7. Create reservations for testing (using Phase 2 form or database):
       - Create overlapping reservations for different rooms
       - Verify both appear in calendar on same day
       - Verify colors are correct for each platform
  </action>
  <verify>Manual: All features work correctly on Chrome browser</verify>
  <done>Calendar fully functional on web (Chrome)</done>
</task>

<task type="checkpoint:human-verify">
  <name>Task 6: Manual testing on Android</name>
  <files>N/A (manual testing)</files>
  <action>
    Run the app on Android device/emulator and verify:

    1. Setup:
       ```bash
       flutter devices  # Find Android device ID
       flutter run -d <device-id>
       ```

    2. Test all functionality from Task 5 (web testing):
       - Calendar loads and displays
       - Italian weekday labels
       - Month navigation
       - Day selection and bottom sheet
       - Platform-colored days
       - Multiple reservation indicators
       - Pull-to-refresh

    3. Android-specific testing:
       - Touch targets are large enough (48x48dp minimum)
       - Bottom sheet keyboard handling works
       - Swipe gestures are smooth
       - Performance is acceptable (no lag)
       - Orientation changes work (portrait/landscape)

    4. Visual checks:
       - Colors display correctly
       - Text is readable
       - Calendar grid is properly sized
       - No overflow errors

    5. Performance:
       - Calendar navigation is smooth
       - Bottom sheet opens/closes without lag
       - No frame drops during interactions

    Note: Any bugs found should be documented for Phase 6 (Android Optimization).
  </action>
  <verify>Manual: All features work correctly on Android device/emulator</verify>
  <done>Calendar fully functional on Android (with known issues noted for Phase 6)</done>
</task>

<task type="auto">
  <name>Task 7: Run complete test suite and verify all tests pass</name>
  <files>N/A (test execution)</files>
  <action>
    Run the complete test suite to ensure everything works:

    1. Run all tests:
       ```bash
       flutter test
       ```

    2. Run with coverage:
       ```bash
       flutter test --coverage
       ```

    3. Verify test counts:
       - Unit tests: CalendarService, CalendarProvider
       - Widget tests: ReservationDayCell, ReservationCalendar, ReservationDayCard, DayDetailBottomSheet, CalendarPage
       - Integration tests: Calendar flow

    4. Check for any skipped or failing tests

    5. Run flutter analyze:
       ```bash
       flutter analyze
       ```

    6. Fix any issues found

    Expected results:
       - All tests pass (100% pass rate)
       - No critical analyzer issues
       - Code coverage acceptable for Phase 3
  </action>
  <verify>
    <automated>flutter test && flutter analyze</automated>
  </verify>
  <done>All tests passing, no critical analyzer issues</done>
</task>

</tasks>

<verification>
1. CalendarPage loads correctly as home screen
2. All calendar features work on web (Chrome)
3. All calendar features work on Android
4. All unit tests pass
5. All widget tests pass
6. Integration test passes
7. `flutter analyze` passes without critical issues
8. Platform colors match BookingPlatform.defaultPlatforms
9. Pull-to-refresh functionality works
10. Bottom sheet shows/hides correctly
</verification>

<success_criteria>
1. ✅ CalendarPage created and set as home route
2. ✅ App runs on web (Chrome) with all features functional
3. ✅ App runs on Android with all features functional
4. ✅ All tests pass (unit, widget, integration)
5. ✅ Pull-to-refresh works
6. ✅ Platform colors correct
7. ✅ Italian localization works
8. ✅ Responsive design works
9. ✅ `flutter analyze` passes
10. ✅ Phase 3 complete and ready for Phase 4
</success_criteria>

<output>
After completion, create `.planning/phases/03-calendario/03-04-PLAN-SUMMARY.md` and `.planning/phases/03-calendario/PHASE-3-COMPLETE.md` with:
- Wave number (4)
- Tasks completed (7)
- Test results summary (all passing)
- Screenshots from web and Android
- Performance observations
- Known issues (if any) for Phase 6
- Phase 3 completion status
</output>
