import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';

/// Card displaying the next upcoming event (check-in or check-out).
class NextEventCountdownCard extends StatelessWidget {
  final List<Reservation> upcomingCheckIns;
  final List<Reservation> upcomingCheckOuts;
  final VoidCallback? onTap;

  const NextEventCountdownCard({
    super.key,
    required this.upcomingCheckIns,
    required this.upcomingCheckOuts,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextEvent = _getNextEvent();

    if (nextEvent == null) {
      return _buildEmptyState(theme);
    }

    return _buildEventCard(context, theme, nextEvent);
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Semantics(
      label: 'Nessun evento programmato',
      child: Card(
        key: const Key('next_event_countdown_card'),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 48,
                  color: Colors.grey[400],
                  semanticLabel: 'Nessun evento',
                ),
                const SizedBox(height: 12),
                Text(
                  'Nessun evento programmato',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    ThemeData theme,
    _NextEvent nextEvent,
  ) {
    final reservation = nextEvent.reservation;
    final isCheckIn = nextEvent.isCheckIn;

    final eventIcon = isCheckIn ? Icons.login : Icons.logout;
    final eventPrefix = isCheckIn ? 'Arrivo' : 'Partenza';
    final roomName = _getRoomDisplayName(reservation.roomId);

    return Semantics(
      label: '$eventPrefix ${_formatTimeRemaining(nextEvent.eventDate)}. ${reservation.guest.name}, $roomName',
      child: Card(
        key: const Key('next_event_countdown_card'),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with icon
                Row(
                  children: [
                    Icon(
                      eventIcon,
                      color: theme.colorScheme.primary,
                      semanticLabel: isCheckIn ? 'Arrivo' : 'Partenza',
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Prossimo Evento',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Event time
                Text(
                  '$eventPrefix ${_formatTimeRemaining(nextEvent.eventDate)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Guest and room
                Text(
                  '${reservation.guest.name} - $roomName',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _NextEvent? _getNextEvent() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get first check-in and check-out
    final firstCheckIn = upcomingCheckIns.isNotEmpty ? upcomingCheckIns.first : null;
    final firstCheckOut = upcomingCheckOuts.isNotEmpty ? upcomingCheckOuts.first : null;

    // If both are null, return null (no events)
    if (firstCheckIn == null && firstCheckOut == null) {
      return null;
    }

    // If only check-in exists
    if (firstCheckOut == null) {
      return _NextEvent(
        reservation: firstCheckIn!,
        eventDate: DateTime(
          firstCheckIn.checkIn.year,
          firstCheckIn.checkIn.month,
          firstCheckIn.checkIn.day,
        ),
        isCheckIn: true,
      );
    }

    // If only check-out exists
    if (firstCheckIn == null) {
      return _NextEvent(
        reservation: firstCheckOut,
        eventDate: DateTime(
          firstCheckOut.checkOut.year,
          firstCheckOut.checkOut.month,
          firstCheckOut.checkOut.day,
        ),
        isCheckIn: false,
      );
    }

    // Both exist - compare dates
    final checkInDate = DateTime(
      firstCheckIn.checkIn.year,
      firstCheckIn.checkIn.month,
      firstCheckIn.checkIn.day,
    );
    final checkOutDate = DateTime(
      firstCheckOut.checkOut.year,
      firstCheckOut.checkOut.month,
      firstCheckOut.checkOut.day,
    );

    // Return whichever is sooner
    if (checkInDate.isBefore(checkOutDate) || checkInDate.isAtSameMomentAs(checkOutDate)) {
      return _NextEvent(
        reservation: firstCheckIn,
        eventDate: checkInDate,
        isCheckIn: true,
      );
    } else {
      return _NextEvent(
        reservation: firstCheckOut,
        eventDate: checkOutDate,
        isCheckIn: false,
      );
    }
  }

  String _formatTimeRemaining(DateTime eventDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);

    final difference = eventDay.difference(today).inDays;

    if (difference == 0) {
      return 'tra oggi (Oggi)';
    } else if (difference == 1) {
      return 'tra 1 giorno (Domani)';
    } else {
      final day = eventDate.day;
      final month = _getItalianMonth(eventDate.month);
      return 'tra $difference giorni ($day $month)';
    }
  }

  String _getItalianMonth(int month) {
    const months = [
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
    ];
    return months[month - 1];
  }

  String _getRoomDisplayName(String roomId) {
    switch (roomId) {
      case 'room-1':
        return 'Stanza 1';
      case 'room-2':
        return 'Stanza 2';
      case 'room-3':
        return 'Stanza 3';
      case 'apartment':
        return 'Appartamento';
      default:
        return roomId;
    }
  }
}

/// Helper class to hold next event information.
class _NextEvent {
  final Reservation reservation;
  final DateTime eventDate;
  final bool isCheckIn;

  const _NextEvent({
    required this.reservation,
    required this.eventDate,
    required this.isCheckIn,
  });
}
