import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../auth/auth_header.dart';

/// The green header background as a Hero, so it morphs between sign in,
/// Home and the tab pages instead of being replaced.
///
/// Only the background flies, never the text or art on it: a title
/// stretched across a resizing rectangle looks broken. In flight it is a
/// plain gradient shape whose lower-corner radius blends from the source
/// header's to the destination's, so nothing jumps at either end.
class BrandHeaderHero extends StatelessWidget {
  const BrandHeaderHero({super.key, required this.radius, this.child});

  final double radius;

  /// Drawn on the shape when it is not flying (the sign-in header's drifting
  /// light, for example).
  final Widget? child;

  static double _radiusOf(BuildContext heroContext) {
    final w = heroContext.findAncestorWidgetOfExactType<BrandHeaderHero>();
    return w?.radius ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: brandHeaderTag,
      // The default is a straight line between the two rectangles; with
      // the route's curve on top, that is the smoothest morph for a shape
      // that mostly changes height.
      flightShuttleBuilder: (_, animation, direction, fromContext, toContext) {
        final from = _radiusOf(fromContext);
        final to = _radiusOf(toContext);
        return AnimatedBuilder(
          animation: animation,
          builder: (_, __) =>
              BrandHeaderShape(radius: lerpDouble(from, to, animation.value)!),
        );
      },
      child: BrandHeaderShape(radius: radius, child: child),
    );
  }
}

/// Runs [then] as the route that owns [arrival] settles, or straight away
/// if it was not arriving at all.
///
/// Screens use it to hold their content back while the header morphs in:
/// building a whole page in the same frame as a Hero flight drops frames.
/// It fires at [settled] of the way through rather than at the very end,
/// because the route's ease-out puts the header visibly in place well
/// before the animation finishes; waiting for the end left a beat of
/// empty green on screen. Content starting to rise as the header settles
/// reads as one motion.
///
/// It looks after the next frame, not now: during a pushed route's first
/// build its animation has not started and still reports `completed`.
void whenRouteArrived(Animation<double>? arrival, VoidCallback then,
    {double settled = .6}) {
  if (arrival == null) {
    then();
    return;
  }
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (arrival.status != AnimationStatus.forward || arrival.value >= settled) {
      then();
      return;
    }
    var done = false;
    late final VoidCallback onValue;
    late final AnimationStatusListener onStatus;
    void fire() {
      if (done) return;
      done = true;
      arrival.removeListener(onValue);
      arrival.removeStatusListener(onStatus);
      then();
    }

    onValue = () {
      if (arrival.value >= settled) fire();
    };
    onStatus = (s) {
      if (s == AnimationStatus.completed || s == AnimationStatus.dismissed) {
        fire();
      }
    };
    arrival.addListener(onValue);
    arrival.addStatusListener(onStatus);
  });
}

/// Hands the shell route's arrival down to the tabs, which live in nested
/// navigators and so cannot see the root route themselves.
class ShellArrival extends InheritedWidget {
  const ShellArrival(
      {super.key, required this.animation, required super.child});

  final Animation<double>? animation;

  static Animation<double>? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellArrival>()?.animation;

  @override
  bool updateShouldNotify(ShellArrival old) => old.animation != animation;
}
