import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/core/providers/theme_provider.dart';
import 'package:app_prenotazioni/features/backup/presentation/pages/backup_settings_page.dart';

/// Settings page for app configuration.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      key: const Key('settings_view'),
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: ListView(
        key: const Key('settings_list'),
        children: [
          // Appearance section
          _buildSectionHeader(context, 'Aspetto'),
          ListTile(
            key: const Key('theme_tile'),
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Tema'),
            subtitle: Text(_getThemeLabel(themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(context, ref),
          ),

          const Divider(),

          // Data section
          _buildSectionHeader(context, 'Dati'),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup e Ripristino'),
            subtitle: const Text('Gestisci i backup dei tuoi dati'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BackupSettingsPage(),
                ),
              );
            },
          ),

          const Divider(),

          // About section
          _buildSectionHeader(context, 'Informazioni'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Versione'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.code_outlined),
            title: Text('Sviluppato con Flutter'),
            subtitle: Text('App per gestire prenotazioni Airbnb'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Sistema';
      case ThemeMode.light:
        return 'Chiaro';
      case ThemeMode.dark:
        return 'Scuro';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentMode = ref.read(themeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleziona Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Sistema'),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeProvider.notifier).setTheme(mode);
                }
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Chiaro'),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeProvider.notifier).setTheme(mode);
                }
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Scuro'),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeProvider.notifier).setTheme(mode);
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
