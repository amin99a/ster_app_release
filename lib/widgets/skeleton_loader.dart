import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? color;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 4,
    this.color,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                (widget.color ?? Colors.grey[300]!).withOpacity(0.6),
                (widget.color ?? Colors.grey[300]!).withOpacity(0.8),
                (widget.color ?? Colors.grey[300]!).withOpacity(0.6),
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

class CarCardSkeleton extends StatelessWidget {
  const CarCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: SkeletonLoader(
              height: 200,
              borderRadius: 0,
            ),
          ),
          
          // Content skeleton
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                SkeletonLoader(
                  width: 150,
                  height: 18,
                ),
                SizedBox(height: 8),
                
                // Rating skeleton
                SkeletonLoader(
                  width: 100,
                  height: 14,
                ),
                SizedBox(height: 8),
                
                // Host skeleton
                SkeletonLoader(
                  width: 120,
                  height: 14,
                ),
                SizedBox(height: 8),
                
                // Price skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLoader(
                      width: 80,
                      height: 16,
                    ),
                    SkeletonLoader(
                      width: 100,
                      height: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FavoriteListSkeleton extends StatelessWidget {
  const FavoriteListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image skeleton
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: SkeletonLoader(
              height: 120,
              borderRadius: 0,
            ),
          ),
          
          // Content skeleton
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                SkeletonLoader(
                  width: 100,
                  height: 16,
                ),
                SizedBox(height: 4),
                
                // Item count skeleton
                SkeletonLoader(
                  width: 60,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 