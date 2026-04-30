import 'package:flutter/material.dart';
import 'package:app_prenotazioni/core/utils/animations.dart';

/// A counter widget that animates from 0 to the target value.
///
/// Example:
/// ```dart
/// AnimatedCounter(
///   value: 42,
///   duration: Duration(milliseconds: 800),
/// )
/// ```
class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration? duration;
  final Curve? curve;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration,
    this.curve,
    this.style,
    this.prefix,
    this.suffix,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration ?? AppAnimations.extraSlow,
      vsync: this,
    );

    _animation = IntTween(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? AppAnimations.smooth,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _animation = IntTween(
        begin: 0,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve ?? AppAnimations.smooth,
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
    final reduceMotion = MediaQuery.of(context).reduceAnimations;

    if (reduceMotion) {
      return Text(
        '${widget.prefix ?? ''}${widget.value}${widget.suffix ?? ''}',
        style: widget.style,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix ?? ''}${_animation.value}${widget.suffix ?? ''}',
          style: widget.style,
        );
      },
    );
  }
}
