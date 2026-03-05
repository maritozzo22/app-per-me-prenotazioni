# Phase 4: Dashboard & Navigation - Context

**Date**: 2026-03-05
**Status**: Ready for Planning

## Overview

Phase 4 creates the main application hub with statistics, navigation, and complete CRUD operations for reservations. This phase transforms the app from a single calendar view into a full-featured management system.

## User Requirements Confirmed

### Dashboard Design
- **Home Screen**: Dashboard (not calendar)
- **Income Display**: Breakdown showing received vs pending payments
- **Calendar Access**: Large card widget in dashboard grid
- **Room Occupancy**: Visual grid showing each room's status (4 boxes: Stanza 1, Stanza 2, Stanza 3, Appartamento)
- **Responsive Focus**: Mobile-first (< 600px) for this phase

### Navigation Approach
- **Strategy**: Dashboard-first, add bottom navigation after core functionality works
- **Edit/Delete Access**: Available from all three screens (dashboard, calendar, list)

### Sorting
- **Default**: Check-in date ascending (nearest first)
- **Future**: Additional sorts in Phase 5

## Current Codebase State

### ✅ Completed Foundations
- Data models: Room, Platform, Guest, Reservation
- Database: SQLite/IndexedDB with repository pattern
- Validation: ReservationValidationService with overlap detection
- Forms: ReservationForm with all input fields
- Calendar: ReservationCalendar with table_calendar integration
- State Management: CalendarProvider, ReservationProvider
- Services: CalendarService for date grouping

### 🚧 To Be Built
- Dashboard screen with statistics
- Dashboard business logic service
- Reservations list screen
- Modify/delete workflows
- Bottom navigation bar
- Responsive layout system

### 📁 Existing Key Files
```
lib/
├── main.dart (currently shows CalendarPage as home)
├── features/reservations/
│   ├── domain/
│   │   ├── entities/reservation.dart
│   │   ├── services/
│   │   │   ├── calendar_service.dart ✅
│   │   │   └── reservation_validation_service.dart ✅
│   │   └── repositories/reservation_repository.dart ✅
│   ├── presentation/
│   │   ├── pages/
│   │   │   └── calendar_page.dart ✅
│   │   ├── providers/
│   │   │   ├── calendar_provider.dart ✅
│   │   │   └── reservation_provider.dart ✅
│   │   └── widgets/
│   │       ├── reservation_form.dart ✅
│   │       ├── reservation_calendar.dart ✅
│   │       └── day_detail_bottom_sheet.dart ✅
```

## Dependencies

### Phase 4 Depends On:
- ✅ Phase 1: Data models and repository (complete)
- ✅ Phase 2: CRUD operations and validation (complete)
- ✅ Phase 3: Calendar UI and state management (complete)

### Phase 4 Enables:
- Phase 5: Advanced features (search, custom platforms, dark mode)
- Phase 6: Android optimization

## Technical Decisions

### Architecture
- **Pattern**: Clean Architecture with Riverpod state management
- **UI Framework**: Material 3 with responsive breakpoints
- **Testing**: TDD approach (unit → widget → integration)

### State Management Strategy
- Create `DashboardProvider` for dashboard state
- Extend `ReservationProvider` if needed for list operations
- Reuse `CalendarProvider` for calendar access

### Navigation
- **Wave 1-3**: Direct routing, no bottom nav yet
- **Wave 4**: Add `BottomNavigationBar` with 3 tabs
- Update `main.dart` to use navigation shell

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Dashboard performance with large datasets | Calculate stats efficiently, paginate lists |
| Complex room occupancy logic | Create dedicated service method with clear tests |
| Edit/delete workflow complexity | Reuse existing ReservationForm, add clear confirmation dialogs |
| Responsive layout issues | Start with mobile-first, test on Chrome DevTools device emulator |

## Success Criteria (from ROADMAP.md)

1. ✅ Dashboard shows rooms occupied today (visual grid)
2. ✅ Dashboard shows upcoming check-ins (7 days)
3. ✅ Dashboard shows upcoming check-outs (7 days)
4. ✅ Dashboard shows monthly income breakdown (received + pending)
5. ⚠️ Calendar accessible from dashboard (card widget)
6. ✅ Reservations list sortable by check-in date
7. ✅ Edit/delete reservations from dashboard, calendar, and list
8. ✅ Responsive design for mobile (< 600px)
9. ✅ All tests pass (unit, widget, integration)
10. ✅ Complete Chrome testing

## Open Questions (All Answered ✅)

- [x] Home screen choice → Dashboard as home
- [x] Sort options → Check-in date default
- [x] Responsive breakpoints → Mobile < 600px
- [x] Navigation timing → Dashboard-first, add nav in Wave 4
- [x] Income calculation → Show breakdown
- [x] Calendar access → Card widget
- [x] Edit/delete locations → All three screens
- [x] Room display → Visual grid

## Next Steps

Proceed with `/gsd:plan-phase 4` to create detailed implementation plans.
