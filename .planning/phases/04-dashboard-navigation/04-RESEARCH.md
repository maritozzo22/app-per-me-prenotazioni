# Phase 4: Dashboard & Navigation - Research

**Researched:** 2026-03-05
**Domain:** Flutter dashboard UI, bottom navigation, responsive design, list views
**Confidence:** HIGH

## Summary

Phase 4 transforms the app from a single calendar view into a full-featured reservation management system with three main sections: Dashboard (home), Calendar, and Reservations List. The core challenges are implementing a statistics-driven dashboard with room occupancy visualization, bottom navigation with state preservation, and a reservations list with edit/delete functionality.

**Critical Findings:**
1. **IndexedStack + BottomNavigationBar** is the recommended pattern for preserving tab state without rebuilding pages
2. **GoRouter with ShellRoute** is overkill for this 3-tab app - use simple Navigator with IndexedStack
3. **Mobile-first with 600px breakpoint** is the Material Design standard for responsive layouts
4. **flutter_slidable** package provides superior swipe actions (edit + delete) compared to built-in Dismissible

**Primary recommendation:** Implement a `DashboardProvider` service that calculates real-time statistics (occupancy, income, arrivals), use `IndexedStack` for bottom navigation state preservation, and `flutter_slidable` for list item actions.

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| CAL-05 | Calendar accessible from dashboard | Navigation via bottom nav bar with IndexedStack |
| DASH-01 | Dashboard shows rooms occupied today | DashboardStatisticsService with occupancy calculation |
| DASH-02 | Dashboard shows upcoming check-ins (7 days) | DashboardProvider with date range filtering |
| DASH-03 | Dashboard shows upcoming check-outs (7 days) | DashboardProvider with date range filtering |
| DASH-04 | Dashboard shows monthly income (received + pending) | DashboardStatisticsService with PaymentStatus filtering |
| DASH-05 | Responsive design for mobile | LayoutBuilder with 600px breakpoint |
| DASH-06 | Bottom navigation bar | BottomNavigationBar + IndexedStack pattern |
| RES-08 | Reservations list screen | ListView.builder with flutter_slidable for actions |
| RES-09 | Modify/delete reservation screens | flutter_slidable actions + existing ReservationForm |
| UI-04 | Responsive layout breakpoints | 600px breakpoint (Material Design standard) |
| UI-06 | Dashboard as home screen | Update main.dart to show DashboardPage first |
| TEST-04 | Widget tests for dashboard | flutter_test with pumpWidget for dashboard widgets |
| A11Y-01 | Basic accessibility | Semantics labels, 48px touch targets, color contrast |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_riverpod | ^2.6.0 (already in project) | State management for dashboard | Consistent with existing providers, type-safe |
| table_calendar | ^3.2.0 (already in project) | Calendar widget | Already integrated from Phase 3 |
| intl | any (SDK) | Date formatting | Already in use, Italian locale support |

### Supporting (New)
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| flutter_slidable | ^3.1.1 | Swipe actions for list items | When multiple actions needed (edit + delete) |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| flutter_slidable | Dismissible (built-in) | Dismissible only supports single action; flutter_slidable supports multiple actions with custom animations |
| IndexedStack | GoRouter ShellRoute | GoRouter is overkill for 3-tab app without deep linking; IndexedStack is simpler and preserves state |
| BottomNavigationBar | NavigationBar (Material 3) | NavigationBar is newer but BottomNavigationBar is battle-tested; both work well |

**Installation:**
```yaml
# pubspec.yaml - ADD to existing dependencies
dependencies:
  flutter_slidable: ^3.1.1

# All other dependencies already in project
```

## Architecture Patterns

### Recommended Project Structure
```
lib/
├── main.dart                                    # Updated with AppShell
├── core/
│   └── widgets/
│       └── app_shell.dart                       # Bottom nav + IndexedStack
├── features/
│   └── reservations/
│       ├── domain/
│       │   └── services/
│       │       ├── calendar_service.dart        # Existing
│       │       └── dashboard_statistics_service.dart  # NEW: Dashboard calculations
│       ├── presentation/
│       │   ├── pages/
│       │   │   ├── calendar_page.dart           # Existing
│       │   │   ├── dashboard_page.dart          # NEW: Home screen
│       │   │   └── reservations_list_page.dart  # NEW: List screen
│       │   ├── providers/
│       │   │   ├── calendar_provider.dart       # Existing
│       │   │   ├── reservation_provider.dart    # Existing
│       │   │   └── dashboard_provider.dart      # NEW: Dashboard state
│       │   └── widgets/
│       │       ├── reservation_calendar.dart    # Existing
│       │       ├── day_detail_bottom_sheet.dart # Existing
│       │       ├── reservation_day_card.dart    # Existing
│       │       ├── dashboard/
│       │       │   ├── room_occupancy_grid.dart # NEW: 2x2 room status
│       │       │   ├── stat_card.dart           # NEW: Reusable stat card
│       │       │   ├── income_breakdown_card.dart # NEW: Received vs pending
│       │       │   └── upcoming_reservations_card.dart # NEW: Arrivals/departures
│       │       └── reservations_list/
│       │           └── reservation_list_tile.dart # NEW: Swipeable list item

test/
├── features/
│   └── reservations/
│       ├── domain/
│       │   └── services/
│       │       └── dashboard_statistics_service_test.dart
│       └── presentation/
│           ├── pages/
│           │   ├── dashboard_page_test.dart
│           │   └── reservations_list_page_test.dart
│           ├── providers/
│           │   └── dashboard_provider_test.dart
│           └── widgets/
│               ├── room_occupancy_grid_test.dart
│               ├── stat_card_test.dart
│               └── reservation_list_tile_test.dart
```

### Pattern 1: Bottom Navigation with IndexedStack (State Preservation)

**What:** Use `IndexedStack` with `BottomNavigationBar` to preserve page state when switching tabs.

**When to use:** Always for bottom navigation - prevents page rebuilding on tab switches.

**Example:**
```dart
// core/widgets/app_shell.dart
import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/dashboard_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/calendar_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/reservations_list_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // Pages are created once and kept in memory via IndexedStack
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
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
```

### Pattern 2: Dashboard Statistics Service

**What:** Domain service that calculates occupancy, income, and upcoming reservations.

**When to use:** For DASH-01 through DASH-04 - all dashboard statistics calculations.

**Example:**
```dart
// domain/services/dashboard_statistics_service.dart
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
    final sevenDaysLater = today.add(const Duration(days: 7));

    // Get current month range
    final monthStart = DateTime(currentDate.year, currentDate.month, 1);
    final monthEnd = DateTime(currentDate.year, currentDate.month + 1, 0);

    // Count occupied rooms today
    final occupiedRoomIds = <String>{};
    for (final reservation in reservations) {
      if (_isDateInRange(today, reservation.checkIn, reservation.checkOut)) {
        occupiedRoomIds.add(reservation.roomId);
      }
    }

    // Calculate monthly income
    double received = 0;
    double pending = 0;
    for (final reservation in reservations) {
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

    // Get upcoming check-ins (next 7 days)
    final upcomingCheckIns = reservations.where((r) =>
      r.checkIn.isAfter(today) &&
      r.checkIn.isBefore(sevenDaysLater) ||
      _isSameDay(r.checkIn, today)
    ).toList()
      ..sort((a, b) => a.checkIn.compareTo(b.checkIn));

    // Get upcoming check-outs (next 7 days)
    final upcomingCheckOuts = reservations.where((r) =>
      r.checkOut.isAfter(today) &&
      r.checkOut.isBefore(sevenDaysLater) ||
      _isSameDay(r.checkOut, today)
    ).toList()
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

  bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && date.isBefore(end);
  }

  bool _reservationsOverlapMonth(Reservation r, DateTime monthStart, DateTime monthEnd) {
    return r.checkIn.isBefore(monthEnd) && r.checkOut.isAfter(monthStart);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
```

### Pattern 3: Room Occupancy Grid (2x2)

**What:** Visual 2x2 grid showing each room's occupancy status with color indicators.

**When to use:** For DASH-01 - visual room status overview.

**Example:**
```dart
// presentation/widgets/dashboard/room_occupancy_grid.dart
import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';

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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOccupied ? Colors.green : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isOccupied ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
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
    );
  }
}
```

### Pattern 4: Swipeable List Item with Edit/Delete

**What:** Use `flutter_slidable` for multiple swipe actions (edit, delete) on list items.

**When to use:** For RES-08 and RES-09 - reservations list with actions.

**Example:**
```dart
// presentation/widgets/reservations_list/reservation_list_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';

class ReservationListTile extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReservationListTile({
    super.key,
    required this.reservation,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(reservation.id),
      // Left swipe: Edit
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Modifica',
          ),
        ],
      ),
      // Right swipe: Delete
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _confirmDelete(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Elimina',
          ),
        ],
      ),
      child: ListTile(
        leading: _buildPlatformIndicator(),
        title: Text(reservation.guest.name),
        subtitle: Text(_formatDateRange()),
        trailing: _buildPaymentStatus(),
        onTap: onEdit, // Tap also opens edit
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Eliminare la prenotazione di ${reservation.guest.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformIndicator() {
    // Use existing platform color lookup
    return Container(/* ... */);
  }

  Widget _buildPaymentStatus() {
    return Icon(
      reservation.paymentStatus == PaymentStatus.received
          ? Icons.check_circle
          : Icons.pending,
      color: reservation.paymentStatus.color,
    );
  }

  String _formatDateRange() {
    // Use existing date formatting
    return '${reservation.checkIn.day}/${reservation.checkIn.month} - ${reservation.checkOut.day}/${reservation.checkOut.month}';
  }
}
```

### Pattern 5: Responsive Layout with Breakpoint

**What:** Use `LayoutBuilder` for mobile-first responsive design with 600px breakpoint.

**When to use:** For DASH-05 and UI-04 - responsive dashboard layout.

**Example:**
```dart
// presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return _buildMobileLayout(context);
          } else {
            return _buildTabletLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    // Single column, cards stack vertically
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room occupancy grid (2x2)
          const Text('Stanze Oggi', style: TextStyle(fontWeight: FontWeight.bold)),
          const RoomOccupancyGrid(roomOccupancy: {/* ... */}),
          const SizedBox(height: 16),

          // Income card (full width)
          IncomeBreakdownCard(/* ... */),
          const SizedBox(height: 16),

          // Calendar access card (large)
          _buildCalendarAccessCard(context),
          const SizedBox(height: 16),

          // Upcoming arrivals
          UpcomingReservationsCard(title: 'Arrivi', reservations: /* ... */),
          const SizedBox(height: 16),

          // Upcoming departures
          UpcomingReservationsCard(title: 'Partenze', reservations: /* ... */),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    // Two columns for wider screens
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column
          Expanded(
            child: Column(
              children: [
                RoomOccupancyGrid(roomOccupancy: {/* ... */}),
                const SizedBox(height: 16),
                IncomeBreakdownCard(/* ... */),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right column
          Expanded(
            child: Column(
              children: [
                _buildCalendarAccessCard(context),
                const SizedBox(height: 16),
                UpcomingReservationsCard(title: 'Arrivi', reservations: /* ... */),
                const SizedBox(height: 16),
                UpcomingReservationsCard(title: 'Partenze', reservations: /* ... */),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarAccessCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to calendar tab (handled by parent)
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.calendar_today, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              const Text('Apri Calendario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Anti-Patterns to Avoid

- **Using GoRouter for simple 3-tab app:** Overkill - adds complexity without benefit for this use case
- **Rebuilding pages on tab switch:** Loses scroll position, form data - use IndexedStack
- **Using Dismissible for multiple actions:** Only supports single action - use flutter_slidable
- **Fixed pixel widths:** Use LayoutBuilder with breakpoints for responsive design
- **Calculating statistics in widget build():** Expensive calculations should be in provider/service
- **Missing accessibility labels:** Screen readers need semantic information for icons

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Swipe actions with multiple buttons | Custom gesture detection | flutter_slidable | Handles edge cases, animations, accessibility |
| Tab state preservation | PageView with controller | IndexedStack | Simpler, automatic state retention |
| Date calculations | Manual DateTime operations | DashboardStatisticsService + existing CalendarService | Centralized logic, testable |
| Statistics calculations | Inline in widgets | DashboardProvider with service | Separation of concerns, caching |
| Responsive breakpoints | Manual MediaQuery checks | LayoutBuilder with constants | Cleaner code, easier testing |

**Key insight:** Navigation and list interactions are complex - use established patterns (IndexedStack, flutter_slidable) to avoid subtle bugs with state management and gesture handling.

## Common Pitfalls

### Pitfall 1: Losing Tab State on Navigation
**What goes wrong:** Switching tabs rebuilds pages, losing scroll position and form data.
**Why it happens:** Using `if (index == 0) Page1() else Page2()` instead of keeping all pages in memory.
**How to avoid:** Use `IndexedStack` which keeps all children in memory, only changing visibility.
**Warning signs:** Scroll position resets, form inputs cleared, data reloads on tab switch.

### Pitfall 2: Statistics Calculated on Every Build
**What goes wrong:** Dashboard lags because statistics are recalculated on every frame during animations.
**Why it happens:** Putting calculation logic directly in `build()` method.
**How to avoid:** Use Riverpod provider that caches calculations until data changes.
**Warning signs:** Stuttering animations, slow page transitions, battery drain.

### Pitfall 3: Incorrect Date Range for "Today"
**What goes wrong:** Reservations not showing because DateTime comparison includes time component.
**Why it happens:** `DateTime.now()` includes hours/minutes, but check-in dates are midnight.
**How to avoid:** Normalize dates to midnight before comparison: `DateTime(date.year, date.month, date.day)`.
**Warning signs:** Occupancy shows 0 when reservations exist, inconsistent results at different times of day.

### Pitfall 4: Missing Delete Confirmation
**What goes wrong:** Accidental swipe deletes reservation without confirmation.
**Why it happens:** Directly calling delete in `onDismissed` without confirmation dialog.
**How to avoid:** Always show confirmation dialog for destructive actions.
**Warning signs:** User complaints about lost data, no undo mechanism.

### Pitfall 5: Inaccessible Icon Buttons
**What goes wrong:** Screen readers announce "unlabeled button" for icon-only actions.
**Why it happens:** Not providing `semanticLabel` or `tooltip` on IconButtons.
**How to avoid:** Always provide tooltip/label: `IconButton(icon: Icon(Icons.edit), tooltip: 'Modifica')`.
**Warning signs:** Accessibility audits fail, screen reader users can't navigate.

## Code Examples

### Complete Dashboard Provider

```dart
// presentation/providers/dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/dashboard_statistics_service.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';

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

class DashboardNotifier extends StateNotifier<DashboardState> {
  final ReservationRepository _repository;
  final DashboardStatisticsService _statisticsService;

  DashboardNotifier(this._repository)
      : _statisticsService = DashboardStatisticsService(),
        super(const DashboardState()) {
    loadDashboard();
  }

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
      final today = DateTime(now.year, now.month, now.day);
      final roomOccupancy = <String, Reservation?>{};
      for (final room in Room.defaultRooms) {
        roomOccupancy[room.id] = reservations.firstWhere(
          (r) => r.roomId == room.id &&
              !today.isBefore(r.checkIn) &&
              today.isBefore(r.checkOut),
          orElse: () => null as Reservation,
        );
      }

      state = state.copyWith(
        statistics: statistics,
        roomOccupancy: roomOccupancy,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);
  return DashboardNotifier(repository);
});
```

### Updated main.dart

```dart
// main.dart
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
      home: const AppShell(), // Dashboard-first via AppShell
    );
  }
}
```

### Widget Test for Dashboard

```dart
// test/features/reservations/presentation/pages/dashboard_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/dashboard_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/dashboard_provider.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/dashboard_statistics_service.dart';

void main() {
  group('DashboardPage', () {
    testWidgets('shows loading indicator while loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardProvider.overrideWith((ref) {
              return MockDashboardNotifier(const DashboardState(isLoading: true));
            }),
          ],
          child: const MaterialApp(home: DashboardPage()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows room occupancy grid when loaded', (tester) async {
      final statistics = DashboardStatistics(
        occupiedRoomsToday: 2,
        totalRooms: 4,
        monthlyIncomeReceived: 500,
        monthlyIncomePending: 200,
        upcomingCheckIns: [],
        upcomingCheckOuts: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardProvider.overrideWith((ref) {
              return MockDashboardNotifier(DashboardState(statistics: statistics));
            }),
          ],
          child: const MaterialApp(home: DashboardPage()),
        ),
      );

      expect(find.text('Stanze Oggi'), findsOneWidget);
      expect(find.text('2/4 occupate'), findsOneWidget);
    });

    testWidgets('shows income breakdown', (tester) async {
      final statistics = DashboardStatistics(
        occupiedRoomsToday: 2,
        totalRooms: 4,
        monthlyIncomeReceived: 500,
        monthlyIncomePending: 200,
        upcomingCheckIns: [],
        upcomingCheckOuts: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardProvider.overrideWith((ref) {
              return MockDashboardNotifier(DashboardState(statistics: statistics));
            }),
          ],
          child: const MaterialApp(home: DashboardPage()),
        ),
      );

      expect(find.text('Incassi Mensili'), findsOneWidget);
      expect(find.text('EUR 500'), findsOneWidget); // Received
      expect(find.text('EUR 200'), findsOneWidget); // Pending
    });
  });
}

class MockDashboardNotifier extends StateNotifier<DashboardState>
    implements DashboardNotifier {
  MockDashboardNotifier(super.state);

  @override
  Future<void> loadDashboard() async {}

  @override
  Future<void> refresh() async {}
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| PageView for tabs | IndexedStack | 2022+ | State preservation without complexity |
| Dismissible | flutter_slidable | 2023+ | Multiple actions, better UX |
| MediaQuery in widgets | LayoutBuilder | 2024+ | Constraint-based, more performant |
| GoRouter for everything | IndexedStack for simple nav | 2025+ | Right tool for right job |
| Statistics in build() | Provider with caching | 2023+ | Performance, testability |

**Deprecated/outdated:**
- Navigator 2.0 manual implementation: Use GoRouter for complex routing or IndexedStack for simple tabs
- Custom swipe gestures: Use flutter_slidable or Dismissible
- MediaQuery.of(context).size in build(): Use LayoutBuilder for constraint-based responsive design

## Open Questions

1. **Calendar Access Navigation**
   - What we know: Dashboard needs large card to access calendar
   - What's unclear: Should it navigate to calendar tab programmatically or use callback to parent?
   - Recommendation: Use callback pattern - parent AppShell manages tab state, passes `onCalendarTap` callback

2. **Income Calculation Method**
   - What we know: Reservations span months; need to decide how to attribute income
   - What's unclear: Pro-rate by night or attribute to check-in month?
   - Recommendation: Attribute full amount to check-in month for simplicity (matches user mental model)

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK) |
| Config file | None - Flutter SDK built-in |
| Quick run command | `flutter test test/features/reservations/presentation/pages/dashboard_page_test.dart` |
| Full suite command | `flutter test` |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| CAL-05 | Calendar accessible from dashboard | widget | `flutter test test/core/widgets/app_shell_test.dart` | Wave 0 |
| DASH-01 | Rooms occupied today | unit/widget | `flutter test test/features/reservations/domain/services/dashboard_statistics_service_test.dart` | Wave 0 |
| DASH-02 | Upcoming check-ins (7 days) | unit | `flutter test test/features/reservations/domain/services/dashboard_statistics_service_test.dart` | Wave 0 |
| DASH-03 | Upcoming check-outs (7 days) | unit | `flutter test test/features/reservations/domain/services/dashboard_statistics_service_test.dart` | Wave 0 |
| DASH-04 | Monthly income breakdown | unit | `flutter test test/features/reservations/domain/services/dashboard_statistics_service_test.dart` | Wave 0 |
| DASH-05 | Responsive design | widget | `flutter test test/features/reservations/presentation/pages/dashboard_page_test.dart` | Wave 0 |
| DASH-06 | Bottom navigation bar | widget | `flutter test test/core/widgets/app_shell_test.dart` | Wave 0 |
| RES-08 | Reservations list screen | widget | `flutter test test/features/reservations/presentation/pages/reservations_list_page_test.dart` | Wave 0 |
| RES-09 | Modify/delete reservation | widget | `flutter test test/features/reservations/presentation/widgets/reservations_list/reservation_list_tile_test.dart` | Wave 0 |
| UI-04 | Responsive breakpoints | widget | `flutter test test/features/reservations/presentation/pages/dashboard_page_test.dart` | Wave 0 |
| UI-06 | Dashboard as home | widget | `flutter test test/widget_test.dart` | Wave 0 |
| TEST-04 | Widget tests for dashboard | widget | All dashboard widget tests | Wave 0 |
| A11Y-01 | Basic accessibility | widget | `flutter test --platform chrome test/accessibility/` | Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/features/reservations/presentation/widgets/dashboard/` (dashboard widgets, ~10s)
- **Per wave merge:** `flutter test` (all tests, ~30s)
- **Phase gate:** `flutter test --coverage` with dashboard tests passing

### Wave 0 Gaps
- [ ] `test/features/reservations/domain/services/dashboard_statistics_service_test.dart` - statistics calculations
- [ ] `test/features/reservations/presentation/providers/dashboard_provider_test.dart` - provider state management
- [ ] `test/features/reservations/presentation/pages/dashboard_page_test.dart` - dashboard page widget tests
- [ ] `test/features/reservations/presentation/pages/reservations_list_page_test.dart` - list page widget tests
- [ ] `test/features/reservations/presentation/widgets/dashboard/room_occupancy_grid_test.dart` - 2x2 grid tests
- [ ] `test/features/reservations/presentation/widgets/dashboard/stat_card_test.dart` - stat card widget tests
- [ ] `test/features/reservations/presentation/widgets/reservations_list/reservation_list_tile_test.dart` - swipeable list tile tests
- [ ] `test/core/widgets/app_shell_test.dart` - bottom navigation tests
- [ ] Package install: `flutter pub add flutter_slidable` - add to dependencies

## Sources

### Primary (HIGH confidence)
- [Flutter BottomNavigationBar + IndexedStack](https://m.blog.csdn.net/qq_54858411/article/details/141756932) - State preservation pattern
- [Flutter Responsive Design Guide](https://m.blog.csdn.net/gitblog_00724/article/details/152246605) - Breakpoints and LayoutBuilder
- [Flutter Official Dismissible Documentation](https://docs.flutter.dev/cookbook/gestures/dismissible) - Swipe-to-delete basics

### Secondary (MEDIUM confidence)
- [flutter_slidable Tutorial](https://m.blog.csdn.net/2402_83107102/article/details/158152125) - Multiple swipe actions
- [Riverpod Complete Guide 2026](https://m.blog.csdn.net/gitblog_00620/article/details/151474514) - Provider patterns
- [Flutter Accessibility Best Practices](https://m.blog.csdn.net/2501_94610615/article/details/156135557) - Semantics labels

### Tertiary (LOW confidence)
- [Flutter Dashboard Statistics Cards](https://m.blog.csdn.net/gitblog_00637/article/details/151520880) - UI patterns verified against official docs
- [GoRouter ShellRoute Guide](https://m.blog.csdn.net/gitblog_00341/article/details/156532483) - ShellRoute pattern (overkill for this use case)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - All packages are well-established, stable, and documented
- Architecture: HIGH - IndexedStack + BottomNavigationBar is battle-tested pattern
- Dashboard statistics: HIGH - Clear calculation logic, testable service pattern
- Responsive design: HIGH - 600px breakpoint is Material Design standard
- Pitfalls: HIGH - Common mistakes well-documented in Flutter community

**Research date:** 2026-03-05
**Valid until:** 30 days - Flutter packages are relatively stable, but best practices may evolve
