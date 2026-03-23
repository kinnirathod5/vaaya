import 'package:flutter/material.dart';

// ============================================================
// ✨ FADE ANIMATION
// Fade + slide entry animation with optional stagger delay.
// Used across all screens for smooth list/card reveals.
//
// Usage:
//   FadeAnimation(child: MyWidget())
//   FadeAnimation(delayInMs: 200, child: MyWidget())
//   FadeAnimation(delayInMs: 100, direction: FadeDirection.up, child: MyWidget())
//   FadeAnimation(delayInMs: 150, direction: FadeDirection.right, child: MyWidget())
//
// Stagger pattern (used in lists and grids):
//   ...items.asMap().entries.map((e) =>
//     FadeAnimation(delayInMs: e.key * 60, child: ItemCard(...))
//   )
// ============================================================

enum FadeDirection { up, down, left, right, none }

class FadeAnimation extends StatefulWidget {
  const FadeAnimation({
    super.key,
    required this.child,
    this.delayInMs = 0,
    this.durationInMs = 500,
    this.direction = FadeDirection.up,
    this.slideDistance = 18.0,
    this.curve = Curves.easeOutCubic,
  });

  /// The widget to animate
  final Widget child;

  /// Delay before animation starts — use for staggered lists
  final int delayInMs;

  /// Total animation duration in milliseconds (default: 500ms)
  final int durationInMs;

  /// Direction the widget slides in from (default: up)
  final FadeDirection direction;

  /// How far the widget travels in pixels during the slide (default: 18)
  final double slideDistance;

  /// Animation curve (default: easeOutCubic)
  final Curve curve;

  @override
  State<FadeAnimation> createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationInMs),
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _slide = Tween<Offset>(
      begin: _beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    // Start after delay
    if (widget.delayInMs > 0) {
      Future.delayed(Duration(milliseconds: widget.delayInMs), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  /// Starting offset based on direction
  Offset get _beginOffset {
    final d = widget.slideDistance;
    switch (widget.direction) {
      case FadeDirection.up:    return Offset(0,  d / 100);
      case FadeDirection.down:  return Offset(0, -d / 100);
      case FadeDirection.left:  return Offset(d / 100, 0);
      case FadeDirection.right: return Offset(-d / 100, 0);
      case FadeDirection.none:  return Offset.zero;
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
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}