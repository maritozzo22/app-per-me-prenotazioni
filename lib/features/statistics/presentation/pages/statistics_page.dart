import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/statistics/presentation/providers/statistics_provider.dart';
import 'package:app_prenotazioni/features/statistics/presentation/widgets/kpi_card.dart';
import 'package:app_prenotazioni/features/statistics/presentation/widgets/period_filter_selector.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/period_filter.dart';
import 'package:app_prenotazioni/core/presentation/widgets/full_screen_loading_widget.dart';
import 'package:app_prenotazioni/core/presentation/widgets/inline_error_message.dart';

/// Main statistics page displaying KPIs and charts.
///
/// Shows key performance indicators (revenue, occupancy, bookings, etc.)
/// with a period filter selector for different time ranges.
class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(statisticsProvider);
    final filter = ref.watch(statisticsFilterProvider);

    return Scaffold(
      key: const Key('statistics_view'),
      appBar: AppBar(
        title: const Text('Statistiche'),
        actions: [
          IconButton(
            key: const Key('refresh_button'),
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(statisticsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Period Filter Selector
          PeriodFilterSelector(
            selectedPeriod: filter.period,
            onPeriodChanged: (period) {
              ref.read(statisticsProvider.notifier).updateFilter(
                filter.copyWith(period: period),
              );
            },
            onCustomRangeSelected: (start, end) {
              ref.read(statisticsProvider.notifier).updateFilter(
                filter.copyWith(
                  period: PeriodFilter.custom,
                  customStartDate: start,
                  customEndDate: end,
                ),
              );
            },
          ),
          // Statistics Content
          Expanded(
            child: statisticsAsync.when(
              data: (statistics) {
                if (statistics == null) {
                  return const Center(
                    child: Text('Nessun dato disponibile'),
                  );
                }
                return _buildStatisticsContent(context, ref, statistics);
              },
              loading: () => const FullScreenLoadingWidget(),
              error: (error, stack) => InlineErrorMessage(
                message: 'Errore caricamento statistiche: ${error.toString()}',
                onDismiss: () {
                  ref.read(statisticsProvider.notifier).refresh();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsContent(
    BuildContext context,
    WidgetRef ref,
    dynamic statistics,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards Section
          Text(
            'Panoramica',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _buildKpiGrid(context, statistics),
          const SizedBox(height: 24),

          // Charts Section (placeholder for Wave 4)
          Text(
            'Grafici',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text('I grafici saranno implementati nella prossima wave'),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(BuildContext context, dynamic statistics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive: 2 columns on mobile, 5 columns on wide screens
        final crossAxisCount = constraints.maxWidth > 800 ? 5 : 2;
        final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * 12) / crossAxisCount;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: itemWidth,
              child: KpiCard(
                title: 'Fatturato',
                value: statistics.totalRevenue,
                format: KpiFormat.currency,
                icon: Icons.euro,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: KpiCard(
                title: 'Occupazione',
                value: statistics.occupancyRate,
                format: KpiFormat.percentage,
                icon: Icons.hotel,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: KpiCard(
                title: 'Durata Media',
                value: statistics.averageStayDuration,
                format: KpiFormat.days,
                icon: Icons.calendar_today,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: KpiCard(
                title: 'Prenotazioni',
                value: statistics.totalBookings,
                format: KpiFormat.number,
                icon: Icons.book,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: KpiCard(
                title: 'Ospiti',
                value: statistics.totalGuests,
                format: KpiFormat.number,
                icon: Icons.people,
              ),
            ),
          ],
        );
      },
    );
  }
}
