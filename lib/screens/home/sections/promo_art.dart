import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../../config/design_tokens.dart';
import '../../../models/catalog.dart';
import '../../../widgets/food_art_view.dart';
import '../../../widgets/rider/rider.dart';

const _cream = Color(0xFFFBF8E6);
const _butter = Color(0xFFFFE58A);

/// One promo banner, drawn in code: either the rider racing through a
/// little city, or a big 3D dish on a dark green ground.
class PromoBannerCard extends StatelessWidget {
  const PromoBannerCard({super.key, required this.banner, this.parallax = 0});

  final PromoBanner banner;

  /// -1..1 while the page is being swiped.
  final double parallax;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.xl),
      child: LayoutBuilder(
        builder: (context, c) => banner.showsRider
            ? _RiderBanner(banner: banner, size: c.biggest, parallax: parallax)
            : _ArtBanner(banner: banner, size: c.biggest, parallax: parallax),
      ),
    );
  }
}

class _RiderBanner extends StatelessWidget {
  const _RiderBanner(
      {required this.banner, required this.size, required this.parallax});

  final PromoBanner banner;
  final Size size;
  final double parallax;

  @override
  Widget build(BuildContext context) {
    final h = size.height;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _CityPainter())),
        Positioned(
          left: -h * .1 + parallax * 30,
          bottom: -h * .1,
          child: Rider(
              width: h * 1.25, speed: 1, showBlob: false, showShadow: false),
        ),
        Positioned(
          right: h * .08 - parallax * 18,
          top: 0,
          bottom: 0,
          width: size.width * .5,
          child:
              _Headline(banner: banner, h: h, align: CrossAxisAlignment.center),
        ),
      ],
    );
  }
}

class _ArtBanner extends StatelessWidget {
  const _ArtBanner(
      {required this.banner, required this.size, required this.parallax});

  final PromoBanner banner;
  final Size size;
  final double parallax;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final h = size.height;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.dealCard, p.accentDeep],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -h * .25,
            top: -h * .2,
            child: Container(
              width: h * 1.4,
              height: h * 1.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  p.accent.withValues(alpha: .45),
                  p.accent.withValues(alpha: 0),
                ]),
              ),
            ),
          ),
          Positioned(
            right: h * .02 - parallax * 40,
            top: h * .06,
            child: Transform.rotate(
              angle: -.12 + parallax * .2,
              child: FoodArtView(banner.art ?? const FoodArt('takeout'),
                  size: h * .9),
            ),
          ),
          Positioned(
            left: h * .14 + parallax * 16,
            top: 0,
            bottom: 0,
            width: size.width * .56,
            child: _Headline(
                banner: banner, h: h, align: CrossAxisAlignment.start),
          ),
        ],
      ),
    );
  }
}

/// Heavy, slanted promo type with a pill call to action.
class _Headline extends StatelessWidget {
  const _Headline({required this.banner, required this.h, required this.align});

  final PromoBanner banner;
  final double h;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final shadow = [
      Shadow(
          color: p.accentDeep.withValues(alpha: .5),
          offset: const Offset(0, 2),
          blurRadius: 0)
    ];
    TextStyle big(double k, Color c) => TextStyle(
          color: c,
          fontSize: h * k,
          height: .95,
          fontWeight: FontWeight.w800,
          letterSpacing: -.5,
          shadows: shadow,
        );
    final textAlign =
        align == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start;
    return Transform(
      transform: Matrix4.skewX(-.16),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: align,
        children: [
          FittedBox(
              child: Text(banner.lineOne,
                  style: big(.17, _cream), textAlign: textAlign)),
          FittedBox(
              child: Text(banner.lineTwo,
                  style: big(.235, _butter), textAlign: textAlign)),
          SizedBox(height: h * .04),
          Text(
            banner.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
            style: TextStyle(
                color: _cream, fontSize: h * .075, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: h * .06),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: h * .1, vertical: h * .035),
            decoration: BoxDecoration(
              color: p.accentDeep,
              borderRadius: BorderRadius.circular(Radii.pill),
              border:
                  Border.all(color: _butter.withValues(alpha: .7), width: 1),
            ),
            child: Text(
              banner.cta.toUpperCase(),
              style: TextStyle(
                  color: _cream,
                  fontSize: h * .065,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .6),
            ),
          ),
        ],
      ),
    );
  }
}

/// A flat little city in greens behind the rider: sky, sun, towers with
/// windows, round trees, a road and a scatter of confetti on the right.
class _CityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFCFE8A6), Color(0xFF8DC34E)],
      ).createShader(Offset.zero & s);
    canvas.drawRect(Offset.zero & s, sky);

    // Right panel, where the type sits.
    final panel = Path()
      ..moveTo(w * .46, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(w * .4, h)
      ..cubicTo(w * .5, h * .7, w * .38, h * .3, w * .46, 0)
      ..close();
    canvas.drawPath(panel, Paint()..color = const Color(0xFF5F9A2A));

    canvas.drawCircle(Offset(w * .08, h * .22), h * .12,
        Paint()..color = const Color(0xFFF4F7D6).withValues(alpha: .8));

    final rnd = math.Random(7);
    const towers = [
      (.0, .38, .09),
      (.08, .22, .07),
      (.15, .46, .1),
      (.26, .3, .08),
      (.34, .5, .07),
    ];
    for (final (x, top, bw) in towers) {
      final r = Rect.fromLTWH(w * x, h * top, w * bw, h);
      canvas.drawRect(r, Paint()..color = const Color(0xFFB6D98B));
      final win = Paint()..color = const Color(0xFFE6F2CD);
      for (var y = r.top + h * .06; y < h * .78; y += h * .09) {
        for (var xx = r.left + w * .012;
            xx < r.right - w * .018;
            xx += w * .025) {
          if (rnd.nextDouble() > .25) {
            canvas.drawRect(Rect.fromLTWH(xx, y, w * .012, h * .04), win);
          }
        }
      }
    }
    final tree = Paint()..color = const Color(0xFF6FA437);
    for (final x in [.05, .2, .31]) {
      canvas.drawCircle(Offset(w * x, h * .72), h * .1, tree);
    }
    canvas.drawRect(Rect.fromLTWH(0, h * .8, w * .55, h * .2),
        Paint()..color = const Color(0xFF4E7F22));

    final confetti = [
      const Color(0xFFFFE58A),
      const Color(0xFFF4F7D6),
      const Color(0xFFB9E07C)
    ];
    for (var i = 0; i < 16; i++) {
      final o = Offset(w * (.55 + rnd.nextDouble() * .43),
          h * (.06 + rnd.nextDouble() * .88));
      canvas.save();
      canvas.translate(o.dx, o.dy);
      canvas.rotate(rnd.nextDouble() * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-3, -1.2, 6, 2.4), const Radius.circular(1)),
        Paint()..color = confetti[i % 3].withValues(alpha: .8),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
