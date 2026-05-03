# Phase 15: Sistema Gestione Magazzino Inventario - Context

**Gathered:** 2026-04-12
**Status:** Ready for planning

<domain>
## Phase Boundary

Sistema di gestione inventario personale per l'appartamento Airbnb. Traccia articoli alimentari con scadenze (deperibilità) e tessili (asciugamani, lenzuola) con quantità. L'utente fa conteggio periodico ogni 2-3 mesi e registra differenze (+/-). Include notifiche per prodotti in scadenza e indicatori visivi colorati.

Non include: tracciamento spese/costi, gestione fornitori, ordini automatici, integrazione esterna.
</domain>

<decisions>
## Implementation Decisions

### Categorie e Organizzazione
- **D-01:** 3 categorie fisse: Alimentari, Tessili, Altro
- **D-02:** Unica lista filtrabile per categoria — nessun comportamento speciale per tipo
- **D-03:** Ogni item ha: nome, categoria, quantità attuale, data scadenza (solo per Alimentari), note opzionali

### Gestione Scadenze
- **D-04:** Doppio sistema di avviso: colori nella lista (rosso = scaduto, arancione = scade presto, verde = ok) + notifiche push
- **D-05:** Notifica 3 giorni prima della scadenza (solo per Alimentari)
- **D-06:** Data di scadenza singola per item — inserimento diretto della data, non calcolo da data acquisto

### Movimenti Magazzino
- **D-07:** Tracciamento periodico: l'utente registra +/- manualmente quando fa il conteggio (ogni 2-3 mesi)
- **D-08:** Ogni registrazione contiene solo: data, quantità +/- (nessun motivo/nota obbligatori)
- **D-09:** Lo storico delle registrazioni è visibile per ogni item (data + delta quantità)
- **D-10:** Quantità può diventare negativa per indicare perdite/spiriti (es: asciugamani scomparsi)

### Posizione nell'App
- **D-11:** Nuova tab "Magazzino" sostituisce tab "Impostazioni" nella bottom navigation
- **D-12:** Impostazioni diventa icona ingranaggio nell'AppBar della Dashboard
- **D-13:** 5 tab finali: Dashboard, Calendario, Prenotazioni, Statistiche, Magazzino

### Claude's Discretion
- Schema database (tabelle, colonne, relazioni)
- Design UI pagina magazzino (layout cards/lista, filtri, form inserimento)
- Implementazione notifiche scadenza (riuso sistema notifiche esistente)
- Ordinamento default della lista magazzino
- Gestione item scaduti (eliminazione automatica vs manuale)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Existing notification system
- `lib/features/notifications/` — Notification system for reuse of push notification infrastructure
- `lib/features/notifications/application/notification_service.dart` — NotificationService for scheduling local notifications
- `lib/features/notifications/application/reservation_notification_scheduler.dart` — Existing scheduler pattern for periodic notifications

### Navigation and app shell
- `lib/core/presentation/pages/app_shell.dart` — AppShell with IndexedStack and BottomNavigationBar (needs modification)
- `lib/core/presentation/pages/settings_page.dart` — Settings page (will move to AppBar)

### Domain patterns
- `lib/features/reservations/domain/entities/` — Entity patterns to follow (freezed, value objects)
- `lib/features/reservations/data/datasources/` — SQLite data source patterns
- `lib/core/database/database_helper.dart` — Database helper for SQLite migrations

### Feature structure
- `lib/features/statistics/` — Complete feature structure example (domain/data/presentation)
- `lib/features/platforms/` — Feature with custom items and color management

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **NotificationService**: Sistema notifiche esistente con scheduling — riutilizzabile per notifiche scadenza alimentari
- **DatabaseHelper**: Migration SQLite già strutturato — aggiungere tabelle magazzino con migration
- **AppShell**: BottomNavigationBar con IndexedStack — modificare per nuova tab e spostare settings
- **Platform management pattern**: CRUD con colori personalizzati — pattern simile per categorie magazzino

### Established Patterns
- **Feature-first architecture**: domain/data/presentation per ogni feature
- **Riverpod state management**: Provider + AsyncNotifier per state management
- **Freezed entities**: Entità immutabili con freezed per dati
- **TDD**: Test prima dell'implementazione (come da PROJECT.md)
- **SQLite locale**: Database locale con repository pattern

### Integration Points
- **AppShell**: Modifica bottom navigation (5 tab con Magazzino al posto di Impostazioni)
- **Dashboard AppBar**: Aggiungere icona settings
- **Notification system**: Agganciare notifiche scadenza al sistema esistente
- **Database migration**: Aggiungere tabelle inventory_items, inventory_movements

</code_context>

<specifics>
## Specific Ideas

- L'utente visita l'appartamento ogni 2-3 mesi, non ha bisogno di tracciamento giornaliero
- L'obiettivo principale è sapere cosa ha in magazzino e cosa è sparito (es: asciugamani che spariscono)
- Il deperibile è il problema principale per i cibi — vuole vedere rapidamente cosa sta per scadere
- La gestione deve essere rapida: inserire conteggio e andare via

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 15-sistema-gestione-magazzino-inventario*
*Context gathered: 2026-04-12*
