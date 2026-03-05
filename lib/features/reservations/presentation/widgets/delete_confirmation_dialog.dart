import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final Reservation reservation;
  final List<Room> rooms;

  const DeleteConfirmationDialog({
    super.key,
    required this.reservation,
    required this.rooms,
  });

  @override
  Widget build(BuildContext context) {
    final roomName = rooms.firstWhere(
      (r) => r.id == reservation.roomId,
      orElse: () => Room(
        id: reservation.roomId,
        name: reservation.roomId,
        type: RoomType.singleRoom,
        createdAt: DateTime.now(),
      ),
    ).name;

    return AlertDialog(
      title: const Text('Eliminare la prenotazione?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Ospite', reservation.guest.name),
          const SizedBox(height: 8),
          _buildDetailRow('Stanza', roomName),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Date',
            '${_formatDate(reservation.checkIn)} - ${_formatDate(reservation.checkOut)}',
          ),
          if (reservation.amount != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              'Importo',
              '€${reservation.amount!.toStringAsFixed(2)}',
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Elimina'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Shows delete confirmation dialog and returns true if confirmed.
Future<bool> showDeleteConfirmation({
  required BuildContext context,
  required Reservation reservation,
  required List<Room> rooms,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => DeleteConfirmationDialog(
      reservation: reservation,
      rooms: rooms,
    ),
  );
  return result ?? false;
}
