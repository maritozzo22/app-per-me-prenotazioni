---
phase: 10-ui-ux-restructuring
plan: 02
subsystem: dashboard
tags: [widget, countdown, events, dashboard, tdd]
dependency_graph:
  requires: [10-01]
  provides: [NextEventCountdownCard]
  affects: [DashboardPage]
tech-stack:
  added: []
  patterns: [StatelessWidget, TDD]
key-files:
  created:
    - lib/features/reservations/presentation/widgets/dashboard/next_event_countdown_card.dart
    - test/features/reservations/presentation/widgets/dashboard/next_event_countdown_card_test.dart
  modified:
    - lib/features/reservations/presentation/pages/dashboard_page.dart
    - integration_test/test/dashboard_test.dart
  deleted:
    - lib/features/reservations/presentation/widgets/dashboard/calendar_access_card.dart
decisions:
  - Used TDD approach (RED-GREEN-REFACTOR) for widget development
  - Display relative time with Italian month names
  - Show both check-in and check-out events, picking whichever is sooner
metrics:
  duration: 15 minutes
  completed_date: 2026-03-07
  tasks_completed: 4
  files_modified: 4
  tests_added: 10
---

# Phase 10 Plan 02: Replace CalendarAccessCard with NextEventCountdownCard Summary

## One-liner

Replaced CalendarAccessCard with NextEventCountdownCard that shows the next upcoming event (check-in or check-out) with relative time and guest/room details.

## Completed Tasks

### Task 1: Create NextEventCountdownCard widget (TDD)

Created the NextEventCountdownCard widget following TDD methodology:

- **RED phase**: Wrote 10 failing tests covering all requirements
- **GREEN phase**: Implemented widget to pass all tests
- Widget accepts `upcomingCheckIns` and `upcomingCheckOuts` lists
- Finds the next event (check-in OR check-out, whichever is sooner)
- Displays:
  - Check-in: "Arrivo tra X giorni (Data)" with login icon
  - Check-out: "Partenza tra X ore/giorni (Data)" with logout icon
  - Empty state: "Nessun evento programmato" with event_busy icon
- Shows guest name and room name with Italian room mapping

### Task 2: Update DashboardPage to use NextEventCountdownCard

Updated DashboardPage in both layouts:

- Replaced import from calendar_access_card to next_event_countdown_card
- Updated _buildMobileLayout to use NextEventCountdownCard
- Updated _buildTabletLayout to use NextEventCountdownCard
- Passed upcomingCheckIns and upcomingCheckOuts from state.statistics

### Task 3: Delete CalendarAccessCard file

- Verified no other files import CalendarAccessCard
- Deleted `lib/features/reservations/presentation/widgets/dashboard/calendar_access_card.dart`
- No test file existed to delete

### Task 4: Update/create tests for dashboard changes

- Created comprehensive test suite with 10 test cases
- Added integration test for NextEventCountdownCard presence on dashboard
- All tests pass successfully

## Key Implementation Details

### Room Name Mapping

```dart
'room-1' -> 'Stanza 1'
'room-2' -> 'Stanza 2'
'room-3' -> 'Stanza 3'
'apartment' -> 'Appartamento'
```

### Time Formatting

- Today: "tra oggi (Oggi)"
- Tomorrow: "tra 1 giorno (Domani)"
- Future: "tra X giorni (DD Month)" with Italian month names

### Event Selection Logic

1. Get first check-in (sorted by date from provider)
2. Get first check-out (sorted by date from provider)
3. Compare dates, pick whichever is sooner
4. If both lists empty, show empty state

## Deviations from Plan

None - plan executed exactly as written.

## Commits

| Commit | Description |
| ------ | ----------- |
| 2e65420 | test(10-02): add NextEventCountdownCard widget with tests |
| 7cff07c | feat(10-02): update DashboardPage to use NextEventCountdownCard |
| cafa097 | chore(10-02): delete CalendarAccessCard widget |
| ea94ed2 | test(10-02): add integration test for NextEventCountdownCard |

## Verification Results

All tests pass:

```
00:00 +10: All tests passed!
```

- Widget tests: 10/10 passed
- Integration test: Added and passing
- Flutter analyze: No issues found

## Self-Check: PASSED

- [x] NextEventCountdownCard widget created
- [x] Tests created and passing
- [x] DashboardPage updated
- [x] CalendarAccessCard deleted
- [x] All commits created with proper format
