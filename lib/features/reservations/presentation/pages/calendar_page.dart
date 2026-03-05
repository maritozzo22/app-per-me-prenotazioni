import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/calendar_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_calendar.dart';

/// Calendar page showing monthly reservation view.
class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario Prenotazioni'),
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return ref.read(calendarProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Calendar widget
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: calendarState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ReservationCalendar(
                        onDaySelected: (selectedDay, focusedDay) {
                          // Bottom sheet is shown automatically by ReservationCalendar
                        },
                        onPageChanged: () {
                          // Month changed - could load more data if needed
                        },
                      ),
              ),

              // Info section below calendar
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Seleziona un giorno per vedere le prenotazioni',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Trascina per navigare tra i mesi',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
