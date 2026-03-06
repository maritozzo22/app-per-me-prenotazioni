import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/backup/presentation/providers/backup_provider.dart';
import 'package:app_prenotazioni/features/backup/data/models/backup_data_model.dart';
import 'package:app_prenotazioni/features/backup/presentation/widgets/backup_list_tile.dart';
import 'package:app_prenotazioni/features/backup/presentation/widgets/restore_confirmation_dialog.dart';
import 'package:share_plus/share_plus.dart';

/// Settings page for backup and restore functionality.
class BackupSettingsPage extends ConsumerWidget {
  const BackupSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup e Ripristino'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            _buildStatusCard(context, ref, backupState),

            const SizedBox(height: 16),

            // Backup actions
            _buildActionsCard(context, ref, backupState),

            const SizedBox(height: 16),

            // Available backups list
            _buildBackupsListCard(context, ref, backupState),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    WidgetRef ref,
    BackupState backupState,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stato Backup',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Ultimo backup:',
              backupState.lastBackupTime != null
                  ? _formatDateTime(backupState.lastBackupTime!)
                  : 'Nessun backup',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              'Backup disponibili:',
              '${backupState.availableBackups.length}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              'Spazio utilizzato:',
              backupState.totalBackupSizeFormatted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(
    BuildContext context,
    WidgetRef ref,
    BackupState backupState,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Azioni',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Create backup button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: backupState.isBackingUp
                    ? null
                    : () => _createBackup(context, ref),
                icon: backupState.isBackingUp
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.backup),
                label: Text(
                  backupState.isBackingUp ? 'Creazione backup...' : 'Crea Backup',
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Refresh list button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: backupState.isLoading
                    ? null
                    : () => ref.read(backupProvider.notifier).loadBackups(),
                icon: const Icon(Icons.refresh),
                label: const Text('Aggiorna lista'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupsListCard(
    BuildContext context,
    WidgetRef ref,
    BackupState backupState,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Backup Disponibili',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (backupState.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Messages
            if (backupState.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        backupState.errorMessage!,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          ref.read(backupProvider.notifier).clearMessages(),
                      icon: const Icon(Icons.close, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

            if (backupState.successMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        backupState.successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          ref.read(backupProvider.notifier).clearMessages(),
                      icon: const Icon(Icons.close, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

            // Backup list
            if (backupState.availableBackups.isEmpty && !backupState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Nessun backup disponibile',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: backupState.availableBackups.length,
                itemBuilder: (context, index) {
                  final backup = backupState.availableBackups[index];
                  return BackupListTile(
                    backup: backup,
                    onRestore: () => _showRestoreConfirmation(context, ref, backup),
                    onDelete: () => _confirmDelete(context, ref, backup),
                    onShare: () => _shareBackup(context, backup),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _createBackup(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final success = await ref.read(backupProvider.notifier).createBackup();

    if (context.mounted) {
      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Backup creato con successo'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showRestoreConfirmation(
    BuildContext context,
    WidgetRef ref,
    BackupInfo backup,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => RestoreConfirmationDialog(backup: backup),
    );

    if (confirmed == true && context.mounted) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      final success = await ref.read(backupProvider.notifier).restoreBackup(backup);

      if (context.mounted) {
        if (success) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Backup ripristinato con successo'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BackupInfo backup,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Sei sicuro di voler eliminare il backup "${backup.fileName}"?\n\n'
          'Questa azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final success = await ref.read(backupProvider.notifier).deleteBackup(backup);

      if (context.mounted && success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Backup eliminato'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _shareBackup(BuildContext context, BackupInfo backup) async {
    try {
      final file = File(backup.filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(backup.filePath)],
          subject: 'Backup App Prenotazioni - ${backup.fileName}',
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File di backup non trovato'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante la condivisione: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
