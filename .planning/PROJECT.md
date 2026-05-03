# App Prenotazioni Airbnb

## What This Is

Un'applicazione Flutter per la gestione personale delle prenotazioni di un appartamento con 3 stanze private più appartamento intero. L'app permette di visualizzare, gestire e tracciare le prenotazioni da diverse piattaforme (Booking, Airbnb, WhatsApp, Sito Web, TikTok) con un calendario intuitivo e sistema di notifiche per i check-in.

## Core Value

**Visibilità immediata**: Sapere istantaneamente quali stanze sono occupate e quando, con colori diversi per provenienza della prenotazione.

## Requirements

### Validated

(Nessuno ancora - da validare dopo ship)

### Active - Milestone 1: MVP Web Complete (66 requirements)

- [x] Gestione stanze (Stanza 1, Stanza 2, Stanza 3, Appartamento Intero)
- [x] Calendario mensile con visualizzazione prenotazioni colorate per piattaforma
- [x] Creazione nuova prenotazione con: stanza, date check-in/out, piattaforma, importo
- [x] Modifica ed eliminazione prenotazioni esistenti
- [x] Informazioni ospite: nome, telefono, note
- [x] Piattaforme prenotazione: Booking, Airbnb, WhatsApp, Sito Web, TikTok, + custom
- [x] Colori distinti per piattaforma (visibili in calendario e lista)
- [x] Importo prenotazione (ricevuto/da ricevere, campo opzionale)
- [x] Dashboard con panoramica veloce: stanze occupate oggi, prossimi check-in/out, incassi mese
- [x] Prevenzione sovrapposizioni date (blocco automatico)
- [x] Notifiche check-in: 5 giorni, 3 giorni, 2 giorni, 1 giorno prima, giorno stesso
- [x] Salvataggio dati locale sul dispositivo
- [x] Test completa con Chrome (web) prima di ottimizzare per Android

### Active - Milestone 2: Performance & Feature Expansion (42 requirements)

**Focus**: Scale to 1000+ reservations, enhanced statistics, UX improvements

- [ ] **Performance Optimization (5 reqs - CRITICAL)**
  - Lazy loading lista prenotazioni (paginazione 20+20)
  - Filtri intelligenti SQL-based (periodo, piattaforma, camera, stato pagamento)
  - Ottimizzazione calendario (carica solo mese visibile)
  - Ottimizzazione indici database
  - Cache statistiche 24h

- [ ] **UI/UX Restructuring (4 reqs)**
  - Dashboard semplificata (rimuovi card calendario ridondante)
  - Nuova tab Statistiche (sostituisce Piattaforme)
  - Piattaforme spostate in Impostazioni
  - Countdown prossimo evento in dashboard

- [ ] **Statistics Feature (8 reqs)**
  - Domain layer con entità statistiche
  - Data layer con calcoli e query SQL
  - Presentation layer con filtri temporali
  - 4 grafici con FL Chart: Year-over-Year, Platform Revenue, Monthly Trend, Platform Bookings
  - KPI cards: Revenue, Occupancy, Avg Stay, Bookings, Guests

- [ ] **Calendar Enhancements (3 reqs)**
  - Tap su prenotazione nel bottom sheet per modifica
  - Indicatori multipli per giorni con >1 prenotazione
  - Swipe gesture per cambiare mese

- [ ] **Notifications 2.0 (4 reqs)**
  - Tasto "Test Notifica"
  - Log notifiche inviate
  - Giorni prima personalizzabili
  - Orario personalizzabile (9:00-10:00)

- [ ] **Data Export (2 reqs)**
  - Export CSV prenotazioni (con share_plus)
  - (Opzionale) Export CSV statistiche

- [ ] **Cross-cutting (2 reqs)**
  - Performance testing suite (1000+ reservations)
  - Integration tests per nuove feature

### Out of Scope

- [Sincronizzazione cloud/multi-dispositivo] — App personale per uso singolo, salvataggio locale sufficiente
- [Pubblicazione Play Store/App Store] — App per uso personale, non per distribuzione pubblica
- [Gestione pagamenti elettronici] — Solo tracciamento importi, non processing pagamenti
- [Multi-valuta] — Solo Euro (€)
- [Autenticazione multi-utente] — App per singolo utente
- [Sistema di recensioni] — Non necessario per gestione personale
- [Integrazione API Booking/Airbnb] — Inserimento manuale sufficiente

## Context

**Utente**: Proprietario di appartamento con 3 stanze private + appartamento intero
**Piattaforme oggi**: Booking, Airbnb, WhatsApp, Sito Web, TikTok
**Esigenza**: Gestione centralizzata con visibilità immediata e promemoria automatici
**Problema attuale**: Difficoltà a ricordare date e contatti ospiti, rischio overbooking

**Milestone 1 (MVP)**: Completata funzionalità base - calendario, prenotazioni, dashboard, notifiche
**Milestone 2 (Performance & Expansion)**: Ottimizzazione per scala (1000+ prenotazioni), statistiche avanzate, UX migliorata

**Approccio sviluppo**:
1. Sviluppo e test completi su Flutter Web (Chrome)
2. Ottimizzazione finale per Android
3. Test approfonditi su Android dopo che tutto funziona su web
4. Correzione bug e miglioramenti basati sui test reali
5. **Milestone 2**: Performance optimization prima di scalare, poi nuove feature

**Metodologia**: TDD (Test-Driven Development) con test automatizzati per tutte le funzionalità core

## Constraints

- **Tech Stack**: Flutter 3.38.9+ (Dart 3.10.8+) — scelta per cross-platform web+Android da singolo codebase
- **Piattaforme target**: Web (Chrome) per sviluppo/test, Android per produzione
- **Database**: SQLite locale (flutter_sqflite per Android,IndexedDB per web via sqflite_common_ffi)
- **Timeline**: Sviluppo iterativo con testing web prima di ottimizzare Android
- **Performance**: Devono funzionare bene su browser Chrome e dispositivo Android medio
- **Offline-first**: Dati salvati localmente, non richiede connessione internet
- **Notifiche**: Local notifications (flutter_local_notifications)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Web-first development | Testare su Chrome è più veloce, permette debug immediato, poi ottimizzare Android | ✅ Success - MVP completato rapidamente |
| Salvataggio locale | App personale per singolo dispositivo, non serve sincronizzazione cloud | ✅ Success - SQLite affidabile |
| Colori piattaforma | Visibilità immediata della provenienza prenotazione senza leggere dettagli | ✅ Success - UX migliorata |
| Blocco sovrapposizioni | Prevenire errori umani, garantire che una stanza non sia doppia-prenotata | ✅ Success - Zero overbooking |
| Dashboard panoramica | Schermata iniziale con riepilogo veloce per decisioni immediate | ✅ Success - Utente soddisfatto |
| Notifiche multiple check-in | Promemoria progressivi per non dimenticare arrivi ospiti | ✅ Success - Notifiche funzionano |
| **Milestone 2: Performance-first** | Ottimizzare prima di aggiungere feature, prevenire problemi di scalabilità | 🔄 In Progress |
| **Lazy loading** | Caricare 20 prenotazioni alla volta per mantenere performance | 🔄 Planned - Phase 9 |
| **SQL-based filters** | Filtrare nel database, non in memoria, per performance ottimali | 🔄 Planned - Phase 9 |
| **Statistics caching** | Evitare ricalcolo costoso, cache 24h con invalidazione automatica | 🔄 Planned - Phase 9 |
| **FL Chart per grafici** | Libreria matura e performante per visualizzazioni statistiche | 🔄 Planned - Phase 11 |
| **Tab Statistiche** | Dedicare spazio alle analisi, rimuovere dalla dashboard | 🔄 Planned - Phase 10 |

---

## Milestone History

### Milestone 1: MVP Web Complete
**Status**: Phase 7 in Progress (Wave 2/5 complete)
**Started**: 2026-03-04
**Phases**: 1-8 (Foundation → Deployment)
**Requirements**: 66
**Key Deliverables**: Calendario, Prenotazioni CRUD, Dashboard, Notifiche, Android optimization

### Milestone 2: Performance & Feature Expansion
**Status**: Planning Complete, Ready to Start
**Started**: 2026-03-07 (planning)
**Phases**: 9-14 (Performance → Export)
**Requirements**: 42
**Key Deliverables**: Lazy loading, Filtri avanzati, Statistiche con grafici, Notifiche 2.0, CSV export

---

*Last updated: 2026-04-13 after Phase 15 completion*
