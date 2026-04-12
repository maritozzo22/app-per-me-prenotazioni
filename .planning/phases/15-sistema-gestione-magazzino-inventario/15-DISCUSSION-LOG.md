# Phase 15: Sistema Gestione Magazzino Inventario - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-12
**Phase:** 15-sistema-gestione-magazzino-inventario
**Areas discussed:** Categorie e Organizzazione, Gestione Scadenze, Movimenti Magazzino, Posizione nell'App

---

## Scopo del Sistema

L'utente ha chiarito che il sistema serve per:
1. Gestire la deperibilità dei prodotti alimentari che acquista
2. Tenere conto di asciugamani e lenzuola (quanti spariscono)
3. Fare conteggio periodico ogni 2-3 mesi (non giornaliero)

---

## Categorie e Organizzazione

| Option | Description | Selected |
|--------|-------------|----------|
| Categorie fisse (4-5) | Es: Cibo, Tessili, Pulizia, Igiene, Altro. Semplice, facile da filtrare. | |
| Categorie personalizzabili | Creare categorie come per piattaforme. Più flessibile ma più setup. | |
| Senza categorie | Ogni item è unico con nome e tipo. Più semplice, meno struttura. | |

**User's choice:** Categorie fisse — poi ha scelto 3 categorie: Alimentari, Tessili, Altro

| Option | Description | Selected |
|--------|-------------|----------|
| Unica lista per categoria | Solo nome, categoria, quantità, scadenza. Lista filtrabile. | ✓ |
| Comportamento per categoria | Ogni categoria ha comportamento diverso (scadenza, stato, ecc.) | |

**User's choice:** Unica lista filtrabile per categoria

---

## Gestione Scadenze

| Option | Description | Selected |
|--------|-------------|----------|
| Colori nella lista | Rosso = scaduto, arancione = scade presto, verde = ok | |
| Notifiche push | Avviso quando qualcosa sta per scadere | |
| Entrambi | Colori + notifiche push | ✓ |

**User's choice:** Entrambi (colori + notifiche)

| Option | Description | Selected |
|--------|-------------|----------|
| 3 giorni prima | Notifica 3 giorni prima della scadenza | ✓ |
| 1 giorno prima | 1 giorno prima + giorno stesso | |
| Personalizzabile | L'utente sceglie giorni (default 3) | |

**User's choice:** 3 giorni prima

| Option | Description | Selected |
|--------|-------------|----------|
| Data singola per item | Ogni prodotto ha la sua data di scadenza | ✓ |
| Data acquisto + giorni vita | Scadenza calcolata da acquisto + giorni conservazione | |

**User's choice:** Data singola per item

---

## Movimenti Magazzino

| Option | Description | Selected |
|--------|-------------|----------|
| Quantità +1/-1 | Aggiungi/diminuisci quantità. Zero = finito. | |
| Storico movimenti completo | Ogni movimento registrato con data e motivo | |
| Solo stato attuale | Solo aggiungi/rimuovi, nessuno storico | |

**User's choice:** Input personalizzato — l'utente fa conteggio ogni 2-3 mesi e registra differenze. Non vuole tracciamento giornaliero.

| Option | Description | Selected |
|--------|-------------|----------|
| Conteggio reale + differenza auto | Inserisci numeri attuali, sistema calcola differenza | |
| Registra +/- manualmente | Inserisci manualmente quanti aggiunti/tolti | ✓ |

**User's choice:** Registra +/- manualmente

| Option | Description | Selected |
|--------|-------------|----------|
| Solo quantità +/- | Solo data e delta quantità. Veloce. | ✓ |
| Con motivo/nota opzionale | Anche il motivo: perso, consumato, ecc. | |

**User's choice:** Solo quantità + data

---

## Posizione nell'App

| Option | Description | Selected |
|--------|-------------|----------|
| Nuova tab nella barra | Sostituisce una tab esistente | |
| In Impostazioni | Accessibile ma non prominente | |
| Accesso da Dashboard | Tile in Dashboard + pagina dedicata | |

**User's choice:** Personalizzato — sostituire tab Impostazioni con Magazzino, spostare Impostazioni come icona ingranaggio nell'AppBar della Dashboard.

Confermato: 5 tab finali = Dashboard, Calendario, Prenotazioni, Statistiche, Magazzino. Settings = icona in AppBar Dashboard.

---

## Claude's Discretion

- Schema database (tabelle, colonne, relazioni)
- Design UI pagina magazzino (layout, filtri, form)
- Implementazione notifiche scadenza (riuso sistema esistente)
- Ordinamento default lista
- Gestione item scaduti

## Deferred Ideas

Nessuna — la discussione è rimasta entro lo scope della fase
