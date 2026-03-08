# Phase 10: UI/UX Restructuring - Context

**Date**: 2026-03-07
**Status**: Ready for Planning
**Prerequisite**: Phase 9 (Performance Optimization) - COMPLETE

---

## Phase Goal

Semplificare dashboard e creare spazio per statistiche, preparando la UI per Phase 11 (Statistics Feature).

**Requirements**: UI-10/11/12/13 (4 requirements)

---

## Prior Context (From Completed Phases)

### From Phase 4 (Dashboard & Navigation)
- Dashboard shows: Room Occupancy Grid, Income Breakdown, Upcoming Check-ins/Check-outs, **Calendar Access Card**
- Navigation: 5 tabs (Dashboard → Calendario → Prenotazioni → Piattaforme → Impostazioni)
- Settings structure: "Aspetto" (Theme), "Dati" (Backup), "Informazioni" (About)

### From Phase 9 (Performance Optimization)
- Statistics caching implemented (24h cache)
- Performance infrastructure ready
- All PERFORMANCE tests passing

---

## User Decisions

### 1. Next Event Countdown Card (UI-10)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Events to show | **Check-in AND check-out** | User wants visibility on both arrivals and departures |
| Time format | **Relative + Absolute** | E.g., "Arrivo tra 2 giorni (9 Marzo)" - best clarity |
| No events state | **Static message** | "Nessun evento programmato" - no action button needed |

**Card Format Examples**:
```
Check-in event:
  "Arrivo tra 2 giorni (9 Marzo)"
  "Mario Rossi - Stanza 1"
  Icon: login/arrow_forward

Check-out event:
  "Partenza tra 3 ore (Oggi)"
  "Luca Verdi - Stanza 2"
  Icon: logout/arrow_back
```

**Empty State**:
```
"Nessun evento programmato"
Icon: event_busy
```

### 2. Statistics Tab Creation (UI-11)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Initial content | **Placeholder "Coming Soon"** | User knows feature is coming, Phase 11 implements full feature |
| Tab visibility | **Visible immediately** | Tab appears in navigation with placeholder content |

**Placeholder Design**:
- Icon: analytics/bar_chart
- Title: "Statistiche"
- Content: Centered message "Statistiche in arrivo..." with subtle animation or icon
- No navigation or interactive elements until Phase 11

### 3. Platforms in Settings (UI-12)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Location | **New "Gestione" section** | Dedicated section between "Aspetto" and "Dati" |
| Section name | "Gestione" | Clear purpose for management-related settings |
| Tile title | "Piattaforme di prenotazione" | Descriptive, matches app terminology |

**Settings Structure After Change**:
```
Impostazioni
├── Aspetto
│   └── Tema
├── Gestione ← NEW SECTION
│   └── Piattaforme di prenotazione → [PlatformsListPage]
├── Dati
│   └── Backup e Ripristino
└── Informazioni
    ├── Versione
    └── Sviluppato con Flutter
```

### 4. Initial Tab Configuration (UI-13)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Default tab | **Dashboard** (unchanged) | Current behavior is correct |
| Future option | Documented, not implemented | "Consider adding Settings option to choose initial tab" |

---

## Code Context

### Files to Modify

| File | Change | Priority |
|------|--------|----------|
| `lib/core/widgets/app_shell.dart` | Replace Platforms tab with Statistics tab | HIGH |
| `lib/features/reservations/presentation/pages/dashboard_page.dart` | Remove CalendarAccessCard, add NextEventCountdownCard | HIGH |
| `lib/core/presentation/pages/settings_page.dart` | Add "Gestione" section with Platforms tile | HIGH |

### Files to Create

| File | Purpose |
|------|---------|
| `lib/features/reservations/presentation/widgets/dashboard/next_event_countdown_card.dart` | New countdown card widget |
| `lib/features/statistics/presentation/pages/statistics_page.dart` | Placeholder statistics page |
| `lib/features/statistics/presentation/widgets/coming_soon_placeholder.dart` | Reusable coming soon widget |

### Files to Potentially Delete/Deprecate

| File | Action |
|------|--------|
| `lib/features/reservations/presentation/widgets/dashboard/calendar_access_card.dart` | **DELETE** - No longer used after dashboard simplification |

---

## Navigation Changes

### Before (Current)
```
[Dashboard] → [Calendario] → [Prenotazioni] → [Piattaforme] → [Impostazioni]
     0              1              2               3               4
```

### After (Phase 10)
```
[Dashboard] → [Calendario] → [Prenotazioni] → [Statistiche] → [Impostazioni]
     0              1              2               3               4
```

**Note**: Tab count remains 5. Piattaforme accessible via Settings → Gestione.

---

## Dashboard Layout Changes

### Mobile Layout (< 600px)

**Before**:
```
┌─────────────────────────┐
│ Stanze Oggi             │
│ [Room Grid 2x2]         │
├─────────────────────────┤
│ Income Breakdown        │
├─────────────────────────┤
│ Calendar Access Card ← REMOVE
├─────────────────────────┤
│ Prossimi Arrivi         │
├─────────────────────────┤
│ Prossime Partenze       │
└─────────────────────────┘
```

**After**:
```
┌─────────────────────────┐
│ Stanze Oggi             │
│ [Room Grid 2x2]         │
├─────────────────────────┤
│ Income Breakdown        │
├─────────────────────────┤
│ Next Event Countdown ← NEW
├─────────────────────────┤
│ Prossimi Arrivi         │
├─────────────────────────┤
│ Prossime Partenze       │
└─────────────────────────┘
```

---

## Testing Strategy

### Widget Tests
- NextEventCountdownCard displays check-in event correctly
- NextEventCountdownCard displays check-out event correctly
- NextEventCountdownCard shows empty state when no events
- StatisticsPage shows "Coming Soon" placeholder
- SettingsPage has "Gestione" section with Platforms tile
- Navigation switches correctly between all 5 tabs

### Integration Tests
- User can navigate from Settings → Platforms
- Dashboard no longer has Calendar Access Card
- Tab order is correct: Dashboard → Calendar → Reservations → Statistics → Settings

### Regression Tests
- All existing dashboard widgets still work
- Theme toggle still works
- Backup settings still accessible
- Existing navigation flows unchanged (except Platforms tab removal)

---

## Dependencies

**No new dependencies required for Phase 10.**

Phase 11 will add:
- `fl_chart: ^0.66.0` (for statistics charts)

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Users confused by Platforms move | Clear navigation path: Settings → Gestione → Piattaforme |
| Dashboard feels empty without Calendar card | NextEventCountdownCard provides value with event awareness |
| Statistics tab looks incomplete | Placeholder clearly indicates "Coming Soon" |
| Breaking existing tests | Update tests to reflect new navigation and dashboard structure |

---

## Deferred Ideas

- Settings option to choose initial/default tab (documented for future)
- Statistics tab with basic KPIs before charts (deferred - placeholder is simpler)
- Animated countdown or live updates (not needed for MVP)

---

## Success Criteria (from ROADMAP.md)

1. ✅ Dashboard rimossa card ridondante "Calendario"
2. ✅ Nuova tab "Statistiche" nella navigazione
3. ✅ Tab "Piattaforme" spostata in Impostazioni
4. ✅ Navigazione funziona correttamente
5. ✅ Layout responsive testato

---

## Next Steps

1. `/gsd:plan-phase 10` - Create detailed implementation plan
2. Execute waves in order (likely 2-3 waves)
3. Update tests for new navigation structure

---

*Context captured: 2026-03-07*
