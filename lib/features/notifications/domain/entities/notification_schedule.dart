/// Represents a scheduled notification for a reservation.
class NotificationSchedule {
  /// Unique identifier for this schedule
  final String id;

  /// ID of the reservation this notification is for
  final String reservationId;

  /// Type of notification (5days, 3days, 2days, 1day, sameday)
  final NotificationType type;

  /// When this notification is scheduled to be sent
  final DateTime scheduledDate;

  /// Whether this notification has been sent
  final bool isSent;

  /// When this schedule was created
  final DateTime createdAt;

  const NotificationSchedule({
    required this.id,
    required this.reservationId,
    required this.type,
    required this.scheduledDate,
    this.isSent = false,
    required this.createdAt,
  });

  /// Creates a copy with some fields replaced
  NotificationSchedule copyWith({
    String? id,
    String? reservationId,
    NotificationType? type,
    DateTime? scheduledDate,
    bool? isSent,
    DateTime? createdAt,
  }) {
    return NotificationSchedule(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      type: type ?? this.type,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isSent: isSent ?? this.isSent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSchedule &&
        other.id == id &&
        other.reservationId == reservationId &&
        other.type == type &&
        other.scheduledDate == scheduledDate &&
        other.isSent == isSent &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        reservationId,
        type,
        scheduledDate,
        isSent,
        createdAt,
      );
}

/// Types of notifications that can be scheduled
enum NotificationType {
  /// 5 days before check-in
  fiveDays('5days', 5),

  /// 3 days before check-in
  threeDays('3days', 3),

  /// 2 days before check-in
  twoDays('2days', 2),

  /// 1 day before check-in
  oneDay('1day', 1),

  /// On the check-in day (morning of)
  sameDay('sameday', 0);

  final String value;
  final int daysBeforeCheckIn;

  const NotificationType(this.value, this.daysBeforeCheckIn);

  /// Gets the display label for this notification type
  String get label {
    switch (this) {
      case NotificationType.fiveDays:
        return '5 giorni prima';
      case NotificationType.threeDays:
        return '3 giorni prima';
      case NotificationType.twoDays:
        return '2 giorni prima';
      case NotificationType.oneDay:
        return '1 giorno prima';
      case NotificationType.sameDay:
        return 'Giorno stesso';
    }
  }

  /// Gets all notification types in order
  static List<NotificationType> get all => [
        NotificationType.fiveDays,
        NotificationType.threeDays,
        NotificationType.twoDays,
        NotificationType.oneDay,
        NotificationType.sameDay,
      ];
}
