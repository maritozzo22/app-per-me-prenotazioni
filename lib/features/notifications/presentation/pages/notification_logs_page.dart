import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app_prenotazioni/features/notifications/presentation/providers/notification_log_provider.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_log.dart';

class NotificationLogsPage extends ConsumerWidget {
  const NotificationLogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logState = ref.watch(notificationLogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storico Notifiche'),
        actions: [
          if (logState.logs.isNotEmpty)
            IconButton(
              key: const Key('clear_logs_button'),
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearConfirmation(context, ref),
              tooltip: 'Cancella tutto',
            ),
        ],
      ),
      body: logState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : logState.logs.isEmpty
              ? _buildEmptyState(context)
              : _buildLogsList(context, ref, logState.logs),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Nessuna notifica inviata',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Le notifiche inviate appariranno qui',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(BuildContext context, WidgetRef ref, List<NotificationLog> logs) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return RefreshIndicator(
      onRefresh: () => ref.read(notificationLogProvider.notifier).refreshLogs(),
      child: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return _LogTile(log: log, dateFormat: dateFormat);
        },
      ),
    );
  }

  Future<void> _showClearConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancella storico'),
        content: const Text(
          'Sei sicuro di voler cancellare tutto lo storico delle notifiche?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cancella'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(notificationLogProvider.notifier).clearAllLogs();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storico cancellato')),
        );
      }
    }
  }
}

class _LogTile extends StatelessWidget {
  final NotificationLog log;
  final DateFormat dateFormat;

  const _LogTile({
    required this.log,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = log.success
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return ListTile(
      leading: Icon(
        log.success ? Icons.check_circle : Icons.error,
        color: iconColor,
      ),
      title: Row(
        children: [
          if (log.isTest)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'TEST',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          Expanded(
            child: Text(
              log.isTest ? 'Notifica di test' : log.guestName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!log.isTest && log.roomLabel.isNotEmpty)
            Text(
              log.roomLabel,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          Text(
            '${log.daysBeforeLabel} - ${dateFormat.format(log.sentAt)}',
          ),
          if (log.errorMessage != null)
            Text(
              log.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      isThreeLine: log.errorMessage != null || (!log.isTest && log.roomLabel.isNotEmpty),
    );
  }
}
