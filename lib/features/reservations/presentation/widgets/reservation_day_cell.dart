import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/core/widgets/animations.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/multi_reservation_indicator.dart';

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
    final platform = BookingPlatform.defaultPlatforms.firstWhere(
      (p) => p.id == reservations.first.platformId,
      orElse: () => BookingPlatform.defaultPlatforms.first,
    );

    // Build semantic label for screen readers
    final semanticLabel = _buildSemanticLabel(platform);

    return Semantics(
      label: semanticLabel,
      hint: 'Tocca per vedere i dettagli delle prenotazioni',
      button: true,
      child: ScaleIn(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        beginScale: 0.8,
        child: Container(
          margin: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: platformColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: platformColor,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Day number
              Text(
                '${day.day}',
                style: TextStyle(
                  color: platformColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Multi-reservation indicator (only if more than 1)
              if (reservations.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: MultiReservationIndicator(
                    reservations: reservations,
                    maxDots: 4,
                    dotSize: 4.0,
                    spacing: 0.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build semantic label for accessibility
  String _buildSemanticLabel(BookingPlatform platform) {
    final dateStr = '${day.day} ${_getMonthName(day.month)}';
    if (reservations.length == 1) {
      return '$dateStr, ${reservations.first.guest.name}, ${platform.name}';
    } else {
      return '$dateStr, ${reservations.length} prenotazioni, prima: ${reservations.first.guest.name}';
    }
  }

  /// Get month name in Italian
  String _getMonthName(int month) {
    const months = [
      'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
      'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'
    ];
    return months[month - 1];
  }

  /// Check if this cell should be rendered (has reservations).
  bool shouldRender() => reservations.isNotEmpty;
}
