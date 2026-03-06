import 'package:flutter/material.dart';
import 'package:app_prenotazioni/core/utils/animations.dart';

/// An animated button that provides visual feedback on press.
///
/// Features:
/// - Scale down animation on press
/// - Loading state with progress indicator
/// - Success animation with checkmark
/// - Respects accessibility settings
///
/// Example:
/// ```dart
/// AnimatedButton(
///   label: 'Submit',
///   onPressed: _handleSubmit,
///   isLoading: _isLoading,
/// )
/// ```
class AnimatedButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSuccess;
  final Widget? icon;
  final ButtonStyle? style;
  final bool isSecondary;

  const AnimatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isSuccess = false,
    this.icon,
    this.style,
    this.isSecondary = false,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _successController;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();

    // Press animation
    _scaleController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Success animation
    _successController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: AppAnimations.easeOutBack,
    ));
  }

  @override
  void didUpdateWidget(AnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSuccess && !oldWidget.isSuccess) {
      _successController.forward();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).reduceAnimations;

    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading && !widget.isSuccess
          ? (_) => _scaleController.forward()
          : null,
      onTapUp: widget.onPressed != null && !widget.isLoading && !widget.isSuccess
          ? (_) => _scaleController.reverse()
          : null,
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: reduceMotion ? const AlwaysStoppedAnimation(1.0) : _scaleAnimation,
        child: _buildButton(context),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    final enabled = widget.onPressed != null &&
        !widget.isLoading &&
        !widget.isSuccess;

    Widget child;

    if (widget.isSuccess) {
      child = _buildSuccessButton();
    } else if (widget.isLoading) {
      child = _buildLoadingButton(context);
    } else {
      child = _buildNormalButton(context);
    }

    return widget.isSecondary
        ? OutlinedButton(
            onPressed: enabled ? widget.onPressed : null,
            style: widget.style,
            child: child,
          )
        : FilledButton(
            onPressed: enabled ? widget.onPressed : null,
            style: widget.style,
            child: child,
          );
  }

  Widget _buildNormalButton(BuildContext context) {
    final children = <Widget>[
      if (widget.icon != null) ...[
        widget.icon!,
        const SizedBox(width: 8),
      ],
      Text(widget.label),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildLoadingButton(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.isSecondary
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildSuccessButton() {
    return ScaleTransition(
      scale: _successAnimation,
      child: const Icon(
        Icons.check_rounded,
        size: 20,
      ),
    );
  }
}

/// An icon button with press animation.
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isLoading;
  final Color? foregroundColor;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.isLoading = false,
    this.foregroundColor,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).reduceAnimations;

    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading
          ? (_) => _controller.forward()
          : null,
      onTapUp: widget.onPressed != null && !widget.isLoading
          ? (_) => _controller.reverse()
          : null,
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: reduceMotion ? const AlwaysStoppedAnimation(1.0) : _animation,
        child: IconButton(
          icon: widget.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.foregroundColor ??
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Icon(widget.icon),
          onPressed: widget.isLoading ? null : widget.onPressed,
          tooltip: widget.tooltip,
          color: widget.foregroundColor,
        ),
      ),
    );
  }
}
