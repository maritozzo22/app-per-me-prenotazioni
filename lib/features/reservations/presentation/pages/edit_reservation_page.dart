import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/reservation_validation_service.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_form.dart';

/// Page for editing an existing reservation.
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

    return Scaffold(
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
            await repository.saveReservation(updatedReservation);
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
    );
  }
}
