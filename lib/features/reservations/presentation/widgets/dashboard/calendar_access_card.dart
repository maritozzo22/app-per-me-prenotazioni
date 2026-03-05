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
