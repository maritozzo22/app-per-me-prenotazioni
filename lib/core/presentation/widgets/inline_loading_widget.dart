import 'package:flutter/material.dart';

/// Inline loading indicator for button/form loading states
///
/// Use for compact loading indicators within buttons, forms,
/// or other tight spaces where a full-screen loader is too much.
///
/// Example:
/// ```dart
/// ElevatedButton(
///   onPressed: isLoading ? null : _handleSubmit,
///   child: isLoading
///     ? const InlineLoadingWidget()
///     : const Text('Salva'),
/// )
/// ```
class InlineLoadingWidget extends StatelessWidget {
  /// Size of the loading indicator
  final double size;

  /// Optional message to show next to the indicator
  final String? message;

  const InlineLoadingWidget({
    super.key,
    this.size = 20,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            backgroundColor: Colors.transparent,
          ),
        ),
        if (message != null) ...[
          const SizedBox(width: 12),
          Text(message!),
        ],
      ],
    );
  }
}

/// Button with built-in loading state
///
/// Automatically shows loading indicator and disables the button
/// while callback is executing.
///
/// Example:
/// ```dart
/// LoadingButton(
///   onPressed: _saveForm,
///   loading: _isSaving,
///   child: const Text('Salva'),
/// )
/// ```
class LoadingButton extends StatelessWidget {
  /// Callback when button is pressed (only called when not loading)
  final VoidCallback? onPressed;

  /// Whether to show loading state
  final bool loading;

  /// Button label or content
  final Widget child;

  /// Loading message to show
  final String? loadingMessage;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.loading,
    required this.child,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? InlineLoadingWidget(
              message: loadingMessage,
            )
          : child,
    );
  }
}
