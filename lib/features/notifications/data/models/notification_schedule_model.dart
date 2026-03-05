import 'package:app_prenotazioni/core/database/database_schema.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_schedule.dart';

/// Model for [NotificationSchedule] that handles database serialization.
class NotificationScheduleModel {
  final String id;
  final String reservationId;
  final NotificationType type;
  final DateTime scheduledDate;
  final bool isSent;
  final DateTime createdAt;

  const NotificationScheduleModel({
    required this.id,
    required this.reservationId,
    required this.type,
    required this.scheduledDate,
    this.isSent = false,
    required this.createdAt,
  });

  /// Creates a [NotificationScheduleModel] from a database map.
  factory NotificationScheduleModel.fromMap(Map<String, dynamic> map) {
    return NotificationScheduleModel(
      id: map[DatabaseSchema.notificationScheduleId] as String,
      reservationId: map[DatabaseSchema.notificationScheduleReservationId] as String,
      type: _parseNotificationType(map[DatabaseSchema.notificationScheduleType] as String),
      scheduledDate: DateTime.parse(map[DatabaseSchema.notificationScheduleScheduledDate] as String),
      isSent: (map[DatabaseSchema.notificationScheduleIsSent] as int) == 1,
      createdAt: DateTime.parse(map[DatabaseSchema.notificationScheduleCreatedAt] as String),
    );
  }

  /// Converts this model to a database map.
  Map<String, dynamic> toMap() {
    return {
      DatabaseSchema.notificationScheduleId: id,
      DatabaseSchema.notificationScheduleReservationId: reservationId,
      DatabaseSchema.notificationScheduleType: type.value,
      DatabaseSchema.notificationScheduleScheduledDate: scheduledDate.toIso8601String(),
      DatabaseSchema.notificationScheduleIsSent: isSent ? 1 : 0,
      DatabaseSchema.notificationScheduleCreatedAt: createdAt.toIso8601String(),
    };
  }

  /// Converts this model to a [NotificationSchedule] entity.
  NotificationSchedule toEntity() {
    return NotificationSchedule(
      id: id,
      reservationId: reservationId,
      type: type,
      scheduledDate: scheduledDate,
      isSent: isSent,
      createdAt: createdAt,
    );
  }

  /// Creates a [NotificationScheduleModel] from a [NotificationSchedule] entity.
  factory NotificationScheduleModel.fromEntity(NotificationSchedule entity) {
    return NotificationScheduleModel(
      id: entity.id,
      reservationId: entity.reservationId,
      type: entity.type,
      scheduledDate: entity.scheduledDate,
      isSent: entity.isSent,
      createdAt: entity.createdAt,
    );
  }

  /// Parses a notification type string to a [NotificationType] enum.
  static NotificationType _parseNotificationType(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid notification type: $value'),
    );
  }

  /// Creates a copy with some fields replaced.
  NotificationScheduleModel copyWith({
    String? id,
    String? reservationId,
    NotificationType? type,
    DateTime? scheduledDate,
    bool? isSent,
    DateTime? createdAt,
  }) {
    return NotificationScheduleModel(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      type: type ?? this.type,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isSent: isSent ?? this.isSent,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
