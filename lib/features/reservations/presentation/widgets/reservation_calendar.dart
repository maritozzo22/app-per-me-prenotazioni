import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/calendar_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_day_cell.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/day_detail_bottom_sheet.dart';

/// Calendar widget showing reservations with platform-colored days.
class ReservationCalendar extends ConsumerStatefulWidget {
  final void Function(DateTime selectedDay, DateTime focusedDay)? onDaySelected;
  final VoidCallback? onPageChanged;

  const ReservationCalendar({
    super.key,
    this.onDaySelected,
    this.onPageChanged,
  });

  @override
  ConsumerState<ReservationCalendar> createState() => _ReservationCalendarState();
}

class _ReservationCalendarState extends ConsumerState<ReservationCalendar> {
  late CalendarFormat _calendarFormat;
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarProvider);
    final calendarNotifier = ref.read(calendarProvider.notifier);

    // Show error state if there's an error
    if (calendarState.error != null) {
      return _buildErrorState(calendarState.error!, calendarNotifier);
    }

    // Show loading state
    if (calendarState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Update focused day when provider changes
    if (_focusedDay != calendarState.focusedDay) {
      _focusedDay = calendarState.focusedDay;
    }

    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final calendarWidth = screenWidth > 1200 ? 1000.0 : screenWidth - 32.0;

    return Center(
      child: SizedBox(
        width: calendarWidth,
        child: RepaintBoundary(
          child: TableCalendar(
          // Locale settings
          locale: 'it_IT',

          // Date range
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,

          // Selection
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            // Update provider
            calendarNotifier.selectDay(selectedDay);
            calendarNotifier.changeMonth(focusedDay);

            // Call callback first
            widget.onDaySelected?.call(selectedDay, focusedDay);

            // Show bottom sheet with day details
            final normalizedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
            final reservations = calendarState.reservationsByDate[normalizedDay] ?? [];

            // Use post-frame callback to show bottom sheet after tap animation
            WidgetsBinding.instance.addPostFrameCallback((_) {
              DayDetailBottomSheet.show(
                context,
                day: selectedDay,
                reservations: reservations,
              );
            });
          },

          // Format
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },

          // Page navigation
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
            calendarNotifier.changeMonth(focusedDay);
            widget.onPageChanged?.call();
          },

          // Events
          eventLoader: (day) {
            final normalizedDay = DateTime(day.year, day.month, day.day);
            return calendarState.reservationsByDate[normalizedDay] ?? [];
          },

          // Style
          calendarStyle: CalendarStyle(
            // Today marker
            todayDecoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),

            // Selected day
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),

            // Default day
            defaultDecoration: const BoxDecoration(),
            defaultTextStyle: const TextStyle(
              color: Colors.black87,
            ),

            // Outside month days
            outsideDecoration: BoxDecoration(
              color: Colors.grey[100],
            ),
            outsideTextStyle: TextStyle(
              color: Colors.grey[400],
            ),

            // Weekend
            weekendDecoration: const BoxDecoration(),
            weekendTextStyle: TextStyle(
              color: Colors.red[700],
            ),

            // Markers
            markersMaxCount: 3,
            markerDecoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
          ),

          // Header style
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
            weekendStyle: TextStyle(
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),

          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: const Icon(Icons.chevron_left, semanticLabel: 'Mese precedente'),
            rightChevronIcon: const Icon(Icons.chevron_right, semanticLabel: 'Mese successivo'),
          ),

          // Custom builders
          calendarBuilders: CalendarBuilders(
            // Custom day cell for platform-colored background
            defaultBuilder: (context, day, focusedDay) {
              final normalizedDay = DateTime(day.year, day.month, day.day);
              final reservations = calendarState.reservationsByDate[normalizedDay] ?? [];

              if (reservations.isEmpty) {
                // Use default styling for days without reservations
                return null;
              }

              // Use custom day cell with platform color
              return RepaintBoundary(
                child: ReservationDayCell(
                  day: day,
                  reservations: reservations,
                ),
              );
            },

            // Marker builder for multiple reservations
            markerBuilder: (context, day, events) {
              if (events.length <= 1) return const SizedBox.shrink();

              final reservations = events as List<Reservation>;

              // Show colored dots for additional platforms (max 3)
              return Positioned(
                bottom: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: reservations.take(3).map((reservation) {
                    final platform = BookingPlatform.defaultPlatforms.firstWhere(
                      (p) => p.id == reservation.platformId,
                      orElse: () => BookingPlatform.defaultPlatforms.first,
                    );
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: platform.color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
              );
            },

            // Default today marker
            todayBuilder: (context, day, focusedDay) {
              final normalizedDay = DateTime(day.year, day.month, day.day);
              final reservations = calendarState.reservationsByDate[normalizedDay] ?? [];

              // Combine today marker with reservation marker
              return Container(
                margin: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue,
                    width: reservations.isEmpty ? 1 : 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),

          // Week starts on Monday (Italy standard)
          startingDayOfWeek: StartingDayOfWeek.monday,
        ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, CalendarNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Errore nel caricamento',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => notifier.retry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Riprova'),
            ),
          ],
        ),
      ),
    );
  }
}
