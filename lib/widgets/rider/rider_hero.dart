import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'rider.dart';
import 'rider_painter.dart';

/// The Hero tag of the delivery rider that rides from the sign-in header
/// into Home's delivery banner.
const riderHeroTag = 'brand-rider';

/// Wraps a [Rider] so it flies between screens. In flight it turns round on
/// a vertical axis: on sign in it faces left and waves, in the banner it
/// faces right and rides. The pose and the scenery (blob, shadow) change at
/// the halfway point, where the drawing is edge-on and nothing shows.
class RiderHero extends StatelessWidget {
  const RiderHero({super.key, required this.child});

  /// The rider as drawn at this end.
  final Rider child;

  static Rider? _riderOf(BuildContext heroContext) =>
      heroContext.findAncestorWidgetOfExactType<RiderHero>()?.child;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: riderHeroTag,
      flightShuttleBuilder: (_, animation, direction, fromContext, toContext) {
        final from = _riderOf(fromContext);
        final to = _riderOf(toContext);
        if (from == null || to == null) return child;
        return AnimatedBuilder(
          animation: animation,
          builder: (_, __) {
            final t = animation.value;
            final early = t < .5;
            final end = early ? from : to;
            // Facing is drawn as a turn, not a mirror: start at the source's
            // facing and finish at the destination's, through edge-on.
            final fromAngle = from.mirrored ? math.pi : 0.0;
            final toAngle = to.mirrored ? math.pi : 0.0;
            final angle = fromAngle +
                (toAngle - fromAngle) * t +
                // Same facing at both ends still gets one full turn, so the
                // flip always reads.
                (fromAngle == toAngle ? math.pi * 2 * t : 0);
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, .0012) // a little perspective
                ..rotateY(angle),
              child: FittedBox(
                child: Rider(
                  width: RiderPainter.design.width,
                  pose: end.pose,
                  // Moving fast while it flies.
                  speed: 1,
                  showBlob: end.showBlob && (t < .15 || t > .85),
                  showShadow: end.showShadow,
                ),
              ),
            );
          },
        );
      },
      child: child,
    );
  }
}
