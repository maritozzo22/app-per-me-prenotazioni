---
phase: 04-dashboard-navigation
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - pubspec.yaml
  - lib/features/reservations/domain/services/dashboard_statistics_service.dart
  - lib/features/reservations/presentation/providers/dashboard_provider.dart
  - test/features/reservations/domain/services/dashboard_statistics_service_test.dart
  - test/features/reservations/presentation/providers/dashboard_provider_test.dart
autonomous: true
requirements:
  - DASH-01
  - DASH-02
  - DASH-03
  - DASH-04
must_haves:
  truths:
    - "Dashboard mostra quante stanze sono occupate oggi (0-4)"
    - "Dashboard mostra i prossimi check-in entro 7 giorni ordinati per data"
    - "Dashboard mostra i prossimi check-out entro 7 giorni ordinati per data"
    - "Dashboard mostra incassi mensili con breakdown ricevuto/pendente"
    - "Le statistiche sono calcolate da un service dedicato"
  artifacts:
    - path: "pubspec.yaml"
      provides: "Dependency flutter_slidable aggiunto"
      contains: "flutter_slidable:"
    - path: "lib/features/reservations/domain/services/dashboard_statistics_service.dart"
      provides: "Business logic per calcolo statistiche dashboard"
      exports: ["DashboardStatistics", "DashboardStatisticsService"]
      min_lines: 80
    - path: "lib/features/reservations/presentation/providers/dashboard_provider.dart"
      provides: "State management per dashboard"
      exports: ["DashboardState", "DashboardNotifier", "dashboardProvider"]
      min_lines: 60
  key_links:
    - from: "dashboard_provider.dart"
      to: "ReservationRepository"
      via: "Constructor injection"
      pattern: "final ReservationRepository _repository"
    - from: "dashboard_provider.dart"
      to: "DashboardStatisticsService"
      via: "Method call"
      pattern: "_statisticsService.calculate"
    - from: "DashboardStatisticsService"
      to: "Reservation"
      via: "Date filtering and aggregation"
      pattern: "checkIn.*checkOut.*paymentStatus"
---

<objective>
Implementare il service per il calcolo delle statistiche dashboard e il provider per la gestione dello stato.

Purpose: Fornire la business logic per calcolare occupazione stanze, incassi mensili, e prenotazioni imminenti. Separare la logica di calcolo dalla UI per testabilita e riusabilita.

Output: DashboardStatisticsService con calcoli completi e DashboardProvider con state management Riverpod.
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

# Existing entities and patterns from Phases 1-3

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

From lib/features/reservations/domain/entities/room.dart:
```dart
class Room {
  final String id;
  final String name;
  final RoomType type;
  final DateTime createdAt;

  static final List<Room> defaultRooms = [
    Room(id: 'room-1', name: 'Stanza 1', type: RoomType.singleRoom, ...),
    Room(id: 'room-2', name: 'Stanza 2', type: RoomType.singleRoom, ...),
    Room(id: 'room-3', name: 'Stanza 3', type: RoomType.singleRoom, ...),
    Room(id: 'apartment', name: 'Appartamento Intero', type: RoomType.entireApartment, ...),
  ];
}
```

From lib/features/reservations/domain/value_objects/payment_status.dart:
```dart
enum PaymentStatus {
  received('Ricevuto', Icons.check_circle, Colors.green),
  pending('In attesa', Icons.pending, Colors.orange);
}
```

From lib/features/reservations/presentation/providers/reservation_provider.dart:
```dart
final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final dataSource = ref.watch(reservationDataSourceProvider);
  return ReservationRepositoryImpl(dataSource: dataSource);
});
```
</context>

<tasks>

<task type="auto">
  <name>Task 1: Add flutter_slidable dependency</name>
  <files>pubspec.yaml</files>
  <action>
    Add flutter_slidable dependency to pubspec.yaml for swipe actions in later plans:
    ```yaml
    dependencies:
      # ... existing dependencies
      flutter_slidable: ^3.1.1
    ```

    Run: `flutter pub get` to install the package.

    This dependency is needed for Wave 3 (reservations list with swipe actions).
  </action>
  <verify>
    <automated>grep "flutter_slidable:" pubspec.yaml && flutter pub deps 2>/dev/null | grep flutter_slidable</automated>
  </verify>
  <done>flutter_slidable package installed and available in project</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Create DashboardStatisticsService</name>
  <files>lib/features/reservations/domain/services/dashboard_statistics_service.dart</files>
  <behavior>
    - DashboardStatistics data class holds: occupiedRoomsToday, totalRooms, monthlyIncomeReceived, monthlyIncomePending, upcomingCheckIns, upcomingCheckOuts
    - Service method calculate() takes List<Reservation> and DateTime currentDate
    - Occupancy: count rooms where today falls between checkIn (inclusive) and checkOut (exclusive)
    - Monthly income: sum amounts for reservations overlapping current month, split by payment status
    - Upcoming check-ins: reservations with checkIn within next 7 days (including today), sorted ascending
    - Upcoming check-outs: reservations with checkOut within next 7 days (including today), sorted ascending
    - Total rooms: 4 (Stanza 1, 2, 3, Appartamento)
    - Dates normalized to midnight for comparison
  </behavior>
  <action>
    Create dashboard_statistics_service.dart:
    ```dart
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

    /// Statistics calculated for the dashboard.
    class DashboardStatistics {
      final int occupiedRoomsToday;
      final int totalRooms;
      final double monthlyIncomeReceived;
      final double monthlyIncomePending;
      final List<Reservation> upcomingCheckIns;
      final List<Reservation> upcomingCheckOuts;

      const DashboardStatistics({
        required this.occupiedRoomsToday,
        required this.totalRooms,
        required this.monthlyIncomeReceived,
        required this.monthlyIncomePending,
        required this.upcomingCheckIns,
        required this.upcomingCheckOuts,
      });

      double get occupancyRate => totalRooms > 0 ? occupiedRoomsToday / totalRooms : 0;
      double get totalMonthlyIncome => monthlyIncomeReceived + monthlyIncomePending;
    }

    /// Service for calculating dashboard statistics.
    class DashboardStatisticsService {
      static const int _totalRooms = 4; // Stanza 1, 2, 3, Appartamento

      /// Calculate statistics from a list of reservations.
      DashboardStatistics calculate({
        required List<Reservation> reservations,
        required DateTime currentDate,
      }) {
        final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
        final sevenDaysLater = today.add(const Duration(days: 8)); // 7 days + today

        // Get current month range
        final monthStart = DateTime(currentDate.year, currentDate.month, 1);
        final monthEnd = DateTime(currentDate.year, currentDate.month + 1, 0, 23, 59, 59);

        // Count occupied rooms today
        final occupiedRoomIds = <String>{};
        for (final reservation in reservations) {
          if (_isDateInRange(today, reservation.checkIn, reservation.checkOut)) {
            occupiedRoomIds.add(reservation.roomId);
          }
        }

        // Calculate monthly income (attribute to check-in month)
        double received = 0;
        double pending = 0;
        for (final reservation in reservations) {
          // Reservation overlaps with current month
          if (_reservationsOverlapMonth(reservation, monthStart, monthEnd)) {
            if (reservation.amount != null) {
              if (reservation.paymentStatus == PaymentStatus.received) {
                received += reservation.amount!;
              } else {
                pending += reservation.amount!;
              }
            }
          }
        }

        // Get upcoming check-ins (next 7 days, including today)
        final upcomingCheckIns = reservations.where((r) {
          final checkInDay = DateTime(r.checkIn.year, r.checkIn.month, r.checkIn.day);
          return !checkInDay.isBefore(today) && checkInDay.isBefore(sevenDaysLater);
        }).toList()
          ..sort((a, b) => a.checkIn.compareTo(b.checkIn));

        // Get upcoming check-outs (next 7 days, including today)
        final upcomingCheckOuts = reservations.where((r) {
          final checkOutDay = DateTime(r.checkOut.year, r.checkOut.month, r.checkOut.day);
          return !checkOutDay.isBefore(today) && checkOutDay.isBefore(sevenDaysLater);
        }).toList()
          ..sort((a, b) => a.checkOut.compareTo(b.checkOut));

        return DashboardStatistics(
          occupiedRoomsToday: occupiedRoomIds.length,
          totalRooms: _totalRooms,
          monthlyIncomeReceived: received,
          monthlyIncomePending: pending,
          upcomingCheckIns: upcomingCheckIns,
          upcomingCheckOuts: upcomingCheckOuts,
        );
      }

      /// Get reservation for each room if occupied today.
      Map<String, Reservation?> getRoomOccupancyToday({
        required List<Reservation> reservations,
        required DateTime currentDate,
      }) {
        final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
        final roomOccupancy = <String, Reservation?>{};

        // Initialize all rooms as null (not occupied)
        for (final roomId in ['room-1', 'room-2', 'room-3', 'apartment']) {
          roomOccupancy[roomId] = null;
        }

        // Find occupying reservation for each room
        for (final reservation in reservations) {
          if (_isDateInRange(today, reservation.checkIn, reservation.checkOut)) {
            roomOccupancy[reservation.roomId] = reservation;
          }
        }

        return roomOccupancy;
      }

      bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final normalizedStart = DateTime(start.year, start.month, start.day);
        final normalizedEnd = DateTime(end.year, end.month, end.day);
        return !normalizedDate.isBefore(normalizedStart) && normalizedDate.isBefore(normalizedEnd);
      }

      bool _reservationsOverlapMonth(Reservation r, DateTime monthStart, DateTime monthEnd) {
        // Normalize reservation dates
        final checkIn = DateTime(r.checkIn.year, r.checkIn.month, r.checkIn.day);
        final checkOut = DateTime(r.checkOut.year, r.checkOut.month, r.checkOut.day);
        return checkIn.isBefore(monthEnd) && checkOut.isAfter(monthStart);
      }
    }
    ```

    Implementation notes:
    - Strip time components from DateTime for reliable date comparisons
    - Room occupancy: today >= checkIn AND today < checkOut (check-out day is free)
    - Monthly income: reservation overlaps month if checkIn < monthEnd AND checkOut > monthStart
    - Income attributed to month where reservation occurs (not pro-rated)
  </action>
  <verify>
    <automated>flutter test test/features/reservations/domain/services/dashboard_statistics_service_test.dart</automated>
  </verify>
  <done>DashboardStatisticsService created with calculate() and getRoomOccupancyToday() methods</done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: Create DashboardProvider</name>
  <files>lib/features/reservations/presentation/providers/dashboard_provider.dart</files>
  <behavior>
    - DashboardState holds: statistics, roomOccupancy map, isLoading, error
    - DashboardNotifier loads statistics on init using DashboardStatisticsService
    - Uses reservationRepositoryProvider from Phase 1
    - refresh() method to reload data after changes
    - Follows Riverpod StateNotifier pattern established in Phase 3
  </behavior>
  <action>
    Create dashboard_provider.dart:
    ```dart
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/services/dashboard_statistics_service.dart';
    import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';

    /// Dashboard state
    class DashboardState {
      final DashboardStatistics? statistics;
      final Map<String, Reservation?> roomOccupancy;
      final bool isLoading;
      final String? error;

      const DashboardState({
        this.statistics,
        this.roomOccupancy = const {},
        this.isLoading = false,
        this.error,
      });

      DashboardState copyWith({
        DashboardStatistics? statistics,
        Map<String, Reservation?>? roomOccupancy,
        bool? isLoading,
        String? error,
      }) {
        return DashboardState(
          statistics: statistics ?? this.statistics,
          roomOccupancy: roomOccupancy ?? this.roomOccupancy,
          isLoading: isLoading ?? this.isLoading,
          error: error,
        );
      }
    }

    /// State notifier for dashboard
    class DashboardNotifier extends StateNotifier<DashboardState> {
      final ReservationRepository _repository;
      final DashboardStatisticsService _statisticsService;

      DashboardNotifier(this._repository)
          : _statisticsService = DashboardStatisticsService(),
            super(const DashboardState()) {
        loadDashboard();
      }

      /// Load dashboard statistics and room occupancy
      Future<void> loadDashboard() async {
        state = state.copyWith(isLoading: true, error: null);
        try {
          final reservations = await _repository.getAllReservations();
          final now = DateTime.now();

          // Calculate statistics
          final statistics = _statisticsService.calculate(
            reservations: reservations,
            currentDate: now,
          );

          // Calculate room occupancy for today
          final roomOccupancy = _statisticsService.getRoomOccupancyToday(
            reservations: reservations,
            currentDate: now,
          );

          state = state.copyWith(
            statistics: statistics,
            roomOccupancy: roomOccupancy,
            isLoading: false,
          );
        } catch (e) {
          state = state.copyWith(isLoading: false, error: e.toString());
        }
      }

      /// Refresh dashboard data (call after create/update/delete)
      Future<void> refresh() async {
        await loadDashboard();
      }
    }

    /// Dashboard provider
    final dashboardProvider =
        StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      final repository = ref.watch(reservationRepositoryProvider);
      return DashboardNotifier(repository);
    });
    ```
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/providers/dashboard_provider_test.dart</automated>
  </verify>
  <done>DashboardProvider created with state management and loading logic</done>
</task>

<task type="auto">
  <name>Task 4: Create unit tests for dashboard service and provider</name>
  <files>
    test/features/reservations/domain/services/dashboard_statistics_service_test.dart
    test/features/reservations/presentation/providers/dashboard_provider_test.dart
  </files>
  <action>
    Create comprehensive unit tests:

    **dashboard_statistics_service_test.dart:**
    ```dart
    import 'package:flutter_test/flutter_test.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
    import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
    import 'package:app_prenotazioni/features/reservations/domain/services/dashboard_statistics_service.dart';

    void main() {
      group('DashboardStatisticsService', () {
        late DashboardStatisticsService service;

        setUp(() {
          service = DashboardStatisticsService();
        });

        group('calculate', () {
          test('counts occupied rooms today correctly', () {
            final today = DateTime(2024, 6, 15);
            final reservations = [
              Reservation(
                id: '1',
                roomId: 'room-1',
                platformId: 'booking',
                guest: Guest(name: 'Mario', phone: null),
                checkIn: DateTime(2024, 6, 14),
                checkOut: DateTime(2024, 6, 17),
                createdAt: DateTime(2024, 6, 1),
                updatedAt: DateTime(2024, 6, 1),
              ),
              Reservation(
                id: '2',
                roomId: 'room-2',
                platformId: 'airbnb',
                guest: Guest(name: 'Luca', phone: null),
                checkIn: DateTime(2024, 6, 15),
                checkOut: DateTime(2024, 6, 16),
                createdAt: DateTime(2024, 6, 1),
                updatedAt: DateTime(2024, 6, 1),
              ),
            ];

            final stats = service.calculate(reservations: reservations, currentDate: today);

            expect(stats.occupiedRoomsToday, 2);
            expect(stats.totalRooms, 4);
          });

          test('check-out day is not occupied', () {
            final today = DateTime(2024, 6, 17);
            final reservations = [
              Reservation(
                id: '1',
                roomId: 'room-1',
                platformId: 'booking',
                guest: Guest(name: 'Mario', phone: null),
                checkIn: DateTime(2024, 6, 14),
                checkOut: DateTime(2024, 6, 17), // Check-out today
                createdAt: DateTime(2024, 6, 1),
                updatedAt: DateTime(2024, 6, 1),
              ),
            ];

            final stats = service.calculate(reservations: reservations, currentDate: today);

            expect(stats.occupiedRoomsToday, 0);
          });

          test('calculates monthly income by payment status', () {
            final today = DateTime(2024, 6, 15);
            final reservations = [
              Reservation(
                id: '1',
                roomId: 'room-1',
                platformId: 'booking',
                guest: Guest(name: 'Mario', phone: null),
                checkIn: DateTime(2024, 6, 10),
                checkOut: DateTime(2024, 6, 15),
                amount: 100,
                paymentStatus: PaymentStatus.received,
                createdAt: DateTime(2024, 6, 1),
                updatedAt: DateTime(2024, 6, 1),
              ),
              Reservation(
                id: '2',
                roomId: 'room-2',
                platformId: 'airbnb',
                guest: Guest(name: 'Luca', phone: null),
                checkIn: DateTime(2024, 6, 20),
                checkOut: DateTime(2024, 6, 25),
                amount: 200,
                paymentStatus: PaymentStatus.pending,
                createdAt: DateTime(2024, 6, 1),
                updatedAt: DateTime(2024, 6, 1),
              ),
            ];

            final stats = service.calculate(reservations: reservations, currentDate: today);

            expect(stats.monthlyIncomeReceived, 100);
            expect(stats.monthlyIncomePending, 200);
            expect(stats.totalMonthlyIncome, 300);
          });

          test('finds upcoming check-ins within 7 days', () {
            final today = DateTime(2024, 6, 15);
            final reservations = [
              Reservation(
                id: '1',
                roomId: 'room-1',
                platformId: 'booking',
                guest: Guest(name: 'Mario', phone: null),
                checkIn: DateTime(2024, 6, 16), // Tomorrow
                checkOut: DateTime(2024, 6, 20),
                createdAt: DateTime(2024, 6, 1),
                updatedAt: DateTime(2024, 6, 1),
              ),
              Reservation(
                id: '2',
                roomId: 'room-2',
                platformId: 'airbnb',
                guest: Guest(name: 'Luca', phone: null),
                checkIn: DateTime(2024, 6, 25), // 10 days - outside range
                checkOut: DateTime(2024, 6, 30),
                createdAt: DateTime(2024, 6, 1),
                updatedAt: DateTime(2024, 6, 1),
              ),
            ];

            final stats = service.calculate(reservations: reservations, currentDate: today);

            expect(stats.upcomingCheckIns.length, 1);
            expect(stats.upcomingCheckIns.first.id, '1');
          });

          test('finds upcoming check-outs within 7 days', () {
            final today = DateTime(2024, 6, 15);
            final reservations = [
              Reservation(
                id: '1',
                roomId: 'room-1',
                platformId: 'booking',
                guest: Guest(name: 'Mario', phone: null),
                checkIn: DateTime(2024, 6, 10),
                checkOut: DateTime(2024, 6, 18), // 3 days
                createdAt: DateTime(2024, 6, 1),
                updatedAt: DateTime(2024, 6, 1),
              ),
            ];

            final stats = service.calculate(reservations: reservations, currentDate: today);

            expect(stats.upcomingCheckOuts.length, 1);
            expect(stats.upcomingCheckOuts.first.id, '1');
          });

          test('sorts upcoming check-ins by date ascending', () {
            final today = DateTime(2024, 6, 15);
            final reservations = [
              Reservation(
                id: '2',
                roomId: 'room-2',
                platformId: 'airbnb',
                guest: Guest(name: 'Luca', phone: null),
                checkIn: DateTime(2024, 6, 18),
                checkOut: DateTime(2024, 6, 20),
                createdAt: DateTime(2024, 6, 1),
                updatedAt: DateTime(2024, 6, 1),
              ),
              Reservation(
                id: '1',
                roomId: 'room-1',
                platformId: 'booking',
                guest: Guest(name: 'Mario', phone: null),
                checkIn: DateTime(2024, 6, 16),
                checkOut: DateTime(2024, 6, 18),
                createdAt: DateTime(2024, 6, 1),
                updatedAt: DateTime(2024, 6, 1),
              ),
            ];

            final stats = service.calculate(reservations: reservations, currentDate: today);

            expect(stats.upcomingCheckIns.first.id, '1');
            expect(stats.upcomingCheckIns.last.id, '2');
          });
        });

        group('getRoomOccupancyToday', () {
          test('returns map with all room IDs', () {
            final today = DateTime(2024, 6, 15);
            final occupancy = service.getRoomOccupancyToday(
              reservations: [],
              currentDate: today,
            );

            expect(occupancy.keys, containsAll(['room-1', 'room-2', 'room-3', 'apartment']));
          });

          test('maps room to occupying reservation', () {
            final today = DateTime(2024, 6, 15);
            final reservation = Reservation(
              id: '1',
              roomId: 'room-1',
              platformId: 'booking',
              guest: Guest(name: 'Mario', phone: null),
              checkIn: DateTime(2024, 6, 14),
              checkOut: DateTime(2024, 6, 17),
              createdAt: DateTime(2024, 6, 1),
              updatedAt: DateTime(2024, 6, 1),
            );

            final occupancy = service.getRoomOccupancyToday(
              reservations: [reservation],
              currentDate: today,
            );

            expect(occupancy['room-1'], reservation);
            expect(occupancy['room-2'], isNull);
          });
        });
      });
    }
    ```

    **dashboard_provider_test.dart:**
    ```dart
    import 'package:flutter_test/flutter_test.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
    import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/providers/dashboard_provider.dart';
    import 'package:mocktail/mocktail.dart';

    class MockReservationRepository extends Mock implements ReservationRepository {}

    void main() {
      group('DashboardNotifier', () {
        late MockReservationRepository mockRepository;
        late DashboardNotifier notifier;

        setUp(() {
          mockRepository = MockReservationRepository();
          registerFallbackValue(Reservation(
            id: 'test',
            roomId: 'room-1',
            platformId: 'booking',
            guest: Guest(name: 'Test', phone: null),
            checkIn: DateTime(2024, 1, 1),
            checkOut: DateTime(2024, 1, 2),
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ));
        });

        test('initial state is loading', () {
          notifier = DashboardNotifier(mockRepository);
          expect(notifier.state.isLoading, true);
        });

        test('loadDashboard updates state with statistics', () async {
          final reservations = [
            Reservation(
              id: '1',
              roomId: 'room-1',
              platformId: 'booking',
              guest: Guest(name: 'Mario', phone: null),
              checkIn: DateTime.now().subtract(const Duration(days: 1)),
              checkOut: DateTime.now().add(const Duration(days: 2)),
              amount: 100,
              paymentStatus: PaymentStatus.received,
              createdAt: DateTime(2024, 6, 1),
              updatedAt: DateTime(2024, 6, 1),
            ),
          ];

          when(() => mockRepository.getAllReservations())
              .thenAnswer((_) async => reservations);

          notifier = DashboardNotifier(mockRepository);
          await Future.delayed(const Duration(milliseconds: 100)); // Wait for init

          expect(notifier.state.isLoading, false);
          expect(notifier.state.statistics, isNotNull);
          expect(notifier.state.statistics!.occupiedRoomsToday, 1);
        });

        test('loadDashboard calculates room occupancy', () async {
          when(() => mockRepository.getAllReservations())
              .thenAnswer((_) async => []);

          notifier = DashboardNotifier(mockRepository);
          await Future.delayed(const Duration(milliseconds: 100));

          expect(notifier.state.roomOccupancy.length, 4);
        });

        test('refresh reloads data', () async {
          when(() => mockRepository.getAllReservations())
              .thenAnswer((_) async => []);

          notifier = DashboardNotifier(mockRepository);
          await Future.delayed(const Duration(milliseconds: 100));

          await notifier.refresh();

          verify(() => mockRepository.getAllReservations()).called(2);
        });
      });
    }
    ```
  </action>
  <verify>
    <automated>flutter test test/features/reservations/domain/services/dashboard_statistics_service_test.dart test/features/reservations/presentation/providers/dashboard_provider_test.dart</automated>
  </verify>
  <done>All dashboard service and provider tests passing</done>
</task>

</tasks>

<verification>
1. `flutter pub get` completes without errors
2. `flutter analyze` passes for new files
3. All unit tests pass for DashboardStatisticsService
4. All unit tests pass for DashboardProvider
5. Statistics calculation correctly handles edge cases (check-out day, empty data)
6. Room occupancy map contains all 4 rooms
</verification>

<success_criteria>
1. flutter_slidable dependency installed for later use
2. DashboardStatisticsService calculates occupancy, income, and upcoming reservations
3. DashboardProvider manages state with Riverpod
4. All unit tests pass (service + provider)
5. Follows established Riverpod patterns from Phase 3
6. Ready for Dashboard UI implementation in Wave 2
</success_criteria>

<output>
After completion, create `.planning/phases/04-dashboard-navigation/04-01-SUMMARY.md` with:
- Wave number (1)
- Tasks completed (4)
- Test results
- Files created/modified
- Next wave (02 - Dashboard UI)
</output>
