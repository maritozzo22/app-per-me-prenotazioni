import 'dart:async';
import 'package:flutter/foundation.dart';

/// A debouncer that delays function execution and cancels previous calls.
///
/// Used to prevent rapid-fire function calls, such as when a user
/// is scrolling through a calendar and triggering multiple data loads.
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  /// Calls the action after the delay, canceling any previous pending call.
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any pending timer.
  void dispose() {
    _timer?.cancel();
  }
}
