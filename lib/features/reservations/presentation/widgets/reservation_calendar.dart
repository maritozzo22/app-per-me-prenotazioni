import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/calendar_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_day_cell.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/day_detail_bottom_sheet.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/multi_reservation_indicator.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/edit_reservation_page.dart';
import 'package:app_prenotazioni/core/platform/platform_service.dart';

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
  DateTime? _previousMonth; // Track for haptic feedback

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _previousMonth = DateTime.now();
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
                onReservationTap: (reservation) {
                  // Close bottom sheet first
                  Navigator.of(context).pop();

                  // Navigate to edit page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditReservationPage(reservation: reservation),
                    ),
                  );
                },
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
            final newMonth = DateTime(focusedDay.year, focusedDay.month);
            final oldMonth = _previousMonth ?? DateTime(_focusedDay.year, _focusedDay.month);

            // Trigger haptic feedback on month change (Android only)
            if (newMonth != oldMonth && PlatformService.isAndroid) {
              HapticFeedback.lightImpact();
            }

            _previousMonth = newMonth;
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
                return null;
              }

              return RepaintBoundary(
                child: ReservationDayCell(
                  day: day,
                  reservations: reservations,
                ),
              );
            },

            // Outside days (from previous/next month visible in grid)
            outsideBuilder: (context, day, focusedDay) {
              final normalizedDay = DateTime(day.year, day.month, day.day);
              final reservations = calendarState.reservationsByDate[normalizedDay] ?? [];

              if (reservations.isEmpty) {
                return null;
              }

              return RepaintBoundary(
                child: Opacity(
                  opacity: 0.5,
                  child: ReservationDayCell(
                    day: day,
                    reservations: reservations,
                  ),
                ),
              );
            },

            // Marker builder for multiple reservations
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return const SizedBox.shrink();

              final reservations = events as List<Reservation>;

              // Only show indicator if more than 1 reservation
              // (single reservation is shown via day cell background)
              if (reservations.length <= 1) return const SizedBox.shrink();

              return Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Center(
                  child: MultiReservationIndicator(
                    reservations: reservations,
                    maxDots: 4,
                    dotSize: 5.0,
                    spacing: 1.0,
                  ),
                ),
              );
            },

            // Today marker - combined with reservation styling when bookings exist
            todayBuilder: (context, day, focusedDay) {
              final normalizedDay = DateTime(day.year, day.month, day.day);
              final reservations = calendarState.reservationsByDate[normalizedDay] ?? [];

              if (reservations.isEmpty) {
                // No reservations - show default today indicator
                return Container(
                  margin: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: 1,
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
              }

              // Reservations present - combine today border with platform color
              final platform = BookingPlatform.defaultPlatforms.firstWhere(
                (p) => p.id == reservations.first.platformId,
                orElse: () => BookingPlatform.defaultPlatforms.first,
              );
              final platformColor = platform.color;

              return Container(
                margin: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: platformColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Colors.blue,
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
            },
          ),

          // Week starts on Monday (Italy standard)
          startingDayOfWeek: StartingDayOfWeek.monday,

          // Enable horizontal swipe only for month navigation
          availableGestures: AvailableGestures.horizontalSwipe,
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
