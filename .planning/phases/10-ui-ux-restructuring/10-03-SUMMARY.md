---
phase: 10-ui-ux-restructuring
plan: 03
subsystem: core/presentation
tags: [settings, navigation, platforms-management, gestione-section]
dependencies:
  requires: [10-01]
  provides: [settings-gestione-section, platforms-settings-access]
  affects: [settings_page.dart]
tech_stack:
  added: []
  patterns: [TDD, Widget Testing]
key_files:
  created:
    - test/core/presentation/pages/settings_page_test.dart
  modified:
    - lib/core/presentation/pages/settings_page.dart
decisions:
  - Use Icons.hotel_outlined for Platforms tile (consistent with previous Platforms tab)
  - Place Gestione section between Aspetto and Dati
  - Add Key('platforms_tile') for testability
metrics:
  duration: 15 minutes
  tasks_completed: 2
  tests_added: 10
  tests_passing: 10
  completed_date: 2026-03-07
---

# Phase 10 Plan 03: Settings Gestione Section Summary

## One-liner

Added "Gestione" section to Settings page with Platforms management tile, enabling access to PlatformsListPage from Settings after Platforms tab was replaced with Statistics.

## Changes Made

### Task 1: Add Gestione Section to SettingsPage

**Files Modified:**
- `lib/core/presentation/pages/settings_page.dart`

**Changes:**
1. Added import for `PlatformsListPage`
2. Created new "Gestione" section header between "Aspetto" and "Dati"
3. Added "Piattaforme di prenotazione" tile with:
   - `Icons.hotel_outlined` (consistent with previous Platforms tab)
   - Title: "Piattaforme di prenotazione"
   - Subtitle: "Gestisci le piattaforme di prenotazione"
   - Trailing chevron icon
   - `Key('platforms_tile')` for testing
   - Navigation to `PlatformsListPage` on tap

### Task 2: Create Tests for Settings Page

**Files Created:**
- `test/core/presentation/pages/settings_page_test.dart`

**Test Coverage (10 tests):**
1. Shows all section headers (Aspetto, Gestione, Dati, Informazioni)
2. Gestione section appears between Aspetto and Dati
3. Shows Platforms tile in Gestione section
4. Platforms tile has correct key ('platforms_tile')
5. Tapping Platforms tile navigates to PlatformsListPage
6. Platforms tile has correct icon
7. Platforms tile has trailing chevron
8. Shows theme tile in Aspetto section
9. Shows backup tile in Dati section
10. Shows version info in Informazioni section

## Settings Page Structure

```
Impostazioni
├── Aspetto
│   └── Tema
├── Gestione (NEW)
│   └── Piattaforme di prenotazione -> [PlatformsListPage]
├── Dati
│   └── Backup e Ripristino
└── Informazioni
    ├── Versione
    └── Sviluppato con Flutter
```

## Deviations from Plan

None - plan executed exactly as written.

## Test Results

```
00:00 +10: All tests passed!
```

All 10 settings page tests pass.

## Commits

| Hash | Message |
|------|---------|
| 6a3d2f9 | test(10-03): add failing tests for Settings Gestione section |
| 939ef4a | feat(10-03): add Gestione section with Platforms tile to SettingsPage |

## Verification

- [x] Settings page shows "Gestione" section
- [x] "Gestione" appears between "Aspetto" and "Dati"
- [x] "Piattaforme di prenotazione" tile exists
- [x] Tapping tile navigates to PlatformsListPage
- [x] All 10 tests pass

## Notes

- The "Gestione" section provides a new home for management features
- Future management items (rooms, etc.) can be added to this section
- Icon choice maintains consistency with the previous Platforms tab experience

## Self-Check: PASSED

- [x] lib/core/presentation/pages/settings_page.dart exists
- [x] test/core/presentation/pages/settings_page_test.dart exists
- [x] Commit 939ef4a (feat) exists
- [x] Commit 6a3d2f9 (test) exists
