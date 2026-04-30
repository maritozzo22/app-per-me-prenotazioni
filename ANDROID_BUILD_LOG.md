# Android Build Log

**Build Date**: 2026-03-06 14:42
**Build Type**: Debug
**Build Method**: Flutter CLI (flutter build apk --debug)

---

## Build Environment

| Component | Version |
|-----------|---------|
| Flutter | 3.38.9 |
| Dart | 3.6.1 |
| Android SDK | 36.1.0 |
| Java | 17 |
| Gradle | (managed by Flutter) |

## Build Configuration

| Setting | Value |
|---------|-------|
| Application ID | app.prenotazioni.app_prenotazioni |
| Min SDK | 21 (Android 5.0) |
| Target SDK | 34 (Android 14) |
| Compile SDK | 34 |

## Build Output

| Metric | Value |
|--------|-------|
| APK Size | 167 MB |
| Build Time | ~12 seconds |
| Output Path | `build/app/outputs/flutter-apk/app-debug.apk` |

## Permissions Declared

- `INTERNET`
- `ACCESS_NETWORK_STATE`
- `POST_NOTIFICATIONS`
- `SCHEDULE_EXACT_ALARM`
- `RECEIVE_BOOT_COMPLETED`

## Deployment

| Detail | Value |
|--------|-------|
| Device Model | DN2103 |
| Android Version | 13 (API 33) |
| Installation Method | adb install -r |
| Installation Result | Success |
| App Launch | Success |
| Process Status | Running (PID 15247) |

## Build Notes

1. **Build Method**: Flutter CLI used instead of Android Studio
   - Reason: App does not have complex native resources that require Android Studio
   - Result: Build completed successfully

2. **Installation**: Used `adb install -r` directly
   - `flutter install` was looking for release APK which didn't exist
   - Direct adb install worked perfectly

3. **Smoke Test**: App launched successfully
   - No crashes detected in logs
   - Process running normally

## Verification Checklist

- [x] Flutter environment verified (flutter doctor passed)
- [x] DN2103 device connected and recognized
- [x] APK built successfully
- [x] APK size reasonable for debug build (167MB)
- [x] APK installed on device
- [x] App launches from home screen
- [x] No crashes during launch
- [x] Build process documented

---

## Commands Reference

```bash
# Build debug APK
flutter build apk --debug

# Check APK
ls -la build/app/outputs/flutter-apk/app-debug.apk

# List devices
flutter devices

# Install via adb
adb -s YHBABYNNINFAC6NJ install -r build/app/outputs/flutter-apk/app-debug.apk

# Launch app
adb -s YHBABYNNINFAC6NJ shell am start -n app.prenotazioni.app_prenotazioni/.MainActivity

# Check if running
adb -s YHBABYNNINFAC6NJ shell "ps -A | grep prenotazioni"
```

---

**Build Status**: ✅ SUCCESS
