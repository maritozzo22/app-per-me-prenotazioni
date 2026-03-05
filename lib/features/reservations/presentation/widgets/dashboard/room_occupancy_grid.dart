import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';

/// Visual 2x2 grid showing occupancy status for each room.
class RoomOccupancyGrid extends StatelessWidget {
  final Map<String, Reservation?> roomOccupancy;

  const RoomOccupancyGrid({
    super.key,
    required this.roomOccupancy,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.5,
      children: Room.defaultRooms.map((room) {
        final reservation = roomOccupancy[room.id];
        final isOccupied = reservation != null;

        return _RoomStatusCard(
          room: room,
          isOccupied: isOccupied,
          reservation: reservation,
        );
      }).toList(),
    );
  }
}

class _RoomStatusCard extends StatelessWidget {
  final Room room;
  final bool isOccupied;
  final Reservation? reservation;

  const _RoomStatusCard({
    required this.room,
    required this.isOccupied,
    this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${room.name}: ${isOccupied ? 'Occupata da ${reservation?.guest.name}' : 'Libera'}',
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isOccupied ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isOccupied
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      room.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    isOccupied ? Icons.check_circle : Icons.circle_outlined,
                    color: isOccupied ? Colors.green : Colors.grey,
                    size: 20,
                    semanticLabel: isOccupied ? 'Occupata' : 'Libera',
                  ),
                ],
              ),
              if (isOccupied && reservation != null) ...[
                const SizedBox(height: 4),
                Text(
                  reservation!.guest.name,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
