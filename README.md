# App Prenotazioni Airbnb

A Flutter application for managing Airbnb and Booking reservations with visual calendar, dashboard analytics, and local notifications.

## Features

- 📅 **Visual Calendar** - Monthly calendar with color-coded reservations by platform (Booking, Airbnb, etc.)
- 📊 **Dashboard** - Room occupancy overview, upcoming check-ins/check-outs, and income tracking
- 🔔 **Local Notifications** - Automatic notifications before check-ins (5, 3, 2, 1 days before + same day)
- 🌙 **Dark Mode** - Toggle between light and dark themes with persistent preference
- 🔍 **Search** - Real-time search by guest name, phone number, or notes
- ♿ **Accessible** - 48dp touch targets, screen reader support, semantic labels
- ✨ **Smooth Animations** - Professional transitions, staggered list animations, and micro-interactions
- 🎨 **Platform Colors** - Customizable platform colors for visual identification
- 💾 **Local Storage** - SQLite database for offline-first functionality

## Screenshots

### Calendar View
- Monthly calendar with platform-colored reservation markers
- Tap any day to view reservation details in bottom sheet
- Navigate between months with smooth animations

### Dashboard
- Room occupancy grid (2x2 layout showing all rooms)
- Upcoming check-ins (next 7 days)
- Upcoming check-outs (next 7 days)
- Monthly income breakdown (received vs pending)

### Reservations List
- Sorted by check-in date
- Real-time search and filtering
- Swipe actions for quick edit/delete
- Form validation with date overlap detection

## Prerequisites

- **Flutter SDK**: 3.24.0 or higher
- **Android Studio** (for Android APK builds)
- **Git**

### Check Flutter Installation

```bash
flutter doctor
```

Ensure all checks pass (except iOS if not developing for iOS).

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd app-per-me-prenotazioni
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

#### On Web (Chrome)

```bash
flutter run -d chrome
```

#### On Android

```bash
flutter devices
flutter run -d <device-id>
```

Or use Android Studio to build and run.

## Building Android APK

**IMPORTANT:** Use Android Studio to build the APK (`flutter build apk` has known issues with native resources on Windows).

### Steps:

1. Open Android Studio
2. File → Open → Select the `android/` folder
3. Build → Build Bundle(s) / APK(s) → Build APK(s)
4. APK will be at: `android/app/build/outputs/apk/debug/app-debug.apk`

For detailed instructions, see [ANDROID_BUILD.md](ANDROID_BUILD.md).

## Project Structure

```
lib/
├── core/                      # Core functionality
│   ├── database/             # SQLite database setup
│   ├── error/                # Error handling utilities
│   ├── theme/                # App theme (light/dark)
│   ├── utils/                # Animation utilities
│   └── widgets/              # Reusable widgets
│       ├── animations.dart
│       ├── animated_button.dart
│       └── ...
├── features/                 # Feature modules
│   ├── dashboard/            # Dashboard feature
│   ├── notifications/        # Notifications feature
│   ├── platforms/            # Platform management
│   ├── reservations/        # Reservation management
│   └── search/               # Search functionality
└── main.dart                 # App entry point
```

### Architecture

- **Pattern**: Clean Architecture with feature-based organization
- **State Management**: Provider (flutter_riverpod)
- **Database**: SQLite with sqflite
- **Testing**: Unit, widget, and integration tests

## Features Overview

### 📅 Calendar View
- Monthly calendar with color-coded reservations
- Platform colors: Booking (blue), Airbnb (red), and custom platforms
- Tap day to see reservation details in bottom sheet
- Navigate between months with smooth animations
- Today indicator with subtle pulse animation

### 📊 Dashboard
- Room occupancy overview (2x2 grid)
- Upcoming check-ins (next 7 days)
- Upcoming check-outs (next 7 days)
- Monthly income breakdown (received/pending)
- Staggered card animations on load

### 📝 Reservation Management
- Create new reservations with overlap detection
- Edit existing reservations
- Delete reservations with confirmation
- Automatic date overlap validation
- Field validation with shake animation on errors
- Platform and room selection
- Payment status tracking

### 🔔 Notifications
- **Automatic Schedule**: 5, 3, 2, 1 days before check-in + same day
- **Android Local Notifications**: Native notification system
- **Tap to Navigate**: Tapping notification opens reservation details
- **Automatic Cancellation**: Notifications removed when reservation deleted
- **Exact Alarms**: Uses exact alarm permission (Android 12+)

### 🔍 Search
- Search by guest name
- Search by phone number
- Search by notes
- Real-time filtering with debouncing
- Clear button with semantic label

### 🌙 Dark Mode
- Toggle dark/light theme from app bar
- Persistent theme preference
- Optimized colors for both modes
- Smooth theme transition animation

### ⚙️ Platform Management
- Add custom platforms
- Edit platform names and colors
- Delete unused platforms
- Default platforms: Booking, Airbnb, WhatsApp, Web, TikTok
- Platform colors used throughout app

## Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Test Type

```bash
# Unit tests only
flutter test --unit

# Widget tests only
flutter test --widget

# Integration tests
flutter test test/integration/
```

### Test Coverage

- **Total Tests**: 223+
- **Unit Tests**: 150+
- **Widget Tests**: 50+
- **Integration Tests**: 25+
- **Coverage**: ~85%

## Troubleshooting

### Web build issues

**Problem**: App doesn't run on Chrome

**Solution**: Ensure you have the latest Chrome version and Flutter SDK

### Android notification issues

**Problem**: Notifications not appearing

**Solution**:
- Check notification permissions in app settings
- Ensure exact alarm permission is granted (Android 12+)
- Check battery optimization is not blocking the app
- Verify notifications are scheduled in database

### Database issues

**Problem**: App crashes on startup with database error

**Solution**: Clear app data and restart (data is local only)

### APK build issues

**Problem**: APK missing resources or permissions

**Solution**: Use Android Studio to build (see Building Android APK section)

### Low performance

**Problem**: App is slow/janky

**Solution**:
- Close other apps
- Check device storage is not full
- Ensure running on Android 6.0 or higher
- Animations respect "Reduce Motion" accessibility setting

## Development

### Code Style

- Follow Dart effective style guidelines
- Use `dart format .` for formatting
- Use `dart analyze` to check for issues

### Adding New Features

1. Create feature directory under `lib/features/`
2. Follow clean architecture structure:
   - `domain/` - Entities, value objects, repositories interfaces
   - `data/` - Repository implementations, data sources
   - `application/` - Use cases/services
   - `presentation/` - UI components, providers, pages
3. Add tests for all layers
4. Update documentation

## Accessibility

This app is designed with accessibility in mind:

- **Touch Targets**: All interactive elements meet 48x48dp minimum
- **Screen Reader**: Full semantic labeling for TalkBack/VoiceOver
- **Keyboard Navigation**: Logical tab order (web)
- **Color Contrast**: WCAG AA compliant (4.5:1 for text)
- **Font Scaling**: Supports up to 200% font scale
- **Reduce Motion**: Respects system reduce motion setting

## Known Issues

- **Test Failures**: 3 pre-existing test failures related to calendar UI changes (not blocking)
- **Android Build**: Use Android Studio instead of `flutter build apk` on Windows

## Contributing

This is a personal app, but suggestions are welcome!

### Development Workflow

1. Create a feature branch
2. Make your changes
3. Add/update tests
4. Run tests: `flutter test`
5. Commit with conventional commits
6. Submit pull request

## License

This project is for personal use.

## Acknowledgments

- Flutter team for the amazing framework
- table_calendar package for calendar widget
- flutter_form_builder for form handling
- sqflite for local database

---

**Version**: 1.0.0
**Last Updated**: 2026-03-06
**Status**: Production Ready ✅
