import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/platform_revenue.dart';

/// Platform revenue breakdown chart using pie chart.
///
/// Displays revenue distribution across booking platforms
/// with platform colors from the entity.
class PlatformRevenueChart extends StatelessWidget {
  const PlatformRevenueChart({
    super.key,
    required this.data,
    this.height = 300,
  });

  final List<PlatformRevenue> data;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter out platforms with zero revenue
    final nonZeroData = data.where((p) => p.totalRevenue > 0).toList();

    if (nonZeroData.isEmpty) {
      return _buildEmptyState(context);
    }

    final totalRevenue =
        nonZeroData.fold<double>(0, (sum, p) => sum + p.totalRevenue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fatturato per Piattaforma',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: height,
          child: Row(
            children: [
              // Pie Chart
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: nonZeroData.map((platform) {
                      final percentage =
                          (platform.totalRevenue / totalRevenue) * 100;
                      return PieChartSectionData(
                        color: Color(platform.color),
                        value: platform.totalRevenue,
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Legend
              Expanded(
                flex: 2,
                child: _buildLegend(context, nonZeroData, totalRevenue),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(
      BuildContext context, List<PlatformRevenue> data, double total) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.map((platform) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(platform.color),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    platform.platformName,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nessun dato disponibile',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
