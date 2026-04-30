import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_prenotazioni/core/error/error_handler.dart';

/// Key for storing theme preference
const String _themePreferenceKey = 'theme_mode';

/// Theme mode notifier
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  /// Load theme from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themePreferenceKey);

      if (themeModeString != null) {
        final themeMode = _parseThemeMode(themeModeString);
        state = themeMode;
      }
    } catch (e, stack) {
      // If loading fails, keep system theme
      ErrorHandler.logError(e, stack);
    }
  }

  /// Parse theme mode from string
  ThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Convert theme mode to string
  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  /// Set theme mode
  Future<void> setTheme(ThemeMode themeMode) async {
    state = themeMode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePreferenceKey, _themeModeToString(themeMode));
    } catch (e, stack) {
      ErrorHandler.logError(e, stack);
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(newTheme);
  }
}

/// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
