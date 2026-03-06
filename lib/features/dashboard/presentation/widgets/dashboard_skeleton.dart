import 'package:flutter/material.dart';

/// Skeleton loader for dashboard page
///
/// Displays placeholder widgets that match the dashboard layout
/// to create a smooth loading experience.
///
/// Example:
/// ```dart
/// if (state.isLoading && state.statistics == null) {
///   return const DashboardSkeleton();
/// }
/// ```
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return _buildMobileSkeleton(context);
        } else {
          return _buildTabletSkeleton(context);
        }
      },
    );
  }

  Widget _buildMobileSkeleton(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room occupancy section
          Text(
            'Stanze Oggi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _buildRoomOccupancySkeleton(context),
          const SizedBox(height: 24),

          // Income card skeleton
          _buildCardSkeleton(context, height: 120),
          const SizedBox(height: 24),

          // Calendar access card skeleton
          _buildCardSkeleton(context, height: 100),
          const SizedBox(height: 24),

          // Upcoming check-ins skeleton
          _buildCardSkeleton(context, height: 150),
          const SizedBox(height: 16),

          // Upcoming check-outs skeleton
          _buildCardSkeleton(context, height: 150),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTabletSkeleton(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column
          Expanded(
            child: Column(
              children: [
                Text(
                  'Stanze Oggi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _buildRoomOccupancySkeleton(context),
                const SizedBox(height: 24),
                _buildCardSkeleton(context, height: 120),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right column
          Expanded(
            child: Column(
              children: [
                _buildCardSkeleton(context, height: 100),
                const SizedBox(height: 24),
                _buildCardSkeleton(context, height: 150),
                const SizedBox(height: 16),
                _buildCardSkeleton(context, height: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomOccupancySkeleton(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildRoomCardSkeleton(context),
    );
  }

  Widget _buildRoomCardSkeleton(BuildContext context) {
    return _buildShimmerContainer(
      context,
      height: double.infinity,
      borderRadius: 12,
    );
  }

  Widget _buildCardSkeleton(BuildContext context, {required double height}) {
    return _buildShimmerContainer(
      context,
      height: height,
      borderRadius: 12,
    );
  }

  Widget _buildShimmerContainer(
    BuildContext context, {
    required double height,
    required double borderRadius,
  }) {
    final baseColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey.shade300
        : Colors.grey.shade700;

    final highlightColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey.shade100
        : Colors.grey.shade600;

    return Container(
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
