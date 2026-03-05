import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/core/providers/theme_provider.dart';

/// Theme toggle button widget
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return IconButton(
      icon: Icon(
        isDark ? Icons.dark_mode : Icons.light_mode,
      ),
      onPressed: () {
        ref.read(themeProvider.notifier).toggleTheme();
      },
      tooltip: 'Cambia tema',
    );
  }
}
