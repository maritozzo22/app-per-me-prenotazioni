# Phase 05: Advanced Features - Implementation Plan

## Overview

**Goal**: Implementare ricerca avanzata, gestione piattaforme custom, dark mode, e preparazione notifiche Android

**Requirements**: UI-05, UI-07, PLAT-06, NOT-01/02/03/04/05/06, NOT-08, TEST-06

**Approccio**: Web-first development con focus su ricerca e piattaforme, dark mode per completezza UI, preparazione notifiche per Android (Phase 6)

## Requirements Mapping

### Primary Requirements
- **UI-05**: Ricerca prenotazioni per nome ospite
- **PLAT-06**: Possibilità di aggiungere nuove piattaforme con colore personalizzato
- **UI-07**: Dark mode support (opzionale)
- **NOT-01/02/03/04/05**: Notifiche multiple (5, 3, 2, 1 giorni prima + giorno stesso)
- **NOT-06**: Notifiche includono nome ospite, stanza, date
- **NOT-08**: Funzionamento su Web (browser notifications se supportato) - **SKIP** (utente ha confermato solo Android)
- **TEST-06**: Test notifiche

### User Preferences (dal discussion)
- **Priorità**: Notifiche Android sono le più critiche
- **Notifiche Web**: SKIP - utente userà solo Android
- **Piattaforme**: Modificare/eliminare TUTTE (anche predefinite)
- **Ricerca**: Tutti i campi testo (nome, telefono, note)

## Wave Strategy

### Wave 1: Foundation (Platform Management & Search Service)
**Goal**: Data layer e business logic per piattaforme e ricerca
**Parallel Work**: 2 tasks

1. **Platform Management System**
   - Platform entity con flag `isSystem`
   - PlatformRepository con CRUD completo
   - Database migration per aggiungere `isSystem` column
   - PlatformService per business logic (validazione modifiche system platforms)

2. **Search Service**
   - SearchService con ricerca full-text su campi testo
   - Ricerca in: guestName, guestPhone, notes
   - Case-insensitive search
   - Filtering avanzato opzionale (piattaforma, stanza, payment status)

### Wave 2: Platform Management UI
**Goal**: Schermata gestione piattaforme
**Parallel Work**: 3 tasks

1. **Platform List Screen**
   - PlatformsListPage con tutte le piattaforme
   - Indicatore visivo per system platforms
   - Badge "System" per predefinite
   - Swipe actions: edit (tutte), delete (solo custom)

2. **Platform Form**
   - PlatformFormScreen per crea/modifica
   - Nome piattaforma (required, unique)
   - Color picker per colore personalizzato
   - Validazione: nome non duplicato
   - Preview colore in real-time

3. **Integration & Tests**
   - Aggiungere "Gestione Piattaforme" in app shell o settings
   - Integration test per CRUD piattaforme
   - Widget tests per form e lista

### Wave 3: Search UI
**Goal**: Interfaccia ricerca prenotazioni
**Parallel Work**: 2 tasks

1. **Search Bar Component**
   - SearchBarWidget con TextField
   - Debouncing (300ms) per ottimizzazione
   - Clear button
   - Loading indicator durante ricerca
   - Empty state "Nessun risultato"

2. **Search Results & Integration**
   - SearchResultsList che reuse ReservationListTile
   - SearchProvider con Riverpod
   - Aggiungere search bar a ReservationsListPage
   - Highlight dei termini cercati (opzionale)
   - Widget tests per search functionality

### Wave 4: Dark Mode
**Goal**: Thema scuro per l'applicazione
**Parallel Work**: 2 tasks

1. **Theme System**
   - ThemeProvider per light/dark mode
   - ThemeData per light theme (esistente)
   - ThemeData per dark theme (ColorScheme.dark())
   - Persistenza preferenza in SharedPreferences
   - Toggle switch in settings/app bar

2. **Dark Mode Styling**
   - Aggiornare tutti i widget per supportare dark mode
   - ColorScheme-based colors (non hardcoded)
   - Test manuale su entrambi i temi
   - Screenshot documentation per entrambi i temi

### Wave 5: Notification Foundation (Android Prep)
**Goal**: Preparare infrastruttura notifiche (implementazione Android Phase 6)
**Parallel Work**: 2 tasks

1. **Notification Scheduling Service**
   - NotificationSchedulerService (abstract interface)
   - Calcolo date notifiche (5, 3, 2, 1 giorni prima + giorno stesso)
   - NotificationSchedule entity (reservationId, scheduledDate, type)
   - Business logic indipendente dalla piattaforma

2. **Notification Data Layer**
   - NotificationSchedule entity/database table
   - NotificationRepository per CRUD schedule
   - Integration con Reservation CRUD (auto-schedule on create)
   - Trigger su delete/modify (cancel+reschedule)
   - Unit tests per scheduling logic

## Success Criteria

1. **Ricerca funzionante**: Ricerca in nome, telefono, note funziona correttamente
2. **Gestione piattaforme**: Puoi aggiungere, modificare, eliminare piattaforme (anche system)
3. **Dark mode**: Toggle funziona, UI coerente in entrambi i temi
4. **Preparazione notifiche**: Scheduling logic implementata e testata (pronto per Android)
5. **Test coverage**: Unit, widget, integration tests per tutte le feature
6. **Zero bug critici**: Flutter analyze passa, test passano

## Deliverables

### Core Files (Foundation)
- `lib/features/platforms/domain/entities/platform.dart` (updated)
- `lib/features/platforms/domain/repositories/platform_repository.dart` (updated)
- `lib/features/platforms/domain/services/platform_service.dart`
- `lib/features/search/domain/services/search_service.dart`
- `lib/features/notifications/domain/services/notification_scheduler_service.dart`
- `lib/features/notifications/domain/entities/notification_schedule.dart`

### Data Layer
- `lib/features/platforms/data/models/platform_model.dart` (updated)
- `lib/features/platforms/data/repositories/platform_repository_impl.dart` (updated)
- `lib/features/platforms/data/datasources/platform_datasource.dart` (updated)
- `lib/features/notifications/data/models/notification_schedule_model.dart`
- `lib/features/notifications/data/repositories/notification_repository_impl.dart`
- `lib/features/notifications/data/datasources/notification_datasource.dart`

### Presentation Layer
- `lib/features/platforms/presentation/pages/platforms_list_page.dart`
- `lib/features/platforms/presentation/pages/platform_form_page.dart`
- `lib/features/platforms/presentation/providers/platform_provider.dart` (updated)
- `lib/features/platforms/presentation/widgets/platform_list_tile.dart`
- `lib/features/search/presentation/providers/search_provider.dart`
- `lib/features/search/presentation/widgets/search_bar_widget.dart`
- `lib/features/search/presentation/pages/search_results_page.dart`
- `lib/core/providers/theme_provider.dart`
- `lib/core/theme/app_theme.dart`

### UI Updates
- `lib/features/reservations/presentation/pages/reservations_list_page.dart` (add search)
- `lib/core/widgets/app_shell.dart` (add theme toggle or settings route)

### Tests
- `test/features/platforms/**/*_test.dart` (unit, widget, integration)
- `test/features/search/**/*_test.dart`
- `test/features/notifications/domain/**/*_test.dart`
- `test/core/providers/theme_provider_test.dart`

### Configuration
- `pubspec.yaml` (add shared_preferences for theme persistence)

## Dependencies

### New Dependencies Required
```yaml
dependencies:
  shared_preferences: ^2.3.5  # For theme persistence

  # For Phase 6 (Android notifications) - NOT NOW
  # flutter_local_notifications: ^17.2.3
  # timezone: ^0.9.4
  # flutter_native_timezone: ^2.0.0
```

## Technical Decisions

### Platform Management
- **Decision**: Permettere modifica/eliminazione di system platforms
- **Rationale**: Utente vuole controllo completo
- **Implementation**: Flag `isSystem` solo per UI indicator, non per blocco operazioni

### Search Strategy
- **Decision**: Ricerca full-text su campi testo, senza filtri avanzati in Phase 5
- **Rationale**: Utente ha chiesto "tutti i campi testo", filtri possono venire dopo
- **Implementation**: Simple SQL LIKE query su multiple colonne

### Dark Mode
- **Decision**: Implementare dark mode completo con ColorScheme
- **Rationale**: Completa UX, utile per uso notturno
- **Implementation**: ThemeProvider + SharedPreferences, no system theme per ora

### Notifications
- **Decision**: Implementare solo scheduling logic, NOT plugin Android
- **Rationale**: Utente userà solo Android, ma meglio fare in Phase 6
- **Implementation**: Abstract service + data layer, ready for flutter_local_notifications

## Database Migration

### Migration 2: Add Platform System Flag
```sql
ALTER TABLE platforms ADD COLUMN is_system INTEGER DEFAULT 0;
UPDATE platforms SET is_system = 1 WHERE name IN ('Booking', 'Airbnb', 'WhatsApp', 'Sito Web', 'TikTok');
```

### Migration 3: Create Notification Schedules Table
```sql
CREATE TABLE notification_schedules (
  id TEXT PRIMARY KEY,
  reservation_id TEXT NOT NULL,
  notification_type TEXT NOT NULL, -- '5days', '3days', '2days', '1day', 'sameday'
  scheduled_date TEXT NOT NULL, -- ISO8601 date string
  is_sent INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  FOREIGN KEY (reservation_id) REFERENCES reservations(id) ON DELETE CASCADE
);

CREATE INDEX idx_notification_schedules_reservation ON notification_schedules(reservation_id);
CREATE INDEX idx_notification_scheduled_date ON notification_schedules(scheduled_date);
CREATE INDEX idx_notification_is_sent ON notification_schedules(is_sent);
```

## Test Strategy

### Unit Tests
- PlatformService: CRUD, validazioni, system platform handling
- SearchService: search logic, case-insensitivity, empty results
- NotificationSchedulerService: date calculations, scheduling logic
- ThemeProvider: theme switching, persistence

### Widget Tests
- PlatformsListPage: renderizza lista, system badge, swipe actions
- PlatformFormPage: validazione form, color picker, crea/modifica
- SearchBarWidget: input handling, debouncing, clear button
- Theme toggle switch: toggle functionality, icon updates

### Integration Tests
- CRUD completo piattaforme (create → read → update → delete)
- Search flow: digita → vede risultati → tap → apre dettaglio
- Theme switch: toggle → UI aggiorna → persiste → restart → tema persiste
- Notification schedule: crea prenotazione → schedules creati → modifica prenotazione → schedules aggiornati

### Manual Tests
- Dark mode visual check on all screens
- Search performance con 100+ prenotazioni
- Platform color changes reflected in calendar/list

## Parallelization Map

```
Wave 1:
├── Platform Management (Foundation) ──┐
└── Search Service (Foundation) ───────┤
                                       ├──> Wave 2
Wave 2:                                │
├── Platform List ─────────────────────┤
├── Platform Form ─────────────────────┤
└── Integration & Tests ───────────────┘
                                       ├──> Wave 3
Wave 3:                                │
├── Search Bar ────────────────────────┤
└── Search Results & Integration ──────┘
                                       ├──> Wave 4
Wave 4:                                │
├── Theme System ──────────────────────┤
└── Dark Mode Styling ─────────────────┘
                                       ├──> Wave 5
Wave 5:                                │
├── Notification Scheduling Service ───┤
└── Notification Data Layer ───────────┘
```

## Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Database migration failure | High | Backup database before migration, test migration in isolation |
| Search performance with large datasets | Medium | Add database indexes, implement debouncing, test with 100+ reservations |
| Dark mode color contrast issues | Medium | Use Material 3 ColorScheme, test accessibility, manual visual review |
| Notification scheduling bugs | High | Comprehensive unit tests for date calculations, integration tests for schedule/cancel |

## Definition of Done

- [ ] Tutti i requirements implementati
- [ ] Ricerca funziona su nome, telefono, note
- [ ] Piattaforme: aggiungi, modifica, elimina (tutte)
- [ ] Dark mode toggle funzionante
- [ ] Notification scheduling logic implementata
- [ ] Tutti i test (unit, widget, integration) passano
- [ ] Flutter analyze: 0 errors
- [ ] Manuale testing completato su web
- [ ] Code review passata
- [ ] Documentation aggiornata

## Next Steps After Phase 5

1. **Phase 6**: Implementare flutter_local_notifications per Android
2. **Test Android**: Verificare notifiche su dispositivo reale
3. **Performance Optimization**: Ottimizzazioni Android-specific
4. **Accessibility Improvements**: Touch targets, screen reader labels
5. **Phase 7**: Polish e documentation

## Notes

### Notification Implementation Note
Le notifiche web (NOT-08) vengono **SKIPPATE** per scelta utente. L'utente userà l'app solo su Android, quindi implementiamo solo la scheduling logic ora e il plugin Android in Phase 6.

### Platform Management Note
Differenza da roadmap originale: permettiamo modifica/eliminazione di TUTTE le piattaforme, non solo aggiunta di custom. Questo richiede flag `isSystem` solo per UI, non per business logic di restrizione.

### Dark Mode Note
Dark mode è marcato "opzionale" in requirements (UI-07), ma lo implementiamo per completezza UX e perché è relativamente semplice con Material 3.

---

**Phase Estimated Duration**: 5 waves, ~3-4 days of focused work

**Complexity**: Medium (più bassa di Phase 2 e 4, più alta di Phase 1 e 3)

**Dependencies**: Phase 4 (Dashboard & Navigation) deve essere completa
