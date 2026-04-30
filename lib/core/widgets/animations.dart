import 'package:flutter/material.dart';
import 'package:app_prenotazioni/core/utils/animations.dart';

/// A widget that fades in its child with optional slide animation.
///
/// Example:
/// ```dart
/// FadeIn(
///   slide: SlideDirection.up,
///   child: Text('Hello'),
/// )
/// ```
class FadeIn extends StatefulWidget {
  final Widget child;
  final SlideDirection? slide;
  final Duration? duration;
  final Curve? curve;
  final Duration? delay;

  const FadeIn({
    super.key,
    required this.child,
    this.slide,
    this.duration,
    this.curve,
    this.delay,
  });

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? AppAnimations.defaultCurve,
    );

    if (widget.slide != null) {
      final begin = _getBeginOffset(widget.slide!);
      _slideAnimation = Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve ?? AppAnimations.smooth,
      ));
    }

    // Start animation after delay if provided
    Future.delayed(widget.delay ?? Duration.zero, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  Offset _getBeginOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.up:
        return const Offset(0, 0.3);
      case SlideDirection.down:
        return const Offset(0, -0.3);
      case SlideDirection.left:
        return const Offset(0.3, 0);
      case SlideDirection.right:
        return const Offset(-0.3, 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check for reduced motion preference
    final reduceMotion = MediaQuery.of(context).reduceAnimations;
    if (reduceMotion) {
      return widget.child;
    }

    final animatedChild = FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );

    if (_slideAnimation != null) {
      return SlideTransition(
        position: _slideAnimation!,
        child: animatedChild,
      );
    }

    return animatedChild;
  }
}

/// A widget that scales in its child with fade.
///
/// Example:
/// ```dart
/// ScaleIn(
///   child: Card(...),
/// )
/// ```
class ScaleIn extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final Curve? curve;
  final double? beginScale;
  final Duration? delay;

  const ScaleIn({
    super.key,
    required this.child,
    this.duration,
    this.curve,
    this.beginScale,
    this.delay,
  });

  @override
  State<ScaleIn> createState() => _ScaleInState();
}

class _ScaleInState extends State<ScaleIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AppAnimations.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale ?? 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? AppAnimations.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? AppAnimations.defaultCurve,
    ));

    Future.delayed(widget.delay ?? Duration.zero, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).reduceAnimations) {
      return widget.child;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// A widget that animates its children in sequence with staggered delays.
///
/// Example:
/// ```dart
/// StaggeredAnimation(
///   children: [
///     Text('First'),
///     Text('Second'),
///     Text('Third'),
///   ],
/// )
/// ```
class StaggeredAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration? duration;
  final Duration? staggerDelay;
  final SlideDirection? slide;

  const StaggeredAnimation({
    super.key,
    required this.children,
    this.duration,
    this.staggerDelay,
    this.slide,
  });

  @override
  Widget build(BuildContext context) {
    final delay = staggerDelay ?? AppAnimations.staggerDelay;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < children.length; i++)
          FadeIn(
            duration: duration,
            delay: Duration(milliseconds: delay.inMilliseconds * i),
            slide: slide,
            child: children[i],
          ),
      ],
    );
  }
}

/// Slide direction for fade animations
enum SlideDirection { up, down, left, right }

/// A widget that provides shake animation on trigger.
///
/// Useful for form validation feedback.
class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final bool trigger;

  const ShakeAnimation({
    super.key,
    required this.child,
    this.duration,
    this.trigger = false,
  });

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      }
    });
  }

  @override
  void didUpdateWidget(ShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && widget.trigger) {
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
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = _calculateOffset(_shakeAnimation.value);
        return Transform.translate(
          offset: offset,
          child: child,
        );
      },
      child: widget.child,
    );
  }

  Offset _calculateOffset(double value) {
    final progress = value * 10;
    return Offset(
      5.0 * (1 - progress) * 0.1,
      0.0,
    );
  }
}
