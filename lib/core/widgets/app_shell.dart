import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/dashboard_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/calendar_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/reservations_list_page.dart';
import 'package:app_prenotazioni/features/platforms/presentation/pages/platforms_list_page.dart';
import 'package:app_prenotazioni/core/presentation/pages/settings_page.dart';

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
    const PlatformsListPage(),
    const SettingsPage(),
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
        key: const Key('indexed_stack'),
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        key: const Key('bottom_nav'),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: 'Piattaforme',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Impostazioni',
          ),
        ],
      ),
    );
  }
}
