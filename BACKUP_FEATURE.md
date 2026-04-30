# Backup Feature Documentation

## Overview

The backup feature provides automatic and manual backup capabilities for all app data, including reservations, platforms, and rooms. Backups are stored as JSON files on the device and can be shared or restored at any time.

## Features

### Automatic Backups
- **Daily Backup**: Automatically creates a backup at 2:00 AM
- **Weekly Backup**: Automatically creates a full backup every Sunday at 3:00 AM

### Manual Backups
- Create backups on-demand from Settings > Backup e Ripristino
- View all available backups with details
- Restore from any backup
- Delete unwanted backups
- Share backup files via email, cloud storage, etc.

## Backup File Format

```json
{
  "version": "1.0.0",
  "timestamp": "2026-03-06T14:30:00.000",
  "reservations": [
    {
      "id": "res-001",
      "roomId": "room-1",
      "platformId": "airbnb",
      "guest": {
        "name": "Guest Name",
        "phone": "+39 123 4567890"
      },
      "checkIn": "2026-03-10T00:00:00.000",
      "checkOut": "2026-03-15T00:00:00.000",
      "amount": 350.00,
      "paymentStatus": "received",
      "notes": "",
      "createdAt": "2026-03-01T00:00:00.000",
      "updatedAt": "2026-03-01T00:00:00.000"
    }
  ],
  "platforms": [...],
  "rooms": [...],
  "backupType": "manual"
}
```

## Backup Storage Location

Backups are stored in the app's private storage:
```
/data/data/app.prenotazioni.app_prenotazioni/app_flutter/backups/
```

On Android 11+, this is accessible via:
- File Manager > Android > data > app.prenotazioni.app_prenotazioni > files > backups

## File Naming Convention

- Manual: `backup_YYYYMMDD_HHMMSS.json`
- Daily: `backup_YYYYMMDD_HHMMSS.json`
- Weekly: `weekly_backup_YYYYMMDD_HHMMSS.json`

Example: `backup_20260306_143000.json`

## How to Use

### Create a Manual Backup
1. Open Settings (Impostazioni)
2. Tap "Backup e Ripristino"
3. Tap "Crea Backup"
4. Wait for confirmation message

### Restore from Backup
1. Open Settings > Backup e Ripristino
2. Find the backup you want to restore
3. Tap "Ripristina" (Restore)
4. Confirm the restore operation
5. Wait for completion

### Share a Backup
1. Open Settings > Backup e Ripristino
2. Find the backup you want to share
3. Tap "Condividi" (Share)
4. Select the sharing method (email, cloud, etc.)

### Delete a Backup
1. Open Settings > Backup e Ripristino
2. Find the backup you want to delete
3. Tap the delete icon
4. Confirm deletion

## Troubleshooting

### Automatic Backups Not Running
- **Cause**: Device battery optimization or Doze mode
- **Solution**:
  1. Go to Settings > Battery > App battery optimization
  2. Find "App Prenotazioni"
  3. Select "Don't optimize"

### Backup Fails
- **Cause**: Insufficient storage
- **Solution**: Free up device storage or delete old backups

### Restore Fails
- **Cause**: Corrupted backup file
- **Solution**:
  1. Try a different backup
  2. Check backup file integrity manually

### Can't Find Backup Files
- **Cause**: Android 11+ storage restrictions
- **Solution**: Use the Share feature to export backups to a visible location

## Data Safety

- Backups contain all app data including reservations, platforms, and rooms
- Restore operations replace ALL current data
- Always create a backup before restoring
- Store important backups externally (cloud, PC) for safety

## Version Compatibility

Current backup version: `1.0.0`

The backup service supports all versions starting with `1.` (e.g., 1.0.0, 1.1.0, etc.)

Future versions may include migration support for older backup formats.
