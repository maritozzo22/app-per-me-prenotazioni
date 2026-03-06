import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

/// Sample test data for backup testing.
/// Contains 15 realistic reservations with various scenarios.
class BackupTestData {
  /// Creates a list of sample reservations for testing.
  static List<Reservation> createSampleReservations() {
    return [
      // Past reservations
      Reservation(
        id: 'test-res-001',
        roomId: 'room-1',
        platformId: 'airbnb',
        guest: const Guest(name: 'Mario Rossi', phone: '+39 333 1234567'),
        checkIn: DateTime(2026, 2, 10),
        checkOut: DateTime(2026, 2, 15),
        amount: 350.00,
        paymentStatus: PaymentStatus.received,
        notes: 'Ottimo ospite, molto puntuale',
        createdAt: DateTime(2026, 2, 1),
        updatedAt: DateTime(2026, 2, 15),
      ),
      Reservation(
        id: 'test-res-002',
        roomId: 'room-2',
        platformId: 'booking',
        guest: const Guest(name: 'Giulia Bianchi', phone: '+39 334 2345678'),
        checkIn: DateTime(2026, 2, 12),
        checkOut: DateTime(2026, 2, 18),
        amount: 420.00,
        paymentStatus: PaymentStatus.received,
        notes: '',
        createdAt: DateTime(2026, 2, 5),
        updatedAt: DateTime(2026, 2, 18),
      ),
      Reservation(
        id: 'test-res-003',
        roomId: 'apartment',
        platformId: 'whatsapp',
        guest: const Guest(name: 'Luca Verdi', phone: '+39 335 3456789'),
        checkIn: DateTime(2026, 2, 20),
        checkOut: DateTime(2026, 2, 25),
        amount: 750.00,
        paymentStatus: PaymentStatus.pending,
        notes: 'Ha pagato caparra di 200 euro, saldo al check-in',
        createdAt: DateTime(2026, 2, 10),
        updatedAt: DateTime(2026, 2, 25),
      ),

      // Current reservations (March 2026)
      Reservation(
        id: 'test-res-004',
        roomId: 'room-1',
        platformId: 'airbnb',
        guest: const Guest(name: 'Anna Neri', phone: '+39 336 4567890'),
        checkIn: DateTime(2026, 3, 5),
        checkOut: DateTime(2026, 3, 10),
        amount: 300.00,
        paymentStatus: PaymentStatus.received,
        notes: 'Richiesta culla per bambino',
        createdAt: DateTime(2026, 2, 28),
        updatedAt: DateTime(2026, 3, 5),
      ),
      Reservation(
        id: 'test-res-005',
        roomId: 'room-2',
        platformId: 'booking',
        guest: const Guest(name: 'Paolo Gialli', phone: '+39 337 5678901'),
        checkIn: DateTime(2026, 3, 8),
        checkOut: DateTime(2026, 3, 12),
        amount: 280.00,
        paymentStatus: PaymentStatus.pending,
        notes: 'Arrivo previsto per le 18:00',
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      ),
      Reservation(
        id: 'test-res-006',
        roomId: 'room-3',
        platformId: 'website',
        guest: const Guest(name: 'Elena Blu', phone: '+39 338 6789012'),
        checkIn: DateTime(2026, 3, 10),
        checkOut: DateTime(2026, 3, 15),
        amount: 320.00,
        paymentStatus: PaymentStatus.received,
        notes: '',
        createdAt: DateTime(2026, 3, 2),
        updatedAt: DateTime(2026, 3, 10),
      ),

      // Future reservations
      Reservation(
        id: 'test-res-007',
        roomId: 'apartment',
        platformId: 'airbnb',
        guest: const Guest(name: 'Marco Ferrari', phone: '+39 339 7890123'),
        checkIn: DateTime(2026, 3, 15),
        checkOut: DateTime(2026, 3, 22),
        amount: 1050.00,
        paymentStatus: PaymentStatus.pending,
        notes: 'Famiglia con 2 bambini, richiede early check-in',
        createdAt: DateTime(2026, 3, 5),
        updatedAt: DateTime(2026, 3, 5),
      ),
      Reservation(
        id: 'test-res-008',
        roomId: 'room-1',
        platformId: 'whatsapp',
        guest: const Guest(name: 'Sara Colombo', phone: '+39 340 8901234'),
        checkIn: DateTime(2026, 3, 18),
        checkOut: DateTime(2026, 3, 21),
        amount: 180.00,
        paymentStatus: PaymentStatus.pending,
        notes: 'Viaggio di lavoro',
        createdAt: DateTime(2026, 3, 8),
        updatedAt: DateTime(2026, 3, 8),
      ),
      Reservation(
        id: 'test-res-009',
        roomId: 'room-2',
        platformId: 'booking',
        guest: const Guest(name: 'Andrea Russo', phone: '+39 341 9012345'),
        checkIn: DateTime(2026, 3, 20),
        checkOut: DateTime(2026, 3, 25),
        amount: 350.00,
        paymentStatus: PaymentStatus.received,
        notes: 'Coppia sposata, luna di miele',
        createdAt: DateTime(2026, 3, 10),
        updatedAt: DateTime(2026, 3, 10),
      ),
      Reservation(
        id: 'test-res-010',
        roomId: 'room-3',
        platformId: 'airbnb',
        guest: const Guest(name: 'Chiara Romano', phone: '+39 342 0123456'),
        checkIn: DateTime(2026, 3, 22),
        checkOut: DateTime(2026, 3, 26),
        amount: 280.00,
        paymentStatus: PaymentStatus.pending,
        notes: '',
        createdAt: DateTime(2026, 3, 12),
        updatedAt: DateTime(2026, 3, 12),
      ),

      // April 2026 reservations
      Reservation(
        id: 'test-res-011',
        roomId: 'apartment',
        platformId: 'website',
        guest: const Guest(name: 'Davide Moretti', phone: '+39 343 1234567'),
        checkIn: DateTime(2026, 4, 1),
        checkOut: DateTime(2026, 4, 5),
        amount: 600.00,
        paymentStatus: PaymentStatus.received,
        notes: 'Pasqua con famiglia',
        createdAt: DateTime(2026, 3, 15),
        updatedAt: DateTime(2026, 3, 15),
      ),
      Reservation(
        id: 'test-res-012',
        roomId: 'room-1',
        platformId: 'booking',
        guest: const Guest(name: 'Francesca Costa', phone: '+39 344 2345678'),
        checkIn: DateTime(2026, 4, 5),
        checkOut: DateTime(2026, 4, 10),
        amount: 300.00,
        paymentStatus: PaymentStatus.pending,
        notes: 'Caparra ricevuta via bonifico',
        createdAt: DateTime(2026, 3, 18),
        updatedAt: DateTime(2026, 3, 18),
      ),
      Reservation(
        id: 'test-res-013',
        roomId: 'room-2',
        platformId: 'whatsapp',
        guest: const Guest(name: 'Simone Fontana', phone: '+39 345 3456789'),
        checkIn: DateTime(2026, 4, 8),
        checkOut: DateTime(2026, 4, 12),
        amount: 280.00,
        paymentStatus: PaymentStatus.pending,
        notes: 'Collega di lavoro di Mario Rossi',
        createdAt: DateTime(2026, 3, 20),
        updatedAt: DateTime(2026, 3, 20),
      ),
      Reservation(
        id: 'test-res-014',
        roomId: 'room-3',
        platformId: 'airbnb',
        guest: const Guest(name: 'Valentina Rizzo', phone: '+39 346 4567890'),
        checkIn: DateTime(2026, 4, 10),
        checkOut: DateTime(2026, 4, 15),
        amount: 320.00,
        paymentStatus: PaymentStatus.received,
        notes: '',
        createdAt: DateTime(2026, 3, 22),
        updatedAt: DateTime(2026, 3, 22),
      ),
      Reservation(
        id: 'test-res-015',
        roomId: 'apartment',
        platformId: 'tiktok',
        guest: const Guest(name: 'Alessandro Conti', phone: '+39 347 5678901'),
        checkIn: DateTime(2026, 4, 15),
        checkOut: DateTime(2026, 4, 20),
        amount: 900.00,
        paymentStatus: PaymentStatus.pending,
        notes: 'Content creator, richiede permesso per video',
        createdAt: DateTime(2026, 3, 25),
        updatedAt: DateTime(2026, 3, 25),
      ),
    ];
  }

  /// Gets a summary of the test data.
  static String getTestDataSummary() {
    final reservations = createSampleReservations();

    final platformCounts = <String, int>{};
    var receivedCount = 0;
    var pendingCount = 0;

    for (final res in reservations) {
      platformCounts[res.platformId] = (platformCounts[res.platformId] ?? 0) + 1;
      switch (res.paymentStatus) {
        case PaymentStatus.received:
          receivedCount++;
          break;
        case PaymentStatus.pending:
          pendingCount++;
          break;
      }
    }

    return '''
Test Data Summary:
- Total reservations: ${reservations.length}
- By platform: ${platformCounts.entries.map((e) => '${e.key}: ${e.value}').join(', ')}
- By payment status: Received=$receivedCount, Pending=$pendingCount
- Date range: ${reservations.first.checkIn.toString().substring(0, 10)} to ${reservations.last.checkOut.toString().substring(0, 10)}
''';
  }
}
