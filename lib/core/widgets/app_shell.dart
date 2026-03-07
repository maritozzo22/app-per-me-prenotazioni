import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/dashboard_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/calendar_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/reservations_list_page.dart';
import 'package:app_prenotazioni/features/platforms/presentation/pages/platforms_list_page.dart';
import 'package:app_prenotazioni/core/presentation/pages/settings_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/dashboard_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/calendar_provider.dart';
import 'package:app_prenotazioni/core/utils/animations.dart';

/// State for tracking current tab index
final currentTabProvider = StateProvider<int>((ref) => 0);

/// Main navigation shell with bottom navigation bar.
///
/// Uses IndexedStack to preserve page state across tab switches.
/// This prevents rebuilding pages when switching tabs.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => AppShellState();
}

/// Public state class for programmatic navigation.
class AppShellState extends ConsumerState<AppShell> {
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

  /// Refresh providers when switching to a tab
  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Update the provider
    ref.read(currentTabProvider.notifier).state = index;

    // Trigger refresh for specific tabs
    if (index == 0) {
      // Dashboard - refresh statistics
      ref.read(dashboardProvider.notifier).refresh();
    } else if (index == 1) {
      // Calendar - refresh reservations
      ref.read(calendarProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppAnimations.shouldReduceMotion(context)
            ? Duration.zero
            : const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Container(
          key: ValueKey(_currentIndex),
          child: IndexedStack(
            key: const Key('indexed_stack'),
            index: _currentIndex,
            children: _pages,
          ),
        ),
      ),
      bottomNavigationBar: Semantics(
        label: 'Barra di navigazione',
        child: BottomNavigationBar(
          key: const Key('bottom_nav'),
          currentIndex: _currentIndex,
          onTap: _onTabChanged,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard, semanticLabel: 'Dashboard'),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, semanticLabel: 'Calendario'),
              label: 'Calendario',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list, semanticLabel: 'Lista prenotazioni'),
              label: 'Prenotazioni',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hotel, semanticLabel: 'Piattaforme'),
              label: 'Piattaforme',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, semanticLabel: 'Impostazioni'),
              label: 'Impostazioni',
            ),
          ],
        ),
      ),
    );
  }
}
