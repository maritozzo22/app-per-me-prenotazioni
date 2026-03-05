# Phase 6: Android Optimization - Research

**Researched:** 2026-03-05
**Domain:** Flutter Android Local Notifications, Performance Optimization, Accessibility
**Confidence:** HIGH

## Summary

Phase 6 focuses on optimizing the existing Flutter web application for Android platform, implementing local notifications, ensuring accessibility compliance, and achieving smooth performance on mid-range Android devices. The application already has a solid foundation with notification scheduling logic (NotificationSchedulerService), database schema v4 with notification_schedules table, and 168 passing tests.

The primary technical challenges include:
1. Integrating `flutter_local_notifications` for Android local notifications
2. Optimizing APK size and build configuration for Android
3. Implementing Material Design 3 theming with platform-adaptive UI
4. Ensuring accessibility compliance (48x48dp touch targets, semantics labels)
5. Database performance optimization on Android
6. Testing on physical Android devices

**Primary recommendation:** Use `flutter_local_notifications^17.2.0` for Android local notifications, implement proper notification channels, optimize APK size using App Bundle format, and ensure accessibility compliance through Semantics widgets and proper touch target sizing.

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| NOT-07 | Funzionamento su Android (local notifications) | flutter_local_notifications integration with Android 8.0+ notification channels |
| NOT-08 | Funzionamento su Web (browser notifications se supportato) | Web Notification API has significant limitations - recommend skipping or implementing as optional enhancement |
| TEST-05 | Test complete su dispositivo Android dopo web testing | Physical device testing workflow with flutter tools |
| PLATFORM-04 | Funzionamento completo su Android | Platform-adaptive UI, back button handling, Android-specific configurations |
| PLATFORM-05 | Performance fluide su dispositivo Android medio | Performance optimization techniques, DevTools profiling, 60fps target |
| A11Y-02 | Dimensioni touch target minime (48x48dp) | Semantics widgets, SizedBox wrapping, GestureDetector with opaque behavior |
| A11Y-03 | Labels per screen readers (Android) | Semantics widget with labels, TalkBack compatibility |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_local_notifications | ^17.2.0 | Local notifications on Android | Most widely used, actively maintained, supports Android 8.0+ notification channels, scheduling, and background execution |
| flutter | 3.38.9+ | UI framework | Current stable version with Impeller rendering engine for Android |
| sqflite | ^2.4.2 | SQLite database on Android | Already in use, performs well on Android with proper optimization |
| flutter_riverpod | ^2.6.0 | State management | Already in use, excellent performance for Android |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| timezone | ^0.9.4 | Timezone support for scheduled notifications | Required for accurate notification scheduling across timezone boundaries |
| flutter_native_timezone | ^2.0.0 | Get device timezone | For scheduling notifications in user's local timezone |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| flutter_local_notifications | local_notifier | local_notifier is simpler but less feature-rich, doesn't support Android notification channels well |
| flutter_local_notifications | awesome_notifications | awesome_notifications has more features but heavier (~2MB vs ~500KB), overkill for simple local notifications |
| App Bundle (AAB) | Split APKs | App Bundle is Google Play standard, automatic optimization; Split APKs only for direct distribution |

**Installation:**
```bash
# Add to pubspec.yaml
flutter pub add flutter_local_notifications
flutter pub add timezone
flutter pub add flutter_native_timezone
```

## Architecture Patterns

### Recommended Project Structure
```
lib/
├── features/
│   └── notifications/
│       ├── application/
│       │   └── notification_service.dart           # New: Platform-specific notification service
│       ├── presentation/
│       │   └── providers/
│       │       └── notification_permission_provider.dart  # New: Permission handling
│       └── domain/
│           └── services/
│               └── notification_scheduler_service.dart    # Existing: Reuse this
├── core/
│   ├── platform/
│   │   └── platform_service.dart                    # New: Platform detection and adaptive UI
│   └── theme/
│       └── app_theme.dart                           # Enhanced: Material Design 3 theming
└── main.dart                                        # Enhanced: Notification initialization
```

### Pattern 1: Platform-Adaptive Notification Service
**What:** Abstract service that handles platform-specific notification initialization and scheduling
**When to use:** When implementing notifications that work differently on web vs Android
**Example:**
```dart
// Source: flutter_local_notifications official documentation
abstract class NotificationService {
  Future<void> initialize();
  Future<void> scheduleNotification(NotificationSchedule schedule);
  Future<void> cancelNotification(String id);
  Future<void> cancelAllNotifications();
}

class AndroidNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
  }

  @override
  Future<void> scheduleNotification(NotificationSchedule schedule) async {
    const androidDetails = AndroidNotificationDetails(
      'reservation_reminders',  // Channel ID
      'Promemoria Prenotazioni', // Channel Name
      channelDescription: 'Notifiche per i promemoria delle prenotazioni',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      schedule.id.hashCode,
      'Promemoria Prenotazione',
      _buildNotificationMessage(schedule),
      schedule.scheduledDate,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void _handleNotificationTap(NotificationResponse response) {
    // Handle notification tap - navigate to reservation details
  }
}
```

### Pattern 2: Platform-Adaptive UI with PlatformWidgetBuilder
**What:** Build different UI components for Android vs Web using platform detection
**When to use:** When UI needs to adapt to platform conventions (Material 3 on Android, responsive on web)
**Example:**
```dart
// Source: Flutter platform adaptation best practices
Widget buildPlatformAdaptiveButton(BuildContext context) {
  return PlatformWidgetBuilder(
    android: (context) => ElevatedButton.icon(
      icon: const Icon(Icons.add),
      label: const Text('Aggiungi'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(48, 48), // A11Y-02: 48x48dp minimum
      ),
      onPressed: () {},
    ),
    web: (context) => ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () {},
      child: const Text('Aggiungi'),
    ),
  );
}
```

### Pattern 3: Accessibility with Semantics
**What:** Wrap interactive elements with Semantics widgets for screen readers
**When to use:** All interactive elements (buttons, icons, form fields)
**Example:**
```dart
// Source: Flutter accessibility documentation
Semantics(
  button: true,
  label: 'Elimina prenotazione',
  hint: 'Rimuove permanentemente questa prenotazione',
  child: GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => _deleteReservation(reservation.id),
    child: const SizedBox(
      width: 48,
      height: 48,
      child: Icon(Icons.delete, size: 24),
    ),
  ),
)
```

### Pattern 4: PopScope for Back Button Handling
**What:** Replace deprecated WillPopScope with PopScope for Android 14+ Predictive Back
**When to use:** When you need to intercept back button behavior (e.g., unsaved changes confirmation)
**Example:**
```dart
// Source: Flutter PopScope migration guide
PopScope(
  canPop: !_hasUnsavedChanges,
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;

    final shouldPop = await _showUnsavedChangesDialog();
    if (shouldPop && context.mounted) {
      context.pop();
    }
  },
  child: Scaffold(...),
)
```

### Anti-Patterns to Avoid
- **WillPopScope**: Deprecated and incompatible with Android 14+ Predictive Back. Use PopScope instead.
- **Hardcoded touch targets**: Don't rely on default widget sizes. Explicitly set minimumSize to 48x48 for buttons.
- **Skipping semantics**: Don't assume icons are self-explanatory. Always provide labels for screen readers.
- **Blocking initialization**: Don't make main() async for notification initialization. Use a multi-frame initialization pattern.
- **Ignoring web limitations**: Don't try to force web notifications to work like Android. Accept the limitations or skip web notifications.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Android notification scheduling | Custom AlarmManager service | flutter_local_notifications | Handles Android 8.0+ notification channels, boot receiver, Doze mode, permissions automatically |
| APK size optimization | Manual resource stripping | flutter build appbundle | Automatic optimization for screen density, language, CPU architecture (95% efficiency) |
| Touch target sizing | Custom padding calculations | SizedBox + minimumSize | Built-in enforcement, clearer intent, automatic semantics |
| Timezone handling | Manual timezone offset calculations | timezone package | Handles DST transitions, historical timezone data, IANA timezone database |
| Platform detection | kIsWeb boolean checks | PlatformWidgetBuilder or Theme.of(context).platform | More expressive, handles future platforms, cleaner code |

**Key insight:** Android has many platform-specific complexities (Doze mode, notification channels, background execution limits) that are difficult to handle correctly. flutter_local_notifications has already solved these problems and is battle-tested across millions of apps.

## Common Pitfalls

### Pitfall 1: Missing POST_NOTIFICATIONS Permission (Android 13+)
**What goes wrong:** Notifications don't appear on Android 13+ devices, no error shown
**Why it happens:** Android 13 (API level 33) requires runtime permission for POST_NOTIFICATIONS
**How to avoid:** Add permission to AndroidManifest.xml and request at runtime

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

```dart
// Request permission at runtime
final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
final bool? result = await plugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();
```

**Warning signs:** Notifications work on emulator but not on physical Android 13+ device

### Pitfall 2: Notification Channels Not Configured
**What goes wrong:** Notifications don't show on Android 8.0+ (API 26+)
**Why it happens:** Notification channels are mandatory for Android 8.0+ but not automatically created
**How to avoid:** Always create notification details with channel information

```dart
const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  'channel_id',           // Required
  'Channel Name',         // Required
  channelDescription: 'Description', // Optional but recommended
  importance: Importance.high,
  priority: Priority.high,
);
```

**Warning signs:** Notifications work on older Android devices but not on Android 8.0+

### Pitfall 3: Blocking Main Thread in build()
**What goes wrong:** Janky scrolling, dropped frames, poor performance on mid-range devices
**Why it happens:** Expensive operations (database queries, JSON parsing) in build() method
**How to avoid:** Move heavy operations to initState, use async loading patterns, cache results

```dart
// BAD - Database query in build()
@override
Widget build(BuildContext context) {
  final reservations = database.getReservations(); // Blocks UI!
  return ListView.builder(...);
}

// GOOD - Load in initState, use Riverpod
@override
void initState() {
  super.initState();
  _reservationsFuture = ref.read(reservationRepositoryProvider).getReservations();
}

@override
Widget build(BuildContext context) {
  final reservationsAsync = ref.watch(reservationsProvider);
  return reservationsAsync.when(...);
}
```

**Warning signs:** Flutter DevTools performance overlay shows red bars, janky scrolling

### Pitfall 4: Not Using RepaintBoundary
**What goes wrong:** Expensive widgets cause entire screen to repaint unnecessarily
**Why it happens:** Flutter repaints widget subtrees when parent rebuilds
**How to avoid:** Wrap expensive widgets (images, complex animations) in RepaintBoundary

```dart
RepaintBoundary(
  child: ExpensiveWidget(),
)
```

**Warning signs:** Profiler shows expensive paint operations for simple state changes

### Pitfall 5: Ignoring Touch Target Sizes
**What goes wrong:** UI fails accessibility testing, users can't reliably tap small buttons
**Why it happens:** Default widget sizes (e.g., Icon) are smaller than 48x48dp
**How to avoid:** Explicitly size interactive elements with SizedBox or minimumSize

```dart
// BAD - Small touch target
IconButton(
  icon: Icon(Icons.delete),
  onPressed: () {},
)

// GOOD - 48x48 touch target
SizedBox(
  width: 48,
  height: 48,
  child: IconButton(
    icon: Icon(Icons.delete),
    onPressed: () {},
  ),
)
```

**Warning signs:** Accessibility scanner flags small touch targets, users complain about difficulty tapping

### Pitfall 6: Universal APK for Distribution
**What goes wrong:** APK size 60-70MB, poor download conversion
**Why it happens:** Building universal APK includes all CPU architectures
**How to avoid:** Use App Bundle for Google Play or --split-per-abi for direct distribution

```bash
# BAD - Universal APK
flutter build apk --release  # 60-70MB

# GOOD - App Bundle (Google Play)
flutter build appbundle --release  # Optimized automatically

# GOOD - Split APKs (direct distribution)
flutter build apk --release --split-per-abi  # 16-28MB per architecture
```

**Warning signs:** APK file size > 50MB, users complain about download size

### Pitfall 7: Skipping Database Indexes
**What goes wrong:** Database queries slow down as data grows
**Why it happens:** Table scans instead of index lookups
**How to avoid:** Create indexes on frequently queried columns

```sql
-- BAD - No index
SELECT * FROM reservations WHERE check_in >= '2026-03-05';

-- GOOD - Index on check_in
CREATE INDEX idx_reservations_check_in ON reservations(check_in);
```

**Warning signs:** Queries slow down as reservation count increases, profiler shows time in database

## Code Examples

Verified patterns from official sources:

### Android Notification Initialization
```dart
// Source: flutter_local_notifications pub.dev documentation
// lib/main.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await _initializeNotifications();

  runApp(const App());
}

Future<void> _initializeNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  const initializationSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      _handleNotificationTap(response.payload);
    },
  );
}

void _handleNotificationTap(String? payload) {
  // Navigate to reservation details
  // This will be implemented with navigation logic
}
```

### Schedule Notification for Reservation
```dart
// Source: flutter_local_notifications zonedSchedule example
// lib/features/notifications/application/notification_service.dart

Future<void> scheduleReservationNotification(
  NotificationSchedule schedule,
  Reservation reservation,
) async {
  const androidDetails = AndroidNotificationDetails(
    'reservation_reminders',
    'Promemoria Prenotazioni',
    channelDescription: 'Notifiche per i promemoria delle prenotazioni Airbnb',
    importance: Importance.high,
    priority: Priority.high,
    styleInformation: BigTextStyleInformation(
      _buildNotificationMessage(schedule, reservation),
    ),
  );

  const notificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    schedule.id.hashCode,
    'Promemoria: ${reservation.guest.name}',
    _buildNotificationMessage(schedule, reservation),
    schedule.scheduledDate,
    notificationDetails,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
    payload: reservation.id,
  );
}

String _buildNotificationMessage(
  NotificationSchedule schedule,
  Reservation reservation,
) {
  return '''
${reservation.room.label}
Ospite: ${reservation.guest.name}
Check-in: ${DateFormat.yMd('it_IT').format(reservation.checkIn)}
Check-out: ${DateFormat.yMd('it_IT').format(reservation.checkOut)}
''';
}
```

### Request Notification Permission (Android 13+)
```dart
// Source: flutter_local_notifications Android 13+ permission guide
// lib/features/notifications/presentation/providers/notification_permission_provider.dart

final notificationPermissionProvider = FutureProvider<bool>((ref) async {
  final plugin = FlutterLocalNotificationsPlugin();

  final androidImplementation = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();

  if (androidImplementation == null) {
    return false; // Not on Android
  }

  final bool? granted = await androidImplementation.requestNotificationsPermission();
  return granted ?? false;
});
```

### Platform-Adaptive Theme
```dart
// Source: Flutter Material Design 3 theming guide
// lib/core/theme/app_theme.dart

ThemeData buildAdaptiveTheme(BuildContext context) {
  final platform = Theme.of(context).platform;

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: MediaQuery.of(context).platformBrightness,
    ),
    // Material 3 components
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(48, 48), // A11Y: 48x48 touch target
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    // Platform-specific adaptations
    appBarTheme: AppBarTheme(
      centerTitle: platform == TargetPlatform.iOS,
      elevation: 0,
    ),
  );
}
```

### Accessibility with Semantics
```dart
// Source: Flutter accessibility documentation
// lib/features/reservations/presentation/widgets/reservation_card.dart

Widget buildReservationCard(BuildContext context, Reservation reservation) {
  return Semantics(
    button: true,
    label: 'Prenotazione per ${reservation.guest.name}',
    hint: 'Tocca per vedere i dettagli',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showReservationDetails(reservation),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reservation.guest.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${reservation.room.label} - ${reservation.platform.name}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
```

### Touch Target Sizing for Icons
```dart
// Source: Material Design touch target guidelines
// lib/features/reservations/presentation/widgets/action_buttons.dart

Widget buildDeleteButton(BuildContext context, VoidCallback onPressed) {
  return Semantics(
    button: true,
    label: 'Elimina prenotazione',
    hint: 'Rimuove permanentemente questa prenotazione',
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: const SizedBox(
        width: 48,
        height: 48,
        child: Icon(
          Icons.delete,
          size: 24,
          color: Colors.red,
        ),
      ),
    ),
  );
}
```

### Database Query Optimization
```dart
// Source: sqflite performance best practices
// lib/features/reservations/data/repositories/reservation_repository_impl.dart

Future<List<Reservation>> getReservationsForDateRange(
  DateTime start,
  DateTime end,
) async {
  final db = await databaseHelper.database;

  // GOOD - Use indexed columns, only select needed data
  final results = await db.query(
    'reservations',
    where: 'check_in >= ? AND check_in <= ?',
    whereArgs: [start.toIso8601String(), end.toIso8601String()],
    orderBy: 'check_in ASC',
    limit: 50, // Pagination
  );

  return results.map((json) => ReservationModel.fromJson(json).toDomain()).toList();
}

// GOOD - Batch insert with transaction
Future<void> insertReservationsBatch(List<Reservation> reservations) async {
  final db = await databaseHelper.database;

  final batch = db.batch();
  for (final reservation in reservations) {
    final model = ReservationModel.fromDomain(reservation);
    batch.insert('reservations', model.toJson());
  }

  await batch.commit(noResult: true); // 15x faster than individual inserts
}
```

### Performance Optimization with ListView.builder
```dart
// Source: Flutter performance best practices
// lib/features/reservations/presentation/widgets/reservation_list.dart

Widget build(BuildContext context) {
  final reservationsAsync = ref.watch(reservationsProvider);

  return reservationsAsync.when(
    data: (reservations) => ListView.builder(
      itemCount: reservations.length,
      itemExtent: 80, // Fixed height improves scrolling performance
      cacheExtent: 500, // Pre-render 500px worth of items
      itemBuilder: (context, index) {
        return ReservationListItem(reservation: reservations[index]);
      },
    ),
    loading: () => const CircularProgressIndicator(),
    error: (error, stack) => Text('Errore: $error'),
  );
}
```

### PopScope for Back Button
```dart
// Source: Flutter PopScope migration guide
// lib/features/reservations/presentation/pages/reservation_form_page.dart

Widget build(BuildContext context) {
  final formState = ref.watch(reservationFormProvider);

  return PopScope(
    canPop: !formState.hasUnsavedChanges,
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop) return;

      final shouldPop = await _showUnsavedChangesDialog(context);
      if (shouldPop && context.mounted) {
        context.pop();
      }
    },
    child: Scaffold(
      appBar: AppBar(title: const Text('Nuova Prenotazione')),
      body: ReservationForm(),
    ),
  );
}

Future<bool> _showUnsavedChangesDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Modifiche non salvate'),
      content: const Text('Vuoi uscire senza salvare?'),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: () => context.pop(true),
          child: const Text('Esci'),
        ),
      ],
    ),
  );
  return result ?? false;
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| WillPopScope | PopScope | Flutter 3.12 (2023) | Required for Android 14+ Predictive Back feature |
| Universal APK | App Bundle (AAB) | Aug 2021 (Google Play mandate) | 60-75% size reduction per device, mandatory for Play Store |
| Manual notification icons | Adaptive icons | Android 8.0 (API 26) | Icons adapt to device theme, better UX |
| POST_NOTIFICATIONS auto-granted | Runtime permission required | Android 13 (API 33) | Must request permission at runtime |
| Impeller optional | Impeller default | Flutter 3.22 (2024) | Eliminates shader compilation jank, smoother animations |
| Material Design 2 | Material Design 3 | Flutter 3.16 (2023) | Dynamic color, updated components, better accessibility |

**Deprecated/outdated:**
- WillPopScope: Use PopScope instead for Android 14+ compatibility
- x86 CPU architecture: Deprecated, exclude from builds to reduce size
- ProGuard: Use R8 instead (automatic in Flutter 3.x)
- NotificationCompat (Android native): flutter_local_notifications handles this

## Open Questions

1. **Web notification implementation**
   - What we know: Web Notification API has significant limitations (user gesture requirement, HTTPS-only, iOS Safari no support, limited customization)
   - What's unclear: Whether to implement web notifications at all given limitations
   - Recommendation: Skip web notifications in Phase 6. Focus on Android implementation. Web notifications can be added later as optional enhancement if user explicitly requests them. The REQUIREMENTS.md says "se supportato" (if supported), which gives discretion to skip.

2. **Notification scheduling persistence**
   - What we know: flutter_local_notifications uses native Android scheduling which persists across app restarts
   - What's unclear: Whether to reschedule notifications on app startup or trust Android's persistence
   - Recommendation: Implement idempotent rescheduling on app startup. Query database for pending notifications and reschedule them. This ensures notifications survive Android's battery optimization and Doze mode.

3. **Minimum Android SDK version**
   - What we know: Flutter default is Android 21 (Android 5.0 Lollipop)
   - What's unclear: Whether to raise minimum SDK to support newer features
   - Recommendation: Keep default SDK 21 for maximum compatibility. Most features (notification channels, adaptive icons) have fallback mechanisms for older Android versions.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (built-in) |
| Config file | None - uses default Flutter test configuration |
| Quick run command | `flutter test` |
| Full suite command | `flutter test --coverage` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| NOT-07 | Android local notifications | integration/manual | Manual testing on Android device required | ❌ Wave 0 |
| NOT-08 | Web browser notifications | integration/manual | Manual testing on Chrome required | ❌ Wave 0 |
| TEST-05 | Complete Android testing | manual | Physical device testing required | ❌ Wave 0 |
| PLATFORM-04 | Android platform functionality | integration | `flutter test integration/android_platform_test.dart` | ❌ Wave 0 |
| PLATFORM-05 | Performance on mid-range device | manual | DevTools profiling on device | ❌ Wave 0 |
| A11Y-02 | 48x48dp touch targets | unit/widget | `flutter test test/features/reservations/presentation/widgets/accessibility_test.dart` | ❌ Wave 0 |
| A11Y-03 | Screen reader labels | widget/manual | `flutter test test/accessibility/semantics_test.dart` + TalkBack verification | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test` (all existing tests must pass)
- **Per wave merge:** `flutter test --coverage` (verify test coverage)
- **Phase gate:** Full suite green + manual Android device testing before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/features/notifications/application/notification_service_test.dart` — Unit tests for notification service
- [ ] `test/features/notifications/presentation/providers/notification_permission_provider_test.dart` — Permission provider tests
- [ ] `test/integration/android_notifications_test.dart` — Integration tests for notification scheduling (requires Android environment)
- [ ] `test/features/reservations/presentation/widgets/accessibility_test.dart` — Touch target size tests
- [ ] `test/accessibility/semantics_test.dart` — Semantics label tests
- [ ] Manual testing checklist for Android device (notifications, performance, accessibility)
- [ ] DevTools profiling checklist for performance validation

### Manual Testing Requirements
Since several requirements (NOT-07, NOT-08, TEST-05, PLATFORM-05, A11Y-03) involve platform-specific behavior and user experience, manual testing on physical Android devices is required:

**Android Device Testing Checklist:**
1. Notifications appear at scheduled time
2. Notifications display correct guest name, room, dates
3. Tapping notification opens app to correct reservation
4. Notifications work after device restart
5. Notifications work in Doze mode
6. App scrolls smoothly on mid-range device (60fps)
7. All touch targets are 48x48dp minimum
8. TalkBack reads meaningful labels for all interactive elements
9. Back button behavior works correctly
10. APK size is reasonable (< 30MB per architecture)

## Sources

### Primary (HIGH confidence)
- [flutter_local_notifications 17.2.0 pub.dev](https://pub.dev/packages/flutter_local_notifications) - Official package documentation, API reference, setup guide
- [Flutter Official Documentation - Debugging](https://docs.flutter.dev/testing/debugging) - Official debugging tools and practices
- [Android Developer Documentation - SQLite Performance Best Practices](https://developer.android.google.cn/topic/performance/sqlite-performance-best-practices) - Official Android SQLite optimization guide
- [Flutter Documentation - PopScope](https://docs.flutter.dev/release/breaking-changes/android-predictive-back) - Official PopScope migration guide
- [Flutter Documentation - Accessibility](https://docs.flutter.cn/ui/accessibility-and-internationalization/accessibility/) - Official accessibility guidelines

### Secondary (MEDIUM confidence)
- [Flutter本地通知终极指南](https://m.blog.csdn.net/gitblog_00526/article/details/155808881) - Comprehensive notification setup guide (Dec 2025)
- [Flutter SQLite 2025实战：从入门到性能优化](https://m.toutiao.com/a7535512503038263847/) - SQLite performance benchmarks and techniques (Aug 2025)
- [Flutter App Bundle Optimization Guide](https://blog.csdn.net/guliang28/article/details/151584518) - APK size optimization strategies (2025)
- [Flutter PopScope 返回拦截完整指南](https://juejin.cn/post/7580592190020452386) - PopScope implementation patterns (2025)
- [Flutter Accessibility Development Guide](https://m.blog.csdn.net/2501_93814044/article/details/155737700) - Accessibility implementation examples (Nov 2025)
- [Flutter Android Testing Guide](https://juejin.cn/post/7493198688870072372) - Physical device and emulator testing (2025)

### Tertiary (LOW confidence)
- [JavaScript Browser Notification API](https://m.php.cn/faq/1880028.html) - Web notification API limitations (marked for validation - official MDN docs should be consulted)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - flutter_local_notifications is de facto standard, well-documented, actively maintained
- Architecture: HIGH - Patterns based on official Flutter documentation and best practices
- Pitfalls: HIGH - All pitfalls verified with official documentation or well-known issues
- Web notifications: MEDIUM - Significant limitations confirmed, but implementation decision is open
- Performance optimization: HIGH - SQLite benchmarks and Flutter DevTools practices well-documented
- Accessibility: HIGH - Material Design guidelines and Flutter Semantics well-established

**Research date:** 2026-03-05
**Valid until:** 2026-04-05 (30 days - Flutter ecosystem is stable, but package versions may update)
