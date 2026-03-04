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
