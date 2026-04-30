import 'dart:math';

import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

/// Generates synthetic reservation data for performance testing.
///
/// Uses a fixed random seed (42) for reproducible test data generation.
/// Ensures no overlapping dates for reservations in the same room.
class TestDataGenerator {
  static Random _random = Random(42); // Fixed seed for reproducibility
  static int _idCounter = 0; // Counter for generating deterministic IDs

  /// Generate synthetic reservations for performance testing.
  ///
  /// [count] - Number of reservations to generate
  /// [startDate] - Starting date for date range (defaults to 1 year ago)
  /// [rooms] - Available rooms (defaults to Room.defaultRooms)
  /// [platforms] - Available platforms (defaults to BookingPlatform.defaultPlatforms)
  ///
  /// Returns a list of reservations with:
  /// - Unique IDs
  /// - Non-overlapping dates per room
  /// - Distributed across all rooms and platforms
  /// - Varied payment statuses
  /// - Realistic pricing (50-200 per night)
  /// - Stay duration 1-14 nights
  static List<Reservation> generateTestReservations(
    int count, {
    DateTime? startDate,
    List<Room>? rooms,
    List<BookingPlatform>? platforms,
  }) {
    // Reset counter and random for reproducibility
    _idCounter = 0;
    _random = Random(42);

    // If no startDate provided, use today as center point
    // This ensures dates span past, present, and future
    startDate ??= DateTime.now();
    rooms ??= Room.defaultRooms;
    platforms ??= BookingPlatform.defaultPlatforms;

    final reservations = <Reservation>[];
    final roomBookings = <String, List<_DateRange>>{};

    // Initialize room booking tracking
    for (final room in rooms) {
      roomBookings[room.id] = [];
    }

    for (int i = 0; i < count; i++) {
      final reservation = _generateReservation(
        startDate: startDate,
        rooms: rooms,
        platforms: platforms,
        roomBookings: roomBookings,
      );
      reservations.add(reservation);
    }

    return reservations;
  }

  static Reservation _generateReservation({
    required DateTime startDate,
    required List<Room> rooms,
    required List<BookingPlatform> platforms,
    required Map<String, List<_DateRange>> roomBookings,
  }) {
    // Select random room
    final room = rooms[_random.nextInt(rooms.length)];

    // Select random platform
    final platform = platforms[_random.nextInt(platforms.length)];

    // Generate non-overlapping date range for this room
    final dateRange = _generateNonOverlappingDateRange(
      startDate: startDate,
      roomBookings: roomBookings[room.id]!,
    );

    // Track this booking
    roomBookings[room.id]!.add(dateRange);

    // Generate deterministic ID based on counter
    final id = 'test-reservation-${_idCounter.toString().padLeft(5, '0')}';
    _idCounter++;

    // Generate guest with deterministic name
    final guest = Guest(
      name: 'Guest ${_idCounter.toString().padLeft(5, '0')}',
      phone: '+39 ${(_random.nextInt(1000000000)).toString().padLeft(9, '0')}',
    );

    // Generate payment status
    final paymentStatus = PaymentStatus.values[_random.nextInt(PaymentStatus.values.length)];

    // Calculate price (50-200 per night)
    final nights = dateRange.duration.inDays;
    final pricePerNight = 50.0 + _random.nextDouble() * 150.0;
    final totalPrice = pricePerNight * nights;

    return Reservation(
      id: id,
      roomId: room.id,
      platformId: platform.id,
      guest: guest,
      checkIn: dateRange.start,
      checkOut: dateRange.end,
      amount: totalPrice,
      paymentStatus: paymentStatus,
      notes: _random.nextBool() ? 'Test reservation $id' : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static _DateRange _generateNonOverlappingDateRange({
    required DateTime startDate,
    required List<_DateRange> roomBookings,
  }) {
    const maxAttempts = 100;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      // Random start date within 365 days BEFORE AND AFTER startDate
      // This ensures dates span past, present, and future
      final checkIn = startDate.add(Duration(days: _random.nextInt(730) - 365));

      // Random stay duration (1-14 nights)
      final nights = 1 + _random.nextInt(14);
      final checkOut = checkIn.add(Duration(days: nights));

      final proposedRange = _DateRange(start: checkIn, end: checkOut);

      // Check for overlaps with existing bookings
      final hasOverlap = roomBookings.any(
        (existing) => _rangesOverlap(proposedRange, existing),
      );

      if (!hasOverlap) {
        return proposedRange;
      }
    }

    // Fallback: append after last booking
    final lastBooking = roomBookings.isNotEmpty
        ? roomBookings.reduce((a, b) => a.start.isAfter(b.start) ? a : b)
        : _DateRange(start: startDate, end: startDate.add(const Duration(days: 1)));

    return _DateRange(
      start: lastBooking.end,
      end: lastBooking.end.add(Duration(days: 1 + _random.nextInt(14))),
    );
  }

  static bool _rangesOverlap(_DateRange a, _DateRange b) {
    // Overlap occurs if: a.start < b.end AND a.end > b.start
    // Adjacent dates (a.end == b.start) are NOT overlapping
    return a.start.isBefore(b.end) && a.end.isAfter(b.start);
  }
}

/// Simple date range helper class.
class _DateRange {
  final DateTime start;
  final DateTime end;

  _DateRange({required this.start, required this.end});

  Duration get duration => end.difference(start);
}
