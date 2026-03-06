import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_day_card.dart';
import 'package:app_prenotazioni/core/widgets/animations.dart';

/// Bottom sheet displaying reservations for a specific day.
class DayDetailBottomSheet extends StatelessWidget {
  final DateTime day;
  final List<Reservation> reservations;

  const DayDetailBottomSheet({
    super.key,
    required this.day,
    required this.reservations,
  });

  /// Show the bottom sheet for a specific day.
  static Future<void> show(
    BuildContext context, {
    required DateTime day,
    required List<Reservation> reservations,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DayDetailBottomSheet(
        day: day,
        reservations: reservations,
      ),
    );
  }

  /// Format the date for the header.
  String _formatDate() {
    // Format: "15 giugno 2024"
    return DateFormat('d MMMM yyyy', 'it_IT').format(day);
  }

  /// Format the weekday for the header.
  String _formatWeekday() {
    // Format: "Venerdì"
    return DateFormat('EEEE', 'it_IT').format(day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeIn(
      slide: SlideDirection.up,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and weekday
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prenotazioni',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatWeekday(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),

                  // Date
                  Text(
                    _formatDate(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Reservations list
            if (reservations.isEmpty)
              // Empty state
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nessuna prenotazione',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Questa data è libera',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            else
              // Reservations list with staggered animations
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: reservations.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    return FadeIn(
                      slide: SlideDirection.up,
                      duration: const Duration(milliseconds: 250),
                      delay: Duration(milliseconds: 50 * index),
                      curve: Curves.easeOut,
                      child: ReservationDayCard(
                        reservation: reservations[index],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    ));
  }
}
