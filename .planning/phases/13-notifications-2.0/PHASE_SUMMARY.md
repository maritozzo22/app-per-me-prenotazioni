# Phase 13: Notifications 2.0 - Summary

## Overview

**Goal**: Migliorare sistema notifiche con test e personalizzazione

**Requirements**: NOT-10, NOT-11, NOT-12, NOT-13

**Status**: Planned

**Estimated Duration**: 2-3 days

## Requirements

| ID | Requirement | Description |
|----|-------------|-------------|
| NOT-10 | Test Notifica | Tasto "Test Notifica" per verificare funzionamento |
| NOT-11 | Log notifiche | Log notifiche inviate con storico |
| NOT-12 | Giorni personalizzabili | Giorni prima personalizzabili (attualmente fissi: 5,3,2,1,0) |
| NOT-13 | Orario personalizzabile | Orario personalizzabile (range 9:00-10:00) |

## Plans (3 waves)

### Wave 1: Data Layer Foundation (13-01)
**Focus**: NotificationSettings entity, repository, and provider

**Deliverables**:
- `NotificationSettings` entity with days/time preferences
- `NotificationSettingsRepository` interface and implementation
- `notification_settings` database table
- `NotificationSettingsProvider` for state management

**Files to create/modify**:
- `lib/features/notifications/domain/entities/notification_settings.dart`
- `lib/features/notifications/data/models/notification_settings_model.dart`
- `lib/features/notifications/domain/repositories/notification_settings_repository.dart`
- `lib/features/notifications/data/repositories/notification_settings_repository_impl.dart`
- `lib/features/notifications/data/datasources/notification_datasource.dart`
- `lib/features/notifications/presentation/providers/notification_settings_provider.dart`

### Wave 2: Logging & Test Notification (13-02)
**Focus**: NotificationLog entity and test notification capability

**Deliverables**:
- `NotificationLog` entity with test support
- `notification_logs` database table
- `NotificationLogRepository` for log management
- `sendTestNotification()` method on NotificationService

**Files to create/modify**:
- `lib/features/notifications/domain/entities/notification_log.dart`
- `lib/features/notifications/data/models/notification_log_model.dart`
- `lib/features/notifications/domain/repositories/notification_log_repository.dart`
- `lib/features/notifications/data/repositories/notification_log_repository_impl.dart`
- `lib/features/notifications/application/notification_service.dart`

### Wave 3: UI Integration (13-03)
**Focus**: Settings page UI and logs page

**Deliverables**:
- `NotificationSettingsPage` with toggles and time picker
- `NotificationLogsPage` with history view
- Integration into SettingsPage
- Test notification button (Android only)

**Files to create/modify**:
- `lib/features/notifications/presentation/pages/notification_settings_page.dart`
- `lib/features/notifications/presentation/pages/notification_logs_page.dart`
- `lib/features/notifications/presentation/providers/notification_log_provider.dart`
- `lib/core/presentation/pages/settings_page.dart`

## Database Changes

### notification_settings table
```sql
CREATE TABLE notification_settings (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  enabled INTEGER NOT NULL DEFAULT 1,
  days_before TEXT NOT NULL DEFAULT '[5,3,2,1,0]',
  notification_hour INTEGER NOT NULL DEFAULT 9,
  notification_minute INTEGER NOT NULL DEFAULT 0,
  updated_at TEXT NOT NULL
);
```

### notification_logs table
```sql
CREATE TABLE notification_logs (
  id TEXT PRIMARY KEY,
  reservation_id TEXT,
  guest_name TEXT,
  room_label TEXT,
  days_before INTEGER NOT NULL DEFAULT 0,
  scheduled_time TEXT NOT NULL,
  sent_at TEXT NOT NULL,
  success INTEGER NOT NULL DEFAULT 1,
  error_message TEXT,
  is_test INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_notification_logs_sent_at ON notification_logs(sent_at DESC);
```

## Success Criteria

- [ ] Tasto "Test Notifica" funziona su Android
- [ ] Log notifiche traccia invii con storico
- [ ] Giorni prima personalizzabili (checkbox per ogni giorno)
- [ ] Orario personalizzabile (time picker)
- [ ] Tutte le preferenze salvate in database
- [ ] Settings page integrata con nuova sezione Notifiche
- [ ] All tests pass (unit, widget, integration)

## Test Coverage

### Unit Tests
- NotificationSettings entity tests
- NotificationLog entity tests
- Repository tests for settings and logs

### Widget Tests
- NotificationSettingsPage widget tests
- NotificationLogsPage widget tests
- SettingsPage notification tile test

### Integration Tests
- End-to-end notification settings flow
- Settings persistence across app restart

## Dependencies

No new packages required. Uses existing:
- `flutter_local_notifications` - For sending notifications
- `flutter_riverpod` - State management
- `uuid` - Unique ID generation
- `sqflite` - Database storage

## Notes

- Test notification button only appears on Android (Web doesn't support notifications)
- Logs older than 30 days can be automatically cleaned up
- Settings are stored as single-row table (id = 1)
