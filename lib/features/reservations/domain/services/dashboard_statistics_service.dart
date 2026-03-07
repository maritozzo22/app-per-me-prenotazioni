import 'dart:convert';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

/// Statistics calculated for the dashboard.
class DashboardStatistics {
  final int occupiedRoomsToday;
  final int totalRooms;
  final double monthlyIncomeReceived;
  final double monthlyIncomePending;
  final List<Reservation> upcomingCheckIns;
  final List<Reservation> upcomingCheckOuts;

  const DashboardStatistics({
    required this.occupiedRoomsToday,
    required this.totalRooms,
    required this.monthlyIncomeReceived,
    required this.monthlyIncomePending,
    required this.upcomingCheckIns,
    required this.upcomingCheckOuts,
  });

  double get occupancyRate => totalRooms > 0 ? occupiedRoomsToday / totalRooms : 0;
  double get totalMonthlyIncome => monthlyIncomeReceived + monthlyIncomePending;

  /// Serialize to JSON for caching.
  Map<String, dynamic> toJson() => {
        'occupiedRoomsToday': occupiedRoomsToday,
        'totalRooms': totalRooms,
        'monthlyIncomeReceived': monthlyIncomeReceived,
        'monthlyIncomePending': monthlyIncomePending,
        'upcomingCheckIns': upcomingCheckIns
            .map((r) => {
                  'id': r.id,
                  'roomId': r.roomId,
                  'platformId': r.platformId,
                  'guest': {'name': r.guest.name, 'phone': r.guest.phone},
                  'checkIn': r.checkIn.toIso8601String(),
                  'checkOut': r.checkOut.toIso8601String(),
                  'amount': r.amount,
                  'paymentStatus': r.paymentStatus.name,
                  'notes': r.notes,
                  'createdAt': r.createdAt.toIso8601String(),
                  'updatedAt': r.updatedAt.toIso8601String(),
                })
            .toList(),
        'upcomingCheckOuts': upcomingCheckOuts
            .map((r) => {
                  'id': r.id,
                  'roomId': r.roomId,
                  'platformId': r.platformId,
                  'guest': {'name': r.guest.name, 'phone': r.guest.phone},
                  'checkIn': r.checkIn.toIso8601String(),
                  'checkOut': r.checkOut.toIso8601String(),
                  'amount': r.amount,
                  'paymentStatus': r.paymentStatus.name,
                  'notes': r.notes,
                  'createdAt': r.createdAt.toIso8601String(),
                  'updatedAt': r.updatedAt.toIso8601String(),
                })
            .toList(),
      };

  /// Deserialize from JSON.
  factory DashboardStatistics.fromJson(Map<String, dynamic> json) =>
      DashboardStatistics(
        occupiedRoomsToday: json['occupiedRoomsToday'] as int,
        totalRooms: json['totalRooms'] as int,
        monthlyIncomeReceived: (json['monthlyIncomeReceived'] as num).toDouble(),
        monthlyIncomePending: (json['monthlyIncomePending'] as num).toDouble(),
        upcomingCheckIns: (json['upcomingCheckIns'] as List)
            .map((r) => _parseReservation(r as Map<String, dynamic>))
            .toList(),
        upcomingCheckOuts: (json['upcomingCheckOuts'] as List)
            .map((r) => _parseReservation(r as Map<String, dynamic>))
            .toList(),
      );

  static Reservation _parseReservation(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      platformId: json['platformId'] as String,
      guest: Guest(
        name: (json['guest'] as Map<String, dynamic>)['name'] as String,
        phone: (json['guest'] as Map<String, dynamic>)['phone'] as String?,
      ),
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      amount: json['amount'] as double?,
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Service for calculating dashboard statistics.
class DashboardStatisticsService {
  static const int _totalRooms = 4; // Stanza 1, 2, 3, Appartamento

  /// Calculate statistics from a list of reservations.
  DashboardStatistics calculate({
    required List<Reservation> reservations,
    required DateTime currentDate,
  }) {
    final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final sevenDaysLater = today.add(const Duration(days: 8)); // 7 days + today

    // Get current month range
    final monthStart = DateTime(currentDate.year, currentDate.month, 1);
    final monthEnd = DateTime(currentDate.year, currentDate.month + 1, 0, 23, 59, 59);

    // Count occupied rooms today
    final occupiedRoomIds = <String>{};
    for (final reservation in reservations) {
      if (_isDateInRange(today, reservation.checkIn, reservation.checkOut)) {
        occupiedRoomIds.add(reservation.roomId);
      }
    }

    // Calculate monthly income (attribute to check-in month)
    double received = 0;
    double pending = 0;
    for (final reservation in reservations) {
      // Reservation overlaps with current month
      if (_reservationsOverlapMonth(reservation, monthStart, monthEnd)) {
        if (reservation.amount != null) {
          if (reservation.paymentStatus == PaymentStatus.received) {
            received += reservation.amount!;
          } else {
            pending += reservation.amount!;
          }
        }
      }
    }

    // Get upcoming check-ins (next 7 days, including today)
    final upcomingCheckIns = reservations.where((r) {
      final checkInDay = DateTime(r.checkIn.year, r.checkIn.month, r.checkIn.day);
      return !checkInDay.isBefore(today) && checkInDay.isBefore(sevenDaysLater);
    }).toList()
      ..sort((a, b) => a.checkIn.compareTo(b.checkIn));

    // Get upcoming check-outs (next 7 days, including today)
    final upcomingCheckOuts = reservations.where((r) {
      final checkOutDay = DateTime(r.checkOut.year, r.checkOut.month, r.checkOut.day);
      return !checkOutDay.isBefore(today) && checkOutDay.isBefore(sevenDaysLater);
    }).toList()
      ..sort((a, b) => a.checkOut.compareTo(b.checkOut));

    return DashboardStatistics(
      occupiedRoomsToday: occupiedRoomIds.length,
      totalRooms: _totalRooms,
      monthlyIncomeReceived: received,
      monthlyIncomePending: pending,
      upcomingCheckIns: upcomingCheckIns,
      upcomingCheckOuts: upcomingCheckOuts,
    );
  }

  /// Get reservation for each room if occupied today.
  Map<String, Reservation?> getRoomOccupancyToday({
    required List<Reservation> reservations,
    required DateTime currentDate,
  }) {
    final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final roomOccupancy = <String, Reservation?>{};

    // Initialize all rooms as null (not occupied)
    for (final roomId in ['room-1', 'room-2', 'room-3', 'apartment']) {
      roomOccupancy[roomId] = null;
    }

    // Find occupying reservation for each room
    for (final reservation in reservations) {
      if (_isDateInRange(today, reservation.checkIn, reservation.checkOut)) {
        roomOccupancy[reservation.roomId] = reservation;
      }
    }

    return roomOccupancy;
  }

  bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    return !normalizedDate.isBefore(normalizedStart) && normalizedDate.isBefore(normalizedEnd);
  }

  bool _reservationsOverlapMonth(Reservation r, DateTime monthStart, DateTime monthEnd) {
    // Normalize reservation dates
    final checkIn = DateTime(r.checkIn.year, r.checkIn.month, r.checkIn.day);
    final checkOut = DateTime(r.checkOut.year, r.checkOut.month, r.checkOut.day);
    return checkIn.isBefore(monthEnd) && checkOut.isAfter(monthStart);
  }
}
