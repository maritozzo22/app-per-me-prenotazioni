---
phase: 03-calendario
plan: 03
type: execute
wave: 3
depends_on: ["03-calendario-02"]
files_modified:
  - lib/features/reservations/presentation/widgets/day_detail_bottom_sheet.dart
  - lib/features/reservations/presentation/widgets/reservation_day_card.dart
  - test/features/reservations/presentation/widgets/day_detail_bottom_sheet_test.dart
autonomous: true
requirements:
  - CAL-04
  - CAL-05
  - UI-01
must_haves:
  truths:
    - "Tappando su un giorno si apre un bottom sheet con dettagli"
    - "Il bottom sheet mostra la lista delle prenotazioni per quel giorno"
    - "Ogni prenotazione mostra: guest name, room, platform, date range"
    - "Il bottom sheet ha drag handle per chiudere"
    - "Il bottom sheet gestisce correttamente la keyboard (SafeArea)"
    - "Se non ci sono prenotazioni, mostra messaggio 'Nessuna prenotazione'"
  artifacts:
    - path: "lib/features/reservations/presentation/widgets/day_detail_bottom_sheet.dart"
      provides: "Bottom sheet per dettagli giorno"
      exports: ["DayDetailBottomSheet"]
      min_lines: 100
    - path: "lib/features/reservations/presentation/widgets/reservation_day_card.dart"
      provides: "Card per visualizzare prenotazione"
      exports: ["ReservationDayCard"]
      min_lines: 80
    - path: "test/features/reservations/presentation/widgets/day_detail_bottom_sheet_test.dart"
      provides: "Widget tests per bottom sheet"
      min_lines: 80
  key_links:
    - from: "ReservationCalendar"
      to: "DayDetailBottomSheet.show"
      via: "onDaySelected callback"
      pattern: "DayDetailBottomSheet.show(context, day: selectedDay, reservations: ...)"
    - from: "DayDetailBottomSheet"
      to: "showModalBottomSheet"
      via: "Flutter API call"
      pattern: "showModalBottomSheet(...)"
    - from: "ReservationDayCard"
      to: "BookingPlatform.defaultPlatforms"
      via: "Static property access per colori"
      pattern: "BookingPlatform.defaultPlatforms.firstWhere"
    - from: "ReservationDayCard"
      to: "Room.defaultRooms"
      via: "Static property access per nomi stanze"
      pattern: "Room.defaultRooms.firstWhere"
---

<objective>
Implementare il bottom sheet per mostrare i dettagli delle prenotazioni di un giorno.

Purpose: Consentire all'utente di visualizzare tutti i dettagli delle prenotazioni per un giorno specifico tramite un bottom sheet draggable e responsive.

Output: Bottom sheet funzionante con lista prenotazioni e card dettagliate.
</objective>

<execution_context>
@./.claude/get-shit-done/workflows/execute-plan.md
@./.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/phases/03-calendario/03-RESEARCH.md
@.planning/phases/03-calendario/03-02-PLAN-SUMMARY.md

# From Research - Bottom sheet pattern
From .planning/phases/03-calendario/03-RESEARCH.md:
```dart
static Future<void> show(
  BuildContext context, {
  required DateTime day,
  required List<Reservation> reservations,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => DayDetailBottomSheet(
      day: day,
      reservations: reservations,
    ),
  );
}
```

# From Wave 2 - Integration with calendar
The ReservationCalendar widget will call DayDetailBottomSheet.show in its onDaySelected callback.

# From Phase 2 - Reservation display pattern
Existing widgets show reservation details with platform colors and room names.
</context>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Create ReservationDayCard widget</name>
  <files>lib/features/reservations/presentation/widgets/reservation_day_card.dart</files>
  <behavior>
    - Card displaying reservation details in compact format
    - Shows: guest name, room name, platform name with color indicator, date range, payment status
    - Platform color shown as colored circle or badge
    - Payment status shown with icon (received = green check, pending = orange clock)
    - Rounded corners with subtle shadow
    - Tap-able (can add edit/delete actions in future waves)
    - Height optimized for bottom sheet list
  </behavior>
  <action>
    Create reservation_day_card.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:intl/intl.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
    import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

    /// Card displaying reservation details in a compact format.
    class ReservationDayCard extends StatelessWidget {
      final Reservation reservation;

      const ReservationDayCard({
        super.key,
        required this.reservation,
      });

      /// Get room name by ID.
      String _getRoomName() {
        final room = Room.defaultRooms.firstWhere(
          (r) => r.id == reservation.roomId,
          orElse: () => Room.defaultRooms.first,
        );
        return room.name;
      }

      /// Get platform by ID.
      BookingPlatform _getPlatform() {
        return BookingPlatform.defaultPlatforms.firstWhere(
          (p) => p.id == reservation.platformId,
          orElse: () => BookingPlatform.defaultPlatforms.first,
        );
      }

      /// Format date range for display.
      String _formatDateRange() {
        final formatter = DateFormat('dd MMM', 'it_IT');
        final checkIn = formatter.format(reservation.checkIn);
        final checkOut = formatter.format(reservation.checkOut);
        return '$checkIn - $checkOut';
      }

      /// Get payment status icon and color.
      ({IconData icon, Color color}) _getPaymentStatusData() {
        switch (reservation.paymentStatus) {
          case PaymentStatus.received:
            return (icon: Icons.check_circle, color: Colors.green);
          case PaymentStatus.pending:
            return (icon: Icons.pending, color: Colors.orange);
        }
      }

      @override
      Widget build(BuildContext context) {
        final platform = _getPlatform();
        final roomName = _getRoomName();
        final paymentData = _getPaymentStatusData();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Guest name (primary)
                Text(
                  reservation.guest.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 8),

                // Room and platform row
                Row(
                  children: [
                    // Platform indicator
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: platform.color,
                        shape: BoxShape.circle,
                      ),
                    ),

                    // Platform name
                    Text(
                      platform.name,
                      style: TextStyle(
                        color: platform.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Spacer(),

                    // Room name
                    Icon(
                      Icons.bed,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      roomName,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Date range
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateRange(),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${reservation.numberOfNights} nott${reservation.numberOfNights == 1 ? 'e' : 'i'})',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),

                // Payment status and amount (if available)
                if (reservation.amount != null || reservation.paymentStatus != PaymentStatus.pending)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          paymentData.icon,
                          size: 16,
                          color: paymentData.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reservation.paymentStatus == PaymentStatus.received
                              ? 'Pagato'
                              : 'In attesa',
                          style: TextStyle(
                            color: paymentData.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (reservation.amount != null) ...[
                          const Spacer(),
                          Text(
                            '€ ${reservation.amount!.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                // Notes (if available)
                if (reservation.notes != null && reservation.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            reservation.notes!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    }
    ```

    Implementation notes:
    - Use record syntax for payment status data: `(IconData icon, Color color)`
    - Compact layout optimized for bottom sheet
    - All text in Italian
    - Show nights count with correct pluralization
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/widgets/reservation_day_card_test.dart</automated>
  </verify>
  <done>ReservationDayCard widget with complete reservation details</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Create DayDetailBottomSheet widget</name>
  <files>lib/features/reservations/presentation/widgets/day_detail_bottom_sheet.dart</files>
  <behavior>
    - Modal bottom sheet showing all reservations for selected day
    - Static `show()` method for easy display
    - Drag handle at top for visual indication
    - Header with "Prenotazioni" title and formatted date
    - List of ReservationDayCard widgets
    - "Nessuna prenotazione" message when empty
    - Rounded top corners (20px radius)
    - SafeArea for keyboard handling
    - Scrollable content when many reservations
    - Dismissible by tapping outside or dragging down
  </behavior>
  <action>
    Create day_detail_bottom_sheet.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:intl/intl.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazi/features/reservations/presentation/widgets/reservation_day_card.dart';

    /// Bottom sheet displaying reservations for a specific day.
    class DayDetailBottomSheet extends StatelessWidget {
      final DateTime day;
      final List<Reservation> reservations;

      const DayDetailBottomSheet({
        super.key,
        required this.day,
        required this.reservations,
      });

      /// Show the bottom sheet for a specific day.
      static Future<void> show(
        BuildContext context, {
        required DateTime day,
        required List<Reservation> reservations,
      }) {
        return showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          isDismissible: true,
          enableDrag: true,
          builder: (context) => DayDetailBottomSheet(
            day: day,
            reservations: reservations,
          ),
        );
      }

      /// Format the date for the header.
      String _formatDate() {
        // Format: "15 giugno 2024"
        return DateFormat('d MMMM yyyy', 'it_IT').format(day);
      }

      /// Format the weekday for the header.
      String _formatWeekday() {
        // Format: "Venerdì"
        return DateFormat('EEEE', 'it_IT').format(day);
      }

      @override
      Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and weekday
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prenotazioni',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatWeekday(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),

                      // Date
                      Text(
                        _formatDate(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Reservations list
                if (reservations.isEmpty)
                  // Empty state
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nessuna prenotazione',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Questa data è libera',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Reservations list
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: reservations.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        return ReservationDayCard(
                          reservation: reservations[index],
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }
    }
    ```

    Implementation notes:
    - Use `isScrollControlled: true` for proper keyboard handling
    - Use `MainAxisSize.min` to size bottom sheet to content
    - Wrap ListView in Flexible for scrollability when content is tall
    - Show empty state with icon and Italian message
    - Format date and weekday in Italian
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/widgets/day_detail_bottom_sheet_test.dart</automated>
  </verify>
  <done>DayDetailBottomSheet widget with reservation list</done>
</task>

<task type="checkpoint:human-verify">
  <name>Task 3: Update ReservationCalendar to show bottom sheet on day tap</name>
  <files>lib/features/reservations/presentation/widgets/reservation_calendar.dart</files>
  <action>
    Update the onDaySelected callback in ReservationCalendar to show the bottom sheet:

    ```dart
    In _ReservationCalendarState.build method, update onDaySelected:

    onDaySelected: (selectedDay, focusedDay) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      // Update provider
      calendarNotifier.selectDay(selectedDay);
      calendarNotifier.changeMonth(focusedDay);

      // Call callback first
      widget.onDaySelected?.call(selectedDay, focusedDay);

      // Show bottom sheet with day details
      final normalizedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
      final reservations = calendarState.reservationsByDate[normalizedDay] ?? [];

      // Use post-frame callback to show bottom sheet after tap animation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DayDetailBottomSheet.show(
          context,
          day: selectedDay,
          reservations: reservations,
        );
      });
    },
    ```

    Import the bottom sheet at the top of the file:
    ```dart
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/day_detail_bottom_sheet.dart';
    ```

    This change:
    1. Maintains existing callback behavior
    2. Shows bottom sheet automatically after day selection
    3. Uses post-frame callback for smooth animation
    4. Normalizes date for map lookup (strip time component)
  </action>
  <verify>Manual: Tap on days in calendar and verify bottom sheet appears with correct reservations</verify>
  <done>Calendar shows bottom sheet when tapping days with/without reservations</done>
</task>

<task type="auto">
  <name>Task 4: Create widget tests for bottom sheet</name>
  <files>
    test/features/reservations/presentation/widgets/reservation_day_card_test.dart
    test/features/reservations/presentation/widgets/day_detail_bottom_sheet_test.dart
  </files>
  <action>
    Create comprehensive widget tests:

    **reservation_day_card_test.dart:**
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_day_card.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
    import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

    void main() {
      group('ReservationDayCard', () {
        testWidgets('displays guest name', (tester) async {
          final reservation = Reservation(
            id: '1',
            roomId: Room.defaultRooms.first.id,
            platformId: 'booking',
            guest: Guest(name: 'Mario Rossi', phone: null),
            checkIn: DateTime(2024, 6, 15),
            checkOut: DateTime(2024, 6, 16),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ReservationDayCard(reservation: reservation),
              ),
            ),
          );

          expect(find.text('Mario Rossi'), findsOneWidget);
        });

        testWidgets('displays platform name and room', (tester) async {
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
                body: ReservationDayCard(reservation: reservation),
              ),
            ),
          );

          expect(find.text('Booking'), findsOneWidget);
          expect(find.text('Stanza 1'), findsOneWidget);
        });

        testWidgets('displays payment status', (tester) async {
          final reservation = Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: Guest(name: 'Mario', phone: null),
            checkIn: DateTime(2024, 6, 15),
            checkOut: DateTime(2024, 6, 16),
            paymentStatus: PaymentStatus.received,
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ReservationDayCard(reservation: reservation),
              ),
            ),
          );

          expect(find.text('Pagato'), findsOneWidget);
          expect(find.byIcon(Icons.check_circle), findsOneWidget);
        });
      });
    }
    ```

    **day_detail_bottom_sheet_test.dart:**
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/day_detail_bottom_sheet.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';

    void main() {
      group('DayDetailBottomSheet', () {
        testWidgets('displays empty state when no reservations', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        DayDetailBottomSheet.show(
                          context,
                          day: DateTime(2024, 6, 15),
                          reservations: [],
                        );
                      },
                      child: const Text('Show'),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.tap(find.text('Show'));
          await tester.pumpAndSettle();

          expect(find.text('Nessuna prenotazione'), findsOneWidget);
          expect(find.text('Questa data è libera'), findsOneWidget);
        });

        testWidgets('displays reservations list', (tester) async {
          final reservations = [
            Reservation(
              id: '1',
              roomId: 'room-1',
              platformId: 'booking',
              guest: Guest(name: 'Mario Rossi', phone: null),
              checkIn: DateTime(2024, 6, 15),
              checkOut: DateTime(2024, 6, 16),
              createdAt: DateTime(2024, 6, 1),
              updatedAt: DateTime(2024, 6, 1),
            ),
          ];

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        DayDetailBottomSheet.show(
                          context,
                          day: DateTime(2024, 6, 15),
                          reservations: reservations,
                        );
                      },
                      child: const Text('Show'),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.tap(find.text('Show'));
          await tester.pumpAndSettle();

          expect(find.text('Mario Rossi'), findsOneWidget);
          expect(find.text('Prenotazioni'), findsOneWidget);
        });

        testWidgets('displays date and weekday in header', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        DayDetailBottomSheet.show(
                          context,
                          day: DateTime(2024, 6, 15), // Saturday
                          reservations: [],
                        );
                      },
                      child: const Text('Show'),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.tap(find.text('Show'));
          await tester.pumpAndSettle();

          expect(find.textContaining('sabato'), findsOneWidget); // Saturday in Italian
          expect(find.text('15 giugno 2024'), findsOneWidget);
        });
      });
    }
    ```

    Run tests:
    ```bash
    flutter test test/features/reservations/presentation/widgets/reservation_day_card_test.dart
    flutter test test/features/reservations/presentation/widgets/day_detail_bottom_sheet_test.dart
    ```
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/widgets/reservation_day_card_test.dart test/features/reservations/presentation/widgets/day_detail_bottom_sheet_test.dart</automated>
  </verify>
  <done>All widget tests passing for bottom sheet components</done>
</task>

</tasks>

<verification>
1. `flutter analyze` passes for all new files
2. All widget tests pass for bottom sheet components
3. Tapping a day in calendar opens bottom sheet
4. Bottom sheet shows correct reservations for the day
5. Empty state displays correctly for days without reservations
6. Bottom sheet can be dismissed by tapping outside or dragging
7. Date formatting is correct in Italian
8. Payment status icons display correctly
</verification>

<success_criteria>
1. ✅ ReservationDayCard displays all reservation details
2. ✅ DayDetailBottomSheet shows reservations for selected day
3. ✅ Empty state shows when no reservations
4. ✅ Bottom sheet is dismissible and draggable
5. ✅ All text is in Italian
6. ✅ Platform colors match BookingPlatform.defaultPlatforms
7. ✅ All widget tests pass
8. ✅ Integration with calendar works (tap day → show bottom sheet)
</success_criteria>

<output>
After completion, create `.planning/phases/03-calendario/03-03-PLAN-SUMMARY.md` with:
- Wave number (3)
- Tasks completed (4)
- Test results (widget tests)
- Screenshots of bottom sheet on web and mobile
- Next wave (04 - Calendar Page Integration & Testing)
</output>
