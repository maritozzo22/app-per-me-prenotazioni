import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';

/// Service for searching reservations.
class SearchService {
  final ReservationRepository _reservationRepository;

  SearchService(this._reservationRepository);

  /// Searches reservations by guest name, phone, or notes.
  ///
  /// The search is case-insensitive and checks all text fields:
  /// - guestName
  /// - guestPhone
  /// - notes
  ///
  /// Returns a list of reservations matching the search query.
  /// Returns an empty list if no matches are found or if query is empty.
  Future<List<Reservation>> search(String query) async {
    // If query is empty, return all reservations
    if (query.trim().isEmpty) {
      return await _reservationRepository.getAllReservations();
    }

    // Get all reservations
    final allReservations = await _reservationRepository.getAllReservations();

    // Filter by search query (case-insensitive)
    final lowerQuery = query.toLowerCase().trim();

    return allReservations.where((reservation) {
      // Search in guest name
      final nameMatch = reservation.guest.name.toLowerCase().contains(lowerQuery);

      // Search in guest phone (if available)
      final phoneMatch = reservation.guest.phone != null &&
          reservation.guest.phone!.toLowerCase().contains(lowerQuery);

      // Search in notes (if available)
      final notesMatch = reservation.notes != null &&
          reservation.notes!.toLowerCase().contains(lowerQuery);

      return nameMatch || phoneMatch || notesMatch;
    }).toList();
  }
}
