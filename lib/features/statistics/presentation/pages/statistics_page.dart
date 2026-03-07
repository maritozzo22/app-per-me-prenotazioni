import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/statistics/presentation/widgets/coming_soon_placeholder.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('statistics_view'),
      appBar: AppBar(
        title: const Text('Statistiche'),
      ),
      body: const Center(
        child: ComingSoonPlaceholder(),
      ),
    );
  }
}
