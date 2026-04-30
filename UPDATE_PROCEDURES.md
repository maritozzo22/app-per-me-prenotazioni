# Update Procedures

**Project**: App Prenotazioni Airbnb
**Last Updated**: 2026-03-06

---

## Overview

This document describes how to update the app when new versions are available.

---

## Pre-Update Checklist

Before updating the app:

- [ ] Create backup of current data (Settings → Backup & Restore → Create Backup)
- [ ] Note current app version
- [ ] Charge device to at least 50%
- [ ] Have 10-15 minutes available for update process

---

## Update Methods

### Method 1: Backup Before Update

1. Open app
2. Navigate to **Settings → Backup & Restore**
3. Tap **Create Backup**
4. Wait for completion
5. Verify backup appears in list
6. Proceed with update

### Method 2: Install New APK

1. Transfer new APK to device (USB, cloud, etc.)
2. Use file manager to locate APK
3. Tap APK to install
4. If prompted, allow installation from unknown sources
5. Wait for installation
6. Open updated app
7. Verify data is intact

### Method 3: Update via Flutter (Development)

1. Connect device via USB
2. Build updated APK:
   ```bash
   flutter build apk --debug
   ```
3. Install to device:
   ```bash
   adb -s YHBABYNNINFAC6NJ install -r build/app/outputs/flutter-apk/app-debug.apk
   ```
4. Test thoroughly

---

## Post-Update Verification

After updating, verify:

- [ ] App launches successfully
- [ ] All reservations present
- [ ] Calendar displays correctly
- [ ] Dashboard statistics accurate
- [ ] All features working
- [ ] No new issues

---

## Rollback Procedure

If update causes problems:

### Step 1: Uninstall Problematic Version
- Settings → Apps → App Prenotazioni → Uninstall

### Step 2: Install Previous Version
- Locate previous APK
- Install APK

### Step 3: Restore Data
1. Open app
2. Navigate to Settings → Backup & Restore
3. Select backup from before update
4. Tap **Restore**
5. Confirm
6. Wait for restore
7. Verify data

---

## Commands Reference

```bash
# Check connected devices
flutter devices

# Build debug APK
flutter build apk --debug

# Install APK via adb
adb -s YHBABYNNINFAC6NJ install -r build/app/outputs/flutter-apk/app-debug.apk

# Launch app
adb shell am start -n app.prenotazioni.app_prenotazioni/.MainActivity

# View app logs
adb logcat | grep flutter
```

---

## Troubleshooting

### App Won't Install
- Check if "Install from unknown sources" is enabled
- Uninstall previous version first
- Check storage space

### Data Lost After Update
- Restore from backup (Settings → Backup & Restore)
- Check backup files exist in storage

### App Crashes After Update
- Clear app data
- Reinstall app
- Restore from backup
