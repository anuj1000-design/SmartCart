import 'package:flutter/material.dart';

// NOTE: This requires flutter_staggered_animations package. 
// If not available, we can build a simple custom one.
// Since I cannot check if the package is installed easily without reading pubspec (which I did earlier and didn't see it),
// I will create a custom simple staggered animation wrapper to avoid dependency issues.

class StaggeredListAnimation extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final double verticalOffset;

  const StaggeredListAnimation({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 375),
    this.verticalOffset = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Interval(
        (0.1 * index).clamp(0.0, 1.0), // Delay based on index
        1.0,
        curve: Curves.easeOutQuad,
      ),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, verticalOffset * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Stagger delay based on index
    final delay = Duration(milliseconds: 50 * widget.index);
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
