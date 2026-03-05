# Phase 05: Task Breakdown

## Wave 1: Foundation

### Task 1.1: Platform Management System (Foundation)
**File**: `lib/features/platforms/domain/entities/platform.dart`
- [ ] Add `bool isSystem` field to Platform entity
- [ ] Update Platform constructor and freezed boilerplate
- [ ] Update toJson/fromJson for serialization

**File**: `lib/features/platforms/data/models/platform_model.dart`
- [ ] Add `isSystem` field to PlatformModel
- [ ] Update toDomain()/fromDomain() methods
- [ ] Update JSON serialization

**File**: `lib/features/platforms/data/datasources/platform_datasource.dart`
- [ ] Update CREATE operation to include `isSystem` column
- [ ] Update UPDATE operation
- [ ] Update getAll() to include `isSystem` in SELECT

**File**: `lib/features/platforms/data/repositories/platform_repository_impl.dart`
- [ ] Update repository implementation to handle `isSystem` field

**File**: `lib/core/database/database_helper.dart`
- [ ] Create migration v2: Add `is_system` column to platforms table
- [ ] Update existing records: set isSystem=1 for default platforms
- [ ] Add migration version increment

**File**: `lib/features/platforms/domain/services/platform_service.dart` (NEW)
- [ ] Create PlatformService class
- [ ] Method: `validatePlatformName()` - check uniqueness
- [ ] Method: `canDeletePlatform()` - check if platform is in use
- [ ] Method: `getDefaultPlatforms()` - return list of system platforms

**File**: `test/features/platforms/domain/services/platform_service_test.dart`
- [ ] Test: validatePlatformName with unique name
- [ ] Test: validatePlatformName with duplicate name
- [ ] Test: canDeletePlatform when platform unused
- [ ] Test: canDeletePlatform when platform in use
- [ ] Test: getDefaultPlatforms returns all system platforms

**Estimated Time**: 2-3 hours

---

### Task 1.2: Search Service (Foundation)
**File**: `lib/features/search/domain/services/search_service.dart` (NEW)
- [ ] Create SearchService class
- [ ] Constructor: `SearchService(this.reservationRepository)`
- [ ] Method: `search(String query)` - searches in guestName, guestPhone, notes
- [ ] Implementation: Case-insensitive search
- [ ] Return type: `Future<List<Reservation>>`

**File**: `test/features/search/domain/services/search_service_test.dart` (NEW)
- [ ] Test: search with matching guest name
- [ ] Test: search with matching phone number
- [ ] Test: search with matching notes
- [ ] Test: search with partial match
- [ ] Test: search with no results
- [ ] Test: search with empty query
- [ ] Test: search is case-insensitive

**Estimated Time**: 1-2 hours

---

## Wave 2: Platform Management UI

### Task 2.1: Platform List Screen
**File**: `lib/features/platforms/presentation/providers/platform_provider.dart` (UPDATE)
- [ ] Add `getAllPlatforms()` state getter
- [ ] Add `deletePlatform(String id)` method
- [ ] Add loading/error states for CRUD operations

**File**: `lib/features/platforms/presentation/widgets/platform_list_tile.dart` (NEW)
- [ ] Create PlatformListTile widget
- [ ] Display platform name with color indicator
- [ ] Show "System" badge if isSystem=true
- [ ] Implement swipe actions:
  - Left swipe: Edit (blue)
  - Right swipe: Delete (red, only if !isSystem or user confirms)
- [ ] Delete confirmation dialog

**File**: `lib/features/platforms/presentation/pages/platforms_list_page.dart` (NEW)
- [ ] Create PlatformsListPage
- [ ] AppBar with title "Gestione Piattaforme"
- [ ] FAB for adding new platform
- [ ] ListView with PlatformListTile widgets
- [ ] Empty state: "Nessuna piattaforma configurata"
- [ ] Loading state during fetch
- [ ] Error handling with retry

**File**: `test/features/platforms/presentation/widgets/platform_list_tile_test.dart`
- [ ] Test: renders platform name
- [ ] Test: shows color indicator
- [ ] Test: shows "System" badge for system platforms
- [ ] Test: swipe left shows edit action
- [ ] Test: swipe right shows delete action
- [ ] Test: tap on tile opens edit page

**File**: `test/features/platforms/presentation/pages/platforms_list_page_test.dart`
- [ ] Test: renders list of platforms
- [ ] Test: shows empty state when no platforms
- [ ] Test: FAB navigates to form page
- [ ] Test: pull-to-refresh reloads list

**Estimated Time**: 3-4 hours

---

### Task 2.2: Platform Form
**File**: `lib/features/platforms/presentation/pages/platform_form_page.dart` (NEW)
- [ ] Create PlatformFormPage
- [ ] Accept optional `Platform` parameter for edit mode
- [ ] Form fields:
  - Name: TextFormField (required, unique validation)
  - Color: Color picker button
- [ ] Color picker dialog:
  - Show preset Material colors
  - Show current platform color
  - Preview circle
- [ ] Save button: calls provider add/update
- [ ] Cancel button: pop without saving
- [ ] Validation: name not empty, name unique

**File**: `lib/features/platforms/presentation/widgets/platform_color_picker.dart` (NEW)
- [ ] Create color picker widget
- [ ] Grid of preset Material colors
- [ ] Selected color indicator
- [ ] onTap callback returns Color

**File**: `test/features/platforms/presentation/pages/platform_form_page_test.dart`
- [ ] Test: renders form fields
- [ ] Test: shows existing data in edit mode
- [ ] Test: validates required fields
- [ ] Test: validates unique name
- [ ] Test: save calls provider.add in create mode
- [ ] Test: save calls provider.update in edit mode
- [ ] Test: cancel pops without saving

**Estimated Time**: 3-4 hours

---

### Task 2.3: Integration & Navigation
**File**: `lib/core/widgets/app_shell.dart` (UPDATE)
- [ ] Add "Piattaforme" to settings or new route
- [ ] OR: Create SettingsPage with platform management link
- [ ] Update navigation if needed

**File**: `test/features/platforms/integration/platform_crud_test.dart` (NEW)
- [ ] Integration test: Create new platform
- [ ] Integration test: Edit existing platform
- [ ] Integration test: Delete platform (not in use)
- [ ] Integration test: Attempt delete platform (in use) - should fail
- [ ] Integration test: Edit system platform

**Estimated Time**: 2-3 hours

---

## Wave 3: Search UI

### Task 3.1: Search Bar Component
**File**: `lib/features/search/presentation/providers/search_provider.dart` (NEW)
- [ ] Create SearchProvider with StateNotifier
- [ ] State: `SearchState(initial, loading, loaded, empty, error)`
- [ ] Method: `search(String query)` with 300ms debouncing
- [ ] Method: `clearSearch()`
- [ ] Error handling

**File**: `lib/features/search/presentation/widgets/search_bar_widget.dart` (NEW)
- [ ] Create SearchBarWidget
- [ ] TextField with prefix icon (search)
- [ ] Suffix icon: clear button (only when text not empty)
- [ ] Trailing icon: loading indicator (only when loading)
- [ ] Debounced onChange callback
- [ ] hintText: "Cerca prenotazioni..."
- [ ] Accessibility labels

**File**: `test/features/search/presentation/providers/search_provider_test.dart`
- [ ] Test: initial state is initial
- [ ] Test: search updates state to loading then loaded
- [ ] Test: search with no results updates to empty
- [ ] Test: search error updates to error
- [ ] Test: clearSearch resets to initial
- [ ] Test: debouncing works (use fake timers)

**File**: `test/features/search/presentation/widgets/search_bar_widget_test.dart`
- [ ] Test: renders text field
- [ ] Test: shows search icon
- [ ] Test: shows clear button when has text
- [ ] Test: clear button clears text
- [ ] Test: shows loading indicator when loading
- [ ] Test: onChange callback works

**Estimated Time**: 2-3 hours

---

### Task 3.2: Search Results & Integration
**File**: `lib/features/search/presentation/pages/search_results_page.dart` (NEW)
- [ ] Create SearchResultsPage
- [ ] Accepts initial query parameter
- [ ] SearchBarWidget at top
- [ ] ListView with ReservationListTile for results
- [ ] Empty state: "Nessuna prenotazione trovata"
- [ ] Error state with retry
- [ ] Loading indicator

**File**: `lib/features/reservations/presentation/pages/reservations_list_page.dart` (UPDATE)
- [ ] Add SearchBarWidget to top of page
- [ ] Wrap existing ListView with ConditionalBuilder:
  - If searching: show search results
  - If not: show all reservations
- [ ] Update state to track search mode

**File**: `test/features/search/integration/search_flow_test.dart` (NEW)
- [ ] Integration test: Type in search bar
- [ ] Integration test: See search results
- [ ] Integration test: Tap result opens edit page
- [ ] Integration test: Clear search shows all reservations
- [ ] Integration test: Search with no results shows empty state

**Estimated Time**: 2-3 hours

---

## Wave 4: Dark Mode

### Task 4.1: Theme System
**File**: `pubspec.yaml`
- [ ] Add `shared_preferences: ^2.3.5` dependency

**File**: `lib/core/providers/theme_provider.dart` (NEW)
- [ ] Create ThemeProvider with StateNotifier
- [ ] State: `ThemeMode.light` or `ThemeMode.dark`
- [ ] Method: `toggleTheme()`
- [ ] Method: `setTheme(ThemeMode mode)`
- [ ] Load theme from SharedPreferences on init
- [ ] Save theme to SharedPreferences on change

**File**: `lib/core/theme/app_theme.dart` (NEW)
- [ ] Create `getLightTheme()` - returns ThemeData for light mode
- [ ] Create `getDarkTheme()` - returns ThemeData for dark mode
- [ ] Use ColorScheme.fromSeed() for both
- [ ] Ensure proper contrast ratios
- [ ] Custom colors for platform colors (work in both themes)

**File**: `lib/main.dart` (UPDATE)
- [ ] Wrap MaterialApp with ProviderScope
- [ ] Watch ThemeProvider
- [ ] Set themeMode based on provider state
- [ ] Set theme/lightTheme/darkTheme

**File**: `test/core/providers/theme_provider_test.dart` (NEW)
- [ ] Test: initial theme loads from SharedPreferences
- [ ] Test: toggleTheme switches between light and dark
- [ ] Test: setTheme updates to specific mode
- [ ] Test: theme is persisted to SharedPreferences

**Estimated Time**: 2-3 hours

---

### Task 4.2: Dark Mode Styling & Toggle
**File**: `lib/core/widgets/theme_toggle_button.dart` (NEW)
- [ ] Create ThemeToggleButton
- [ ] Icon: sun/moon based on current theme
- [ ] onPressed: calls provider.toggleTheme()
- [ ] Tooltip: "Cambia tema"

**File**: `lib/core/widgets/app_shell.dart` (UPDATE)
- [ ] Add ThemeToggleButton to AppBar
- [ ] OR: Add to settings page if preferred

**File**: All widget files (UPDATE)
- [ ] Review hardcoded colors → use Theme.of(context).colorScheme
- [ ] Test: ReservationListTile in dark mode
- [ ] Test: CalendarPage in dark mode
- [ ] Test: DashboardPage in dark mode
- [ ] Test: ReservationFormPage in dark mode
- [ ] Test: PlatformsListPage in dark mode
- [ ] Ensure all text has proper contrast

**File**: `test/core/widgets/theme_toggle_button_test.dart` (NEW)
- [ ] Test: renders correct icon for light theme
- [ ] Test: renders correct icon for dark theme
- [ ] Test: onPressed calls toggleTheme

**Manual Testing Required**:
- [ ] Screenshot all pages in light mode
- [ ] Screenshot all pages in dark mode
- [ ] Verify contrast ratios meet WCAG AA standards

**Estimated Time**: 3-4 hours

---

## Wave 5: Notification Foundation

### Task 5.1: Notification Scheduling Service
**File**: `lib/features/notifications/domain/entities/notification_schedule.dart` (NEW)
- [ ] Create NotificationSchedule entity (freezed)
- [ ] Fields: id, reservationId, notificationType, scheduledDate, isSent, createdAt
- [ ] notificationType enum: 5days, 3days, 2days, 1day, sameday
- [ ] JSON serialization

**File**: `lib/features/notifications/domain/entities/notification_type.dart` (NEW)
- [ ] Create enum NotificationType
- [ ] Values: fiveDays, threeDays, twoDays, oneDay, sameDay
- [ ] Extension method: `daysBeforeCheckIn()` returns 5, 3, 2, 1, 0
- [ ] Extension method: `displayName()` returns Italian strings

**File**: `lib/features/notifications/domain/services/notification_scheduler_service.dart` (NEW)
- [ ] Create NotificationSchedulerService (abstract interface)
- [ ] Method: `scheduleNotificationsForReservation(Reservation)`
- [ ] Method: `cancelNotificationsForReservation(String reservationId)`
- [ ] Method: `rescheduleNotificationsForReservation(Reservation)`
- [ ] Method: `getPendingNotifications()` - for debugging
- [ ] Business logic:
  - Calculate dates for each notification type
  - Skip dates in the past
  - Don't schedule if check-in is today

**File**: `test/features/notifications/domain/services/notification_scheduler_service_test.dart` (NEW)
- [ ] Test: schedules all 5 notifications for future reservation
- [ ] Test: skips past dates when scheduling
- [ ] Test: doesn't schedule if check-in is today
- [ ] Test: cancels all notifications for reservation
- [ ] Test: reschedules after reservation update
- [ ] Test: handles date calculation correctly

**Estimated Time**: 2-3 hours

---

### Task 5.2: Notification Data Layer
**File**: `lib/features/notifications/data/models/notification_schedule_model.dart` (NEW)
- [ ] Create NotificationScheduleModel
- [ ] toDomain()/fromDomain() methods
- [ ] JSON serialization
- [ ] Database serialization

**File**: `lib/features/notifications/data/datasources/notification_datasource.dart` (NEW)
- [ ] Create NotificationDatasource interface
- [ ] Method: `create(NotificationSchedule)`
- [ ] Method: `getAll()`
- [ ] Method: `getByReservationId(String reservationId)`
- [ ] Method: `delete(String id)`
- [ ] Method: `deleteByReservationId(String reservationId)`
- [ ] Method: `getPendingNotifications()` - WHERE isSent=0

**File**: `lib/features/notifications/data/datasources/notification_datasource_impl.dart` (NEW)
- [ ] Implement NotificationDatasource with DatabaseHelper
- [ ] CREATE TABLE notification_schedules
- [ ] Implement all CRUD methods
- [ ] Add indexes for performance

**File**: `lib/core/database/database_helper.dart` (UPDATE)
- [ ] Create migration v3: Create notification_schedules table
- [ ] Add indexes on reservation_id, scheduled_date, is_sent
- [ ] Update version number

**File**: `lib/features/notifications/data/repositories/notification_repository_impl.dart` (NEW)
- [ ] Implement NotificationRepository interface
- [ ] Delegate to datasource
- [ ] Error handling

**File**: `test/features/notifications/data/models/notification_schedule_model_test.dart` (NEW)
- [ ] Test: toDomain/fromDomain conversion
- [ ] Test: JSON serialization
- [ ] Test: Database serialization

**File**: `test/features/notifications/integration/notification_schedule_integration_test.dart` (NEW)
- [ ] Integration test: Create reservation → 5 schedules created
- [ ] Integration test: Update reservation → old schedules cancelled, new created
- [ ] Integration test: Delete reservation → all schedules cancelled
- [ ] Integration test: Get pending notifications

**File**: `lib/features/reservations/data/repositories/reservation_repository_impl.dart` (UPDATE)
- [ ] In create method: call notificationScheduler.scheduleNotificationsForReservation
- [ ] In update method: call notificationScheduler.rescheduleNotificationsForReservation
- [ ] In delete method: call notificationScheduler.cancelNotificationsForReservation

**Estimated Time**: 3-4 hours

---

## Total Estimated Time

| Wave | Tasks | Estimated Time |
|------|-------|----------------|
| Wave 1 | 2 tasks | 3-5 hours |
| Wave 2 | 3 tasks | 8-11 hours |
| Wave 3 | 2 tasks | 4-6 hours |
| Wave 4 | 2 tasks | 5-7 hours |
| Wave 5 | 2 tasks | 5-7 hours |
| **Total** | **11 tasks** | **25-36 hours** |

## Task Dependencies

```
Wave 1 (Foundation)
├── Task 1.1 (Platform System) ──────┐
└── Task 1.2 (Search Service) ───────┤
                                      ├──> Wave 2
Wave 2                               │
├── Task 2.1 (Platform List) ─────────┤
├── Task 2.2 (Platform Form) ─────────┤
└── Task 2.3 (Integration) ───────────┘
                                      ├──> Wave 3
Wave 3                               │
├── Task 3.1 (Search Bar) ────────────┤
└── Task 3.2 (Search Results) ────────┘
                                      ├──> Wave 4
Wave 4                               │
├── Task 4.1 (Theme System) ──────────┤
└── Task 4.2 (Dark Mode UI) ──────────┘
                                      ├──> Wave 5
Wave 5                               │
├── Task 5.1 (Notification Service) ──┤
└── Task 5.2 (Notification Data) ─────┘
```

## Notes

1. **Wave 1** must complete before Wave 2 (foundation dependency)
2. **Wave 2** tasks can be done in parallel (all depend on Wave 1)
3. **Wave 3** tasks depend on Wave 1 completion
4. **Wave 4** is independent of Waves 2-3 (can run in parallel)
5. **Wave 5** is independent of Waves 2-4 (can run in parallel)

**Optimal Parallelization**:
- Days 1: Wave 1
- Days 2-3: Wave 2 + Wave 3 + Wave 4 (in parallel)
- Days 4-5: Wave 5

---

*This task breakdown supports the 05-PLAN.md and provides granular implementation guidance.*
