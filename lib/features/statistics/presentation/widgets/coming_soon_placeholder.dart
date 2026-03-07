import 'package:flutter/material.dart';

class ComingSoonPlaceholder extends StatelessWidget {
  final String title;
  final IconData icon;

  const ComingSoonPlaceholder({
    super.key,
    this.title = 'Statistiche in arrivo...',
    this.icon = Icons.bar_chart,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Funzionalità in arrivo',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
