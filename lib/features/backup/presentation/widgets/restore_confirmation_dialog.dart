import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/backup/data/models/backup_data_model.dart';

/// Confirmation dialog for restoring a backup.
class RestoreConfirmationDialog extends StatelessWidget {
  final BackupInfo backup;

  const RestoreConfirmationDialog({
    super.key,
    required this.backup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          const Text('Conferma Ripristino'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ATTENZIONE: Il ripristino sostituira tutti i dati attuali con quelli del backup.',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Backup details
          Text(
            'Dettagli Backup',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Data:', backup.timestampFormatted),
          _buildDetailRow('Tipo:', _getBackupTypeLabel()),
          _buildDetailRow('Prenotazioni:', '${backup.reservationCount}'),
          _buildDetailRow('Piattaforme:', '${backup.platformCount}'),
          _buildDetailRow('Stanze:', '${backup.roomCount}'),
          _buildDetailRow('Dimensione:', backup.fileSizeFormatted),

          const SizedBox(height: 16),

          const Text(
            'Sei sicuro di voler continuare?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annulla'),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.restore),
          label: const Text('Ripristina'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
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
      ),
    );
  }

  String _getBackupTypeLabel() {
    switch (backup.backupType) {
      case 'daily':
        return 'Giornaliero';
      case 'weekly':
        return 'Settimanale';
      default:
        return 'Manuale';
    }
  }
}
