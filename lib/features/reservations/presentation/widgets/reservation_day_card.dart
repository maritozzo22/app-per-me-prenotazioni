import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

/// Card displaying reservation details in a compact format.
class ReservationDayCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onTap;

  const ReservationDayCard({
    super.key,
    required this.reservation,
    this.onTap,
  });

  /// Get room name by ID.
  String _getRoomName() {
    final room = Room.defaultRooms.firstWhere(
      (r) => r.id == reservation.roomId,
      orElse: () => Room.defaultRooms.first,
    );
    return room.name;
  }

  /// Get platform by ID.
  BookingPlatform _getPlatform() {
    return BookingPlatform.defaultPlatforms.firstWhere(
      (p) => p.id == reservation.platformId,
      orElse: () => BookingPlatform.defaultPlatforms.first,
    );
  }

  /// Format date range for display.
  String _formatDateRange() {
    final formatter = DateFormat('dd MMM', 'it_IT');
    final checkIn = formatter.format(reservation.checkIn);
    final checkOut = formatter.format(reservation.checkOut);
    return '$checkIn - $checkOut';
  }

  /// Get payment status icon and color.
  ({IconData icon, Color color}) _getPaymentStatusData() {
    switch (reservation.paymentStatus) {
      case PaymentStatus.received:
        return (icon: Icons.check_circle, color: Colors.green);
      case PaymentStatus.pending:
        return (icon: Icons.pending, color: Colors.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final platform = _getPlatform();
    final roomName = _getRoomName();
    final paymentData = _getPaymentStatusData();

    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guest name (primary)
            Text(
              reservation.guest.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            // Room and platform row
            Row(
              children: [
                // Platform indicator
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: platform.color,
                    shape: BoxShape.circle,
                  ),
                ),

                // Platform name
                Text(
                  platform.name,
                  style: TextStyle(
                    color: platform.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                // Room name
                Icon(
                  Icons.bed,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  roomName,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Date range
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateRange(),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${reservation.numberOfNights} nott${reservation.numberOfNights == 1 ? 'e' : 'i'})',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            // Payment status and amount (if available)
            if (reservation.amount != null || reservation.paymentStatus != PaymentStatus.pending)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      paymentData.icon,
                      size: 16,
                      color: paymentData.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      reservation.paymentStatus == PaymentStatus.received
                          ? 'Pagato'
                          : 'In attesa',
                      style: TextStyle(
                        color: paymentData.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (reservation.amount != null) ...[
                      const Spacer(),
                      Text(
                        '€ ${reservation.amount!.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Notes (if available)
            if (reservation.notes != null && reservation.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.note,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        reservation.notes!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );

    // Wrap with InkWell for tap feedback if onTap is provided
    if (onTap == null) {
      return card;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: card,
    );
  }
}
