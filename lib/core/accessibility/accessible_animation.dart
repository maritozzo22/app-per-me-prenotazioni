import 'package:flutter/material.dart';

/// Widget that conditionally shows animations based on system settings.
///
/// Respects the system "Reduce Motion" accessibility setting.
/// When animations are disabled, shows child immediately without animation.
class AccessibleAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration? delay;
  final Curve curve;
  final Widget Function(Widget child, Animation<double> animation)? builder;

  const AccessibleAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay,
    this.curve = Curves.easeInOut,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // If reduce motion is enabled, skip animation
    if (reduceMotion) {
      return child;
    }

    // Otherwise, use the provided animation
    if (builder != null) {
      return _CustomAnimatedBuilder(
        duration: duration,
        delay: delay,
        curve: curve,
        builder: builder!,
        child: child,
      );
    }

    // Default to fade in
    return _DefaultAccessibleAnimation(
      duration: duration,
      delay: delay,
      curve: curve,
      child: child,
    );
  }
}

/// Custom animation builder
class _CustomAnimatedBuilder extends StatefulWidget {
  final Duration duration;
  final Duration? delay;
  final Curve curve;
  final Widget Function(Widget child, Animation<double> animation) builder;
  final Widget child;

  const _CustomAnimatedBuilder({
    required this.duration,
    required this.delay,
    required this.curve,
    required this.builder,
    required this.child,
  });

  @override
  State<_CustomAnimatedBuilder> createState() => _CustomAnimatedBuilderState();
}

class _CustomAnimatedBuilderState extends State<_CustomAnimatedBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context) => widget.builder(widget.child, _animation),
    );
  }
}

/// Default fade-in animation
class _DefaultAccessibleAnimation extends StatefulWidget {
  final Duration duration;
  final Duration? delay;
  final Curve curve;
  final Widget child;

  const _DefaultAccessibleAnimation({
    required this.duration,
    required this.delay,
    required this.curve,
    required this.child,
  });

  @override
  State<_DefaultAccessibleAnimation> createState() =>
      _DefaultAccessibleAnimationState();
}

class _DefaultAccessibleAnimationState
    extends State<_DefaultAccessibleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// Mixin for widgets that need to respect reduce motion setting.
mixin ReduceMotionMixin<T extends StatefulWidget> on State<T> {
  /// Check if animations should be reduced.
  bool get shouldReduceMotion {
    final context = this.context;
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get animation duration, accounting for reduce motion.
  Duration animationDuration(Duration normalDuration) {
    return shouldReduceMotion ? Duration.zero : normalDuration;
  }

  /// Optionally animate based on reduce motion setting.
  Widget optionalAnimate({
    required Widget child,
    required Duration duration,
    Curve curve = Curves.easeInOut,
  }) {
    if (shouldReduceMotion) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) => child!,
      child: child,
    );
  }
}
