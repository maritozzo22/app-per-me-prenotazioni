# Phase 2 Context: CRUD Prenotazioni

**Phase Goal**: Creazione, lettura, modifica, eliminazione prenotazioni con validazione

**Requirements**: ROOM-02/03, RES-01/02/03/04/05/06/07/10, TEST-02/07

---

## Prior Context (From Phase 1)

### Existing Code Assets
| Asset | Location | Notes |
|-------|----------|-------|
| `Reservation` entity | `lib/features/reservations/domain/entities/reservation.dart` | Has `overlapsWith()` method for date overlap |
| `Room` entity | `lib/features/reservations/domain/entities/room.dart` | Has `RoomType` enum, default rooms list |
| `Guest` entity | `lib/features/reservations/domain/entities/guest.dart` | Name + optional phone |
| `BookingPlatform` entity | `lib/features/reservations/domain/entities/platform.dart` | Locked colors for default platforms |
| `ReservationRepository` | `lib/features/reservations/domain/repositories/` | Interface with CRUD + date range methods |
| `ReservationRepositoryImpl` | `lib/features/reservations/data/repositories/` | SQLite-backed implementation |
| `ReservationLocalDataSource` | `lib/features/reservations/data/datasources/` | Direct DB operations |

### Locked Decisions
- **Date overlap logic**: `overlapsWith()` allows same-day turnaround (check-out = next check-in is OK)
- **Room types**: `singleRoom` (Stanza 1/2/3) and `entireApartment`
- **Default platforms**: Booking(blue #2196F3), Airbnb(pink #E91E63), WhatsApp(green #4CAF50), Website(purple #9C27B0), TikTok(black #212121)
- **Database**: SQLite with reservations, rooms, platforms tables
- **Testing**: TDD with unit tests for entities/models

---

## User Decisions

### 1. Form UX Flow

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Form layout | **Single page form** | Classic scrollable form with all fields visible |
| Mandatory fields | **Nome, Date, Stanza, Piattaforma** | Essential fields only - keeps form simple |
| Optional fields | Importo, Telefono, Note | Available but not required |
| Notes field | **Multi-line textarea** | Expandable for detailed notes (arrival times, requests) |
| Amount field | **Amount + payment status** | Toggle/checkbox for "Già ricevuto" vs "In attesa" |

**Form Fields Order (top to bottom)**:
1. Stanza (dropdown - filtered by availability)
2. Check-in date
3. Check-out date
4. Piattaforma (dropdown)
5. Nome ospite (text)
6. Telefono (text, optional)
7. Importo (number + payment status toggle)
8. Note (multi-line textarea, optional)

### 2. Validation Feedback

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Overlap error display | **Inline + details** | Show error below dates with conflicting reservation info |
| Validation timing | **Real-time** | Validate as user types/selects, not just on submit |
| Room availability preview | **Show available rooms only** | Dropdown filters to only show rooms free for selected dates |
| Check-out validation | **Simple validation** | Error message if check-out <= check-in |

**Overlap Error Format**:
```
Sovrapposizione date: Stanza 1 già prenotata da Mario Rossi (15-18 giugno)
```

**Real-time Validation Points**:
- Check-in selected → validate against existing reservations
- Check-out selected → validate check-out > check-in AND no overlaps
- Room selected → immediately check if room is free for dates
- Form is valid → enable Save button; invalid → disable with red indicators

### 3. Apartment Blocking Behavior

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Apartment booking confirmation | **Show confirmation** | Warn user that all 3 rooms will be blocked |
| Apartment vs room conflict | **Block apartment** | If ANY room booked, apartment unavailable |
| Blocked message | **Show which room blocks it** | Specific: "Appartamento non disponibile: Stanza 2 occupata 15-18 giugno" |
| Visual indication | **Gray out in dropdown** | Apartment shown but disabled with tooltip |

**Business Rules**:
- Booking apartment → blocks Stanza 1, Stanza 2, Stanza 3
- If Stanza 1/2/3 booked → apartment blocked for those dates
- Adjacent dates ARE allowed (check-out day = next check-in day)

**Confirmation Dialog for Apartment**:
```
Titolo: Prenotazione Appartamento Intero
Messaggio: Questa prenotazione bloccherà tutte e 3 le stanze (Stanza 1, 2, 3) per le date selezionate. Continuare?
Pulsanti: [Annulla] [Conferma]
```

### 4. Delete Confirmation

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Confirmation style | **Dialog with details** | Shows guest name, dates, room before confirming |
| Delete access points | **List + detail screens** | Swipe-to-delete on list, button on detail/edit |
| Undo option | **Yes, 5 second undo** | Snackbar with Undo action |
| Post-delete feedback | **Simple toast** | "Prenotazione eliminata" message |

**Delete Confirmation Dialog**:
```
Titolo: Eliminare la prenotazione?
Dettagli:
- Ospite: Mario Rossi
- Stanza: Stanza 1
- Date: 15-18 giugno 2024
Pulsanti: [Annulla] [Elimina]
```

**Undo Snackbar**:
```
Messaggio: Prenotazione eliminata
Azione: [Annulla] (visible for 5 seconds)
```

---

## Code Context

### Service Layer Needed
Phase 2 requires a **service layer** between UI and repository for:
- Validation logic (date overlap, room availability)
- Apartment blocking rules
- Payment status tracking

**New file**: `lib/features/reservations/domain/services/reservation_service.dart`

### Data Model Extensions
- Add `paymentStatus` field to Reservation (enum: received, pending)
- Update `ReservationModel` and database schema

### UI Components Needed
| Component | Purpose |
|-----------|---------|
| `ReservationForm` | Create/edit form widget |
| `RoomDropdown` | Dropdown with availability filtering |
| `PlatformDropdown` | Platform selector with colors |
| `DateRangePicker` | Check-in/out date selection |
| `PaymentStatusToggle` | Received/Pending toggle |
| `DeleteConfirmationDialog` | Delete dialog with details |
| `UndoSnackbar` | Snackbar with undo action |

---

## Testing Strategy

### Widget Tests (TEST-02)
- Form validation displays errors correctly
- Room dropdown filters by availability
- Apartment confirmation dialog appears
- Delete confirmation shows reservation details
- Undo snackbar restores deleted reservation

### Integration Tests (TEST-07)
- Create → Read → Update → Delete flow
- Date overlap prevention works
- Apartment blocking prevents room double-booking
- Real-time validation responds to input

---

## Deferred Ideas

*None identified - scope is clear*

---

## Next Steps

1. `/gsd:research-phase 2` - Research Flutter form patterns, validation libraries
2. `/gsd:plan-phase 2` - Create detailed implementation plan

---

*Context captured: 2026-03-04*
