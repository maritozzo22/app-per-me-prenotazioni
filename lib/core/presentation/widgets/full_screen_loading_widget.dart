import 'package:flutter/material.dart';

/// Full-screen loading overlay with semi-transparent backdrop
///
/// Use for page-level async operations like initial data loads,
/// form submissions, or complex computations.
///
/// Example:
/// ```dart
/// Stack(
///   children: [
///     MyPageContent(),
///     if (isLoading) FullScreenLoadingWidget(),
///   ],
/// )
/// ```
class FullScreenLoadingWidget extends StatelessWidget {
  /// Optional message to display below the loading indicator
  final String? message;

  /// Whether the loading indicator can be dismissed by tapping
  /// Default: false (loading cannot be dismissed)
  final bool dismissible;

  /// Callback when dismissed (only called if dismissible is true)
  final VoidCallback? onDismiss;

  const FullScreenLoadingWidget({
    super.key,
    this.message,
    this.dismissible = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.3),
      child: GestureDetector(
        onTap: dismissible ? onDismiss : null,
        child: Center(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (dismissible) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Tocca per annullare',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
