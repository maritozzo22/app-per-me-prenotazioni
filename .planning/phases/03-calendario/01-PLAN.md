---
phase: 03-calendario
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - pubspec.yaml
  - lib/features/reservations/presentation/providers/calendar_provider.dart
  - lib/features/reservations/domain/services/calendar_service.dart
autonomous: true
requirements:
  - CAL-01
  - CAL-02
  - CAL-05
  - PLAT-07
must_haves:
  truths:
    - "L'utente può vedere un calendario mensile con tutti i giorni"
    - "I giorni con prenotazioni mostrano il colore della piattaforma"
    - "L'intera durata della prenotazione (check-in to check-out) è colorata"
    - "Più prenotazioni nello stesso giorno mostrano indicatori visivi"
    - "I colori delle piattaforme corrispondono a BookingPlatform.defaultPlatforms"
  artifacts:
    - path: "pubspec.yaml"
      provides: "Dependency table_calendar aggiunto"
      contains: "table_calendar: ^3.2.0"
    - path: "lib/features/reservations/presentation/providers/calendar_provider.dart"
      provides: "State management per calendario"
      exports: ["CalendarState", "CalendarNotifier", "calendarProvider"]
      min_lines: 80
    - path: "lib/features/reservations/domain/services/calendar_service.dart"
      provides: "Business logic per raggruppamento date"
      exports: ["CalendarService", "groupReservationsByDate"]
      min_lines: 50
  key_links:
    - from: "calendar_provider.dart"
      to: "ReservationRepository"
      via: "Constructor injection"
      pattern: "final ReservationRepository _repository"
    - from: "calendar_provider.dart"
      to: "CalendarService"
      via: "Method call"
      pattern: "_calendarService.groupReservationsByDate"
    - from: "calendar_provider.dart"
      to: "BookingPlatform.defaultPlatforms"
      via: "Static property access"
      pattern: "BookingPlatform.defaultPlatforms"
    - from: "CalendarService"
      to: "Reservation.overlapsWith"
      via: "Method call for date range expansion"
      pattern: "reservation.checkIn.*reservation.checkOut"
---

<objective>
Implementare lo state management e la business logic per il calendario mensile.

Purpose: Fornire la foundation per il widget calendario gestendo lo stato (mese focalizzato, giorno selezionato) e la logica di raggruppamento delle prenotazioni per data.

Output: Provider Riverpod con stato calendario e service per raggruppamento date.
</objective>

<execution_context>
@./.claude/get-shit-done/workflows/execute-plan.md
@./.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md
@.planning/phases/03-calendario/03-RESEARCH.md
@.planning/phases/02-crud-prenotazioni/PHASE-2-COMPLETE.md

# Existing entities and patterns from Phase 1 & 2
From lib/features/reservations/domain/entities/reservation.dart:
```dart
class Reservation {
  final String id;
  final String roomId;
  final String platformId;
  final Guest guest;
  final DateTime checkIn;
  final DateTime checkOut;
  final double? amount;
  final PaymentStatus paymentStatus;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get numberOfNights => checkOut.difference(checkIn).inDays;
  bool overlapsWith(DateTime otherStart, DateTime otherEnd);
}
```

From lib/features/reservations/domain/entities/platform.dart:
```dart
class BookingPlatform {
  final String id;
  final String name;
  final Color color;
  final bool isDefault;

  static final List<BookingPlatform> defaultPlatforms = [
    BookingPlatform(id: 'booking', name: 'Booking', color: Color(0xFF2196F3)),
    BookingPlatform(id: 'airbnb', name: 'Airbnb', color: Color(0xFFE91E63)),
    BookingPlatform(id: 'whatsapp', name: 'WhatsApp', color: Color(0xFF4CAF50)),
    BookingPlatform(id: 'website', name: 'Sito Web', color: Color(0xFF9C27B0)),
    BookingPlatform(id: 'tiktok', name: 'TikTok', color: Color(0xFF212121)),
  ];
}
```

From Phase 2 - Riverpod pattern established:
```dart
// Pattern: StateNotifier with immutable state
class XxxState {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<Reservation>> reservationsByDate;
  final bool isLoading;

  XxxState copyWith({...});
}

class XxxNotifier extends StateNotifier<XxxState> {
  final XxxRepository _repository;

  XxxNotifier(this._repository) : super(initialState) {
    loadData();
  }
}

final xxxProvider = StateNotifierProvider<XxxNotifier, XxxState>((ref) {
  final repository = ref.watch(xxxRepositoryProvider);
  return XxxNotifier(repository);
});
```
</context>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Add table_calendar dependency</name>
  <files>pubspec.yaml</files>
  <behavior>
    - Dependency added to pubspec.yaml under dependencies section
    - Version: table_calendar: ^3.2.0
    - intl package already available via Flutter SDK (no need to add)
  </behavior>
  <action>
    Add table_calendar dependency to pubspec.yaml:
    ```yaml
    dependencies:
      # ... existing dependencies
      table_calendar: ^3.2.0
    ```

    CRITICAL: Do NOT add intl as dependency - it's already included in Flutter SDK.

    Run: `flutter pub get` to install the package.
  </action>
  <verify>
    <automated>grep "table_calendar: \^3.2.0" pubspec.yaml && flutter pub deps | grep table_calendar</automated>
  </verify>
  <done>table_calendar package installed and available in project</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Create CalendarService for date grouping logic</name>
  <files>lib/features/reservations/domain/services/calendar_service.dart</files>
  <behavior>
    - Service takes List<Reservation> and returns Map<DateTime, List<Reservation>>
    - Each reservation is added to EVERY day in its date range (check-in to check-out, excluding check-out day)
    - Date keys in map are normalized to midnight (time component stripped)
    - Handles overlapping reservations for different rooms
    - Empty list returns empty map
  </behavior>
  <action>
    Create calendar_service.dart:
    ```dart
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';

    /// Service for calendar-related business logic.
    class CalendarService {
      /// Groups reservations by date, adding each reservation to every day
      /// in its date range (from check-in to check-out, exclusive).
      ///
      /// Returns a map where keys are normalized dates (time stripped) and
      /// values are lists of reservations active on that day.
      Map<DateTime, List<Reservation>> groupReservationsByDate(
        List<Reservation> reservations,
      ) {
        final map = <DateTime, List<Reservation>>{};

        for (final reservation in reservations) {
          // Add reservation to each day in its range
          var current = reservation.checkIn;
          // Stop before checkOut (check-out day is not occupied)
          while (current.isBefore(reservation.checkOut)) {
            // Normalize to midnight to avoid time component issues
            final day = DateTime(current.year, current.month, current.day);

            map[day] = [...map[day] ?? [], reservation];
            current = current.add(const Duration(days: 1));
          }
        }

        return map;
      }
    }
    ```

    Implementation notes:
    - Strip time components from DateTime keys to avoid equality issues
    - Loop from checkIn to checkOut (exclusive) - check-out day is not occupied
    - Use spread operator to add to existing lists
  </action>
  <verify>
    <automated>flutter test test/features/reservations/domain/services/calendar_service_test.dart</automated>
  </verify>
  <done>CalendarService created with groupReservationsByDate method</done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: Create CalendarProvider with Riverpod</name>
  <files>lib/features/reservations/presentation/providers/calendar_provider.dart</files>
  <behavior>
    - CalendarState holds: focusedDay, selectedDay, reservationsByDate, isLoading
    - CalendarNotifier loads reservations on init and groups them by date
    - selectDay() updates selectedDay
    - changeMonth() updates focusedDay
    - Uses ReservationRepository from Phase 1
    - Uses CalendarService for grouping logic
    - Provider follows Riverpod StateNotifier pattern from Phase 2
  </behavior>
  <action>
    Create calendar_provider.dart:
    ```dart
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
    import 'package:app_prenotazioni/features/reservations/domain/services/calendar_service.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';

    /// Calendar state
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

      @override
      bool operator ==(Object other) {
        if (identical(this, other)) return true;
        return other is CalendarState &&
            other.focusedDay == focusedDay &&
            other.selectedDay == selectedDay &&
            other.isLoading == isLoading &&
            _mapEquals(other.reservationsByDate, reservationsByDate);
      }

      @override
      int get hashCode => Object.hash(focusedDay, selectedDay, isLoading);

      bool _mapEquals(Map<dynamic, dynamic> a, Map<dynamic, dynamic> b) {
        if (a.length != b.length) return false;
        for (final key in a.keys) {
          if (!b.containsKey(key)) return false;
          final aList = a[key] as List;
          final bList = b[key] as List;
          if (aList.length != bList.length) return false;
        }
        return true;
      }
    }

    /// State notifier for calendar
    class CalendarNotifier extends StateNotifier<CalendarState> {
      final ReservationRepository _repository;
      final CalendarService _calendarService;

      CalendarNotifier(this._repository)
          : _calendarService = CalendarService(),
            super(const CalendarState(
              focusedDay: null, // Will be set to now in constructor body
              selectedDay: null,
              reservationsByDate: {},
              isLoading: false,
            )) {
        // Initialize with current date
        state = CalendarState(
          focusedDay: DateTime.now(),
          reservationsByDate: {},
          isLoading: true,
        );
        loadReservations();
      }

      /// Load all reservations and group them by date
      Future<void> loadReservations() async {
        state = state.copyWith(isLoading: true);
        try {
          final reservations = await _repository.getAllReservations();
          final reservationsByDate = _calendarService.groupReservationsByDate(reservations);
          state = state.copyWith(
            reservationsByDate: reservationsByDate,
            isLoading: false,
          );
        } catch (e) {
          state = state.copyWith(isLoading: false);
          // TODO: Handle error properly in future waves
        }
      }

      /// Select a specific day
      void selectDay(DateTime day) {
        state = state.copyWith(selectedDay: day);
      }

      /// Change the focused month
      void changeMonth(DateTime focusedDay) {
        state = state.copyWith(focusedDay: focusedDay);
      }

      /// Refresh reservations (call after create/update/delete)
      Future<void> refresh() async {
        await loadReservations();
      }
    }

    /// Calendar provider
    final calendarProvider =
        StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
      final repository = ref.watch(reservationRepositoryProvider);
      return CalendarNotifier(repository);
    });
    ```

    Implementation notes:
    - Import reservationRepositoryProvider from Phase 2
    - Initialize focusedDay to DateTime.now() via constructor body
    - Add refresh() method for after CRUD operations
    - Include proper equality operators for state comparison
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/providers/calendar_provider_test.dart</automated>
  </verify>
  <done>CalendarProvider created with state management and date grouping</done>
</task>

<task type="auto">
  <name>Task 4: Create widget tests for calendar state</name>
  <files>
    test/features/reservations/domain/services/calendar_service_test.dart
    test/features/reservations/presentation/providers/calendar_provider_test.dart
  </files>
  <action>
    Create comprehensive widget tests:

    **calendar_service_test.dart:**
    ```dart
    import 'package:flutter_test/flutter_test.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
    import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
    import 'package:app_prenotazioni/features/reservations/domain/services/calendar_service.dart';

    void main() {
      group('CalendarService', () {
        late CalendarService service;

        setUp(() {
          service = CalendarService();
        });

        test('groups single-day reservation correctly', () {
          final reservation = Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: Guest(name: 'Mario', phone: null),
            checkIn: DateTime(2024, 6, 15),
            checkOut: DateTime(2024, 6, 16), // 1 night
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          );

          final result = service.groupReservationsByDate([reservation]);

          expect(result.length, 1);
          expect(result[DateTime(2024, 6, 15)], [reservation]);
        });

        test('groups multi-day reservation to all days in range', () {
          final reservation = Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: Guest(name: 'Mario', phone: null),
            checkIn: DateTime(2024, 6, 15),
            checkOut: DateTime(2024, 6, 18), // 3 nights
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          );

          final result = service.groupReservationsByDate([reservation]);

          expect(result.length, 3);
          expect(result[DateTime(2024, 6, 15)], [reservation]);
          expect(result[DateTime(2024, 6, 16)], [reservation]);
          expect(result[DateTime(2024, 6, 17)], [reservation]);
          expect(result[DateTime(2024, 6, 18)], isNull); // Check-out day NOT included
        });

        test('groups multiple overlapping reservations for same day', () {
          final reservation1 = Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: Guest(name: 'Mario', phone: null),
            checkIn: DateTime(2024, 6, 15),
            checkOut: DateTime(2024, 6, 18),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          );

          final reservation2 = Reservation(
            id: '2',
            roomId: 'room-2', // Different room
            platformId: 'airbnb',
            guest: Guest(name: 'Luca', phone: null),
            checkIn: DateTime(2024, 6, 15),
            checkOut: DateTime(2024, 6, 17),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          );

          final result = service.groupReservationsByDate([reservation1, reservation2]);

          expect(result[DateTime(2024, 6, 15)]?.length, 2);
          expect(result[DateTime(2024, 6, 16)]?.length, 2);
          expect(result[DateTime(2024, 6, 17)]?.length, 1); // Only reservation1
        });

        test('returns empty map for empty reservations list', () {
          final result = service.groupReservationsByDate([]);
          expect(result, isEmpty);
        });
      });
    }
    ```

    **calendar_provider_test.dart:**
    ```dart
    import 'package:flutter_test/flutter_test.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
    import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/providers/calendar_provider.dart';
    import 'package:mocktail/mocktail.dart';

    class MockReservationRepository extends Mock implements ReservationRepository {}

    void main() {
      group('CalendarNotifier', () {
        late MockReservationRepository mockRepository;
        late CalendarNotifier notifier;

        setUp(() {
          mockRepository = MockReservationRepository();
          notifier = CalendarNotifier(mockRepository);
        });

        test('initial state has current focused day and isLoading true', () {
          expect(notifier.state.focusedDay, isNotNull);
          expect(notifier.state.reservationsByDate, isEmpty);
          expect(notifier.state.isLoading, false); // Loaded immediately
        });

        test('loadReservations groups reservations by date', () async {
          final reservations = [
            Reservation(
              id: '1',
              roomId: 'room-1',
              platformId: 'booking',
              guest: Guest(name: 'Mario', phone: null),
              checkIn: DateTime(2024, 6, 15),
              checkOut: DateTime(2024, 6, 16),
              createdAt: DateTime(2024, 6, 1),
              updatedAt: DateTime(2024, 6, 1),
            ),
          ];

          when(() => mockRepository.getAllReservations())
              .thenAnswer((_) async => reservations);

          await notifier.loadReservations();

          expect(notifier.state.reservationsByDate.length, greaterThan(0));
          expect(notifier.state.isLoading, false);
        });

        test('selectDay updates selected day', () {
          final day = DateTime(2024, 6, 15);
          notifier.selectDay(day);
          expect(notifier.state.selectedDay, day);
        });

        test('changeMonth updates focused day', () {
          final newMonth = DateTime(2024, 7, 1);
          notifier.changeMonth(newMonth);
          expect(notifier.state.focusedDay, newMonth);
        });
      });
    }
    ```

    Run: `flutter test test/features/reservations/domain/services/calendar_service_test.dart test/features/reservations/presentation/providers/calendar_provider_test.dart`
  </action>
  <verify>
    <automated>flutter test test/features/reservations/domain/services/calendar_service_test.dart test/features/reservations/presentation/providers/calendar_provider_test.dart</automated>
  </verify>
  <done>All calendar state tests passing (unit tests for service and provider)</done>
</task>

</tasks>

<verification>
1. `flutter pub get` completes without errors
2. `flutter analyze` passes for new files
3. All unit tests pass: `flutter test test/features/reservations/domain/services/ test/features/reservations/presentation/providers/`
4. CalendarService correctly groups multi-day reservations
5. CalendarProvider loads and groups reservations on init
6. State updates work correctly (selectDay, changeMonth, refresh)
</verification>

<success_criteria>
1. ✅ table_calendar dependency installed
2. ✅ CalendarService groups reservations by date with entire range colored
3. ✅ CalendarProvider manages calendar state with Riverpod
4. ✅ All unit tests pass (service + provider)
5. ✅ Platform colors accessible via BookingPlatform.defaultPlatforms
6. ✅ Follows Phase 2 Riverpod patterns
</success_criteria>

<output>
After completion, create `.planning/phases/03-calendario/03-01-PLAN-SUMMARY.md` with:
- Wave number (1)
- Tasks completed (4)
- Test results
- Files created/modified
- Next wave (02 - Calendar UI Widget)
</output>
