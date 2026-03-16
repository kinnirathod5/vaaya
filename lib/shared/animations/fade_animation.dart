import 'package:flutter/material.dart';

class FadeAnimation extends StatelessWidget {
  final Widget child;
  final int delayInMs;

  const FadeAnimation({
    super.key,
    required this.child,
    this.delayInMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)), // Thoda sa neeche se upar aayega (Fade + Slide)
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}