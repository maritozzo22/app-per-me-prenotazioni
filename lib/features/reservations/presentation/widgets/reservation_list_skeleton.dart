import 'package:flutter/material.dart';

/// Skeleton loader for reservation list items
///
/// Displays placeholder items that match the layout of ReservationListTile
/// to create a smooth loading experience.
///
/// Example:
/// ```dart
/// ListView.builder(
///   itemCount: isLoading ? 5 : reservations.length,
///   itemBuilder: (context, index) {
///     if (isLoading) {
///       return const ReservationListSkeleton();
///     }
///     return ReservationListTile(...);
///   },
/// )
/// ```
class ReservationListSkeleton extends StatelessWidget {
  final int itemCount;

  const ReservationListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => _buildSkeletonItem(context),
    );
  }

  Widget _buildSkeletonItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Platform color indicator skeleton
          _buildShimmer(
            context,
            width: 4,
            height: 48,
            borderRadius: 2,
          ),
          const SizedBox(width: 12),
          // Main content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Guest name skeleton
                _buildShimmer(
                  context,
                  width: double.infinity,
                  height: 16,
                  marginBottom: 4,
                ),
                const SizedBox(height: 4),
                // Details skeleton
                Row(
                  children: [
                    _buildShimmer(
                      context,
                      width: 14,
                      height: 14,
                      borderRadius: 7,
                    ),
                    const SizedBox(width: 4),
                    _buildShimmer(context, width: 60, height: 12),
                    const SizedBox(width: 12),
                    _buildShimmer(
                      context,
                      width: 14,
                      height: 14,
                      borderRadius: 7,
                    ),
                    const SizedBox(width: 4),
                    _buildShimmer(context, width: 80, height: 12),
                  ],
                ),
              ],
            ),
          ),
          // Payment status skeleton
          _buildShimmer(
            context,
            width: 24,
            height: 24,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(
    BuildContext context, {
    required double width,
    required double height,
    double borderRadius = 4,
    double marginBottom = 0,
  }) {
    final baseColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey.shade300
        : Colors.grey.shade700;

    final highlightColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey.shade100
        : Colors.grey.shade600;

    // Respect reduce motion accessibility setting
    if (MediaQuery.of(context).disableAnimations ||
        MediaQuery.of(context).accessibleNavigation) {
      return Container(
        margin: EdgeInsets.only(bottom: marginBottom),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: _ShimmerAnimation(
        baseColor: baseColor,
        highlightColor: highlightColor,
      ),
    );
  }
}

/// Shimmer animation for skeleton loading
class _ShimmerAnimation extends StatefulWidget {
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerAnimation({
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<_ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<_ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
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
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}
