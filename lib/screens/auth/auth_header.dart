import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/app_brand.dart';
import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../config/motion.dart';
import '../../widgets/rider/rider.dart';
import '../../widgets/rider/rider_painter.dart';
import '../../widgets/wordmark.dart';

/// The hero tag shared by the sign-in header and the home header, so the
/// green shape morphs from one into the other on sign in.
const brandHeaderTag = 'brand-header';

/// The green gradient shape with rounded lower corners. One widget for
/// both screens so the Hero flight is between identical surfaces.
class BrandHeaderShape extends StatelessWidget {
  const BrandHeaderShape({super.key, this.radius = Radii.header, this.child});

  final double radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: context.palette.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
      ),
      child: child,
    );
  }
}

/// The sign-in header. It stays alive while someone types: the rider waves
/// the phone, sparkles twinkle, and soft light drifts across the green.
///
/// [t] is the screen's entrance progress (0..1); the header drops in, the
/// wordmark fades up, then the rider drives in from the right edge.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.t, required this.height});

  final double t;
  final double height;

  double _seg(double a, double b, [Curve c = Motion.enter]) =>
      c.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final width = MediaQuery.sizeOf(context).width;
    final drop = _seg(0, .35);
    final text = _seg(.2, .5);
    final drive = _seg(.3, .75, Curves.easeOutCubic);
    final riderW = (width * .56).clamp(190.0, 260.0);

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: FractionalTranslation(
              translation: Offset(0, -(1 - drop)),
              child: Opacity(
                opacity: .35 + .65 * drop,
                child: Hero(
                  tag: brandHeaderTag,
                  child: BrandHeaderShape(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(Radii.header)),
                      child: const _DriftingLight(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: Space.gutter + 4,
            top: top + 22,
            child: Opacity(
              opacity: text,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - text)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Wordmark(size: 30, onDark: true),
                    const SizedBox(height: 10),
                    Text(
                      AppBrand.headerLine,
                      style: TextStyle(
                        color: context.palette.card.withValues(alpha: .85),
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // The rider's wheels break the header's lower edge, which is what
          // makes the white form read as a card cut into the scene.
          Positioned(
            right: -riderW * .08 - (1 - drive) * (riderW + 40),
            bottom: -riderW * .07,
            child: Rider(
              width: riderW,
              pose: RiderPose.waving,
              mirrored: true,
              speed: (1 - drive) * .9,
            ),
          ),
        ],
      ),
    );
  }
}

/// Slow, soft circles of light drifting across the header.
class _DriftingLight extends StatefulWidget {
  const _DriftingLight();

  @override
  State<_DriftingLight> createState() => _DriftingLightState();
}

class _DriftingLightState extends State<_DriftingLight>
    with SingleTickerProviderStateMixin {
  late final _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 9));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.loops(context)) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => CustomPaint(painter: _LightPainter(_c.value)),
    );
  }
}

class _LightPainter extends CustomPainter {
  _LightPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    const spots = [
      (.15, .75, .32, 0.0),
      (.55, .25, .22, .33),
      (.85, .7, .4, .66),
      (.35, .1, .18, .5),
    ];
    for (final (x, y, r, ph) in spots) {
      final a = (t + ph) * math.pi * 2;
      final c = Offset(
        size.width * (x + math.sin(a) * .05),
        size.height * (y + math.cos(a) * .06),
      );
      final radius = size.width * r;
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFFFFFFF).withValues(alpha: .13),
            const Color(0x00FFFFFF),
          ]).createShader(Rect.fromCircle(center: c, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(_LightPainter old) => old.t != t;
}
