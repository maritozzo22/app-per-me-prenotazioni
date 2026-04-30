import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_settings.dart';
import 'package:app_prenotazioni/features/notifications/presentation/providers/notification_settings_provider.dart';
import 'package:app_prenotazioni/features/notifications/presentation/providers/notification_log_provider.dart';
import 'package:app_prenotazioni/features/notifications/presentation/providers/notification_permission_provider.dart';
import 'package:app_prenotazioni/features/notifications/presentation/pages/notification_logs_page.dart';
import 'package:app_prenotazioni/features/notifications/application/notification_service.dart';
import 'package:app_prenotazioni/core/platform/platform_service.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(notificationSettingsProvider);
    final settings = settingsState.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifiche'),
      ),
      body: ListView(
        children: [
          // Enable/Disable
          SwitchListTile(
            key: const Key('notifications_enabled_switch'),
            title: const Text('Notifiche abilitate'),
            subtitle: Text(
              settings.enabled
                  ? 'Riceverai promemoria per i check-in'
                  : 'Nessun promemoria inviato',
            ),
            value: settings.enabled,
            onChanged: settingsState.isLoading
                ? null
                : (value) {
                    ref.read(notificationSettingsProvider.notifier).setEnabled(value);
                  },
          ),

          const Divider(),

          // Days before check-in
          _buildSectionHeader(context, 'Giorni di promemoria'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Seleziona quando ricevere i promemoria',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          ...NotificationSettings.availableDays.map((days) {
            return CheckboxListTile(
              key: Key('day_checkbox_$days'),
              title: Text(_getDayLabel(days)),
              value: settings.isDayEnabled(days),
              onChanged: settingsState.isLoading || !settings.enabled
                  ? null
                  : (value) {
                      ref.read(notificationSettingsProvider.notifier).toggleDay(days);
                    },
            );
          }),

          const Divider(),

          // Notification time
          ListTile(
            key: const Key('notification_time_tile'),
            leading: const Icon(Icons.access_time),
            title: const Text('Orario notifiche'),
            subtitle: Text(settings.notificationTimeString),
            enabled: settings.enabled,
            onTap: settings.enabled
                ? () => _showTimePicker(context, ref, settings)
                : null,
          ),

          const Divider(),

          // Test notification (Android only)
          if (PlatformService.isAndroid) ...[
            _buildSectionHeader(context, 'Test'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                key: const Key('test_notification_button'),
                onPressed: () => _sendTestNotification(context, ref),
                icon: const Icon(Icons.notifications_active),
                label: const Text('Invia notifica di test'),
              ),
            ),
            const Divider(),
          ],

          // Logs link
          _buildSectionHeader(context, 'Storico'),
          ListTile(
            key: const Key('view_logs_tile'),
            leading: const Icon(Icons.history),
            title: const Text('Vedi storico notifiche'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationLogsPage(),
                ),
              );
            },
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

  String _getDayLabel(int days) {
    if (days == 0) return 'Giorno stesso';
    if (days == 1) return '1 giorno prima';
    return '$days giorni prima';
  }

  Future<void> _showTimePicker(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.notificationHour,
        minute: settings.notificationMinute,
      ),
    );

    if (time != null) {
      ref.read(notificationSettingsProvider.notifier).setTime(
            time.hour,
            time.minute,
          );
    }
  }

  Future<void> _sendTestNotification(BuildContext context, WidgetRef ref) async {
    final service = ref.read(notificationServiceProvider);
    final success = await service.sendTestNotification();

    // Log the test notification
    await ref.read(notificationLogProvider.notifier).addTestLog(
          success: success,
          errorMessage: success ? null : 'Failed to send notification',
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Notifica di test inviata!'
                : 'Errore nell\'invio della notifica',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
