import 'package:flutter/material.dart';

/// Animation constants used throughout the app.
///
/// Provides consistent timing and curves for all animations.
class AppAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 800);

  // Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounce = Curves.elasticOut;
  static const Curve sharp = Curves.easeOutCubic;
  static const Curve smooth = Curves.easeOutQuart;
  static const Curve sharpIn = Curves.easeInCubic;

  // Stagger delays for list animations
  static const Duration staggerDelay = Duration(milliseconds: 50);

  // Custom curves
  static const Curve easeInOutCubic = Curves.easeInOutCubic;
  static const Curve easeOutBack = Curves.easeOutBack;
  static const Curve easeInOutBack = Curves.easeInOutBack;
}

/// Extension to check if reduced motion is enabled
extension MediaQueryAnimations on MediaQueryData {
  /// Whether animations should be reduced based on accessibility settings
  bool get reduceAnimations => disableAnimations || accessibleNavigation;
}
