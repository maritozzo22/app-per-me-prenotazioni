import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

/// Widget showing multiple reservation indicators as colored dots.
///
/// Shows up to 4 dots representing different platforms.
/// If more than 4 reservations, shows "+X" indicator.
class MultiReservationIndicator extends StatelessWidget {
  final List<Reservation> reservations;
  final int maxDots;
  final double dotSize;
  final double spacing;

  const MultiReservationIndicator({
    super.key,
    required this.reservations,
    this.maxDots = 4,
    this.dotSize = 6.0,
    this.spacing = 1.0,
  });

  /// Get platform color for a reservation.
  Color _getPlatformColor(Reservation reservation) {
    final platform = BookingPlatform.defaultPlatforms.firstWhere(
      (p) => p.id == reservation.platformId,
      orElse: () => BookingPlatform.defaultPlatforms.first,
    );
    return platform.color;
  }

  /// Whether to show the overflow indicator.
  bool get _showOverflow => reservations.length > maxDots;

  /// Number of additional reservations beyond maxDots.
  int get _overflowCount => reservations.length - maxDots;

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Colored dots
        ...reservations.take(maxDots).map((reservation) {
          return Container(
            width: dotSize,
            height: dotSize,
            margin: EdgeInsets.symmetric(horizontal: spacing),
            decoration: BoxDecoration(
              color: _getPlatformColor(reservation),
              shape: BoxShape.circle,
            ),
          );
        }),

        // Overflow indicator "+X"
        if (_showOverflow)
          Padding(
            padding: EdgeInsets.only(left: spacing * 2),
            child: Text(
              '+$_overflowCount',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
      ],
    );
  }
}
