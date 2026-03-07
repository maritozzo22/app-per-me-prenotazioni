import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/reservation_validation_service.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/dashboard_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_form.dart';
import 'package:app_prenotazioni/features/notifications/application/reservation_notification_scheduler.dart';
import 'package:app_prenotazioni/features/notifications/domain/services/notification_scheduler_service.dart';
import 'package:app_prenotazioni/core/platform/platform_service.dart';
import 'package:app_prenotazioni/features/notifications/domain/services/notification_scheduler_service.dart' show NotificationSchedulerServiceImpl;
import 'package:app_prenotazioni/features/notifications/presentation/providers/notification_permission_provider.dart';

/// Provider for notification scheduler
final reservationNotificationSchedulerProvider = Provider<ReservationNotificationScheduler>((ref) {
  final schedulerService = NotificationSchedulerServiceImpl();
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);

  return ReservationNotificationScheduler(
    schedulerService: schedulerService,
    notificationRepository: notificationRepository,
    notificationService: notificationService,
  );
});

/// Page for editing an existing reservation with PopScope for Android 14+.
class EditReservationPage extends ConsumerWidget {
  final Reservation reservation;

  const EditReservationPage({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(reservationRepositoryProvider);
    final validationService = ReservationValidationService(repository);

    return PopScope(
      canPop: true, // Allow back navigation for now
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Modifica Prenotazione'),
          elevation: 2,
        ),
        body: ReservationForm(
          existingReservation: reservation,
          rooms: Room.defaultRooms,
          platforms: BookingPlatform.defaultPlatforms,
          validationService: validationService,
          onSubmit: (updatedReservation) async {
            try {
              // Save the reservation
              await repository.saveReservation(updatedReservation);

              // Invalidate dashboard cache (statistics changed)
              final cacheService = ref.read(statisticsCacheServiceProvider);
              await cacheService.invalidateCache();

              // Schedule notifications (Android only)
              if (PlatformService.notificationsSupported) {
                try {
                  final scheduler = ref.read(reservationNotificationSchedulerProvider);
                  await scheduler.rescheduleReservationNotifications(updatedReservation);
                } catch (e) {
                  // Don't fail the save if notification scheduling fails
                  print('Error scheduling notifications: $e');
                }
              }

              return true;
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Errore: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return false;
            }
          },
        ),
      ),
    );
  }
}
