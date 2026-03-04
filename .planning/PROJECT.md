# App Prenotazioni Airbnb

## What This Is

Un'applicazione Flutter per la gestione personale delle prenotazioni di un appartamento con 3 stanze private più appartamento intero. L'app permette di visualizzare, gestire e tracciare le prenotazioni da diverse piattaforme (Booking, Airbnb, WhatsApp, Sito Web, TikTok) con un calendario intuitivo e sistema di notifiche per i check-in.

## Core Value

**Visibilità immediata**: Sapere istantaneamente quali stanze sono occupate e quando, con colori diversi per provenienza della prenotazione.

## Requirements

### Validated

(Nessuno ancora - da validare dopo ship)

### Active

- [ ] Gestione stanze (Stanza 1, Stanza 2, Stanza 3, Appartamento Intero)
- [ ] Calendario mensile con visualizzazione prenotazioni colorate per piattaforma
- [ ] Creazione nuova prenotazione con: stanza, date check-in/out, piattaforma, importo
- [ ] Modifica ed eliminazione prenotazioni esistenti
- [ ] Informazioni ospite: nome, telefono, note
- [ ] Piattaforme prenotazione: Booking, Airbnb, WhatsApp, Sito Web, TikTok, + custom
- [ ] Colori distinti per piattaforma (visibili in calendario e lista)
- [ ] Importo prenotazione (ricevuto/da ricevere, campo opzionale)
- [ ] Dashboard con panoramica veloce: stanze occupate oggi, prossimi check-in/out, incassi mese
- [ ] Prevenzione sovrapposizioni date (blocco automatico)
- [ ] Notifiche check-in: 5 giorni, 3 giorni, 2 giorni, 1 giorno prima, giorno stesso
- [ ] Salvataggio dati locale sul dispositivo
- [ ] Test completa con Chrome (web) prima di ottimizzare per Android

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

**Approccio sviluppo**:
1. Sviluppo e test completi su Flutter Web (Chrome)
2. Ottimizzazione finale per Android
3. Test approfonditi su Android dopo che tutto funziona su web
4. Correzione bug e miglioramenti basati sui test reali

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
| Web-first development | Testare su Chrome è più veloce, permette debug immediato, poi ottimizzare Android | — Pending |
| Salvataggio locale | App personale per singolo dispositivo, non serve sincronizzazione cloud | — Pending |
| Colori piattaforma | Visibilità immediata della provenienza prenotazione senza leggere dettagli | — Pending |
| Blocco sovrapposizioni | Prevenire errori umani, garantire che una stanza non sia doppia-prenotata | — Pending |
| Dashboard panoramica | Schermata iniziale con riepilogo veloce per decisioni immediate | — Pending |
| Notifiche multiple check-in | Promemoria progressivi per non dimenticare arrivi ospiti | — Pending |

---
*Last updated: 2026-03-04 after initialization*
