import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

/// Tile widget for displaying a platform in the platforms list
class PlatformListTile extends StatelessWidget {
  final BookingPlatform platform;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PlatformListTile({
    super.key,
    required this.platform,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: platform.color,
        child: Icon(
          Icons.hotel,
          color: _getContrastColor(platform.color),
        ),
      ),
      title: Row(
        children: [
          Text(platform.name),
          if (platform.isSystem) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Text(
                'System',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        'Colore: ${_getColorName(platform.color)}',
        style: TextStyle(
          color: platform.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Modifica',
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              tooltip: 'Elimina',
              color: Colors.red,
            ),
        ],
      ),
      onTap: onTap,
    );
  }

  /// Calculate contrast color (black or white) based on background color
  Color _getContrastColor(Color color) {
    // Calculate luminance
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Get a human-readable color name
  String _getColorName(Color color) {
    // Simple color name mapping for common colors
    if (color.value == Color(0xFF2196F3).value) return 'Blu';
    if (color.value == Color(0xFFE91E63).value) return 'Rosa';
    if (color.value == Color(0xFF4CAF50).value) return 'Verde';
    if (color.value == Color(0xFF9C27B0).value) return 'Viola';
    if (color.value == Color(0xFF212121).value) return 'Nero';
    if (color.value == Color(0xFFFF9800).value) return 'Arancione';
    if (color.value == Color(0xFF3F51B5).value) return 'Indaco';
    if (color.value == Color(0xFF009688).value) return 'Turchese';
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
