import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

/// Custom day cell widget for calendar with platform-colored background.
class ReservationDayCell extends StatelessWidget {
  final DateTime day;
  final List<Reservation> reservations;

  const ReservationDayCell({
    super.key,
    required this.day,
    required this.reservations,
  });

  /// Get the dominant platform color for the day.
  ///
  /// Strategy: Use the first reservation's platform color.
  /// Additional platforms are shown as colored dots in markerBuilder.
  Color _getPlatformColor() {
    if (reservations.isEmpty) {
      return Colors.transparent;
    }

    final platform = BookingPlatform.defaultPlatforms.firstWhere(
      (p) => p.id == reservations.first.platformId,
      orElse: () => BookingPlatform.defaultPlatforms.first,
    );

    return platform.color;
  }

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      // No reservations - use default day cell styling
      return const SizedBox.shrink();
    }

    final platformColor = _getPlatformColor();

    return Container(
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: platformColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: platformColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: platformColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Check if this cell should be rendered (has reservations).
  bool shouldRender() => reservations.isNotEmpty;
}
