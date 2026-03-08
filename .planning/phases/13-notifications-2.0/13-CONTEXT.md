# Phase 13: Notifications 2.0 - Context

## Overview

**Goal**: Migliorare sistema notifiche con test e personalizzazione

**Requirements**: NOT-10, NOT-11, NOT-12, NOT-13

**Estimated Duration**: 2-3 days

## Requirements Mapping

| ID | Requirement | Description |
|----|-------------|-------------|
| NOT-10 | Test Notifica | Tasto "Test Notifica" per verificare funzionamento |
| NOT-11 | Log notifiche | Log notifiche inviate con storico |
| NOT-12 | Giorni personalizzabili | Giorni prima personalizzabili (attualmente fissi: 5,3,2,1,0) |
| NOT-13 | Orario personalizzabile | Orario personalizzabile (range 9:00-10:00) |

## Current Implementation Analysis

### Notification System Architecture

**Domain Layer**:
- `lib/features/notifications/domain/entities/notification_schedule.dart` - Entity with NotificationType enum (fixed: fiveDays, threeDays, twoDays, oneDay, sameDay)
- `lib/features/notifications/domain/repositories/notification_repository.dart` - Repository interface
- `lib/features/notifications/domain/services/notification_scheduler_service.dart` - Scheduler service

**Data Layer**:
- `lib/features/notifications/data/models/notification_schedule_model.dart` - SQLite model
- `lib/features/notifications/data/datasources/notification_datasource.dart` - SQLite datasource
- `lib/features/notifications/data/repositories/notification_repository_impl.dart` - Repository implementation

**Application Layer**:
- `lib/features/notifications/application/notification_service.dart` - Platform notification service (Android/Web)
- `lib/features/notifications/application/reservation_notification_scheduler.dart` - Scheduling logic
- `lib/features/notifications/application/notification_initializer.dart` - App startup init

**Presentation Layer**:
- `lib/features/notifications/presentation/providers/notification_permission_provider.dart` - Permission state

### Current NotificationType (FIXED)

```dart
enum NotificationType {
  fiveDays('5days', 5),
  threeDays('3days', 3),
  twoDays('2days', 2),
  oneDay('1day', 1),
  sameDay('sameday', 0);
}
```

**Problem**: Days are hardcoded in enum, not configurable.

### Settings Page

**File**: `lib/core/presentation/pages/settings_page.dart`

**Current Sections**:
- Aspetto (Theme)
- Gestione (Platforms)
- Dati (Backup)
- Informazioni (Version)

**Missing**:
- Notifications section with:
  - Enable/disable toggle
  - Days before configuration
  - Time configuration
  - Test notification button
  - View notification logs

## Gap Analysis

### NOT-10: Test Notification Button
**Status**: NOT IMPLEMENTED
**Changes Needed**:
- Add test button to notifications settings
- Create immediate notification trigger
- Handle Android vs Web differences

### NOT-11: Notification Log
**Status**: NOT IMPLEMENTED
**Changes Needed**:
- Create `NotificationLog` entity
- Add `notification_logs` table
- Track sent notifications with timestamp, type, reservation
- Create logs page UI

### NOT-12: Customizable Days
**Status**: NOT IMPLEMENTED (fixed enum)
**Changes Needed**:
- Create `NotificationSettings` entity
- Store user preferences (which days to notify)
- Modify scheduler to use settings instead of hardcoded enum
- Add UI for selecting notification days

### NOT-13: Customizable Time
**Status**: NOT IMPLEMENTED (uses scheduled time from day calculation)
**Changes Needed**:
- Add `notificationTime` to NotificationSettings (default 9:00)
- Add time picker UI
- Update scheduling logic to use custom time

## Proposed Architecture

### New Entities

```dart
// NotificationSettings - User preferences
class NotificationSettings {
  final bool enabled;
  final Set<int> daysBeforeCheckIn; // e.g., {5, 3, 2, 1, 0}
  final TimeOfDay notificationTime; // e.g., 9:00
  final DateTime updatedAt;
}

// NotificationLog - Sent notification history
class NotificationLog {
  final String id;
  final String reservationId;
  final String guestName;
  final int daysBefore;
  final DateTime scheduledTime;
  final DateTime sentAt;
  final bool success;
  final String? errorMessage;
}
```

### Database Schema

```sql
-- notification_settings table (single row)
CREATE TABLE notification_settings (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  enabled INTEGER NOT NULL DEFAULT 1,
  days_before TEXT NOT NULL DEFAULT '[5,3,2,1,0]', -- JSON array
  notification_hour INTEGER NOT NULL DEFAULT 9,
  notification_minute INTEGER NOT NULL DEFAULT 0,
  updated_at TEXT NOT NULL
);

-- notification_logs table
CREATE TABLE notification_logs (
  id TEXT PRIMARY KEY,
  reservation_id TEXT NOT NULL,
  guest_name TEXT NOT NULL,
  days_before INTEGER NOT NULL,
  scheduled_time TEXT NOT NULL,
  sent_at TEXT NOT NULL,
  success INTEGER NOT NULL DEFAULT 1,
  error_message TEXT,
  FOREIGN KEY (reservation_id) REFERENCES reservations(id)
);

CREATE INDEX idx_notification_logs_sent_at ON notification_logs(sent_at);
CREATE INDEX idx_notification_logs_reservation ON notification_logs(reservation_id);
```

## Key Files

### To Create
1. `lib/features/notifications/domain/entities/notification_settings.dart`
2. `lib/features/notifications/domain/entities/notification_log.dart`
3. `lib/features/notifications/domain/repositories/notification_settings_repository.dart`
4. `lib/features/notifications/domain/repositories/notification_log_repository.dart`
5. `lib/features/notifications/data/models/notification_settings_model.dart`
6. `lib/features/notifications/data/models/notification_log_model.dart`
7. `lib/features/notifications/data/repositories/notification_settings_repository_impl.dart`
8. `lib/features/notifications/data/repositories/notification_log_repository_impl.dart`
9. `lib/features/notifications/presentation/pages/notification_settings_page.dart`
10. `lib/features/notifications/presentation/pages/notification_logs_page.dart`
11. `lib/features/notifications/presentation/providers/notification_settings_provider.dart`

### To Modify
1. `lib/features/notifications/application/reservation_notification_scheduler.dart` - Use settings instead of hardcoded enum
2. `lib/core/presentation/pages/settings_page.dart` - Add notifications section
3. `lib/features/notifications/data/datasources/notification_datasource.dart` - Add new tables
4. Database migration for new tables

## Dependencies

- `flutter_local_notifications` - Already installed
- No new packages required

## Success Criteria

1. Tasto "Test Notifica" funziona su Android
2. Log notifiche traccia invii con storico
3. Giorni prima personalizzabili (checkbox per ogni giorno)
4. Orario personalizzabile (time picker 9:00-10:00 default)
5. Tutte le preferenze salvate in database
6. Settings page integrata con nuova sezione Notifiche

## Test Strategy

### Unit Tests
- NotificationSettings entity tests
- NotificationLog entity tests
- Repository tests for settings and logs

### Widget Tests
- NotificationSettingsPage widget tests
- NotificationLogsPage widget tests
- Time picker interaction tests

### Integration Tests
- Test notification end-to-end
- Settings persistence across app restart
- Log creation on notification send

### Manual Tests
- Test notification on Android device
- Verify notification appears at scheduled time
- Check logs are populated correctly
