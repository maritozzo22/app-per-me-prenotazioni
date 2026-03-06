import 'package:flutter/material.dart';
import 'package:app_prenotazioni/core/utils/animations.dart';

/// A circular progress indicator with smooth rotation animation.
///
/// Example:
/// ```dart
/// AnimatedCircularProgressIndicator(
///   value: 0.7,
///   showPercentage: true,
/// )
/// ```
class AnimatedCircularProgressIndicator extends StatefulWidget {
  final double? value;
  final double? size;
  final double? strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final bool showPercentage;
  final String? label;

  const AnimatedCircularProgressIndicator({
    super.key,
    this.value,
    this.size,
    this.strokeWidth,
    this.color,
    this.backgroundColor,
    this.showPercentage = false,
    this.label,
  });

  @override
  State<AnimatedCircularProgressIndicator> createState() =>
      _AnimatedCircularProgressIndicatorState();
}

class _AnimatedCircularProgressIndicatorState
    extends State<AnimatedCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    if (widget.value != null) {
      _progressAnimation = Tween<double>(
        begin: 0.0,
        end: widget.value!,
      ).animate(CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeOut,
      ));
    }
  }

  @override
  void didUpdateWidget(AnimatedCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != null) {
      _progressAnimation = Tween<double>(
        begin: 0.0,
        end: widget.value!,
      ).animate(CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeOut,
      ));
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).reduceAnimations;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size ?? 40,
          height: widget.size ?? 40,
          child: CircularProgressIndicator(
            value: reduceMotion ? widget.value : null,
            strokeWidth: widget.strokeWidth ?? 4,
            backgroundColor: widget.backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        if (widget.showPercentage && widget.value != null) ...[
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Text(
                '${(_progressAnimation.value * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.bold,
                    ),
              );
            },
          ),
        ],
        if (widget.label != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// A linear progress indicator with smooth animation.
///
/// Example:
/// ```dart
/// AnimatedLinearProgressIndicator(
///   value: 0.7,
///   label: 'Loading...',
/// )
/// ```
class AnimatedLinearProgressIndicator extends StatefulWidget {
  final double? value;
  final double? height;
  final double? width;
  final Color? color;
  final Color? backgroundColor;
  final String? label;
  final bool showLabel;

  const AnimatedLinearProgressIndicator({
    super.key,
    this.value,
    this.height,
    this.width,
    this.color,
    this.backgroundColor,
    this.label,
    this.showLabel = false,
  });

  @override
  State<AnimatedLinearProgressIndicator> createState() =>
      _AnimatedLinearProgressIndicatorState();
}

class _AnimatedLinearProgressIndicatorState
    extends State<AnimatedLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    if (widget.value != null) {
      _animation = Tween<double>(
        begin: 0.0,
        end: widget.value!,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));

      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedLinearProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != null) {
      _animation = Tween<double>(
        begin: 0.0,
        end: widget.value!,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel && widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
        ],
        SizedBox(
          width: widget.width ?? double.infinity,
          child: LinearProgressIndicator(
            value: _animation.value,
            minHeight: widget.height ?? 4,
            backgroundColor: widget.backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
