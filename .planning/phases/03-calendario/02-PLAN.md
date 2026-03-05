---
phase: 03-calendario
plan: 02
type: execute
wave: 2
depends_on: ["03-calendario-01"]
files_modified:
  - lib/features/reservations/presentation/widgets/reservation_calendar.dart
  - lib/features/reservations/presentation/widgets/reservation_day_cell.dart
  - test/features/reservations/presentation/widgets/reservation_calendar_test.dart
autonomous: true
requirements:
  - CAL-01
  - CAL-02
  - CAL-03
  - CAL-05
  - PLAT-07
  - UI-01
must_haves:
  truths:
    - "Il calendario mensile è visualizzato con griglia di giorni"
    - "I giorni con prenotazioni hanno sfondo colorato per piattaforma"
    - "L'intera durata della prenotazione (check-in to check-out) è colorata"
    - "Più prenotazioni nello stesso giorno mostrano indicatori (punti colorati)"
    - "Il colore della piattaforma corrisponde a BookingPlatform.defaultPlatforms"
    - "Il calendario è responsive (funziona su web e mobile)"
  artifacts:
    - path: "lib/features/reservations/presentation/widgets/reservation_calendar.dart"
      provides: "Widget calendario con table_calendar"
      exports: ["ReservationCalendar"]
      min_lines: 150
    - path: "lib/features/reservations/presentation/widgets/reservation_day_cell.dart"
      provides: "Widget cella giorno personalizzata"
      exports: ["ReservationDayCell"]
      min_lines: 80
    - path: "test/features/reservations/presentation/widgets/reservation_calendar_test.dart"
      provides: "Widget tests per calendario"
      min_lines: 100
  key_links:
    - from: "ReservationCalendar"
      to: "calendarProvider"
      via: "ConsumerWidget ref.watch"
      pattern: "ref.watch(calendarProvider)"
    - from: "ReservationCalendar"
      to: "table_calendar"
      via: "TableCalendar widget import"
      pattern: "import 'package:table_calendar/table_calendar.dart'"
    - from: "ReservationCalendar"
      to: "BookingPlatform.defaultPlatforms"
      via: "Static property access per colori"
      pattern: "BookingPlatform.defaultPlatforms.firstWhere"
    - from: "ReservationDayCell"
      to: "CalendarBuilders.defaultBuilder"
      via: "Custom builder callback"
      pattern: "calendarBuilders: CalendarBuilders(defaultBuilder: ...)"
---

<objective>
Implementare il widget calendario con colorazione per piattaforma e indicatori multipli.

Purpose: Visualizzare il calendario mensile con giorni colorati in base alla piattaforma delle prenotazioni, supportando più prenotazioni per giorno e design responsive.

Output: Widget calendario funzionante con table_calendar e personalizzazioni.
</objective>

<execution_context>
@./.claude/get-shit-done/workflows/execute-plan.md
@./.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/phases/03-calendario/03-RESEARCH.md
@.planning/phases/03-calendario/03-01-PLAN-SUMMARY.md

# From Research - table_calendar integration pattern
From .planning/phases/03-calendario/03-RESEARCH.md:
```dart
// Core table_calendar usage pattern
TableCalendar(
  firstDay: DateTime.utc(2020, 1, 1),
  lastDay: DateTime.utc(2030, 12, 31),
  focusedDay: focusedDay,
  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
  onDaySelected: onDaySelected,
  eventLoader: (day) => reservationsByDate[day] ?? [],
  calendarStyle: CalendarStyle(
    todayDecoration: BoxDecoration(...),
    selectedDecoration: BoxDecoration(...),
  ),
  calendarBuilders: CalendarBuilders(
    defaultBuilder: (context, day, focusedDay) {
      // Custom day cell with platform color
    },
    markerBuilder: (context, day, events) {
      // Colored dots for multiple reservations
    },
  ),
)
```

# From Wave 1 - CalendarProvider interface
From lib/features/reservations/presentation/providers/calendar_provider.dart:
```dart
class CalendarState {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<Reservation>> reservationsByDate;
  final bool isLoading;
  // ... copyWith method
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  Future<void> loadReservations();
  void selectDay(DateTime day);
  void changeMonth(DateTime focusedDay);
  Future<void> refresh();
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>(...);
```

# Platform colors from Phase 1
From lib/features/reservations/domain/entities/platform.dart:
```dart
static final List<BookingPlatform> defaultPlatforms = [
  BookingPlatform(id: 'booking', name: 'Booking', color: Color(0xFF2196F3)),
  BookingPlatform(id: 'airbnb', name: 'Airbnb', color: Color(0xFFE91E63)),
  BookingPlatform(id: 'whatsapp', name: 'WhatsApp', color: Color(0xFF4CAF50)),
  BookingPlatform(id: 'website', name: 'Sito Web', color: Color(0xFF9C27B0)),
  BookingPlatform(id: 'tiktok', name: 'TikTok', color: Color(0xFF212121)),
];
```
</context>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Create ReservationDayCell widget</name>
  <files>lib/features/reservations/presentation/widgets/reservation_day_cell.dart</files>
  <behavior>
    - Widget displays a single day cell with platform-colored background
    - Shows day number as text
    - Background color uses platform color with 30% opacity
    - Border color uses full platform color
    - Rounded corners (8px radius)
    - Returns null for days without reservations (uses default styling)
    - Gets platform color from BookingPlatform.defaultPlatforms
  </behavior>
  <action>
    Create reservation_day_cell.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

    /// Custom day cell widget for calendar with platform-colored background.
    class ReservationDayCell extends StatelessWidget {
      final DateTime day;
      final List<Reservation> reservations;

      const ReservationDayCell({
        super.key,
        required this.day,
        required this.reservations,
      });

      /// Get the dominant platform color for the day.
      ///
      /// Strategy: Use the first reservation's platform color.
      /// Additional platforms are shown as colored dots in markerBuilder.
      Color _getPlatformColor() {
        if (reservations.isEmpty) {
          return Colors.transparent;
        }

        final platform = BookingPlatform.defaultPlatforms.firstWhere(
          (p) => p.id == reservations.first.platformId,
          orElse: () => BookingPlatform.defaultPlatforms.first,
        );

        return platform.color;
      }

      @override
      Widget build(BuildContext context) {
        if (reservations.isEmpty) {
          // No reservations - use default day cell styling
          return null;
        }

        final platformColor = _getPlatformColor();

        return Container(
          margin: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: platformColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: platformColor,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: platformColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }

      /// Check if this cell should be rendered (has reservations).
      bool shouldRender() => reservations.isNotEmpty;
    }
    ```

    Implementation notes:
    - Use `withOpacity(0.3)` for background color
    - Full opacity for border and text color
    - Return null for days without reservations to use default styling
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/widgets/reservation_day_cell_test.dart</automated>
  </verify>
  <done>ReservationDayCell widget created with platform coloring</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Create ReservationCalendar widget</name>
  <files>lib/features/reservations/presentation/widgets/reservation_calendar.dart</files>
  <behavior>
    - ConsumerStatefulWidget that watches calendarProvider
    - Displays TableCalendar with custom day cell builder
    - Custom defaultBuilder uses ReservationDayCell for days with reservations
    - Custom markerBuilder shows colored dots for multiple reservations (max 3)
    - Locale set to Italian ('it_IT')
    - Calendar format starts with month view
    - Week starts on Monday (Italy standard)
    - Responsive sizing with MediaQuery
    - Calls onDaySelected callback when user taps a day
    - Calls onPageChanged callback when user navigates to different month
  </behavior>
  <action>
    Create reservation_calendar.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:table_calendar/table_calendar.dart';
    import 'package:intl/intl.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/providers/calendar_provider.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_day_cell.dart';

    /// Calendar widget showing reservations with platform-colored days.
    class ReservationCalendar extends ConsumerStatefulWidget {
      final void Function(DateTime selectedDay, DateTime focusedDay)? onDaySelected;
      final VoidCallback? onPageChanged;

      const ReservationCalendar({
        super.key,
        this.onDaySelected,
        this.onPageChanged,
      });

      @override
      ConsumerState<ReservationCalendar> createState() => _ReservationCalendarState();
    }

    class _ReservationCalendarState extends ConsumerState<ReservationCalendar> {
      late CalendarFormat _calendarFormat;
      late DateTime _selectedDay;
      late DateTime _focusedDay;

      @override
      void initState() {
        super.initState();
        _calendarFormat = CalendarFormat.month;
        _selectedDay = DateTime.now();
        _focusedDay = DateTime.now();
      }

      @override
      Widget build(BuildContext context) {
        final calendarState = ref.watch(calendarProvider);
        final calendarNotifier = ref.read(calendarProvider.notifier);

        // Update focused day when provider changes
        if (_focusedDay != calendarState.focusedDay) {
          _focusedDay = calendarState.focusedDay;
        }

        // Get screen width for responsive sizing
        final screenWidth = MediaQuery.of(context).size.width;
        final calendarWidth = screenWidth > 1200 ? 1000.0 : screenWidth - 32.0;

        return Center(
          child: SizedBox(
            width: calendarWidth,
            child: TableCalendar(
              // Locale settings
              locale: 'it_IT',

              // Date range
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,

              // Selection
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                // Update provider
                calendarNotifier.selectDay(selectedDay);
                calendarNotifier.changeMonth(focusedDay);

                // Call callback
                widget.onDaySelected?.call(selectedDay, focusedDay);
              },

              // Format
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },

              // Page navigation
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                calendarNotifier.changeMonth(focusedDay);
                widget.onPageChanged?.call();
              },

              // Events
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return calendarState.reservationsByDate[normalizedDay] ?? [];
              },

              // Style
              calendarStyle: CalendarStyle(
                // Today marker
                todayDecoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),

                // Selected day
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),

                // Default day
                defaultDecoration: const BoxDecoration(),
                defaultTextStyle: const TextStyle(
                  color: Colors.black87,
                ),

                // Outside month days
                outsideDecoration: BoxDecoration(
                  color: Colors.grey[100],
                ),
                outsideTextStyle: TextStyle(
                  color: Colors.grey[400],
                ),

                // Weekend
                weekendDecoration: const BoxDecoration(),
                weekendTextStyle: TextStyle(
                  color: Colors.red[700],
                ),

                // Markers
                markersMaxCount: 3,
                markerDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
              ),

              // Header style
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
                weekendStyle: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),

              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: const Icon(Icons.chevron_left),
                rightChevronIcon: const Icon(Icons.chevron_right),
              ),

              // Custom builders
              calendarBuilders: CalendarBuilders(
                // Custom day cell for platform-colored background
                defaultBuilder: (context, day, focusedDay) {
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  final reservations = calendarState.reservationsByDate[normalizedDay] ?? [];

                  if (reservations.isEmpty) {
                    // Use default styling for days without reservations
                    return null;
                  }

                  // Use custom day cell with platform color
                  return ReservationDayCell(
                    day: day,
                    reservations: reservations,
                  );
                },

                // Marker builder for multiple reservations
                markerBuilder: (context, day, events) {
                  if (events.length <= 1) return const SizedBox.shrink();

                  final reservations = events as List<Reservation>;

                  // Show colored dots for additional platforms (max 3)
                  return Positioned(
                    bottom: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: reservations.take(3).map((reservation) {
                        final platform = BookingPlatform.defaultPlatforms.firstWhere(
                          (p) => p.id == reservation.platformId,
                          orElse: () => BookingPlatform.defaultPlatforms.first,
                        );
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: platform.color,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },

                // Default today marker
                todayBuilder: (context, day, focusedDay) {
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  final reservations = calendarState.reservationsByDate[normalizedDay] ?? [];

                  // Combine today marker with reservation marker
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue,
                        width: reservations.isEmpty ? 1 : 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Week starts on Monday (Italy standard)
              startingDayOfWeek: StartingDayOfWeek.monday,
            ),
          ),
        );
      }
    }
    ```

    Implementation notes:
    - Use `isSameDay` from table_calendar for date comparisons
    - Normalize dates to midnight for map lookups
    - Responsive width calculation for desktop web
    - Italian locale for month/day names
    - Monday as first day of week
    - Show max 3 colored dots for multiple reservations
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/widgets/reservation_calendar_test.dart</automated>
  </verify>
  <done>ReservationCalendar widget with platform-colored days</done>
</task>

<task type="auto">
  <name>Task 3: Create widget tests for calendar widgets</name>
  <files>
    test/features/reservations/presentation/widgets/reservation_day_cell_test.dart
    test/features/reservations/presentation/widgets/reservation_calendar_test.dart
  </files>
  <action>
    Create comprehensive widget tests:

    **reservation_day_cell_test.dart:**
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_day_cell.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

    void main() {
      group('ReservationDayCell', () {
        testWidgets('renders null when no reservations', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: ReservationDayCell(
                  day: DateTime(2024, 6, 15),
                  reservations: [],
                ),
              ),
            ),
          );

          // Widget should return null, rendering nothing
          expect(find.byType(ReservationDayCell), findsNothing);
        });

        testWidgets('renders colored background for reservation', (tester) async {
          final reservation = Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking', // Blue color
            guest: Guest(name: 'Mario', phone: null),
            checkIn: DateTime(2024, 6, 15),
            checkOut: DateTime(2024, 6, 16),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ReservationDayCell(
                  day: DateTime(2024, 6, 15),
                  reservations: [reservation],
                ),
              ),
            ),
          );

          expect(find.text('15'), findsOneWidget);
          expect(find.byType(Container), findsWidgets);

          // Check for booking platform color (blue)
          final container = tester.widget<Container>(
            find.descendant(
              of: find.byType(ReservationDayCell),
              matching: find.byType(Container),
            ).first,
          );

          final decoration = container.decoration as BoxDecoration;
          expect(decoration.color, Colors.blue.withOpacity(0.3));
        });

        testWidgets('displays day number correctly', (tester) async {
          final reservation = Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: Guest(name: 'Mario', phone: null),
            checkIn: DateTime(2024, 6, 15),
            checkOut: DateTime(2024, 6, 16),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ReservationDayCell(
                  day: DateTime(2024, 6, 15),
                  reservations: [reservation],
                ),
              ),
            ),
          );

          expect(find.text('15'), findsOneWidget);
        });
      });
    }
    ```

    **reservation_calendar_test.dart:**
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_calendar.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
    import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/providers/calendar_provider.dart';
    import 'package:mocktail/mocktail.dart';

    class MockReservationRepository extends Mock implements ReservationRepository {}

    void main() {
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

          // Check for calendar elements
          expect(find.text('Lun'), findsOneWidget); // Monday in Italian
          expect(find.text('Mar'), findsOneWidget); // Tuesday in Italian
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
    ```

    Run tests:
    ```bash
    flutter test test/features/reservations/presentation/widgets/reservation_day_cell_test.dart
    flutter test test/features/reservations/presentation/widgets/reservation_calendar_test.dart
    ```
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/widgets/reservation_day_cell_test.dart test/features/reservations/presentation/widgets/reservation_calendar_test.dart</automated>
  </verify>
  <done>All widget tests passing for calendar components</done>
</task>

</tasks>

<verification>
1. `flutter analyze` passes for all new files
2. All widget tests pass:
   - `flutter test test/features/reservations/presentation/widgets/`
3. Calendar renders with Italian locale
4. Day cells show platform-colored backgrounds for reservations
5. Multiple reservations show colored dots (max 3)
6. Calendar is responsive (works on different screen sizes)
7. Week starts on Monday (Italy standard)
</verification>

<success_criteria>
1. ✅ ReservationCalendar widget displays monthly calendar
2. ✅ Days with reservations have platform-colored backgrounds
3. ✅ Entire date range (check-in to check-out) is colored
4. ✅ Multiple reservations show colored dot indicators
5. ✅ Platform colors match BookingPlatform.defaultPlatforms
6. ✅ Calendar is responsive for web and mobile
7. ✅ All widget tests pass
</success_criteria>

<output>
After completion, create `.planning/phases/03-calendario/03-02-PLAN-SUMMARY.md` with:
- Wave number (2)
- Tasks completed (3)
- Test results (widget tests)
- Screenshots of calendar on web and mobile
- Next wave (03 - Day Details Bottom Sheet)
</output>
