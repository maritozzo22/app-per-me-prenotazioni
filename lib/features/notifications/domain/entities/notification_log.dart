/// Represents a log entry for a sent notification.
class NotificationLog {
  /// Unique identifier
  final String id;

  /// ID of the related reservation (empty for test notifications)
  final String reservationId;

  /// Guest name (for display purposes)
  final String guestName;

  /// Room label (for display purposes)
  final String roomLabel;

  /// Days before check-in (0 for test notifications)
  final int daysBefore;

  /// When the notification was scheduled
  final DateTime scheduledTime;

  /// When the notification was actually sent
  final DateTime sentAt;

  /// Whether the notification was sent successfully
  final bool success;

  /// Error message if failed
  final String? errorMessage;

  /// Whether this is a test notification
  final bool isTest;

  const NotificationLog({
    required this.id,
    required this.reservationId,
    required this.guestName,
    required this.roomLabel,
    required this.daysBefore,
    required this.scheduledTime,
    required this.sentAt,
    this.success = true,
    this.errorMessage,
    this.isTest = false,
  });

  /// Create a test notification log
  factory NotificationLog.test({
    required String id,
    required DateTime sentAt,
    bool success = true,
    String? errorMessage,
  }) {
    return NotificationLog(
      id: id,
      reservationId: '',
      guestName: 'Test',
      roomLabel: '',
      daysBefore: 0,
      scheduledTime: sentAt,
      sentAt: sentAt,
      success: success,
      errorMessage: errorMessage,
      isTest: true,
    );
  }

  /// Create from JSON map
  factory NotificationLog.fromJson(Map<String, dynamic> json) {
    return NotificationLog(
      id: json['id'] as String,
      reservationId: json['reservation_id'] as String? ?? '',
      guestName: json['guest_name'] as String? ?? '',
      roomLabel: json['room_label'] as String? ?? '',
      daysBefore: json['days_before'] as int? ?? 0,
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      sentAt: DateTime.parse(json['sent_at'] as String),
      success: json['success'] == 1 || json['success'] == true,
      errorMessage: json['error_message'] as String?,
      isTest: json['is_test'] == 1 || json['is_test'] == true,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_id': reservationId,
      'guest_name': guestName,
      'room_label': roomLabel,
      'days_before': daysBefore,
      'scheduled_time': scheduledTime.toIso8601String(),
      'sent_at': sentAt.toIso8601String(),
      'success': success ? 1 : 0,
      'error_message': errorMessage,
      'is_test': isTest ? 1 : 0,
    };
  }

  /// Create a copy with some fields replaced
  NotificationLog copyWith({
    String? id,
    String? reservationId,
    String? guestName,
    String? roomLabel,
    int? daysBefore,
    DateTime? scheduledTime,
    DateTime? sentAt,
    bool? success,
    String? errorMessage,
    bool? isTest,
  }) {
    return NotificationLog(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      guestName: guestName ?? this.guestName,
      roomLabel: roomLabel ?? this.roomLabel,
      daysBefore: daysBefore ?? this.daysBefore,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      sentAt: sentAt ?? this.sentAt,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
      isTest: isTest ?? this.isTest,
    );
  }

  /// Get display text for days before
  String get daysBeforeLabel {
    if (isTest) return 'Test';
    if (daysBefore == 0) return 'Giorno stesso';
    if (daysBefore == 1) return '1 giorno prima';
    return '$daysBefore giorni prima';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationLog &&
        other.id == id &&
        other.reservationId == reservationId &&
        other.sentAt == sentAt;
  }

  @override
  int get hashCode => Object.hash(id, reservationId, sentAt);
}
