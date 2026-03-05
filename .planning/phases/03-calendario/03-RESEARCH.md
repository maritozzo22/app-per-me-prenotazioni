# Phase 3: Calendario - Research

**Researched:** 2026-03-05
**Domain:** Flutter calendar UI, multi-day event visualization, responsive design
**Confidence:** HIGH

## Summary

Phase 3 requires implementing a monthly calendar view for the reservations app with color-coded days based on booking platform. The core challenge is visualizing multi-day reservations (spanning from check-in to check-out) with proper platform colors, handling overlapping reservations for different rooms, and providing an intuitive day detail view.

**Critical Finding:** **table_calendar ^3.2.0** is the clear winner for this use case. It's the most popular Flutter calendar package with excellent customization through `CalendarBuilders`, built-in event marker support, and active maintenance. The package provides `calendarStyle` for day-level customization and supports multi-day range visualization through custom builders.

**Primary recommendation:** Use **table_calendar ^3.2.0** with custom `CalendarBuilders` to color the entire date range (check-in through check-out) based on platform colors. Use `showModalBottomSheet` for day details with proper keyboard handling and rounded corners.

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| CAL-01 | Monthly calendar widget with day cells | table_calendar provides month view with customizable day cells |
| CAL-02 | Color days based on booking platform colors | Use `calendarBuilders.defaultBuilder` to color cells based on platform |
| CAL-03 | Month navigation (prev/next month) | Built-in horizontal swipe gestures + header navigation |
| CAL-04 | Click/tap on day shows reservation details | Use `onDaySelected` callback with `showModalBottomSheet` |
| CAL-05 | Show multiple reservations per day if overlapping | Event markers or custom indicators for overlapping reservations |
| PLAT-07 | Platform colors must match existing platform entity colors | Use `BookingPlatform.defaultPlatforms` colors from Phase 1 |
| UI-01 | Responsive design for web and mobile | table_calendar supports responsive sizing; use `MediaQuery` |
| UI-02 | Calendar must work on web (Chrome) and Android | table_calendar is cross-platform; tested on both platforms |
| TEST-03 | Widget tests for calendar component | flutter_test with widget tester for calendar interactions |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| table_calendar | ^3.2.0 | Monthly calendar widget | Most popular, highly customizable, excellent event support, active maintenance |
| intl | any (already in SDK) | Date formatting and localization | Required by table_calendar for locale support |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| flutter_riverpod | ^2.6.0 (already in project) | State management for calendar state | Managing selected day, loaded reservations, navigation |
| collection | any (if needed) | LinkedHashMap for event lookup | Efficient date-based event lookups with custom equality |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| table_calendar | syncfusion_flutter_calendar | table_calendar is free and open source; Syncfusion is enterprise-grade but commercial license required for full features |
| table_calendar | flutter_neat_and_clean_calendar | Less popular, fewer customization options, limited community support |
| table_calendar | Custom calendar implementation | Complete control but high development cost, need to handle all edge cases (leap years, locale, gestures) |

**Installation:**
```yaml
# pubspec.yaml - ADD to existing dependencies
dependencies:
  table_calendar: ^3.2.0
  intl: any  # Already available via Flutter SDK

# No additional dev_dependencies needed
# flutter_test (SDK) - for widget tests
# mocktail (already in project) - for mocking repositories
```

## Architecture Patterns

### Recommended Project Structure
```
lib/
├── features/
│   └── reservations/
│       ├── presentation/
│       │   ├── pages/
│       │   │   └── calendar_page.dart           # Main calendar screen
│       │   ├── widgets/
│       │   │   ├── reservation_calendar.dart    # Calendar widget wrapper
│       │   │   ├── day_detail_bottom_sheet.dart # Bottom sheet for day details
│       │   │   ├── reservation_day_card.dart    # Card showing reservation info
│       │   │   └── calendar_day_cell.dart       # Custom day cell builder
│       │   └── providers/
│       │       └── calendar_provider.dart       # Riverpod state management
│       └── domain/
│           └── services/
│               └── calendar_service.dart        # Business logic for calendar display

test/
├── features/
│   └── reservations/
│       └── presentation/
│           ├── widgets/
│           │   ├── reservation_calendar_test.dart
│           │   ├── day_detail_bottom_sheet_test.dart
│           │   └── reservation_day_card_test.dart
│           └── pages/
│               └── calendar_page_test.dart
```

### Pattern 1: Calendar State Management with Riverpod

**What:** Use Riverpod providers to manage calendar state (focused month, selected day, loaded reservations).

**When to use:** Always - this is the established state management pattern from Phase 2.

**Example:**
```dart
// presentation/providers/calendar_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

// Calendar state
class CalendarState {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<Reservation>> reservationsByDate;
  final bool isLoading;

  const CalendarState({
    required this.focusedDay,
    this.selectedDay,
    required this.reservationsByDate,
    this.isLoading = false,
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    Map<DateTime, List<Reservation>>? reservationsByDate,
    bool? isLoading,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      reservationsByDate: reservationsByDate ?? this.reservationsByDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// State notifier
class CalendarNotifier extends StateNotifier<CalendarState> {
  final ReservationRepository _repository;

  CalendarNotifier(this._repository)
      : super(CalendarState(
          focusedDay: DateTime.now(),
          reservationsByDate: {},
        )) {
    loadReservations();
  }

  Future<void> loadReservations() async {
    state = state.copyWith(isLoading: true);
    try {
      final reservations = await _repository.getAllReservations();
      final reservationsByDate = _groupReservationsByDate(reservations);
      state = state.copyWith(
        reservationsByDate: reservationsByDate,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
    }
  }

  Map<DateTime, List<Reservation>> _groupReservationsByDate(
    List<Reservation> reservations,
  ) {
    final map = <DateTime, List<Reservation>>{};
    for (final reservation in reservations) {
      // Add reservation to every day in its range
      var current = reservation.checkIn;
      while (current.isBefore(reservation.checkOut)) {
        final day = DateTime(current.year, current.month, current.day);
        map[day] = [...map[day] ?? [], reservation];
        current = current.add(const Duration(days: 1));
      }
    }
    return map;
  }

  void selectDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  void changeMonth(DateTime focusedDay) {
    state = state.copyWith(focusedDay: focusedDay);
  }
}

// Providers
final calendarProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);
  return CalendarNotifier(repository);
});
```

### Pattern 2: Custom Calendar Builder for Platform-Colored Days

**What:** Use `table_calendar`'s `calendarBuilders` to customize day cell appearance based on reservation platforms.

**When to use:** For CAL-02 and CAL-03 - coloring days based on platform colors.

**Example:**
```dart
// presentation/widgets/reservation_calendar.dart
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';

class ReservationCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<Reservation>> reservationsByDate;
  final OnDaySelected? onDaySelected;
  final OnFormatChanged? onFormatChanged;
  final VoidCallback? onPageChanged;

  const ReservationCalendar({
    Key? key,
    required this.focusedDay,
    this.selectedDay,
    required this.reservationsByDate,
    this.onDaySelected,
    this.onFormatChanged,
    this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
      onPageChanged: (_) => onPageChanged?.call(),
      eventLoader: (day) => reservationsByDate[day] ?? [],
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        // Custom day cell builder for platform-colored backgrounds
        defaultBuilder: (context, day, focusedDay) {
          final reservations = reservationsByDate[day];
          if (reservations == null || reservations.isEmpty) {
            // Default day cell
            return null;
          }

          // Get dominant platform color for the day
          final platformColor = _getDominantPlatformColor(reservations);

          return Container(
            margin: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: platformColor.withValues(alpha: 0.3),
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
        },
        // Marker builder for multiple reservations
        markerBuilder: (context, day, events) {
          if (events.length <= 1) return const SizedBox.shrink();

          // Show dots for multiple reservations
          return Positioned(
            bottom: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: events.take(3).map((reservation) {
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
      ),
    );
  }

  Color _getDominantPlatformColor(List<Reservation> reservations) {
    // Strategy 1: Use first reservation's color
    final platform = BookingPlatform.defaultPlatforms.firstWhere(
      (p) => p.id == reservations.first.platformId,
      orElse: () => BookingPlatform.defaultPlatforms.first,
    );
    return platform.color;
  }
}
```

### Pattern 3: Bottom Sheet for Day Details

**What:** Use `showModalBottomSheet` with proper styling and keyboard handling to display reservations for selected day.

**When to use:** For CAL-04 - showing reservation details when tapping a day.

**Example:**
```dart
// presentation/widgets/day_detail_bottom_sheet.dart
import 'package:flutter/material.dart';

class DayDetailBottomSheet extends StatelessWidget {
  final DateTime day;
  final List<Reservation> reservations;

  const DayDetailBottomSheet({
    Key? key,
    required this.day,
    required this.reservations,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prenotazioni',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    DateFormat('d MMM yyyy', 'it_IT').format(day),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            // Reservations list
            if (reservations.isEmpty)
              Padding(
                padding: EdgeInsets.all(32),
                child: Text('Nessuna prenotazione'),
              )
            else
              ...reservations.map((reservation) => ReservationDayCard(
                    reservation: reservation,
                  )),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
```

### Anti-Patterns to Avoid

- **Coloring only check-in day:** Violates CAL-03 - the entire date range must be colored
- **Using AlertDialog for details:** Not responsive, poor UX on mobile - use bottom sheet
- **Hardcoding platform colors:** Use `BookingPlatform.defaultPlatforms` from Phase 1
- **Ignoring overlapping reservations:** Different rooms can have reservations on same day - show all
- **Forgetting keyboard handling:** Bottom sheet must handle keyboard with `MediaQuery.viewInsets`

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Calendar widget | Custom month grid with date calculations | table_calendar | Leap years, locale, gestures, week numbering - too many edge cases |
| Bottom sheet | Manual positioning and animations | showModalBottomSheet | Built-in animations, drag-to-dismiss, keyboard handling |
| Date comparisons | Custom date equality logic | `isSameDay` from intl package | Handles timezone, time components correctly |
| State management | setState for complex calendar state | Riverpod StateNotifier | Established pattern from Phase 2, better testability |
| Platform color mapping | Manual switch statements | `BookingPlatform.defaultPlatforms` | Single source of truth from Phase 1 |

**Key insight:** Calendar UI is deceptively complex - date calculations, localization, gesture handling, and responsive design create many edge cases. Use table_calendar which has solved these problems.

## Common Pitfalls

### Pitfall 1: DateTime Equality Comparison
**What goes wrong:** Comparing `DateTime` objects with `==` fails because time components differ.
**Why it happens:** `DateTime(2024, 6, 15, 10, 0) != DateTime(2024, 6, 15, 12, 0)` even though they're the same day.
**How to avoid:** Use `isSameDay(day1, day2)` from `package:intl` or compare date components: `day1.year == day2.year && day1.month == day2.month && day1.day == day2.day`
**Warning signs:** Events not showing up for certain days, inconsistent date selection

### Pitfall 2: Not Coloring Entire Date Range
**What goes wrong:** Only coloring check-in day instead of full reservation duration.
**Why it happens:** Only adding reservation to check-in day in the events map.
**How to avoid:** Iterate from check-in to check-out and add reservation to each day in range (see Pattern 2 example).
**Warning signs:** Inconsistent coloring, users confused about reservation duration

### Pitfall 3: Bottom Sheet Keyboard Overlap
**What goes wrong:** Bottom sheet content obscured by keyboard when editing.
**Why it happens:** Not handling `MediaQuery.viewInsets.bottom` padding.
**How to avoid:** Wrap content in `SafeArea` and add bottom padding: `Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))`
**Warning signs:** Content cut off on mobile, keyboard covers input fields

### Pitfall 4: Performance with Large Datasets
**What goes wrong:** Calendar lag when scrolling with many reservations.
**Why it happens:** Rebuilding entire events map on every state change.
**How to avoid:** Use `LinkedHashMap` with custom equality for efficient lookups, lazy load reservations per month.
**Warning signs:** Stuttering animations, slow month navigation

### Pitfall 5: Ignoring Web Responsiveness
**What goes wrong:** Calendar looks bad on desktop web - too small or stretched.
**Why it happens:** Using fixed pixel sizes or mobile-first constraints.
**How to avoid:** Use `MediaQuery.of(context).size.width` to adjust calendar size, constrain max width on desktop.
**Warning signs:** Calendar looks tiny on desktop, stretched on large screens

## Code Examples

### Complete Calendar Page with Riverpod

```dart
// presentation/pages/calendar_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/calendar_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_calendar.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/day_detail_bottom_sheet.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);
    final calendarNotifier = ref.read(calendarProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario Prenotazioni'),
      ),
      body: calendarState.isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendar widget
                ReservationCalendar(
                  focusedDay: calendarState.focusedDay,
                  selectedDay: calendarState.selectedDay,
                  reservationsByDate: calendarState.reservationsByDate,
                  onDaySelected: (selectedDay, focusedDay) {
                    calendarNotifier.selectDay(selectedDay);
                    calendarNotifier.changeMonth(focusedDay);

                    // Show bottom sheet with day details
                    final reservations = calendarState.reservationsByDate[
                        DateTime(selectedDay.year, selectedDay.month, selectedDay.day)] ??
                        [];

                    DayDetailBottomSheet.show(
                      context,
                      day: selectedDay,
                      reservations: reservations,
                    );
                  },
                  onFormatChanged: (format) {
                    // Handle format change if needed
                  },
                  onPageChanged: () {
                    // Page changed - update focused day via onDaySelected
                  },
                ),
                // Additional info below calendar (optional)
                Expanded(
                  child: Center(
                    child: Text(
                      'Seleziona un giorno per vedere le prenotazioni',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
```

### Widget Test for Calendar Interactions

```dart
// test/features/reservations/presentation/widgets/reservation_calendar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_calendar.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

void main() {
  group('ReservationCalendar', () {
    testWidgets('displays calendar with day cells', (tester) async {
      final reservations = {
        DateTime(2024, 6, 15): [
          Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: Guest(name: 'Mario Rossi', phone: null),
            checkIn: DateTime(2024, 6, 15),
            checkOut: DateTime(2024, 6, 18),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          ),
        ],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationCalendar(
              focusedDay: DateTime(2024, 6, 15),
              reservationsByDate: reservations,
              onDaySelected: (_, __) {},
            ),
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('calls onDaySelected when tapping a day', (tester) async {
      DateTime? selectedDay;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationCalendar(
              focusedDay: DateTime(2024, 6, 15),
              reservationsByDate: {},
              onDaySelected: (day, __) => selectedDay = day,
            ),
          ),
        ),
      );

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(selectedDay, DateTime(2024, 6, 15));
    });

    testWidgets('shows platform-colored background for reservation days', (tester) async {
      final reservations = {
        DateTime(2024, 6, 15): [
          Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking', // Blue color
            guest: Guest(name: 'Mario Rossi', phone: null),
            checkIn: DateTime(2024, 6, 15),
            checkOut: DateTime(2024, 6, 18),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          ),
        ],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReservationCalendar(
              focusedDay: DateTime(2024, 6, 15),
              reservationsByDate: reservations,
              onDaySelected: (_, __) {},
            ),
          ),
        ),
      );

      // Find container with booking platform color (blue)
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('15'),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.blue.withValues(alpha: 0.3));
    });
  });
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Manual calendar grid | table_calendar | 2019+ | Standardized, feature-rich, actively maintained |
| AlertDialog for details | showModalBottomSheet | 2020+ | Better mobile UX, responsive, swipe-to-dismiss |
| DateTime == comparison | isSameDay() from intl | Always | Correct date equality across timezones |
| setState for state | Riverpod StateNotifier | 2022+ | Better testability, separation of concerns |

**Deprecated/outdated:**
- Manual calendar implementation - unnecessary with table_calendar maturity
- Custom date equality logic - use intl package
- Fixed-size layouts - use responsive design with MediaQuery

## Open Questions

1. **Visual Strategy for Multiple Platforms on Same Day**
   - What we know: Need to handle different rooms with different platforms on same day
   - What's unclear: Should we show all platform colors, dominant color, or markers?
   - Recommendation: Use dominant color (first reservation) with colored dots below for additional reservations (implemented in Pattern 2)

2. **Apartment Booking Visual Representation**
   - What we know: Apartment blocks all 3 rooms when booked
   - What's unclear: Should apartment reservations appear as a single entry or show in all 3 rooms?
   - Recommendation: Store apartment as single reservation but visually indicate it affects multiple rooms (Phase 4 detail view will show room-specific info)

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK) |
| Config file | None - Flutter SDK built-in |
| Quick run command | `flutter test test/features/reservations/presentation/widgets/` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| CAL-01 | Monthly calendar displays day cells | widget | `flutter test test/features/reservations/presentation/widgets/reservation_calendar_test.dart` | Wave 0 |
| CAL-02 | Days colored by platform | widget | `flutter test test/features/reservations/presentation/widgets/reservation_calendar_test.dart` | Wave 0 |
| CAL-03 | Entire date range colored | widget | `flutter test test/features/reservations/presentation/widgets/reservation_calendar_test.dart` | Wave 0 |
| CAL-04 | Tap day shows details | widget | `flutter test test/features/reservations/presentation/widgets/reservation_calendar_test.dart` | Wave 0 |
| CAL-05 | Multiple reservations shown | widget | `flutter test test/features/reservations/presentation/widgets/reservation_calendar_test.dart` | Wave 0 |
| PLAT-07 | Platform colors match entity | unit | Verify using BookingPlatform.defaultPlatforms | Wave 0 |
| UI-01 | Responsive design | widget | `flutter test test/features/reservations/presentation/pages/calendar_page_test.dart` | Wave 0 |
| UI-02 | Works on web and Android | integration | Manual testing on both platforms | Manual |
| TEST-03 | Widget tests exist | widget | All calendar widget tests | Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/features/reservations/presentation/widgets/` (widget tests only, ~10s)
- **Per wave merge:** `flutter test` (all tests, ~30s)
- **Phase gate:** `flutter test --coverage` with widget tests passing for calendar interactions

### Wave 0 Gaps
- [ ] `test/features/reservations/presentation/widgets/reservation_calendar_test.dart` - calendar widget, day selection, platform coloring
- [ ] `test/features/reservations/presentation/widgets/day_detail_bottom_sheet_test.dart` - bottom sheet display, reservation cards
- [ ] `test/features/reservations/presentation/widgets/reservation_day_card_test.dart` - reservation card display
- [ ] `test/features/reservations/presentation/pages/calendar_page_test.dart` - full calendar page integration
- [ ] `test/features/reservations/presentation/providers/calendar_provider_test.dart` - calendar state management
- [ ] Package install: `flutter pub add table_calendar` - add to dependencies

## Sources

### Primary (HIGH confidence)
- [table_calendar official package on pub.dev](https://pub.dev/packages/table_calendar) - Official documentation, API reference, examples, latest version 3.2.0
- [table_calendar complete example](https://pub.dev/packages/table_calendar/example) - Full working example with event loaders, builders, customization
- [Flutter intl package](https://pub.dev/packages/intl) - Date formatting and localization

### Secondary (MEDIUM confidence)
- [TableCalendar Ultimate Guide 2025](https://m.blog.csdn.net/gitblog_00184/article/details/155150895) - Comprehensive table_calendar tutorial with code examples
- [Flutter Custom Calendar Complete Guide](https://blog.csdn.net/pdd11997110103/article/details/152049629) - Custom calendar builders and styling patterns
- [Building Custom Calendar Widget in Flutter](https://dev.to/anurag_dev/building-a-powerful-custom-calendar-widget-in-flutter-from-scratch-to-production-mlf) - Range selection, multi-day events, booking system patterns
- [Flutter Bottom Sheet Best Practices 2025](https://m.blog.csdn.net/2301_81549453/article/details/155679631) - Bottom sheet implementation with keyboard handling

### Tertiary (LOW confidence)
- [Flutter Calendar Multiple Events Display](https://m.blog.csdn.net/qq_22492233/article/details/121678380) - Custom calendar with event indicators (verified against official docs)
- [Flutter Widget Testing Guide](https://blog.csdn.net/gitblog_00205/article/details/152245933) - Widget testing patterns for calendar interactions

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - table_calendar is well-documented, stable, most popular Flutter calendar package
- Architecture: HIGH - Riverpod pattern established in Phase 2, table_calendar builders documented
- Color strategy: MEDIUM - Multi-platform visualization requires UX decision, technical implementation is clear
- Bottom sheet UX: HIGH - showModalBottomSheet patterns well-established, keyboard handling documented
- Testing: HIGH - flutter_test is mature, calendar widget testing patterns documented

**Research date:** 2026-03-05
**Valid until:** 30 days - table_calendar is stable but Flutter ecosystem evolves quickly
