# Requisiti - App Prenotazioni Airbnb

## Versione 1.0

### Gestione Stanze

- [ ] **ROOM-01**: L'app gestisce 4 tipi di unità: Stanza 1, Stanza 2, Stanza 3, Appartamento Intero
- [ ] **ROOM-02**: L'appartamento intero blocca tutte e 3 le stanze quando prenotato
- [ ] **ROOM-03**: Ogni stanza può essere prenotata indipendentemente dalle altre

### Calendario

- [ ] **CAL-01**: Visualizzazione calendario mensile classica
- [ ] **CAL-02**: Giorni con prenotazione mostrati con colore della piattaforma
- [ ] **CAL-03**: Colore uniforme per tutta la durata della prenotazione (check-in e check-out dello stesso colore)
- [ ] **CAL-04**: Possibilità di navigare tra mesi precedenti e successivi
- [ ] **CAL-05**: Tocco/click su giorno mostra prenotazioni di quel giorno

### Gestione Prenotazioni

- [ ] **RES-01**: Creazione nuova prenotazione con stanza selezionabile
- [ ] **RES-02**: Inserimento date check-in e check-out
- [ ] **RES-03**: Selezione piattaforma (Booking, Airbnb, WhatsApp, Sito Web, TikTok, Altro)
- [ ] **RES-04**: Campo importo opzionale (ricevuto/da ricevere)
- [ ] **RES-05**: Inserimento nome ospite
- [ ] **RES-06**: Inserimento telefono ospite
- [ ] **RES-07**: Campo note per informazioni aggiuntive
- [ ] **RES-08**: Modifica prenotazione esistente
- [ ] **RES-09**: Eliminazione prenotazione esistente con conferma
- [ ] **RES-10**: Blocco automatico se date si sovrappongono a prenotazione esistente per stessa stanza

### Piattaforme e Colori

- [ ] **PLAT-01**: Booking = Blu
- [ ] **PLAT-02**: Airbnb = Rosa/Rosso
- [ ] **PLAT-03**: WhatsApp = Verde
- [ ] **PLAT-04**: Sito Web = Viola
- [ ] **PLAT-05**: TikTok = Nero/Grigio scuro
- [ ] **PLAT-06**: Possibilità di aggiungere nuove piattaforme con colore personalizzato
- [ ] **PLAT-07**: Colore visibile nel calendario e nella lista prenotazioni

### Dashboard

- [ ] **DASH-01**: Schermata iniziale con panoramica veloce
- [ ] **DASH-02**: Numero stanze occupate oggi
- [ ] **DASH-03**: Lista prossimi check-in ( prossimi 7 giorni)
- [ ] **DASH-04**: Lista prossimi check-out (prossimi 7 giorni)
- [ ] **DASH-05**: Totale incassi del mese corrente
- [ ] **DASH-06**: Accesso rapido al calendario dalla dashboard

### Notifiche

- [ ] **NOT-01**: Notifica 5 giorni prima del check-in
- [ ] **NOT-02**: Notifica 3 giorni prima del check-in
- [ ] **NOT-03**: Notifica 2 giorni prima del check-in
- [ ] **NOT-04**: Notifica 1 giorno prima del check-in
- [ ] **NOT-05**: Notifica il giorno stesso del check-in
- [ ] **NOT-06**: Notifiche includono nome ospite, stanza, date
- [ ] **NOT-07**: Funzionamento su Android (local notifications)
- [ ] **NOT-08**: Funzionamento su Web (browser notifications se supportato)

### Persistenza Dati

- [ ] **DATA-01**: Salvataggio locale dati prenotazioni
- [ ] **DATA-02**: Salvataggio locale configurazione piattaforme/colori
- [ ] **DATA-03**: Persistenza dati tra sessioni
- [ ] **DATA-04**: Database SQLite per Android
- [ ] **DATA-05**: IndexedDB per Web (via sqflite)

### Interfaccia Utente

- [ ] **UI-01**: Design semplice e intuitivo
- [ ] **UI-02**: Navigazione bottom bar: Dashboard, Calendario, Prenotazioni, Impostazioni
- [ ] **UI-03**: Form di creazione/modifica con validazione campi
- [ ] **UI-04**: Lista prenotazioni ordinabile per data
- [ ] **UI-05**: Ricerca prenotazioni per nome ospite
- [ ] **UI-06**: Responsive design per vari schermi (desktop, tablet, mobile)
- [ ] **UI-07**: Dark mode support (opzionale)

### Test

- [ ] **TEST-01**: Unit tests per tutti i modelli dati
- [ ] **TEST-02**: Widget tests per tutti i componenti UI
- [ ] **TEST-03**: Integration tests per flussi core
- [ ] **TEST-04**: Test complete su browser Chrome
- [ ] **TEST-05**: Test complete su dispositivo Android dopo web testing
- [ ] **TEST-06**: Test notifiche
- [ ] **TEST-07**: Test sovrapposizione date e blocchi

### Piattaforme Target

- [ ] **PLATFORM-01**: Funzionamento completo su Chrome (Web)
- [ ] **PLATFORM-02**: Ottimizzazione layout per schermi desktop
- [ ] **PLATFORM-03**: Ottimizzazione layout per schermi mobile
- [ ] **PLATFORM-04**: Funzionamento completo su Android
- [ ] **PLATFORM-05**: Performance fluide su dispositivo Android medio

### Accessibilità

- [ ] **A11Y-01**: Contrast ratio sufficiente per testo
- [ ] **A11Y-02**: Dimensioni touch target minime (48x48dp)
- [ ] **A11Y-03**: Labels per screen readers (Android)

## Versione 2.0 (Future)

### Funzionalità Avanzate

- [ ] **EXP-01**: Export prenotazioni in CSV/PDF
- [ ] **EXP-02**: Backup e restore dati
- [ ] **EXP-03**: Statistiche e reportistiche
- [ ] **EXP-04**: Grafico occupazione anno
- [ ] **EXP-05**: Sync cloud opzionale (Firebase/Supabase)
- [ ] **EXP-06**: Multi-valuta
- [ ] **EXP-07**: Gestione spese aggiuntive
- [ ] **EXP-08**: Sistem di reminder custom per ogni prenotazione

## Out of Scope

- [Multi-utente] — App per uso personale, non serve autenticazione
- [Publishing store] — Non prevista pubblicazione su Play Store/App Store
- [API integration] — Inserimento manuale sufficiente per volume di prenotazioni
- [Payment processing] — Solo tracciamento importi, non processing pagamenti reali
- [Reviews system] — Non necessario per gestione personale
- [Channel manager] — Non prevista integrazione con channel manager esterni
- [Multi-language] — Solo italiano per uso personale
- [iOS support] — Solo Android target dopo web development

## Tracciatura Phase

| REQ-ID | Phase |
|--------|-------|
| ROOM-01 | Phase 1 |
| ROOM-02 | Phase 2 |
| ROOM-03 | Phase 2 |
| CAL-01 | Phase 3 |
| CAL-02 | Phase 3 |
| CAL-03 | Phase 3 |
| CAL-04 | Phase 3 |
| CAL-05 | Phase 4 |
| RES-01 | Phase 2 |
| RES-02 | Phase 2 |
| RES-03 | Phase 2 |
| RES-04 | Phase 2 |
| RES-05 | Phase 2 |
| RES-06 | Phase 2 |
| RES-07 | Phase 2 |
| RES-08 | Phase 4 |
| RES-09 | Phase 4 |
| RES-10 | Phase 2 |
| PLAT-01 | Phase 1 |
| PLAT-02 | Phase 1 |
| PLAT-03 | Phase 1 |
| PLAT-04 | Phase 1 |
| PLAT-05 | Phase 1 |
| PLAT-06 | Phase 5 |
| PLAT-07 | Phase 3 |
| DASH-01 | Phase 4 |
| DASH-02 | Phase 4 |
| DASH-03 | Phase 4 |
| DASH-04 | Phase 4 |
| DASH-05 | Phase 4 |
| DASH-06 | Phase 4 |
| NOT-01 | Phase 5 |
| NOT-02 | Phase 5 |
| NOT-03 | Phase 5 |
| NOT-04 | Phase 5 |
| NOT-05 | Phase 5 |
| NOT-06 | Phase 5 |
| NOT-07 | Phase 6 |
| NOT-08 | Phase 6 |
| DATA-01 | Phase 1 |
| DATA-02 | Phase 1 |
| DATA-03 | Phase 1 |
| DATA-04 | Phase 1 |
| DATA-05 | Phase 1 |
| UI-01 | Phase 3 |
| UI-02 | Phase 3 |
| UI-03 | Phase 2 |
| UI-04 | Phase 4 |
| UI-05 | Phase 5 |
| UI-06 | Phase 4 |
| UI-07 | Phase 5 |
| TEST-01 | Phase 1 |
| TEST-02 | Phase 2 |
| TEST-03 | Phase 3 |
| TEST-04 | Phase 4 |
| TEST-05 | Phase 6 |
| TEST-06 | Phase 5 |
| TEST-07 | Phase 2 |
| PLATFORM-01 | Phase 4 |
| PLATFORM-02 | Phase 4 |
| PLATFORM-03 | Phase 4 |
| PLATFORM-04 | Phase 6 |
| PLATFORM-05 | Phase 6 |
| A11Y-01 | Phase 4 |
| A11Y-02 | Phase 6 |
| A11Y-03 | Phase 6 |

---

## Versione 2.0 - Milestone 2: Performance & Feature Expansion

**Status**: Active
**Created**: 2026-03-07
**Based on**: PRIORITY_FEATURES_TASK.md

### Overview

Milestone 2 focuses on performance optimization, enhanced statistics, UI/UX improvements, and new features requested after MVP completion. Target: scale to 1000+ reservations while maintaining performance.

**Total New Requirements**: 42
**Critical**: 5 | **High**: 15 | **Medium**: 14 | **Low**: 8

---

### Phase 9: Performance Optimization (CRITICO)

#### PERF-01: Lazy Loading Reservation List
**Priority**: CRITICAL
**Type**: Performance

- [ ] Initial load shows only first 20 reservations
- [ ] Load more triggered at 80% scroll position
- [ ] Loading indicator shown during fetch
- [ ] Query uses `LIMIT` and `OFFSET` in SQL
- [ ] Scrolling remains smooth with 500+ reservations loaded
- [ ] Test with 1000 reservations passes

#### PERF-02: Intelligent Period Filters
**Priority**: CRITICAL
**Type**: Performance + UX

- [ ] Filters: Future only, Last 30/90/180 days, Year 2025/2024, Custom range
- [ ] Additional filters: Payment status, Platform, Room
- [ ] Filters use SQL WHERE clauses (not Dart filtering)
- [ ] Filter UI uses FilterChip/ChoiceChip widgets
- [ ] Filter preferences saved to SharedPreferences
- [ ] Result counter shows "X of Y reservations"
- [ ] All filter combinations tested

#### PERF-03: Calendar Query Optimization
**Priority**: CRITICAL
**Type**: Performance

- [ ] Load only visible month + previous/next month
- [ ] Reload when user swipes to different month
- [ ] Debounce reload (300ms) to avoid query spam
- [ ] Test with 3+ years of historical data
- [ ] Month change < 300ms on mid-range device

#### PERF-04: Database Index Optimization
**Priority**: CRITICAL
**Type**: Performance

- [ ] Verify existing indexes on `check_in`, `check_out`, `created_at`
- [ ] Add index on `platform_id` if missing
- [ ] Add index on `payment_status` if missing
- [ ] Add composite index `(check_in, platform_id)` if beneficial
- [ ] Test with `EXPLAIN QUERY PLAN` to verify index usage
- [ ] Document query performance before/after

#### PERF-05: Statistics Caching (24h)
**Priority**: CRITICAL
**Type**: Performance

- [ ] Cache statistics in SharedPreferences or SQLite
- [ ] Cache valid for 24 hours
- [ ] Invalidate cache when reservation added/modified/deleted
- [ ] Show last update timestamp ("Updated: 7 Mar 2025, 10:30")
- [ ] "Refresh now" button to force recalculation
- [ ] Test with 100+ reservations, verify cache hit/miss

---

### Phase 10: UI/UX Restructuring

#### UI-10: Simplified Dashboard
**Priority**: HIGH
**Type**: UX

- [ ] Remove "Calendar Access Card" (calendar is already a tab)
- [ ] Keep: Room Occupancy Grid, Income Breakdown, Upcoming Reservations
- [ ] Add: Next Event Countdown Card (e.g., "Next check-in: 2 days - Mario Rossi")
- [ ] Test responsive layout on mobile/tablet
- [ ] No regression in existing dashboard tests

#### UI-11: Statistics Tab Creation
**Priority**: HIGH
**Type**: Feature

- [ ] New "Statistics" tab replaces "Platforms" tab in navigation
- [ ] Tab order: Dashboard → Calendar → Reservations → Statistics → Settings
- [ ] Statistics page shows time period filters
- [ ] Statistics page shows KPI cards and charts
- [ ] Navigation works correctly
- [ ] Test tab switching performance

#### UI-12: Platforms Moved to Settings
**Priority**: HIGH
**Type**: UX

- [ ] Remove Platforms tab from bottom navigation
- [ ] Add "Platform Management" tile in Settings page
- [ ] Navigation to platforms page works from Settings
- [ ] Deep links to platforms still work (if any)
- [ ] Test navigation flow

#### UI-13: Initial Tab Configuration
**Priority**: LOW
**Type**: UX

- [ ] Dashboard remains default initial tab for now
- [ ] Future consideration: Settings option to choose initial tab
- [ ] Document decision in code comments

---

### Phase 11: Statistics Feature

#### STAT-01: Statistics Domain Layer
**Priority**: HIGH
**Type**: Feature

- [ ] Entity: `DashboardStatistics` with period, revenue, occupancy, etc.
- [ ] Entity: `PlatformRevenue` with platform breakdown
- [ ] Entity: `MonthlyRevenue` for trend data
- [ ] Entity: `YearOverYearComparison` for YoY analysis
- [ ] Repository interface: `StatisticsRepository`
- [ ] All entities use freezed for immutability

#### STAT-02: Statistics Data Layer
**Priority**: HIGH
**Type**: Feature

- [ ] `StatisticsRepositoryImpl` implements calculations
- [ ] SQL queries for platform revenue breakdown
- [ ] SQL queries for monthly revenue trends
- [ ] SQL queries for year-over-year comparison
- [ ] Occupancy rate calculation (occupied days / total available days)
- [ ] Average stay duration calculation
- [ ] Test calculations with known dataset
- [ ] Verify correctness (manual calculation spot-check)

#### STAT-03: Statistics Presentation Layer
**Priority**: HIGH
**Type**: Feature

- [ ] `StatisticsProvider` with Riverpod state management
- [ ] `StatisticsPage` with responsive layout
- [ ] Period filter selector (month, quarter, year, custom)
- [ ] KPI cards: Revenue, Occupancy %, Avg Stay, Booking Count, Guest Count
- [ ] Test all time period filters
- [ ] Loading states and error handling

#### STAT-04: Year-over-Year Comparison Chart
**Priority**: HIGH
**Type**: Feature

- [ ] Bar chart with side-by-side bars (2024 vs 2025)
- [ ] X-axis: months (Jan-Dec)
- [ ] Y-axis: revenue in €
- [ ] Legend showing which color is which year
- [ ] Tooltips on tap/hover showing exact values
- [ ] Test with 2+ years of data

#### STAT-05: Platform Revenue Pie Chart
**Priority**: HIGH
**Type**: Feature

- [ ] Pie chart showing revenue share per platform
- [ ] Platform colors match app theme (Booking=blue, Airbnb=red, etc.)
- [ ] Percentage labels on chart sections
- [ ] Legend with platform name and € amount
- [ ] Test with 3+ platforms having data
- [ ] Handle case with 0 revenue gracefully

#### STAT-06: Monthly Trend Line Chart
**Priority**: HIGH
**Type**: Feature

- [ ] Line chart with months on X-axis, revenue on Y-axis
- [ ] Smooth curve or straight lines connecting data points
- [ ] Grid lines for easier reading
- [ ] Optional: overlay previous year trend (dashed line)
- [ ] Tooltips showing month and amount
- [ ] Test with 12+ months of data

#### STAT-07: Platform Bookings Bar Chart
**Priority**: MEDIUM
**Type**: Feature

- [ ] Bar chart with platforms on X-axis, booking count on Y-axis
- [ ] Bars colored by platform color
- [ ] Value labels on top of bars
- [ ] Sorted by booking count (descending)
- [ ] Test with 3+ platforms

#### STAT-08: FL Chart Integration
**Priority**: HIGH
**Type**: Technical

- [ ] Add `fl_chart: ^0.66.0` to pubspec.yaml
- [ ] Verify compatibility with Flutter 3.38.9+
- [ ] Test rendering on web (Chrome) and Android
- [ ] Test chart animations and interactions
- [ ] Document chart color schemes and styling

---

### Phase 12: Calendar Enhancements

#### CAL-10: Reservation Tap in Bottom Sheet
**Priority**: MEDIUM
**Type**: UX

- [ ] Tap on reservation in day bottom sheet opens edit page
- [ ] Bottom sheet closes before navigation
- [ ] Reservation data passed to edit form
- [ ] Return to calendar after save/cancel
- [ ] Test navigation flow

#### CAL-11: Multiple Reservation Indicators
**Priority**: MEDIUM
**Type**: UX

- [ ] Show up to 4 colored dots (one per reservation) at bottom of day cell
- [ ] If >4 reservations, show "+X" badge in corner
- [ ] Dots use platform colors
- [ ] Test with days having 1, 4, and 10+ reservations
- [ ] Layout doesn't overlap day number

#### CAL-12: Swipe Gesture for Month Navigation
**Priority**: LOW
**Type**: UX

- [ ] Horizontal swipe changes month
- [ ] Swipe left: next month
- [ ] Swipe right: previous month
- [ ] Smooth animation
- [ ] No conflict with day tap gesture
- [ ] Test gesture recognition

---

### Phase 13: Notifications 2.0

#### NOT-10: Test Notification Button
**Priority**: MEDIUM
**Type**: Feature

- [ ] "Send Test Notification" button in Settings
- [ ] Button triggers immediate local notification
- [ ] Notification appears within 5 seconds
- [ ] Snackbar confirms "Notification sent!"
- [ ] Handle case where notifications disabled (show dialog to enable)
- [ ] Test on Android device

#### NOT-11: Notification Log
**Priority**: MEDIUM
**Type**: Feature

- [ ] Database table `notification_logs` created
- [ ] Log entry for every scheduled notification
- [ ] Fields: id, reservation_id, type, scheduled_date, sent_date, status, error_message
- [ ] UI shows log history (date, time, type, status)
- [ ] Status icons: ✓ sent, ⏱ pending, ✗ failed
- [ ] Test logging for all notification types

#### NOT-12: Customizable Notification Days
**Priority**: MEDIUM
**Type**: Feature

- [ ] Settings UI with checkboxes for each day option
- [ ] Options: 5, 3, 2, 1 day(s) before, same day
- [ ] Preferences saved to SharedPreferences
- [ ] NotificationScheduler reads preferences before scheduling
- [ ] Default: all options enabled
- [ ] Test with various combinations

#### NOT-13: Customizable Notification Time
**Priority**: MEDIUM
**Type**: Feature

- [ ] Time picker in settings
- [ ] Time range validation: 9:00-10:00
- [ ] If outside range, clamp to min/max
- [ ] Saved to SharedPreferences
- [ ] NotificationScheduler uses custom time
- [ ] Default: 9:00
- [ ] Test with different times

---

### Phase 14: Data Export

#### EXP-01: Reservation CSV Export
**Priority**: LOW
**Type**: Feature

- [ ] Export button in reservations list AppBar
- [ ] Generates CSV with all filtered reservations
- [ ] CSV format: ID, Guest, Phone, Room, Platform, Check-in, Check-out, Amount, Payment Status, Notes, Created
- [ ] Proper CSV escaping (quotes, commas)
- [ ] Share dialog to save/send file
- [ ] Test CSV opens correctly in Excel
- [ ] Italian localization (comma decimal separator)

#### EXP-02: Statistics CSV Export
**Priority**: LOW
**Type**: Feature

- [ ] Export button in statistics page
- [ ] CSV with KPI summary + platform breakdown + monthly breakdown
- [ ] Multi-section CSV format
- [ ] Share dialog
- [ ] Test CSV opens in Excel

---

### Cross-Cutting Requirements

#### TEST-10: Performance Testing Suite
**Priority**: HIGH
**Type**: Testing

- [ ] Test dataset with 1000+ reservations
- [ ] Automated tests for load times (list, calendar, statistics)
- [ ] Performance benchmarks documented
- [ ] Regression tests for performance

#### TEST-11: Milestone 2 Integration Tests
**Priority**: HIGH
**Type**: Testing

- [ ] Integration test for statistics page (filter → view → chart interaction)
- [ ] Integration test for CSV export flow
- [ ] Integration test for notification customization
- [ ] All tests pass on web and Android

---

### Dependencies

**New Packages Required**:
- `fl_chart: ^0.66.0` - Charting library
- `share_plus: ^7.2.1` - File sharing for CSV export

---

### Success Criteria - Milestone 2

**Performance Targets**:
- [ ] App remains responsive with 1000+ reservations
- [ ] List initial load < 500ms with filters
- [ ] Calendar month change < 300ms
- [ ] Statistics calculation < 1s (with cache: instant)
- [ ] CSV export of 500 reservations < 2s

**UX Targets**:
- [ ] All new features have loading states
- [ ] Error messages are user-friendly
- [ ] Charts are readable on mobile screens
- [ ] Navigation is intuitive
- [ ] No feature regressions from Milestone 1

**Quality Targets**:
- [ ] Test coverage maintained > 80%
- [ ] Zero critical bugs at milestone completion
- [ ] All acceptance criteria met
- [ ] Documentation updated
- [ ] Both web and Android tested

---

### Phase Tracking - Milestone 2

| REQ-ID | Phase | Priority |
|--------|-------|----------|
| PERF-01 | Phase 9 | CRITICAL |
| PERF-02 | Phase 9 | CRITICAL |
| PERF-03 | Phase 9 | CRITICAL |
| PERF-04 | Phase 9 | CRITICAL |
| PERF-05 | Phase 9 | CRITICAL |
| UI-10 | Phase 10 | HIGH |
| UI-11 | Phase 10 | HIGH |
| UI-12 | Phase 10 | HIGH |
| UI-13 | Phase 10 | LOW |
| STAT-01 | Phase 11 | HIGH |
| STAT-02 | Phase 11 | HIGH |
| STAT-03 | Phase 11 | HIGH |
| STAT-04 | Phase 11 | HIGH |
| STAT-05 | Phase 11 | HIGH |
| STAT-06 | Phase 11 | HIGH |
| STAT-07 | Phase 11 | MEDIUM |
| STAT-08 | Phase 11 | HIGH |
| CAL-10 | Phase 12 | MEDIUM |
| CAL-11 | Phase 12 | MEDIUM |
| CAL-12 | Phase 12 | LOW |
| NOT-10 | Phase 13 | MEDIUM |
| NOT-11 | Phase 13 | MEDIUM |
| NOT-12 | Phase 13 | MEDIUM |
| NOT-13 | Phase 13 | MEDIUM |
| EXP-01 | Phase 14 | LOW |
| EXP-02 | Phase 14 | LOW |
| TEST-10 | Cross-cutting | HIGH |
| TEST-11 | Cross-cutting | HIGH |
