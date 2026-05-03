import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/dashboard_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/dashboard/room_occupancy_grid.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/dashboard/income_breakdown_card.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/dashboard/upcoming_reservations_card.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/dashboard/next_event_countdown_card.dart';
import 'package:app_prenotazioni/features/dashboard/presentation/widgets/dashboard_skeleton.dart';
import 'package:app_prenotazioni/core/presentation/widgets/error_display_widget.dart';
import 'package:app_prenotazioni/core/presentation/pages/settings_page.dart';
import 'package:app_prenotazioni/core/widgets/animations.dart';

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
      key: const Key('dashboard_view'),
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Impostazioni',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
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
      return const DashboardSkeleton();
    }

    if (state.error != null && state.statistics == null) {
      return ErrorDisplayWidget(
        error: state.error!,
        onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
      );
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

  Widget _buildMobileLayout(BuildContext context, DashboardState state) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room occupancy section
          FadeIn(
            slide: SlideDirection.up,
            delay: Duration.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stanze Oggi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                RoomOccupancyGrid(
                  key: const Key('occupancy_grid'),
                  roomOccupancy: state.roomOccupancy,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Income card
          FadeIn(
            slide: SlideDirection.up,
            delay: const Duration(milliseconds: 100),
            child: IncomeBreakdownCard(
              key: const Key('income_card'),
              received: state.statistics?.monthlyIncomeReceived ?? 0,
              pending: state.statistics?.monthlyIncomePending ?? 0,
            ),
          ),
          const SizedBox(height: 24),

          // Next event countdown card
          FadeIn(
            slide: SlideDirection.up,
            delay: const Duration(milliseconds: 200),
            child: NextEventCountdownCard(
              upcomingCheckIns: state.statistics?.upcomingCheckIns ?? [],
              upcomingCheckOuts: state.statistics?.upcomingCheckOuts ?? [],
            ),
          ),
          const SizedBox(height: 24),

          // Upcoming check-ins
          FadeIn(
            slide: SlideDirection.up,
            delay: const Duration(milliseconds: 300),
            child: UpcomingReservationsCard(
              key: const Key('check_ins_card'),
              title: 'Prossimi Arrivi',
              reservations: state.statistics?.upcomingCheckIns ?? [],
            ),
          ),
          const SizedBox(height: 16),

          // Upcoming check-outs
          FadeIn(
            slide: SlideDirection.up,
            delay: const Duration(milliseconds: 400),
            child: UpcomingReservationsCard(
              key: const Key('check_outs_card'),
              title: 'Prossime Partenze',
              reservations: state.statistics?.upcomingCheckOuts ?? [],
              showCheckOutDate: true,
            ),
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
                NextEventCountdownCard(
                  upcomingCheckIns: state.statistics?.upcomingCheckIns ?? [],
                  upcomingCheckOuts: state.statistics?.upcomingCheckOuts ?? [],
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
