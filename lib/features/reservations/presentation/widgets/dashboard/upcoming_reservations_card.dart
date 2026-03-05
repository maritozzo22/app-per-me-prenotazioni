import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:intl/intl.dart';

/// Card showing upcoming check-ins or check-outs.
class UpcomingReservationsCard extends StatelessWidget {
  final String title;
  final List<Reservation> reservations;
  final bool showCheckOutDate;

  const UpcomingReservationsCard({
    super.key,
    required this.title,
    required this.reservations,
    this.showCheckOutDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (reservations.isEmpty)
              _buildEmptyState(context)
            else
              _buildReservationsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'Nessuna prenotazione',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      ),
    );
  }

  Widget _buildReservationsList(BuildContext context) {
    return Column(
      children: reservations.take(5).map((reservation) {
        return _ReservationItem(
          reservation: reservation,
          showCheckOutDate: showCheckOutDate,
        );
      }).toList(),
    );
  }
}

class _ReservationItem extends StatelessWidget {
  final Reservation reservation;
  final bool showCheckOutDate;

  const _ReservationItem({
    required this.reservation,
    this.showCheckOutDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final platform = BookingPlatform.defaultPlatforms.firstWhere(
      (p) => p.id == reservation.platformId,
      orElse: () => BookingPlatform.defaultPlatforms.first,
    );
    final room = Room.defaultRooms.firstWhere(
      (r) => r.id == reservation.roomId,
      orElse: () => Room.defaultRooms.first,
    );
    final date = showCheckOutDate ? reservation.checkOut : reservation.checkIn;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Platform color indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: platform.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Guest and room info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.guest.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  room.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Date
          Text(
            DateFormat('dd/MM').format(date),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
