import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/backup/data/models/backup_data_model.dart';

/// List tile widget for displaying a backup item.
class BackupListTile extends StatelessWidget {
  final BackupInfo backup;
  final VoidCallback onRestore;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const BackupListTile({
    super.key,
    required this.backup,
    required this.onRestore,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with date and type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getBackupTypeIcon(),
                      size: 20,
                      color: _getBackupTypeColor(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      backup.timestampFormatted,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getBackupTypeColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getBackupTypeLabel(),
                    style: TextStyle(
                      color: _getBackupTypeColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Stats row
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _buildStatItem(
                  Icons.inventory_2_outlined,
                  '${backup.reservationCount} prenotazioni',
                ),
                _buildStatItem(
                  Icons.layers_outlined,
                  '${backup.platformCount} piattaforme',
                ),
                _buildStatItem(
                  Icons.meeting_room_outlined,
                  '${backup.roomCount} stanze',
                ),
                _buildStatItem(
                  Icons.storage_outlined,
                  backup.fileSizeFormatted,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Actions row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Condividi'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onRestore,
                  icon: const Icon(Icons.restore, size: 18),
                  label: const Text('Ripristina'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  tooltip: 'Elimina backup',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  IconData _getBackupTypeIcon() {
    switch (backup.backupType) {
      case 'daily':
        return Icons.today;
      case 'weekly':
        return Icons.calendar_view_week;
      default:
        return Icons.backup;
    }
  }

  Color _getBackupTypeColor() {
    switch (backup.backupType) {
      case 'daily':
        return Colors.blue;
      case 'weekly':
        return Colors.purple;
      default:
        return Colors.green;
    }
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
