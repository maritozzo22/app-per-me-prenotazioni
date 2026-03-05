# Phase 6: Android Optimization - Planning Summary

**Phase:** 06-android-optimization
**Total Plans:** 5 plans
**Total Waves:** 5 waves
**Estimated Duration:** 3-5 days (depending on device testing availability)
**Requirements:** PLATFORM-04, PLATFORM-05, NOT-07, TEST-05, A11Y-02, A11Y-03

## Wave Structure

| Wave | Plans | Focus | Dependencies | Autonomous |
|------|-------|-------|--------------|------------|
| 1 | 06-01 | Notification Foundation | None | No (checkpoint) |
| 2 | 06-02 | Notification Scheduling | 06-01 | No (checkpoint) |
| 3 | 06-03 | Performance Optimization | 06-01, 06-02 | No (checkpoint) |
| 4 | 06-04 | Accessibility Implementation | 06-01, 06-02, 06-03 | No (checkpoint) |
| 5 | 06-05 | Android Testing & Bug Fixes | All previous | No (human-action) |

## Plan Overview

### Plan 06-01: Notification Foundation (Wave 1)
**Objective:** Set up flutter_local_notifications plugin, Android permissions, platform detection, and notification service interfaces.

**Key Tasks:**
1. Install flutter_local_notifications plugin and dependencies
2. Configure Android manifest with notification permissions
3. Create platform detection service
4. Create notification service interface and Android implementation
5. Create notification permission provider
6. Create notification initializer
7. Wire notification initialization in main.dart
8. Create unit tests for notification service

**Deliverables:**
- flutter_local_notifications^17.2.0 installed
- Android manifest with POST_NOTIFICATIONS permission
- PlatformService for platform detection
- NotificationService interface with Android implementation
- Notification permission provider for runtime permissions
- Notification initializer for app startup
- Unit tests for notification service

**Checkpoint:** Verify plugin installation, permissions, and service initialization.

---

### Plan 06-02: Notification Scheduling (Wave 2)
**Objective:** Implement notification scheduling workflow that triggers on reservation create/edit/delete.

**Key Tasks:**
1. Enhance notification repository with batch operations
2. Create reservation notification scheduler
3. Wire notification scheduler into reservation form
4. Wire notification cancellation into delete flow
5. Create unit tests for reservation notification scheduler
6. Create integration test for notification scheduling

**Deliverables:**
- NotificationRepository with save/delete/pending schedules methods
- ReservationNotificationScheduler for orchestrating workflow
- Integration with reservation form (schedule on save)
- Integration with delete flow (cancel on delete)
- Unit tests for scheduler
- Integration tests for end-to-end scheduling

**Checkpoint:** Verify notifications are scheduled/canceled correctly.

---

### Plan 06-03: Performance Optimization (Wave 3)
**Objective:** Optimize database queries, list rendering, and APK size for mid-range Android devices.

**Key Tasks:**
1. Add database indexes for query optimization
2. Optimize reservation repository queries with pagination
3. Verify ListView.builder usage in lists
4. Optimize Android build configuration (APK size, shrinking)
5. Add RepaintBoundary to expensive widgets
6. Create performance benchmark tests

**Deliverables:**
- Database indexes on check_in, check_out, created_at
- Optimized queries with pagination (limit 50)
- ListView.builder with itemExtent and cacheExtent
- APK size optimization (60-75% reduction)
- RepaintBoundary on calendar widget
- Performance tests (< 100ms for queries)

**Checkpoint:** Verify performance improvements and APK size reduction.

---

### Plan 06-04: Accessibility Implementation (Wave 4)
**Objective:** Implement accessibility features (48x48dp touch targets, screen reader labels).

**Key Tasks:**
1. Update theme to enforce 48x48dp touch targets globally
2. Add Semantics to reservation list tiles
3. Add Semantics to reservation form fields
4. Add Semantics to dashboard widgets
5. Add Semantics to calendar widget
6. Create automated accessibility tests

**Deliverables:**
- Theme with 48x48dp minimum touch targets
- Semantics widgets on all interactive elements
- Semantic labels and hints for form fields
- Semantic labels for dashboard and calendar
- Automated accessibility tests (touch targets, semantics)

**Checkpoint:** Verify accessibility compliance and TalkBack support.

---

### Plan 06-05: Android Testing & Bug Fixes (Wave 5)
**Objective:** Test on physical Android device, verify all functionality, and fix discovered bugs.

**Key Tasks:**
1. Replace WillPopScope with PopScope for Android 14+
2. Verify Android manifest permissions are complete
3. Create Android platform integration tests
4. Run all tests and verify no regressions
5. **Physical device testing** (37 test checks)
6. Create Android testing report
7. Fix any bugs discovered during testing

**Deliverables:**
- PopScope for back button handling
- Complete Android manifest permissions
- Android platform integration tests
- All 180+ tests passing
- Physical device testing report
- All bugs fixed

**Checkpoint:** Final verification on physical Android device.

---

## Dependencies

### Wave Dependencies
```
Wave 1 (Foundation)
    ↓
Wave 2 (Scheduling) ← Wave 1
    ↓
Wave 3 (Performance) ← Wave 1, Wave 2
    ↓
Wave 4 (Accessibility) ← Wave 1, Wave 2, Wave 3
    ↓
Wave 5 (Testing) ← All previous waves
```

### File Dependencies
- `lib/main.dart` is modified in Wave 1 (notification initialization)
- `lib/features/reservations/presentation/pages/reservation_form_page.dart` is modified in Waves 2 and 5 (scheduling + PopScope)
- `lib/core/theme/app_theme.dart` is modified in Wave 4 (accessibility)
- `android/app/src/main/AndroidManifest.xml` is modified in Waves 1 and 5 (permissions)
- `lib/features/reservations/data/repositories/reservation_repository_impl.dart` is modified in Wave 3 (performance)

## Testing Strategy

### Automated Tests
- **Unit Tests:** 180+ tests (existing 168 + new notification, accessibility, performance tests)
- **Integration Tests:** Notification scheduling, Android platform
- **Performance Tests:** Database query benchmarks (< 100ms)
- **Accessibility Tests:** Touch target sizes, Semantics labels

### Manual Tests (Physical Device)
- **Basic Functionality:** 9 checks (CRUD operations, navigation)
- **Notifications:** 7 checks (scheduling, appearance, persistence)
- **Performance:** 4 checks (scrolling, 60fps target)
- **Accessibility:** 6 checks (TalkBack, touch targets)
- **Back Button:** 3 checks (PopScope behavior)
- **Edge Cases:** 4 checks (validation, overlaps)
- **App Behavior:** 4 checks (rotation, memory, crashes)
- **Total:** 37 manual test checks

## Success Criteria

By the end of Phase 6, the following must be true:

1. ✅ **Platform Support (PLATFORM-04):** App works on Android device
2. ✅ **Performance (PLATFORM-05):** Smooth 60fps on mid-range device
3. ✅ **Notifications (NOT-07):** Local notifications work on Android
4. ✅ **Touch Targets (A11Y-02):** All interactive elements 48x48dp minimum
5. ✅ **Screen Reader (A11Y-03):** TalkBack reads meaningful labels
6. ✅ **Testing (TEST-05):** All 180+ tests pass on Android
7. ✅ **Bug Fixes:** All bugs discovered during testing are fixed

## Risk Mitigation

### High Risk Areas
1. **Notification permissions on Android 13+:**
   - Risk: Runtime permission denied, notifications don't appear
   - Mitigation: Request permission explicitly, show explanation, handle denial gracefully

2. **Performance on mid-range devices:**
   - Risk: Janky scrolling, slow queries
   - Mitigation: Database indexes, ListView.builder, pagination, RepaintBoundary

3. **APK size:**
   - Risk: APK too large (60-70MB), poor download conversion
   - Mitigation: App Bundle or split APKs, R8 shrinking, remove unused resources

4. **Accessibility compliance:**
   - Risk: Touch targets too small, missing labels
   - Mitigation: Theme enforcement, automated tests, manual TalkBack verification

5. **Physical device testing:**
   - Risk: No device available, testing incomplete
   - Mitigation: Use Android emulator as fallback, document limitations

## Known Limitations

1. **Web Notifications:** NOT-08 (web notifications) is not implemented due to significant limitations (user gesture requirement, HTTPS-only, iOS Safari no support). The REQUIREMENTS.md says "se supportato" (if supported), which gives discretion to skip. Can be added later as optional enhancement.

2. **Notification Tap Navigation:** Tapping a notification will log the payload but won't navigate to reservation details yet. This will be implemented in Phase 7 (Polish) or Phase 8 (Deployment).

3. **Boot Receiver:** Notifications persist after device restart (Android reschedules them), but a proper BootReceiver isn't implemented. This is acceptable for personal use app. Can be enhanced in future phases.

4. **Predictive Back Animation:** PopScope is implemented for Android 14+, but the predictive back animation (swipe-to-go-back gesture) may not work perfectly without additional configuration. This is acceptable for MVP.

## File Changes Summary

### New Files Created
- `lib/core/platform/platform_service.dart` - Platform detection
- `lib/features/notifications/application/notification_service.dart` - Platform-specific notification service
- `lib/features/notifications/presentation/providers/notification_permission_provider.dart` - Permission handling
- `lib/features/notifications/application/notification_initializer.dart` - Notification initialization
- `lib/features/notifications/application/reservation_notification_scheduler.dart` - Scheduling orchestrator
- `test/features/notifications/application/notification_service_test.dart` - Unit tests
- `test/features/notifications/application/reservation_notification_scheduler_test.dart` - Unit tests
- `test/integration/notification_scheduling_integration_test.dart` - Integration tests
- `test/performance/database_query_performance_test.dart` - Performance tests
- `test/accessibility/touch_target_test.dart` - Accessibility tests
- `test/accessibility/semantics_test.dart` - Accessibility tests
- `test/integration/android_platform_test.dart` - Android platform tests
- `.planning/phases/06-android-optimization/06-ANDROID-TESTING.md` - Testing report

### Modified Files
- `pubspec.yaml` - Add flutter_local_notifications, timezone, flutter_native_timezone
- `android/app/src/main/AndroidManifest.xml` - Add notification permissions
- `lib/main.dart` - Initialize notifications on startup
- `lib/core/theme/app_theme.dart` - Enforce 48x48dp touch targets
- `lib/core/database/database_schema.dart` - Add indexes, version 5
- `lib/features/reservations/data/repositories/reservation_repository_impl.dart` - Optimize queries
- `lib/features/reservations/presentation/pages/reservation_form_page.dart` - Schedule notifications, PopScope
- `lib/features/reservations/presentation/widgets/reservation_list_tile.dart` - Cancel notifications, Semantics
- `lib/features/reservations/presentation/widgets/reservation_form.dart` - Semantics labels
- `lib/features/reservations/presentation/widgets/reservation_calendar.dart` - Semantics labels, RepaintBoundary
- `lib/features/reservations/presentation/widgets/dashboard/room_occupancy_grid.dart` - Semantics labels
- `lib/features/notifications/data/repositories/notification_repository_impl.dart` - Add batch operations
- `android/app/build.gradle` - Optimize build (shrinking, splits)

## Next Steps After Phase 6

After completing Phase 6:
1. **Phase 7: Polish & Documentation** - Code review, documentation, UI/UX polish
2. **Phase 8: Deployment & Verification** - Build APK, install on personal device, final verification

## Estimated Effort

| Wave | Tasks | Estimated Time | Complexity |
|------|-------|----------------|------------|
| 1 | 8 tasks | 3-4 hours | Medium |
| 2 | 6 tasks | 2-3 hours | Medium |
| 3 | 6 tasks | 2-3 hours | Low |
| 4 | 6 tasks | 2-3 hours | Low |
| 5 | 7 tasks | 4-8 hours | High (device testing) |
| **Total** | **33 tasks** | **13-21 hours** | **Medium-High** |

**Note:** Wave 5 timing depends on availability of physical Android device and number of bugs discovered during testing.

---

**Planned By:** GSD Planner
**Date:** 2026-03-05
**Status:** Ready for execution
