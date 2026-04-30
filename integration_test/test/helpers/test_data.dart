/// Test data fixtures for integration tests.
class TestData {
  /// Valid reservation data for testing.
  static const Map<String, dynamic> validReservation = {
    'guestName': 'Mario Rossi',
    'phone': '3331234567',
    'checkIn': '2026-03-10',
    'checkOut': '2026-03-15',
    'platform': 'Airbnb',
    'room': 'Room 1',
    'paymentStatus': 'Paid',
    'price': '500.00',
    'notes': 'Check-in after 3PM',
  };

  /// Second valid reservation for overlap testing.
  static const Map<String, dynamic> secondReservation = {
    'guestName': 'Giulia Bianchi',
    'phone': '3337654321',
    'checkIn': '2026-03-20',
    'checkOut': '2026-03-25',
    'platform': 'Booking',
    'room': 'Room 2',
    'paymentStatus': 'Pending',
    'price': '600.00',
    'notes': 'Late checkout requested',
  };

  /// Multiple reservations for performance testing.
  static const List<Map<String, dynamic>> multipleReservations = [
    {
      'guestName': 'Guest 1',
      'phone': '3331111111',
      'checkIn': '2026-03-01',
      'checkOut': '2026-03-05',
      'platform': 'Airbnb',
      'room': 'Room 1',
      'paymentStatus': 'Paid',
      'price': '400.00',
    },
    {
      'guestName': 'Guest 2',
      'phone': '3332222222',
      'checkIn': '2026-03-06',
      'checkOut': '2026-03-10',
      'platform': 'Booking',
      'room': 'Room 2',
      'paymentStatus': 'Pending',
      'price': '500.00',
    },
    {
      'guestName': 'Guest 3',
      'phone': '3333333333',
      'checkIn': '2026-03-11',
      'checkOut': '2026-03-15',
      'platform': 'WhatsApp',
      'room': 'Entire',
      'paymentStatus': 'Partially Paid',
      'price': '700.00',
    },
  ];

  /// Search queries for search testing.
  static const List<String> searchQueries = [
    'Mario',
    'Rossi',
    '333',
    'Airbnb',
    'Room',
  ];

  /// Edge cases for date testing.
  static const Map<String, String> edgeCases = {
    'one_night_checkin': '2026-03-10',
    'one_night_checkout': '2026-03-11',
    'long_reservation_checkin': '2026-03-01',
    'long_reservation_checkout': '2026-04-30',
    'year_boundary_checkin': '2026-12-28',
    'year_boundary_checkout': '2027-01-03',
  };

  /// Invalid data for validation testing.
  static const Map<String, dynamic> invalidReservation = {
    'guestName': '', // Empty name - should fail
    'phone': 'abc', // Invalid phone
    'checkIn': '2026-03-15', // After checkout
    'checkOut': '2026-03-10',
    'platform': '',
    'room': '',
    'price': 'not-a-number',
  };

  /// Platform names for testing.
  static const List<String> platforms = [
    'Airbnb',
    'Booking',
    'WhatsApp',
    'Vrbo',
    'Direct',
  ];

  /// Room names for testing.
  static const List<String> rooms = [
    'Room 1',
    'Room 2',
    'Entire',
  ];

  /// Payment statuses for testing.
  static const List<String> paymentStatuses = [
    'Pending',
    'Partially Paid',
    'Paid',
  ];

  /// Get a date relative to today.
  static String getRelativeDate(int daysFromNow) {
    final date = DateTime.now().add(Duration(days: daysFromNow));
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get check-in/checkout dates relative to today.
  static Map<String, String> getRelativeDateRange(int startDaysFromNow, int duration) {
    final checkIn = DateTime.now().add(Duration(days: startDaysFromNow));
    final checkOut = checkIn.add(Duration(days: duration));
    return {
      'checkIn': '${checkIn.year}-${checkIn.month.toString().padLeft(2, '0')}-${checkIn.day.toString().padLeft(2, '0')}',
      'checkOut': '${checkOut.year}-${checkOut.month.toString().padLeft(2, '0')}-${checkOut.day.toString().padLeft(2, '0')}',
    };
  }
}
