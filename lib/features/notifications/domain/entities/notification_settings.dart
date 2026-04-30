import 'dart:convert';

/// User preferences for notification scheduling.
class NotificationSettings {
  /// Whether notifications are enabled
  final bool enabled;

  /// Days before check-in to send notifications (e.g., {5, 3, 2, 1, 0})
  final Set<int> daysBeforeCheckIn;

  /// Hour of day to send notifications (0-23)
  final int notificationHour;

  /// Minute of hour to send notifications (0-59)
  final int notificationMinute;

  /// When settings were last updated
  final DateTime updatedAt;

  const NotificationSettings({
    this.enabled = true,
    this.daysBeforeCheckIn = const {5, 3, 2, 1, 0},
    this.notificationHour = 9,
    this.notificationMinute = 0,
    required this.updatedAt,
  });

  /// Default settings
  factory NotificationSettings.defaults() {
    return NotificationSettings(
      enabled: true,
      daysBeforeCheckIn: const {5, 3, 2, 1, 0},
      notificationHour: 9,
      notificationMinute: 0,
      updatedAt: DateTime.now(),
    );
  }

  /// Create from JSON map
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      daysBeforeCheckIn: Set<int>.from(
        jsonDecode(json['days_before'] as String? ?? '[5,3,2,1,0]') as List,
      ),
      notificationHour: json['notification_hour'] as int? ?? 9,
      notificationMinute: json['notification_minute'] as int? ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'days_before': jsonEncode(daysBeforeCheckIn.toList()..sort()),
      'notification_hour': notificationHour,
      'notification_minute': notificationMinute,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with some fields replaced
  NotificationSettings copyWith({
    bool? enabled,
    Set<int>? daysBeforeCheckIn,
    int? notificationHour,
    int? notificationMinute,
    DateTime? updatedAt,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      daysBeforeCheckIn: daysBeforeCheckIn ?? this.daysBeforeCheckIn,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get notification time as formatted string (HH:mm)
  String get notificationTimeString {
    final hour = notificationHour.toString().padLeft(2, '0');
    final minute = notificationMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Check if a specific day count is enabled
  bool isDayEnabled(int days) => daysBeforeCheckIn.contains(days);

  /// Available day options for notifications
  static const List<int> availableDays = [5, 3, 2, 1, 0];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
        other.enabled == enabled &&
        _setEquals(other.daysBeforeCheckIn, daysBeforeCheckIn) &&
        other.notificationHour == notificationHour &&
        other.notificationMinute == notificationMinute;
  }

  @override
  int get hashCode => Object.hash(
        enabled,
        Object.hashAll(daysBeforeCheckIn),
        notificationHour,
        notificationMinute,
      );

  bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    for (final item in a) {
      if (!b.contains(item)) return false;
    }
    return true;
  }
}
