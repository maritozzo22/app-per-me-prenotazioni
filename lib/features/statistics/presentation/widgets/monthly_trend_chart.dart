import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/monthly_revenue.dart';

/// Monthly revenue trend chart using curved line chart.
///
/// Displays revenue progression over time with data points
/// and gradient fill below the line.
class MonthlyTrendChart extends StatelessWidget {
  const MonthlyTrendChart({
    super.key,
    required this.data,
    this.height = 300,
  });

  final List<MonthlyRevenue> data;
  final double height;

  static const _months = [
    'Gen',
    'Feb',
    'Mar',
    'Apr',
    'Mag',
    'Giu',
    'Lug',
    'Ago',
    'Set',
    'Ott',
    'Nov',
    'Dic'
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState(context);
    }

    final maxY =
        data.map((d) => d.revenue).reduce((a, b) => a > b ? a : b) * 1.2;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trend Mensile',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 5,
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                          '€${NumberFormat.compactCurrency(symbol: '').format(value)}');
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= data.length) {
                        return const SizedBox();
                      }
                      final monthStr = data[value.toInt()].month;
                      final parts = monthStr.split('-');
                      final monthIndex = int.parse(parts[1]) - 1;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _months[monthIndex],
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (data.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.revenue);
                  }).toList(),
                  isCurved: true,
                  color: theme.colorScheme.primary,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: theme.colorScheme.primary,
                        strokeWidth: 2,
                        strokeColor: theme.colorScheme.surface,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final index = spot.x.toInt();
                      final monthStr = data[index].month;
                      return LineTooltipItem(
                        '$monthStr\n€${spot.y.toStringAsFixed(0)}',
                        const TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
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
              Icons.show_chart,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.5),
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
