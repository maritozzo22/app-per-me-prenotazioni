---
phase: 01-foundation-data-model
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - pubspec.yaml
  - analysis_options.yaml
  - lib/main.dart
  - lib/core/constants/app_constants.dart
autonomous: true
requirements:
  - DATA-04
  - DATA-05
must_haves:
  truths:
    - "Flutter project runs on Chrome without errors"
    - "All dependencies are correctly resolved"
    - "Code analysis passes with no warnings"
  artifacts:
    - path: "pubspec.yaml"
      provides: "Project dependencies configuration"
      contains: "sqflite"
      min_lines: 30
    - path: "lib/main.dart"
      provides: "Application entry point"
      exports: ["main"]
  key_links:
    - from: "pubspec.yaml"
      to: "pub.dev"
      via: "dependency resolution"
      pattern: "flutter pub get"
---

<objective>
Create Flutter project with correct dependencies for cross-platform SQLite storage (web + Android).

Purpose: Establish the foundation for a reservations management app that works on both web and Android.
Output: Configured Flutter project with all necessary dependencies.
</objective>

<execution_context>
@./.claude/get-shit-done/workflows/execute-plan.md
@./.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md
@.planning/phases/01-foundation-data-model/01-RESEARCH.md

## Critical Research Findings

1. **sqflite_common_ffi_web is EXPERIMENTAL** - NOT recommended for production
2. **Recommended approach:** sqflite for Android + idb_shim for web (IndexedDB wrapper)
3. **Alternative:** Hive has better cross-platform support but less query flexibility
4. **Data models:** Use freezed + json_serializable for immutable models with JSON support
5. **Platform colors locked:** Booking=0xFF2196F3, Airbnb=0xFFE91E63, WhatsApp=0xFF4CAF50, Website=0xFF9C27B0, TikTok=0xFF212121
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create Flutter project structure</name>
  <files>pubspec.yaml, lib/main.dart, lib/core/constants/app_constants.dart</files>
  <action>
Create the Flutter project with the following structure:

1. Initialize Flutter project in the current directory (if not already done):
   ```
   flutter create . --platforms=web,android
   ```

2. Update pubspec.yaml with dependencies:

```yaml
name: app_prenotazioni
description: App per gestire prenotazioni Airbnb
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.10.8 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Database
  sqflite: ^2.4.2
  path: ^1.8.3
  idb_shim: ^2.6.0

  # Data models
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

  # Utilities
  uuid: ^4.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  mocktail: ^1.0.0
  # CRITICAL: Required for running sqflite tests on desktop/web platforms
  sqflite_common_ffi: ^2.3.0

flutter:
  uses-material-design: true
```

**Note:** `sqflite_common_ffi: ^2.3.0` in dev_dependencies is required for tests in Plan 04 to work correctly on Windows/desktop platforms. Without this, DatabaseHelper tests will fail because sqflite requires a native implementation that is not available outside of mobile platforms.

3. Create lib/core/constants/app_constants.dart with app-wide constants:

```dart
/// App-wide constants for the reservations management app.
class AppConstants {
  AppConstants._();

  static const String appName = 'Prenotazioni';
  static const String databaseName = 'reservations.db';
  static const int databaseVersion = 1;
}
```

4. Update lib/main.dart with minimal working app:

```dart
import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      home: const Scaffold(
        body: Center(
          child: Text('Prenotazioni App - Foundation Phase'),
        ),
      ),
    );
  }
}
```

5. Run `flutter pub get` to resolve dependencies.
</action>
  <verify>
    <automated>flutter analyze && flutter pub get</automated>
    <manual>After automated verification passes, manually verify: `flutter run -d chrome` launches the app in Chrome browser showing placeholder text</manual>
  </verify>
  <done>
    - Flutter project created with web and android platforms
    - All dependencies in pubspec.yaml resolve without conflicts
    - `flutter analyze` passes with no errors
    - sqflite_common_ffi included in dev_dependencies for test support
    - App launches on Chrome showing placeholder text (manual verification)
  </done>
</task>

<task type="auto">
  <name>Task 2: Configure analysis options</name>
  <files>analysis_options.yaml</files>
  <action>
Create analysis_options.yaml with strict linting rules for code quality:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "build/**"
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - avoid_print
    - avoid_relative_lib_imports
    - prefer_single_quotes
    - sort_child_properties_last
    - use_key_in_widget_constructors
```

The exclude rules are critical because freezed and json_serializable generate `.freezed.dart` and `.g.dart` files that we should not analyze.
</action>
  <verify>
    <automated>flutter analyze</automated>
  </verify>
  <done>
    - analysis_options.yaml created with Flutter lints
    - Generated files excluded from analysis
    - `flutter analyze` passes with no warnings
  </done>
</task>

</tasks>

<verification>
- [ ] Flutter project initialized with web and android platforms
- [ ] pubspec.yaml contains all required dependencies including sqflite_common_ffi
- [ ] `flutter pub get` completes without errors
- [ ] `flutter analyze` passes with no issues
- [ ] App runs on Chrome: `flutter run -d chrome` (manual verification step)
</verification>

<success_criteria>
1. Flutter project structure follows Clean Architecture
2. All dependencies resolve correctly (sqflite, idb_shim, freezed, json_serializable, sqflite_common_ffi)
3. Code analysis passes with no warnings
4. App launches successfully on Chrome browser
</success_criteria>

<output>
After completion, create `.planning/phases/01-foundation-data-model/01-01-SUMMARY.md`
</output>
