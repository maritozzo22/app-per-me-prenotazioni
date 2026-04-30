# Phase 12: Calendar Enhancements - Context

## Overview

**Goal**: Migliorare interattivita e feedback visivo calendario

**Requirements**: CAL-10, CAL-11, CAL-12

**Estimated Duration**: 1 day

## Requirements Mapping

| ID | Requirement | Description |
|----|-------------|-------------|
| CAL-10 | Bottom sheet tappabile | Tap su prenotazione nel bottom sheet apre modifica |
| CAL-11 | Indicatori multipli | Giorni con piu prenotazioni mostrano indicatori multipli (fino a 4 dots, poi "+X") |
| CAL-12 | Swipe gestures | Swipe orizzontale cambia mese con navigazione fluida |

## Current Implementation Analysis

### Bottom Sheet (CAL-10)
**File**: `lib/features/reservations/presentation/widgets/day_detail_bottom_sheet.dart`

**Current State**:
- Shows reservations in a `ListView` using `ReservationDayCard`
- Cards are purely informational, NOT tappable
- No navigation to edit page

**Changes Needed**:
- Make `ReservationDayCard` tappable (GestureDetector or InkWell)
- Navigate to `EditReservationPage` on tap
- Close bottom sheet after navigation

### Multi-Reservation Indicators (CAL-11)
**File**: `lib/features/reservations/presentation/widgets/reservation_calendar.dart`

**Current State** (lines 223-250):
- `markerBuilder` shows up to 3 colored dots
- No "+X" indicator for more than 3 reservations
- Dots are 6px circles

**Changes Needed**:
- Increase max dots to 4
- Add "+X" text indicator for 5+ reservations
- Improve positioning and visibility

### Swipe Gestures (CAL-12)
**File**: `lib/features/reservations/presentation/widgets/reservation_calendar.dart`

**Current State**:
- TableCalendar already supports swipe via `onPageChanged`
- Lazy loading implemented in `CalendarProvider`
- Debouncer prevents rapid-fire queries

**Changes Needed**:
- Verify gesture feedback is smooth
- Add haptic feedback on month change (Android)
- Ensure no lag during swipe animation

## Key Files

### To Modify
1. `lib/features/reservations/presentation/widgets/day_detail_bottom_sheet.dart`
2. `lib/features/reservations/presentation/widgets/reservation_day_card.dart`
3. `lib/features/reservations/presentation/widgets/reservation_calendar.dart`

### To Reference
1. `lib/features/reservations/presentation/pages/edit_reservation_page.dart` - Navigation target
2. `lib/features/reservations/presentation/providers/calendar_provider.dart` - State management
3. `lib/features/reservations/domain/entities/platform.dart` - Platform colors

## Navigation Pattern

From `reservations_list_page.dart`:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EditReservationPage(reservation: reservation),
  ),
);
```

## Success Criteria

1. ✅ Tap su prenotazione nel bottom sheet apre modifica
2. ✅ Giorni con piu prenotazioni mostrano indicatori multipli (4 dots + "+X")
3. ✅ Swipe orizzontale cambia mese con feedback fluido
4. ✅ Navigazione fluida (no lag, no jank)

## Test Strategy

### Widget Tests
- Test bottom sheet card tap triggers navigation
- Test indicator count and "+X" display
- Test swipe gesture recognition

### Integration Tests
- Test complete flow: day tap → bottom sheet → reservation tap → edit page
- Test swipe month change updates provider state

### Manual Tests
- Verify haptic feedback on Android
- Verify smooth animations on device
