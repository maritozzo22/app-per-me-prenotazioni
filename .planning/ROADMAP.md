# Roadmap - App Prenotazioni Airbnb

## Overview

**8 Phases** | **66 Requirements** | Web-first then Android optimization

## Milestone 1: MVP Web Complete

### Phase 1: Foundation & Data Model
**Goal**: Struttura dati, database locale, e setup base del progetto

**Requirements**: ROOM-01, PLAT-01/02/03/04/05, DATA-01/02/03/04/05, TEST-01

**Plans**: 4 plans in 4 waves

Plans:
- [x] 01-01-PLAN.md — Flutter project setup with dependencies (Wave 1)
- [x] 01-02-PLAN.md — Domain entities with TDD (Wave 2)
- [x] 01-03-PLAN.md — Data models with freezed + JSON serialization (Wave 3)
- [x] 01-04-PLAN.md — Database layer and repository pattern (Wave 4)

**Success Criteria**:
1. Flutter project creato con struttura cartelle corretta
2. Modelli dati definiti (Room, Reservation, Platform, Guest)
3. Database SQLite configurato e funzionante su web
4. Unit tests per tutti i modelli dati passano
5. Repository pattern implementato per accesso dati

**Deliverables**:
- Project Flutter con dipendenze configurate
- Modelli: Room, Reservation, Platform, Guest
- Database helper e repository classes
- Unit tests per modelli (coverage > 80%)
- Configurazione piattaforme con colori di default

---

### Phase 2: CRUD Prenotazioni
**Goal**: Creazione, lettura, modifica, eliminazione prenotazioni con validazione

**Requirements**: ROOM-02/03, RES-01/02/03/04/05/06/07/10, TEST-02/07

**Plans**: 2 plans in 2 waves

Plans:
- [x] 02-01-PLAN.md — Payment status and validation service (Wave 1)
- [x] 02-02-PLAN.md — UI components and form (Wave 2)

**Success Criteria**:
1. Form creazione prenotazione funzionale con tutti i campi
2. Validazione date (check-out > check-in)
3. Blocco sovrapposizioni date per stessa stanza funzionante
4. Gestione appartamento intero (blocca tutte le stanze)
5. Widget tests per form prenotazione passano
6. Integration test per flusso crea→modifica→elimina

**Deliverables**:
- Form crea/modifica prenotazione
- Service layer per business logic
- Validazioni e controllo sovrapposizioni
- Widget tests per form components
- Integration test per CRUD operations

---

### Phase 3: Calendario
**Goal**: Visualizzazione calendario mensile con prenotazioni colorate

**Requirements**: CAL-01/02/03/04/05, PLAT-07, UI-01/02, TEST-03

**Plans**: 4 plans in 4 waves

Plans:
- [ ] 03-01-PLAN.md — State management and date grouping service (Wave 1)
- [ ] 03-02-PLAN.md — Calendar UI widget with platform colors (Wave 2)
- [ ] 03-03-PLAN.md — Day details bottom sheet (Wave 3)
- [ ] 03-04-PLAN.md — Calendar page integration and testing (Wave 4)

**Success Criteria**:
1. Calendario mensile visualizzato correttamente
2. Giorni con prenotazioni mostrano colore piattaforma
3. Navigazione mesi funzionale
4. Click/tap su giorno mostra dettagli prenotazioni
5. Widget tests per calendario passano
6. Integration test per visualizzazione prenotazioni
7. Funziona su web (Chrome) e Android

**Deliverables**:
- Calendar widget con table_calendar
- CalendarProvider con state management
- CalendarService per raggruppamento date
- Logica colorazione giorni per piattaforma
- Dettagli prenotazioni per giorno selezionato (bottom sheet)
- Widget tests per calendar component
- Integration test per visualization
- CalendarPage come home screen

---

### Phase 4: Dashboard & Navigation
**Goal**: Schermata iniziale con panoramica e navigazione completa

**Requirements**: CAL-05, DASH-01/02/03/04/05/06, RES-08/09, UI-04/06, TEST-04, A11Y-01

**Plans**: 4 plans in 4 waves

Plans:
- [ ] 04-01-PLAN.md — Dashboard statistics service and provider (Wave 1)
- [ ] 04-02-PLAN.md — Dashboard UI with responsive layout (Wave 2)
- [ ] 04-03-PLAN.md — Reservations list with swipe actions (Wave 3)
- [ ] 04-04-PLAN.md — Navigation shell and integration (Wave 4)

**Success Criteria**:
1. Dashboard mostra stanze occupate oggi
2. Dashboard mostra prossimi check-in/out (7 giorni)
3. Dashboard mostra incassi mese corrente (ricevuto + in attesa)
4. Navigazione bottom bar funzionante
5. Lista prenotazioni con accesso a modifica/elimina
6. Design responsive per desktop e mobile (600px breakpoint)
7. Tutti i test web (unit, widget, integration) passano
8. App testata completamente su Chrome

**Deliverables**:
- DashboardStatisticsService per calcolo statistiche
- DashboardProvider con state management
- DashboardPage con room occupancy grid (2x2)
- IncomeBreakdownCard con breakdown ricevuto/pendente
- UpcomingReservationsCard per arrivi/partenze
- CalendarAccessCard per accesso calendario
- ReservationsListPage con swipe actions (flutter_slidable)
- EditReservationPage che riusa ReservationForm
- AppShell con IndexedStack e BottomNavigationBar
- Responsive layout con LayoutBuilder
- Widget tests per tutti i componenti
- Integration tests per navigazione
- Test report documentato

---

### Phase 5: Advanced Features
**Goal**: Ricerca avanzata, gestione piattaforme custom, dark mode, preparazione notifiche

**Requirements**: UI-05/07, PLAT-06, NOT-01/02/03/04/05/06, TEST-06

**Plans**: 5 plans in 5 waves

Plans:
- [x] 05-01-PLAN.md — Platform management & search foundation (Wave 1)
- [x] 05-02-PLAN.md — Platform management UI (Wave 2)
- [x] 05-03-PLAN.md — Search UI implementation (Wave 3)
- [x] 05-04-PLAN.md — Dark mode theme system (Wave 4)
- [x] 05-05-PLAN.md — Notification scheduling foundation (Wave 5)

**Success Criteria**:
1. Ricerca prenotazioni funzionante (nome, telefono, note)
2. Gestione piattaforme completa (aggiungi, modifica, elimina tutte)
3. Dark mode toggle e styling coerente
4. Notification scheduling logic implementata (pronta per Android)
5. Tutti i test passano (47+ tests)
6. UI ottimizzata per dark mode

**Deliverables**:
- Search functionality with full-text search
- Platform management screen (list + form + color picker)
- Dark mode theme with persistence
- Notification scheduling service (foundation for Phase 6)
- 47+ tests (unit, widget, integration)

---

### Phase 6: Android Optimization
**Goal**: Ottimizzazione per Android, test dispositivo reale

**Requirements**: PLATFORM-04/05, NOT-07, TEST-05, A11Y-02/03

**Success Criteria**:
1. App funziona su dispositivo Android
2. Performance fluide su dispositivo medio
3. Local notifications funzionano su Android
4. Touch target sizes corretti (48x48dp)
5. Screen reader labels presenti
6. Tutti i test passano su Android
7. Bug individuati durante testing corretti

**Deliverables**:
- Android-specific optimizations
- Local notifications plugin configuration
- Accessibility improvements
- Android device testing report
- Bug fixes e improvements
- Performance optimizations

---

### Phase 7: Polish & Documentation
**Goal**: Rifiniture, documentazione, preparazione deployment personale

**Requirements**: (nessun nuovo requirement, polish di esistenti)

**Success Criteria**:
1. Code review e cleanup completato
2. Documentazione utente scritta
3. README con istruzioni setup/running
4. Error handling robusto
5. Loading states e feedback utente
6. Animazioni fluide

**Deliverables**:
- Code refactoring e cleanup
- User documentation
- Developer documentation
- Error handling migliorato
- UI/UX polish
- Final bug fixes

---

### Phase 8: Deployment & Verification
**Goal**: Build Android APK, installazione dispositivo personale, verifica finale

**Requirements**: (deployment)

**Success Criteria**:
1. Android APK generato con successo
2. APK installato su dispositivo personale
3. App verificata con dati reali
4. Backup dati configurato
5. Procedura aggiornamento documentato

**Deliverables**:
- Release APK (non per Play Store)
- Installation guide
- Backup/restore procedure
- Final verification report
- User guide completo

---

## Phase Summary

| Phase | Name | Requirements | Est. Complexity |
|-------|------|--------------|-----------------|
| 1 | Foundation & Data Model | 15 | Medium |
| 2 | CRUD Prenotazioni | 10 | High |
| 3 | Calendario | 8 | Medium |
| 4 | Dashboard & Navigation | 13 | High |
| 5 | Advanced Features | 8 | Medium |
| 6 | Android Optimization | 7 | High |
| 7 | Polish & Documentation | 0 (polish) | Low |
| 8 | Deployment & Verification | 0 (deployment) | Low |

## Parallelization Strategy

**Parallel-safe combinations**:
- Phase 1 deve essere completata prima di tutto (foundation)
- Phase 2 e 3 possono essere sviluppate in parallelo dopo Phase 1
- Phase 4 dipende da Phase 2 e 3
- Phase 5 puo iniziare dopo Phase 4
- Phase 6 dipende da tutte le precedenti (Android optimization)
- Phase 7 e 8 sequenziali alla fine

## Risk Mitigation

**High Risk Areas**:
1. **Calendar complexity** (Phase 3): Usare libreria table_calendar testata
2. **Sovrapposizioni date** (Phase 2): Integration tests approfonditi
3. **Web performance** (Phase 4): Test con dataset grandi (100+ prenotazioni)
4. **Android differences** (Phase 6): Test early su Android device reale

## Definition of Done

Per ogni phase:
- [ ] Tutti i requirements implementati
- [ ] Tutti i test (unit, widget, integration) passano
- [ ] Code review passata
- [ ] Documentation aggiornata
- [ ] Zero bug critici
- [ ] Performance accettabile

Per il progetto completo:
- [ ] Tutte le 8 phase completate
- [ ] Web testing su Chrome completato
- [ ] Android testing su dispositivo reale completato
- [ ] Documentazione utente completa
- [ ] APK installabile su dispositivo personale
