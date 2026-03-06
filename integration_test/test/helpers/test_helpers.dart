import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Common test utilities for integration testing.
class TestHelpers {
  /// Wait for widget to appear with timeout.
  static Future<void> waitForWidget(
    WidgetTester tester,
    Key key, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      if (find.byKey(key).evaluate().isNotEmpty) {
        return;
      }
    }
    throw TimeoutException('Widget with key $key not found within ${timeout.inSeconds}s', timeout);
  }

  /// Wait for widget to disappear with timeout.
  static Future<void> waitForWidgetToDisappear(
    WidgetTester tester,
    Key key, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      if (find.byKey(key).evaluate().isEmpty) {
        return;
      }
    }
    throw TimeoutException('Widget with key $key still visible after ${timeout.inSeconds}s', timeout);
  }

  /// Tap widget and wait for animations.
  static Future<void> tapAndWait(
    WidgetTester tester,
    Key key, {
    Duration settleTime = const Duration(seconds: 2),
  }) async {
    await tester.ensureVisible(find.byKey(key));
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle(settleTime);
  }

  /// Tap widget by text and wait.
  static Future<void> tapTextAndWait(
    WidgetTester tester,
    String text, {
    Duration settleTime = const Duration(seconds: 2),
  }) async {
    await tester.ensureVisible(find.text(text).first);
    await tester.tap(find.text(text).first);
    await tester.pumpAndSettle(settleTime);
  }

  /// Tap widget by icon and wait.
  static Future<void> tapIconAndWait(
    WidgetTester tester,
    IconData icon, {
    Duration settleTime = const Duration(seconds: 2),
  }) async {
    await tester.ensureVisible(find.byIcon(icon).first);
    await tester.tap(find.byIcon(icon).first);
    await tester.pumpAndSettle(settleTime);
  }

  /// Enter text and wait.
  static Future<void> enterTextAndWait(
    WidgetTester tester,
    Key key,
    String text, {
    Duration settleTime = const Duration(milliseconds: 500),
  }) async {
    await tester.ensureVisible(find.byKey(key));
    await tester.enterText(find.byKey(key), text);
    await tester.pumpAndSettle(settleTime);
  }

  /// Scroll until widget is visible.
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Key key, {
    Duration timeout = const Duration(seconds: 10),
    double delta = -300,
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      try {
        await tester.ensureVisible(find.byKey(key));
        if (find.byKey(key).evaluate().isNotEmpty) {
          return;
        }
      } catch (_) {
        // Continue scrolling
      }
      await tester.drag(find.byType(ListView).first, Offset(0, delta));
      await tester.pumpAndSettle();
    }
    throw TimeoutException('Could not scroll to widget $key', timeout);
  }

  /// Measure performance of an action.
  static Future<Map<String, dynamic>> measurePerformance(
    WidgetTester tester,
    Future<void> Function() action,
  ) async {
    final start = DateTime.now();
    final stopwatch = Stopwatch()..start();

    await action();

    stopwatch.stop();
    final end = DateTime.now();

    return {
      'start_time': start.toIso8601String(),
      'end_time': end.toIso8601String(),
      'duration_ms': stopwatch.elapsedMilliseconds,
      'duration_seconds': stopwatch.elapsedMilliseconds / 1000.0,
    };
  }

  /// Wait for app to fully load.
  static Future<void> waitForAppToLoad(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      // Check if the main navigation is visible
      if (find.byKey(const Key('bottom_nav')).evaluate().isNotEmpty) {
        return;
      }
    }
    throw TimeoutException('App did not load within ${timeout.inSeconds}s', timeout);
  }

  /// Navigate to a specific tab.
  static Future<void> navigateToTab(
    WidgetTester tester,
    Key tabKey,
  ) async {
    await tapAndWait(tester, tabKey);
  }

  /// Check if widget exists.
  static bool widgetExists(Key key) {
    return find.byKey(key).evaluate().isNotEmpty;
  }

  /// Check if text exists.
  static bool textExists(String text) {
    return find.text(text).evaluate().isNotEmpty;
  }

  /// Check if text containing substring exists.
  static bool textContainingExists(String substring) {
    return find.textContaining(substring).evaluate().isNotEmpty;
  }

  /// Dismiss any open dialogs or modals.
  static Future<void> dismissDialog(WidgetTester tester) async {
    if (find.byType(Dialog).evaluate().isNotEmpty) {
      await tester.tapAt(const Offset(10, 10)); // Tap outside dialog
      await tester.pumpAndSettle();
    }
  }

  /// Dismiss bottom sheet.
  static Future<void> dismissBottomSheet(WidgetTester tester) async {
    if (find.byType(BottomSheet).evaluate().isNotEmpty) {
      await tester.drag(find.byType(BottomSheet), const Offset(0, 500));
      await tester.pumpAndSettle();
    }
  }

  /// Log test step for debugging.
  static void logStep(String step) {
    print('[TEST STEP] $step');
  }
}
