import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

/// Swipeable list tile for a reservation with edit and delete actions.
class ReservationListTile extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReservationListTile({
    super.key,
    required this.reservation,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(reservation.id),
      // Left swipe: Edit
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Modifica',
            autoClose: true,
          ),
        ],
      ),
      // Right swipe: Delete
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _confirmDelete(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Elimina',
            autoClose: true,
          ),
        ],
      ),
      child: Semantics(
        button: true,
        label: 'Prenotazione per ${reservation.guest.name}',
        hint: 'Tocca per vedere i dettagli della prenotazione, modificare o eliminare',
        child: InkWell(
          onTap: onEdit,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final platform = BookingPlatform.defaultPlatforms.firstWhere(
      (p) => p.id == reservation.platformId,
      orElse: () => BookingPlatform.defaultPlatforms.first,
    );
    final room = Room.defaultRooms.firstWhere(
      (r) => r.id == reservation.roomId,
      orElse: () => Room.defaultRooms.first,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Platform color indicator
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: platform.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.guest.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.bed,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      room.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateRange(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Payment status
          Icon(
            reservation.paymentStatus.icon,
            color: reservation.paymentStatus.color,
            size: 24,
            semanticLabel: reservation.paymentStatus.label,
          ),
        ],
      ),
    );
  }

  String _formatDateRange() {
    final checkIn = DateFormat('dd/MM').format(reservation.checkIn);
    final checkOut = DateFormat('dd/MM').format(reservation.checkOut);
    return '$checkIn - $checkOut';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Eliminare la prenotazione di ${reservation.guest.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}
