import 'package:flutter/material.dart';

import '../config/motion.dart';

/// A cross-fade route. Shared Hero elements (the green header) morph across
/// it, which is what makes sign-in hand over to Home as one motion.
PageRoute<T> fadeRoute<T>(Widget page, {Duration duration = Motion.handOff}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) => FadeTransition(
      opacity: CurvedAnimation(
          parent: anim, curve: const Interval(.25, 1, curve: Curves.easeOut)),
      child: child,
    ),
  );
}

/// Pushes a detail page that rises a little as it fades in.
Route<T> riseRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: Motion.medium,
    reverseTransitionDuration: Motion.short,
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) {
      final c = CurvedAnimation(
          parent: anim, curve: Motion.enter, reverseCurve: Motion.exit);
      return FadeTransition(
        opacity: c,
        child: SlideTransition(
          position:
              Tween(begin: const Offset(0, .06), end: Offset.zero).animate(c),
          child: child,
        ),
      );
    },
  );
}
