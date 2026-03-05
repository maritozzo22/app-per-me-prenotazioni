---
phase: 04-dashboard-navigation
plan: 02
type: execute
wave: 2
depends_on:
  - 04-01
files_modified:
  - lib/features/reservations/presentation/pages/dashboard_page.dart
  - lib/features/reservations/presentation/widgets/dashboard/room_occupancy_grid.dart
  - lib/features/reservations/presentation/widgets/dashboard/stat_card.dart
  - lib/features/reservations/presentation/widgets/dashboard/income_breakdown_card.dart
  - lib/features/reservations/presentation/widgets/dashboard/upcoming_reservations_card.dart
  - lib/features/reservations/presentation/widgets/dashboard/calendar_access_card.dart
  - test/features/reservations/presentation/pages/dashboard_page_test.dart
autonomous: true
requirements:
  - DASH-01
  - DASH-05
  - UI-04
  - UI-06
  - TEST-04
  - A11Y-01
must_haves:
  truths:
    - "L'utente vede una griglia 2x2 con lo stato di ogni stanza"
    - "L'utente vede il breakdown degli incassi (ricevuto vs in attesa)"
    - "L'utente vede i prossimi arrivi e partenze"
    - "L'utente puo cliccare sulla card Calendario per navigare"
    - "Il layout e responsive (mobile-first con breakpoint 600px)"
    - "Ogni elemento interattivo ha etichette di accessibilita"
  artifacts:
    - path: "lib/features/reservations/presentation/pages/dashboard_page.dart"
      provides: "Pagina dashboard principale"
      exports: ["DashboardPage"]
      min_lines: 100
    - path: "lib/features/reservations/presentation/widgets/dashboard/room_occupancy_grid.dart"
      provides: "Griglia 2x2 stato stanze"
      exports: ["RoomOccupancyGrid"]
      min_lines: 80
    - path: "lib/features/reservations/presentation/widgets/dashboard/income_breakdown_card.dart"
      provides: "Card incassi con breakdown"
      exports: ["IncomeBreakdownCard"]
      min_lines: 60
    - path: "lib/features/reservations/presentation/widgets/dashboard/upcoming_reservations_card.dart"
      provides: "Card arrivi/partenze"
      exports: ["UpcomingReservationsCard"]
      min_lines: 60
    - path: "lib/features/reservations/presentation/widgets/dashboard/calendar_access_card.dart"
      provides: "Card accesso calendario"
      exports: ["CalendarAccessCard"]
      min_lines: 40
  key_links:
    - from: "dashboard_page.dart"
      to: "dashboardProvider"
      via: "ref.watch"
      pattern: "ref.watch\\(dashboardProvider\\)"
    - from: "room_occupancy_grid.dart"
      to: "Room.defaultRooms"
      via: "Static property"
      pattern: "Room.defaultRooms"
    - from: "dashboard_page.dart"
      to: "CalendarAccessCard"
      via: "Callback navigation"
      pattern: "onCalendarTap"
---

<objective>
Implementare la UI della Dashboard con tutte le card statistiche e layout responsive.

Purpose: Fornire all'utente una panoramica immediata dello stato delle prenotazioni con interfaccia mobile-first e accessibile.

Output: DashboardPage con griglia stanze, card incassi, card arrivi/partenze, e card accesso calendario.
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

# Wave 1 outputs (dependencies)
@.planning/phases/04-dashboard-navigation/01-PLAN.md

# Existing entities from Phases 1-3

From lib/features/reservations/domain/entities/room.dart:
```dart
class Room {
  final String id;
  final String name;
  final RoomType type;

  static final List<Room> defaultRooms = [
    Room(id: 'room-1', name: 'Stanza 1', ...),
    Room(id: 'room-2', name: 'Stanza 2', ...),
    Room(id: 'room-3', name: 'Stanza 3', ...),
    Room(id: 'apartment', name: 'Appartamento Intero', ...),
  ];
}
```

From lib/features/reservations/domain/entities/platform.dart:
```dart
class BookingPlatform {
  final String id;
  final String name;
  final Color color;

  static final List<BookingPlatform> defaultPlatforms = [...];
  static BookingPlatform? getById(String id) => ...;
}
```

From lib/features/reservations/domain/value_objects/payment_status.dart:
```dart
enum PaymentStatus {
  received('Ricevuto', Icons.check_circle, Colors.green),
  pending('In attesa', Icons.pending, Colors.orange);
}
```

# Wave 1 Provider (to be created)

From lib/features/reservations/presentation/providers/dashboard_provider.dart:
```dart
class DashboardState {
  final DashboardStatistics? statistics;
  final Map<String, Reservation?> roomOccupancy;
  final bool isLoading;
  final String? error;
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  Future<void> loadDashboard();
  Future<void> refresh();
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>(...);
```

# Dashboard Statistics (from Wave 1)

```dart
class DashboardStatistics {
  final int occupiedRoomsToday;
  final int totalRooms;
  final double monthlyIncomeReceived;
  final double monthlyIncomePending;
  final List<Reservation> upcomingCheckIns;
  final List<Reservation> upcomingCheckOuts;

  double get occupancyRate;
  double get totalMonthlyIncome;
}
```
</context>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Create RoomOccupancyGrid widget</name>
  <files>lib/features/reservations/presentation/widgets/dashboard/room_occupancy_grid.dart</files>
  <behavior>
    - Displays 2x2 grid with 4 room status cards
    - Each card shows: room name, occupied status (icon), guest name if occupied
    - Green border/icon for occupied, grey for free
    - Uses Room.defaultRooms for room list
    - Receives Map<String, Reservation?> with occupancy data
    - Accessible: semantic labels for screen readers
  </behavior>
  <action>
    Create room_occupancy_grid.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';

    /// Visual 2x2 grid showing occupancy status for each room.
    class RoomOccupancyGrid extends StatelessWidget {
      final Map<String, Reservation?> roomOccupancy;

      const RoomOccupancyGrid({
        super.key,
        required this.roomOccupancy,
      });

      @override
      Widget build(BuildContext context) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.5,
          children: Room.defaultRooms.map((room) {
            final reservation = roomOccupancy[room.id];
            final isOccupied = reservation != null;

            return _RoomStatusCard(
              room: room,
              isOccupied: isOccupied,
              reservation: reservation,
            );
          }).toList(),
        );
      }
    }

    class _RoomStatusCard extends StatelessWidget {
      final Room room;
      final bool isOccupied;
      final Reservation? reservation;

      const _RoomStatusCard({
        required this.room,
        required this.isOccupied,
        this.reservation,
      });

      @override
      Widget build(BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;

        return Semantics(
          label: '${room.name}: ${isOccupied ? 'Occupata da ${reservation?.guest.name}' : 'Libera'}',
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isOccupied ? Colors.green : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isOccupied
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          room.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        isOccupied ? Icons.check_circle : Icons.circle_outlined,
                        color: isOccupied ? Colors.green : Colors.grey,
                        size: 20,
                        semanticLabel: isOccupied ? 'Occupata' : 'Libera',
                      ),
                    ],
                  ),
                  if (isOccupied && reservation != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      reservation!.guest.name,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }
    }
    ```
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/widgets/dashboard/room_occupancy_grid_test.dart</automated>
  </verify>
  <done>RoomOccupancyGrid widget created with 2x2 layout and accessibility labels</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Create IncomeBreakdownCard widget</name>
  <files>lib/features/reservations/presentation/widgets/dashboard/income_breakdown_card.dart</files>
  <behavior>
    - Shows monthly income with breakdown: received vs pending
    - Total prominently displayed at top
    - Two rows showing received (green) and pending (orange) amounts
    - Uses PaymentStatus colors for consistency
    - Formatted as EUR currency
  </behavior>
  <action>
    Create income_breakdown_card.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

    /// Card showing monthly income breakdown (received vs pending).
    class IncomeBreakdownCard extends StatelessWidget {
      final double received;
      final double pending;

      const IncomeBreakdownCard({
        super.key,
        required this.received,
        required this.pending,
      });

      @override
      Widget build(BuildContext context) {
        final total = received + pending;
        final theme = Theme.of(context);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Incassi Mensili',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatCurrency(total),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _IncomeRow(
                  label: PaymentStatus.received.label,
                  amount: received,
                  color: PaymentStatus.received.color,
                  icon: PaymentStatus.received.icon,
                ),
                const SizedBox(height: 8),
                _IncomeRow(
                  label: PaymentStatus.pending.label,
                  amount: pending,
                  color: PaymentStatus.pending.color,
                  icon: PaymentStatus.pending.icon,
                ),
              ],
            ),
          ),
        );
      }

      String _formatCurrency(double amount) {
        return 'EUR ${amount.toStringAsFixed(2)}';
      }
    }

    class _IncomeRow extends StatelessWidget {
      final String label;
      final double amount;
      final Color color;
      final IconData icon;

      const _IncomeRow({
        required this.label,
        required this.amount,
        required this.color,
        required this.icon,
      });

      @override
      Widget build(BuildContext context) {
        return Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              _formatCurrency(amount),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        );
      }

      String _formatCurrency(double amount) {
        return 'EUR ${amount.toStringAsFixed(2)}';
      }
    }
    ```
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/widgets/dashboard/income_breakdown_card_test.dart</automated>
  </verify>
  <done>IncomeBreakdownCard widget created with received/pending breakdown</done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: Create UpcomingReservationsCard widget</name>
  <files>lib/features/reservations/presentation/widgets/dashboard/upcoming_reservations_card.dart</files>
  <behavior>
    - Shows list of upcoming check-ins or check-outs
    - Title configurable (Arrivi/Partenze)
    - Each item shows: guest name, date, room
    - Platform color indicator
    - Empty state with message
    - Maximum 5 items visible, scrollable for more
  </behavior>
  <action>
    Create upcoming_reservations_card.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
    import 'package:intl/intl.dart';

    /// Card showing upcoming check-ins or check-outs.
    class UpcomingReservationsCard extends StatelessWidget {
      final String title;
      final List<Reservation> reservations;
      final bool showCheckOutDate;

      const UpcomingReservationsCard({
        super.key,
        required this.title,
        required this.reservations,
        this.showCheckOutDate = false,
      });

      @override
      Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (reservations.isEmpty)
                  _buildEmptyState(context)
                else
                  _buildReservationsList(context),
              ],
            ),
          ),
        );
      }

      Widget _buildEmptyState(BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              'Nessuna prenotazione',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
        );
      }

      Widget _buildReservationsList(BuildContext context) {
        return Column(
          children: reservations.take(5).map((reservation) {
            return _ReservationItem(
              reservation: reservation,
              showCheckOutDate: showCheckOutDate,
            );
          }).toList(),
        );
      }
    }

    class _ReservationItem extends StatelessWidget {
      final Reservation reservation;
      final bool showCheckOutDate;

      const _ReservationItem({
        required this.reservation,
        this.showCheckOutDate = false,
      });

      @override
      Widget build(BuildContext context) {
        final platform = BookingPlatform.defaultPlatforms.firstWhere(
          (p) => p.id == reservation.platformId,
          orElse: () => BookingPlatform.defaultPlatforms.first,
        );
        final room = Room.defaultRooms.firstWhere(
          (r) => r.id == reservation.roomId,
          orElse: () => Room.defaultRooms.first,
        );
        final date = showCheckOutDate ? reservation.checkOut : reservation.checkIn;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Platform color indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: platform.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Guest and room info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.guest.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      room.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Date
              Text(
                DateFormat('dd/MM').format(date),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        );
      }
    }
    ```
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/widgets/dashboard/upcoming_reservations_card_test.dart</automated>
  </verify>
  <done>UpcomingReservationsCard widget created for arrivals and departures</done>
</task>

<task type="auto" tdd="true">
  <name>Task 4: Create CalendarAccessCard widget</name>
  <files>lib/features/reservations/presentation/widgets/dashboard/calendar_access_card.dart</files>
  <behavior>
    - Large card with calendar icon
    - "Apri Calendario" label
    - Tap callback for navigation
    - Visual feedback on tap (InkWell)
    - Accessible with semantic label
  </behavior>
  <action>
    Create calendar_access_card.dart:
    ```dart
    import 'package:flutter/material.dart';

    /// Large card for navigating to calendar view.
    class CalendarAccessCard extends StatelessWidget {
      final VoidCallback onTap;

      const CalendarAccessCard({
        super.key,
        required this.onTap,
      });

      @override
      Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return Semantics(
          label: 'Apri calendario prenotazioni',
          button: true,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 48,
                      color: theme.colorScheme.primary,
                      semanticLabel: 'Calendario',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Apri Calendario',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Visualizza prenotazioni per mese',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
    ```
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/widgets/dashboard/calendar_access_card_test.dart</automated>
  </verify>
  <done>CalendarAccessCard widget created with tap callback</done>
</task>

<task type="auto" tdd="true">
  <name>Task 5: Create DashboardPage with responsive layout</name>
  <files>lib/features/reservations/presentation/pages/dashboard_page.dart</files>
  <behavior>
    - Uses dashboardProvider for state
    - Shows loading indicator while loading
    - Shows error message on error
    - LayoutBuilder with 600px breakpoint for responsive design
    - Mobile: single column layout
    - Tablet/desktop: two column layout
    - onCalendarTap callback for navigation (to be connected in Wave 4)
    - Pull-to-refresh to reload data
  </behavior>
  <action>
    Create dashboard_page.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/providers/dashboard_provider.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/dashboard/room_occupancy_grid.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/dashboard/income_breakdown_card.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/dashboard/upcoming_reservations_card.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/dashboard/calendar_access_card.dart';

    /// Dashboard page showing reservation statistics and overview.
    class DashboardPage extends ConsumerWidget {
      final VoidCallback? onCalendarTap;

      const DashboardPage({
        super.key,
        this.onCalendarTap,
      });

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final dashboardState = ref.watch(dashboardProvider);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            elevation: 2,
          ),
          body: RefreshIndicator(
            onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
            child: _buildBody(context, ref, dashboardState),
          ),
        );
      }

      Widget _buildBody(
        BuildContext context,
        WidgetRef ref,
        DashboardState state,
      ) {
        if (state.isLoading && state.statistics == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.error != null && state.statistics == null) {
          return _buildError(context, ref, state.error!);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            if (isMobile) {
              return _buildMobileLayout(context, state);
            } else {
              return _buildTabletLayout(context, state);
            }
          },
        );
      }

      Widget _buildError(BuildContext context, WidgetRef ref, String error) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Errore nel caricamento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
                child: const Text('Riprova'),
              ),
            ],
          ),
        );
      }

      Widget _buildMobileLayout(BuildContext context, DashboardState state) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room occupancy section
              Text(
                'Stanze Oggi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              RoomOccupancyGrid(roomOccupancy: state.roomOccupancy),
              const SizedBox(height: 24),

              // Income card
              IncomeBreakdownCard(
                received: state.statistics?.monthlyIncomeReceived ?? 0,
                pending: state.statistics?.monthlyIncomePending ?? 0,
              ),
              const SizedBox(height: 24),

              // Calendar access card
              CalendarAccessCard(
                onTap: onCalendarTap ?? () {},
              ),
              const SizedBox(height: 24),

              // Upcoming check-ins
              UpcomingReservationsCard(
                title: 'Prossimi Arrivi',
                reservations: state.statistics?.upcomingCheckIns ?? [],
              ),
              const SizedBox(height: 16),

              // Upcoming check-outs
              UpcomingReservationsCard(
                title: 'Prossime Partenze',
                reservations: state.statistics?.upcomingCheckOuts ?? [],
                showCheckOutDate: true,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }

      Widget _buildTabletLayout(BuildContext context, DashboardState state) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Stanze Oggi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    RoomOccupancyGrid(roomOccupancy: state.roomOccupancy),
                    const SizedBox(height: 24),
                    IncomeBreakdownCard(
                      received: state.statistics?.monthlyIncomeReceived ?? 0,
                      pending: state.statistics?.monthlyIncomePending ?? 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right column
              Expanded(
                child: Column(
                  children: [
                    CalendarAccessCard(
                      onTap: onCalendarTap ?? () {},
                    ),
                    const SizedBox(height: 24),
                    UpcomingReservationsCard(
                      title: 'Prossimi Arrivi',
                      reservations: state.statistics?.upcomingCheckIns ?? [],
                    ),
                    const SizedBox(height: 16),
                    UpcomingReservationsCard(
                      title: 'Prossime Partenze',
                      reservations: state.statistics?.upcomingCheckOuts ?? [],
                      showCheckOutDate: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }
    ```
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/pages/dashboard_page_test.dart</automated>
  </verify>
  <done>DashboardPage created with responsive layout and all widgets integrated</done>
</task>

<task type="auto">
  <name>Task 6: Create widget tests for dashboard components</name>
  <files>
    test/features/reservations/presentation/widgets/dashboard/room_occupancy_grid_test.dart
    test/features/reservations/presentation/widgets/dashboard/income_breakdown_card_test.dart
    test/features/reservations/presentation/widgets/dashboard/upcoming_reservations_card_test.dart
    test/features/reservations/presentation/widgets/dashboard/calendar_access_card_test.dart
    test/features/reservations/presentation/pages/dashboard_page_test.dart
  </files>
  <action>
    Create widget tests for all dashboard components:

    **room_occupancy_grid_test.dart:**
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/dashboard/room_occupancy_grid.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';

    void main() {
      group('RoomOccupancyGrid', () {
        testWidgets('displays 4 room cards', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: RoomOccupancyGrid(roomOccupancy: {}),
              ),
            ),
          );

          expect(find.byType(Card), findsNWidgets(4));
        });

        testWidgets('shows room names', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: RoomOccupancyGrid(roomOccupancy: {}),
              ),
            ),
          );

          expect(find.text('Stanza 1'), findsOneWidget);
          expect(find.text('Stanza 2'), findsOneWidget);
          expect(find.text('Stanza 3'), findsOneWidget);
          expect(find.text('Appartamento Intero'), findsOneWidget);
        });

        testWidgets('shows guest name when room occupied', (tester) async {
          final reservation = Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: const Guest(name: 'Mario Rossi', phone: null),
            checkIn: DateTime(2024, 6, 14),
            checkOut: DateTime(2024, 6, 17),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: RoomOccupancyGrid(
                  roomOccupancy: {'room-1': reservation},
                ),
              ),
            ),
          );

          expect(find.text('Mario Rossi'), findsOneWidget);
        });

        testWidgets('shows occupied icon for occupied room', (tester) async {
          final reservation = Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: const Guest(name: 'Mario', phone: null),
            checkIn: DateTime(2024, 6, 14),
            checkOut: DateTime(2024, 6, 17),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: RoomOccupancyGrid(
                  roomOccupancy: {'room-1': reservation},
                ),
              ),
            ),
          );

          expect(find.byIcon(Icons.check_circle), findsOneWidget);
        });
      });
    }
    ```

    **income_breakdown_card_test.dart:**
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/dashboard/income_breakdown_card.dart';

    void main() {
      group('IncomeBreakdownCard', () {
        testWidgets('shows total income', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: IncomeBreakdownCard(received: 100, pending: 50),
              ),
            ),
          );

          expect(find.text('EUR 150.00'), findsOneWidget);
        });

        testWidgets('shows received and pending labels', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: IncomeBreakdownCard(received: 100, pending: 50),
              ),
            ),
          );

          expect(find.text('Ricevuto'), findsOneWidget);
          expect(find.text('In attesa'), findsOneWidget);
          expect(find.text('EUR 100.00'), findsOneWidget);
          expect(find.text('EUR 50.00'), findsOneWidget);
        });
      });
    }
    ```

    **upcoming_reservations_card_test.dart:**
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/dashboard/upcoming_reservations_card.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';

    void main() {
      group('UpcomingReservationsCard', () {
        testWidgets('shows title', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: UpcomingReservationsCard(
                  title: 'Prossimi Arrivi',
                  reservations: [],
                ),
              ),
            ),
          );

          expect(find.text('Prossimi Arrivi'), findsOneWidget);
        });

        testWidgets('shows empty state when no reservations', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: UpcomingReservationsCard(
                  title: 'Prossimi Arrivi',
                  reservations: [],
                ),
              ),
            ),
          );

          expect(find.text('Nessuna prenotazione'), findsOneWidget);
        });

        testWidgets('shows guest name for reservations', (tester) async {
          final reservations = [
            Reservation(
              id: '1',
              roomId: 'room-1',
              platformId: 'booking',
              guest: const Guest(name: 'Mario Rossi', phone: null),
              checkIn: DateTime(2024, 6, 15),
              checkOut: DateTime(2024, 6, 17),
              createdAt: DateTime(2024, 6, 1),
              updatedAt: DateTime(2024, 6, 1),
            ),
          ];

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: UpcomingReservationsCard(
                  title: 'Prossimi Arrivi',
                  reservations: reservations,
                ),
              ),
            ),
          );

          expect(find.text('Mario Rossi'), findsOneWidget);
        });
      });
    }
    ```

    **calendar_access_card_test.dart:**
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/dashboard/calendar_access_card.dart';

    void main() {
      group('CalendarAccessCard', () {
        testWidgets('shows calendar icon', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: CalendarAccessCard(onTap: () {}),
              ),
            ),
          );

          expect(find.byIcon(Icons.calendar_today), findsOneWidget);
        });

        testWidgets('shows label', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: CalendarAccessCard(onTap: () {}),
              ),
            ),
          );

          expect(find.text('Apri Calendario'), findsOneWidget);
        });

        testWidgets('calls onTap when tapped', (tester) async {
          var tapped = false;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: CalendarAccessCard(onTap: () => tapped = true),
              ),
            ),
          );

          await tester.tap(find.byType(InkWell));
          expect(tapped, true);
        });
      });
    }
    ```

    **dashboard_page_test.dart:**
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/pages/dashboard_page.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/providers/dashboard_provider.dart';
    import 'package:app_prenotazioni/features/reservations/domain/services/dashboard_statistics_service.dart';

    class MockDashboardNotifier extends DashboardNotifier {
      MockDashboardNotifier(super.repository);

      @override
      Future<void> loadDashboard() async {
        // Don't load in tests
      }
    }

    void main() {
      group('DashboardPage', () {
        testWidgets('shows loading indicator when loading', (tester) async {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                dashboardProvider.overrideWith((ref) {
                  return MockDashboardNotifier(null);
                }),
              ],
              child: const MaterialApp(home: DashboardPage()),
            ),
          );

          // Initial state shows loading
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        });

        testWidgets('shows room occupancy section', (tester) async {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                dashboardProvider.overrideWith((ref) {
                  final notifier = MockDashboardNotifier(null);
                  notifier.state = DashboardState(
                    statistics: DashboardStatistics(
                      occupiedRoomsToday: 2,
                      totalRooms: 4,
                      monthlyIncomeReceived: 100,
                      monthlyIncomePending: 50,
                      upcomingCheckIns: [],
                      upcomingCheckOuts: [],
                    ),
                    roomOccupancy: {},
                  );
                  return notifier;
                }),
              ],
              child: const MaterialApp(home: DashboardPage()),
            ),
          );

          expect(find.text('Stanze Oggi'), findsOneWidget);
        });

        testWidgets('shows income card', (tester) async {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                dashboardProvider.overrideWith((ref) {
                  final notifier = MockDashboardNotifier(null);
                  notifier.state = DashboardState(
                    statistics: DashboardStatistics(
                      occupiedRoomsToday: 2,
                      totalRooms: 4,
                      monthlyIncomeReceived: 100,
                      monthlyIncomePending: 50,
                      upcomingCheckIns: [],
                      upcomingCheckOuts: [],
                    ),
                    roomOccupancy: {},
                  );
                  return notifier;
                }),
              ],
              child: const MaterialApp(home: DashboardPage()),
            ),
          );

          expect(find.text('Incassi Mensili'), findsOneWidget);
        });
      });
    }
    ```
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/widgets/dashboard/ test/features/reservations/presentation/pages/dashboard_page_test.dart</automated>
  </verify>
  <done>All dashboard widget tests passing</done>
</task>

</tasks>

<verification>
1. `flutter analyze` passes for all new files
2. All widget tests pass
3. RoomOccupancyGrid displays 4 rooms correctly
4. IncomeBreakdownCard shows received/pending breakdown
5. UpcomingReservationsCard shows reservations sorted by date
6. CalendarAccessCard is tappable
7. DashboardPage has responsive layout with 600px breakpoint
8. Loading and error states handled correctly
</verification>

<success_criteria>
1. DashboardPage shows all statistics cards
2. Room occupancy grid displays 2x2 layout
3. Income breakdown shows received vs pending amounts
4. Upcoming arrivals and departures displayed
5. Calendar access card available for navigation
6. Responsive layout works at 600px breakpoint
7. All widget tests pass
8. Accessibility labels present on interactive elements
</success_criteria>

<output>
After completion, create `.planning/phases/04-dashboard-navigation/04-02-SUMMARY.md` with:
- Wave number (2)
- Tasks completed (6)
- Test results
- Files created/modified
- Next wave (03 - Reservations List & Edit/Delete)
</output>
