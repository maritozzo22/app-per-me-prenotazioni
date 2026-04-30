import 'package:flutter/material.dart';
import 'dart:async';

/// Inline error message for form fields and compact spaces
///
/// Displays a compact error message with icon and optional auto-dismiss.
/// Ideal for form validation errors or field-level error feedback.
///
/// Example:
/// ```dart
/// if (_hasError) {
///   return InlineErrorMessage(
///     message: 'Campo obbligatorio',
///     onDismiss: () => setState(() => _hasError = false),
///   );
/// }
/// ```
class InlineErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final IconData? icon;
  final Duration? autoDismissDuration;

  const InlineErrorMessage({
    super.key,
    required this.message,
    this.onDismiss,
    this.icon,
    this.autoDismissDuration,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: Colors.red.shade700,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade900,
                fontSize: 13,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ],
      ),
    );

    if (autoDismissDuration != null) {
      return _AutoDismiss(
        duration: autoDismissDuration!,
        onDismiss: onDismiss,
        child: widget,
      );
    }

    return widget;
  }
}

/// Widget that auto-dismisses after a duration
class _AutoDismiss extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onDismiss;
  final Widget child;

  const _AutoDismiss({
    required this.duration,
    this.onDismiss,
    required this.child,
  });

  @override
  State<_AutoDismiss> createState() => _AutoDismissState();
}

class _AutoDismissState extends State<_AutoDismiss> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Inline warning message (similar to error but with different styling)
class InlineWarningMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final IconData? icon;

  const InlineWarningMessage({
    super.key,
    required this.message,
    this.onDismiss,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.warning_outlined,
            color: Colors.orange.shade700,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.orange.shade900,
                fontSize: 13,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline info message (similar to error but with different styling)
class InlineInfoMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final IconData? icon;

  const InlineInfoMessage({
    super.key,
    required this.message,
    this.onDismiss,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.info_outline,
            color: Colors.blue.shade700,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 13,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
