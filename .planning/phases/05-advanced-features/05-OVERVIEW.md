# Phase 05: Advanced Features - Quick Overview

## 📋 Phase Summary

**Status**: 📝 Planning Complete | Ready for Execution
**Duration**: 25-36 hours estimated
**Complexity**: Medium
**Waves**: 5 parallel execution waves

## 🎯 Main Goals

1. **Ricerca Avanzata**: Cerca prenotazioni per nome, telefono, note
2. **Gestione Piattaforme**: Aggiungi, modifica, elimina piattaforme (anche predefinite)
3. **Dark Mode**: Tema scuro con toggle e persistenza
4. **Preparazione Notifiche**: Scheduling logic per implementazione Android (Phase 6)

## 📊 Requirements Coverage

| ID | Requirement | Status |
|----|-------------|--------|
| UI-05 | Ricerca prenotazioni | ✅ Full |
| PLAT-06 | Piattaforme custom | ✅ Full |
| UI-07 | Dark mode | ✅ Full |
| NOT-01/02/03/04/05/06 | Notifiche (scheduling) | ✅ Logic |
| NOT-08 | Notifiche web | ⏭️ Skipped (Android only) |
| TEST-06 | Test notifiche | ✅ Logic tests |

## 🔄 Wave Breakdown

```
Wave 1: Foundation (3-5h)
├─ Platform management system
└─ Search service

Wave 2: Platform UI (8-11h)
├─ Platform list page
├─ Platform form with color picker
└─ Integration & navigation

Wave 3: Search UI (4-6h)
├─ Search bar with debouncing
└─ Search results integration

Wave 4: Dark Mode (5-7h)
├─ Theme system with persistence
└─ Dark mode styling all widgets

Wave 5: Notification Foundation (5-7h)
├─ Notification scheduling service
└─ Notification data layer
```

## 📁 Deliverables

### New Features
- ✅ Platform management (list, form, color picker)
- ✅ Full-text search (nome, telefono, note)
- ✅ Dark mode with toggle
- ✅ Notification scheduling (foundation)

### New Files
- 20+ new source files
- 47+ tests (unit, widget, integration)
- 2 database migrations

### Dependencies
- `shared_preferences: ^2.3.5`

## 🗄️ Database Changes

### Migration 2: Platform System Flag
```sql
ALTER TABLE platforms ADD COLUMN is_system INTEGER DEFAULT 0;
```

### Migration 3: Notification Schedules
```sql
CREATE TABLE notification_schedules (
  id TEXT PRIMARY KEY,
  reservation_id TEXT NOT NULL,
  notification_type TEXT NOT NULL,
  scheduled_date TEXT NOT NULL,
  is_sent INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  FOREIGN KEY (reservation_id) REFERENCES reservations(id) ON DELETE CASCADE
);
```

## ⚡ Technical Highlights

### Platform Management
- Flag `isSystem` solo per UI (non blocca operazioni)
- Modifica/eliminazione di TUTTE le piattaforme
- Color picker con preset Material colors

### Search
- Full-text su: guestName, guestPhone, notes
- Case-insensitive
- Debouncing 300ms
- Database indexes per performance

### Dark Mode
- Material 3 ColorScheme (light/dark)
- Persistenza in SharedPreferences
- Toggle in app bar
- Tutti i widget aggiornati

### Notifications
- Scheduling logic (NO plugin Android)
- 5 notifiche: 5, 3, 2, 1 giorni prima + giorno stesso
- Abstract service per facile integrazione Phase 6
- Auto-schedule su create/reschedule/delete

## ✅ Success Criteria

- [ ] Ricerca funziona su tutti i campi testo
- [ ] Piattaforme: CRUD completo (incluso system)
- [ ] Dark mode toggle funzionante
- [ ] Notification scheduling implementata
- [ ] 47+ tests passano
- [ ] Flutter analyze: 0 errors
- [ ] Manual testing web completato

## 🚀 Next Steps

1. **Execute**: Run `/gsd:execute-phase 5`
2. **Test**: Complete all 47+ tests
3. **Verify**: Manual testing on web
4. **Phase 6**: Implement Android notifications

## 📝 Notes

### User Preferences
- **Priorità**: Notifiche Android sono più importanti
- **Notifiche Web**: SKIP - solo Android
- **Piattaforme**: Modificare/eliminare TUTTE
- **Ricerca**: Tutti i campi testo

### Architecture Decisions
- Web-first development (test su Chrome)
- Notifiche Android in Phase 6 (ora solo foundation)
- Dark mode completo per UX
- Platform management flessibile

---

**Phase 05 is ready for execution! 🎉**
