import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../config/palette.dart';

/// What the rider is doing with their free arm.
enum RiderPose {
  /// Both hands on the handlebar: the splash and the banners.
  riding,

  /// One hand on the bar, the other raised with a phone, waving it: the
  /// sign-in header, so the rider keeps moving while someone types.
  waving,
}

/// The delivery rider and scooter, drawn on a 240 x 200 design canvas and
/// scaled to whatever size it is given.
///
/// Everything that moves is a parameter, so one painter serves the splash,
/// the sign-in header, the promo banner and the order-placed sheet.
/// The app icon script draws the same geometry (see tool/make_icon_test.dart).
class RiderPainter extends CustomPainter {
  RiderPainter({
    required this.phase,
    this.pose = RiderPose.riding,
    this.speed = 0,
    this.showBlob = true,
    this.showShadow = true,
  });

  /// 0..1 through one idle cycle. Drives the bob, wheels, wave and sparkles.
  final double phase;
  final RiderPose pose;

  /// 0..1: how strongly the speed lines and exhaust show.
  final double speed;
  final bool showBlob;
  final bool showShadow;

  static const design = Size(240, 200);

  static Paint _fill(Color c) => Paint()
    ..color = c
    ..isAntiAlias = true;

  static Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  double get _wave => math.sin(phase * math.pi * 2);
  double get _bob => math.sin(phase * math.pi * 4) * 1.4;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / design.width, size.height / design.height);
    if (showBlob) _blob(canvas);
    if (showShadow) _shadow(canvas);
    if (speed > 0) {
      _speedLines(canvas);
      _exhaust(canvas);
    }
    _wheel(canvas, const Offset(64, 160));
    _wheel(canvas, const Offset(186, 160));
    canvas.save();
    canvas.translate(0, _bob * .5);
    _scooter(canvas);
    canvas.restore();
    canvas.save();
    canvas.translate(0, _bob);
    _rider(canvas);
    canvas.restore();
    canvas.restore();
  }

  void _blob(Canvas c) {
    final wobble = math.sin(phase * math.pi * 2) * 3;
    final p = Path()
      ..moveTo(70, 70 + wobble)
      ..cubicTo(80, 22, 150, 10, 182, 44)
      ..cubicTo(214, 76, 206 + wobble, 128, 176, 146)
      ..cubicTo(146, 166, 84, 168, 62, 140)
      ..cubicTo(44, 116, 60, 96 - wobble, 70, 70 + wobble)
      ..close();
    c.drawPath(p, _fill(RiderInk.blob));
  }

  void _shadow(Canvas c) {
    c.drawOval(
      Rect.fromCenter(center: const Offset(126, 184), width: 186, height: 10),
      _fill(RiderInk.scooterShade.withValues(alpha: .18)),
    );
  }

  void _speedLines(Canvas c) {
    final paint =
        _stroke(RiderInk.scooterLight.withValues(alpha: .55 * speed), 3);
    for (var i = 0; i < 3; i++) {
      final y = 112.0 + i * 18;
      final shift = ((phase * 3 + i * .37) % 1) * 30;
      final len = 26.0 - i * 5;
      final x = 6 - shift + i * 8;
      c.drawLine(Offset(x + 30, y), Offset(x + 30 - len, y), paint);
    }
  }

  void _exhaust(Canvas c) {
    for (var i = 0; i < 3; i++) {
      final t = (phase * 2 + i / 3) % 1;
      final r = 3 + t * 7;
      c.drawCircle(
        Offset(26 - t * 26, 158 - t * 10),
        r,
        _fill(RiderInk.hub.withValues(alpha: (1 - t) * .5 * speed)),
      );
    }
  }

  void _wheel(Canvas c, Offset o) {
    c.drawCircle(o, 22, _fill(RiderInk.tyre));
    c.drawCircle(o, 12.5, _fill(RiderInk.hub));
    final spoke = _stroke(RiderInk.tyre.withValues(alpha: .55), 2);
    final a = phase * math.pi * 2 * 3;
    for (var i = 0; i < 3; i++) {
      final ang = a + i * math.pi / 3;
      final d = Offset(math.cos(ang), math.sin(ang)) * 11;
      c.drawLine(o - d, o + d, spoke);
    }
    c.drawCircle(o, 4.5, _fill(RiderInk.tyre));
    c.drawCircle(o.translate(-1, -1), 1.6, _fill(RiderInk.hub));
  }

  void _scooter(Canvas c) {
    // Rack and delivery box.
    c.drawRRect(
      RRect.fromLTRBR(16, 112, 80, 118, const Radius.circular(3)),
      _fill(RiderInk.scooterShade),
    );
    final box = RRect.fromLTRBR(14, 66, 76, 114, const Radius.circular(7));
    c.drawRRect(box, _fill(RiderInk.box));
    c.drawRRect(
      RRect.fromLTRBAndCorners(14, 66, 76, 76,
          topLeft: const Radius.circular(7),
          topRight: const Radius.circular(7)),
      _fill(RiderInk.boxShade),
    );
    c.drawRRect(
      RRect.fromLTRBR(18, 80, 22, 110, const Radius.circular(2)),
      _fill(RiderInk.scooterLight.withValues(alpha: .6)),
    );
    _boxMark(c, const Offset(46, 93));

    // Rear cowl, which covers the top of the rear wheel.
    final cowl = Path()
      ..moveTo(28, 150)
      ..cubicTo(26, 128, 46, 112, 76, 110)
      ..lineTo(118, 112)
      ..cubicTo(126, 126, 122, 142, 110, 152)
      ..lineTo(34, 152)
      ..close();
    c.drawPath(cowl, _fill(RiderInk.scooter));
    final cowlShade = Path()
      ..moveTo(30, 142)
      ..cubicTo(40, 146, 90, 148, 116, 140)
      ..cubicTo(118, 146, 114, 150, 110, 152)
      ..lineTo(34, 152)
      ..close();
    c.drawPath(cowlShade, _fill(RiderInk.scooterShade));
    c.drawPath(
      Path()
        ..moveTo(40, 124)
        ..cubicTo(52, 116, 74, 115, 92, 116),
      _stroke(RiderInk.scooterLight, 3),
    );
    c.drawCircle(const Offset(32, 132), 3.2,
        _fill(RiderInk.light.withValues(alpha: .9)));

    // Floorboard.
    c.drawRRect(
      RRect.fromLTRBR(104, 146, 164, 157, const Radius.circular(5)),
      _fill(RiderInk.scooterShade),
    );

    // Front fender.
    final fender = Path()
      ..moveTo(164, 154)
      ..cubicTo(170, 134, 202, 130, 210, 150)
      ..lineTo(202, 152)
      ..cubicTo(196, 142, 178, 142, 174, 156)
      ..close();
    c.drawPath(fender, _fill(RiderInk.scooter));

    // Leg shield and steering column.
    final shield = Path()
      ..moveTo(150, 156)
      ..lineTo(168, 156)
      ..cubicTo(184, 128, 182, 98, 168, 76)
      ..lineTo(156, 78)
      ..cubicTo(162, 102, 158, 130, 150, 156)
      ..close();
    c.drawPath(shield, _fill(RiderInk.scooter));
    c.drawPath(
      Path()
        ..moveTo(170, 84)
        ..cubicTo(178, 104, 178, 126, 168, 150),
      _stroke(RiderInk.scooterLight, 2.5),
    );

    // Headlight.
    c.drawOval(
      Rect.fromCenter(center: const Offset(177, 96), width: 11, height: 15),
      _fill(RiderInk.light),
    );
    c.drawOval(
      Rect.fromCenter(center: const Offset(178, 95), width: 4, height: 6),
      _fill(const Color(0xFFFFFFFF).withValues(alpha: .9)),
    );

    // Handlebar and mirror.
    c.drawLine(const Offset(162, 80), const Offset(160, 64),
        _stroke(RiderInk.scooterShade, 5));
    c.drawLine(const Offset(148, 63), const Offset(170, 60),
        _stroke(RiderInk.tyre, 5));
    c.drawLine(const Offset(166, 60), const Offset(171, 46),
        _stroke(RiderInk.tyre, 2));
    c.drawCircle(const Offset(172, 44), 4.5, _fill(RiderInk.hub));

    // Seat.
    c.drawRRect(
      RRect.fromLTRBR(72, 102, 122, 112, const Radius.circular(5)),
      _fill(RiderInk.trousers),
    );
  }

  /// A small bowl-and-steam mark on the delivery box.
  void _boxMark(Canvas c, Offset o) {
    final ink = RiderInk.light.withValues(alpha: .85);
    final bowl = Path()
      ..moveTo(o.dx - 11, o.dy)
      ..lineTo(o.dx + 11, o.dy)
      ..cubicTo(o.dx + 10, o.dy + 9, o.dx - 10, o.dy + 9, o.dx - 11, o.dy)
      ..close();
    c.drawPath(bowl, _fill(ink));
    final steam = _stroke(ink, 1.8);
    for (final dx in [-5.0, 0.0, 5.0]) {
      c.drawPath(
        Path()
          ..moveTo(o.dx + dx, o.dy - 3)
          ..quadraticBezierTo(o.dx + dx + 3, o.dy - 7, o.dx + dx, o.dy - 11),
        steam,
      );
    }
  }

  void _rider(Canvas c) {
    // Far arm (waving pose only), drawn behind the torso.
    if (pose == RiderPose.waving) _wavingArm(c);

    // Leg.
    c.drawLine(const Offset(100, 102), const Offset(134, 110),
        _stroke(RiderInk.trousers, 17));
    c.drawLine(const Offset(134, 110), const Offset(136, 142),
        _stroke(RiderInk.trousers, 13));
    c.drawRRect(
      RRect.fromLTRBR(128, 140, 154, 150, const Radius.circular(5)),
      _fill(RiderInk.tyre),
    );

    // Torso.
    final torso = Path()
      ..moveTo(84, 108)
      ..cubicTo(78, 90, 80, 70, 92, 58)
      ..lineTo(112, 57)
      ..cubicTo(122, 70, 124, 92, 120, 108)
      ..close();
    c.drawPath(torso, _fill(RiderInk.jacket));
    c.drawPath(
      Path()
        ..moveTo(84, 108)
        ..cubicTo(80, 92, 82, 74, 90, 62)
        ..lineTo(96, 62)
        ..cubicTo(90, 76, 90, 94, 94, 108)
        ..close(),
      _fill(RiderInk.jacketShade),
    );
    // Zip and collar.
    c.drawLine(const Offset(110, 62), const Offset(114, 104),
        _stroke(RiderInk.jacketShade, 1.6));
    c.drawPath(
      Path()
        ..moveTo(95, 57)
        ..lineTo(112, 56)
        ..lineTo(108, 64)
        ..lineTo(98, 64)
        ..close(),
      _fill(RiderInk.visor),
    );

    // Near arm to the handlebar.
    c.drawLine(const Offset(106, 66), const Offset(126, 86),
        _stroke(RiderInk.jacketShade, 11));
    c.drawLine(const Offset(126, 86), const Offset(150, 66),
        _stroke(RiderInk.jacketShade, 10));
    c.drawCircle(const Offset(153, 64), 5.5, _fill(RiderInk.skin));

    _head(c);
  }

  void _head(Canvas c) {
    // Neck.
    c.drawRect(const Rect.fromLTRB(98, 46, 107, 58), _fill(RiderInk.skinShade));
    // Helmet shell.
    c.drawCircle(const Offset(100, 34), 18, _fill(RiderInk.helmet));
    // Face in the helmet opening.
    c.drawRRect(
      RRect.fromLTRBAndCorners(103, 30, 121, 52,
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(8),
          bottomLeft: const Radius.circular(8),
          bottomRight: const Radius.circular(10)),
      _fill(RiderInk.skin),
    );
    // Visor brim.
    c.drawRRect(
      RRect.fromLTRBR(100, 25, 126, 32, const Radius.circular(3.5)),
      _fill(RiderInk.visor),
    );
    // Eye and smile.
    c.drawCircle(const Offset(115, 38), 1.7, _fill(RiderInk.visor));
    c.drawPath(
      Path()
        ..moveTo(111, 45)
        ..quadraticBezierTo(115, 48.5, 119, 45),
      _stroke(RiderInk.visor, 1.5),
    );
    // Ear guard and highlight.
    c.drawCircle(const Offset(96, 38), 5.5, _fill(RiderInk.jacketShade));
    c.drawArc(
      Rect.fromCircle(center: const Offset(100, 34), radius: 13),
      math.pi * 1.1,
      math.pi * .45,
      false,
      _stroke(const Color(0xFFFFFFFF).withValues(alpha: .35), 3),
    );
  }

  /// The raised arm holding a phone, rocking with [_wave].
  void _wavingArm(Canvas c) {
    const shoulder = Offset(88, 66);
    final rock = _wave * .22;
    final elbow =
        shoulder + Offset.fromDirection(math.pi * 1.04 + rock * .4, 24);
    final hand = elbow + Offset.fromDirection(math.pi * 1.38 + rock, 22);
    final arm = _stroke(RiderInk.jacketShade, 10);
    c.drawLine(shoulder, elbow, arm);
    c.drawLine(elbow, hand, arm);

    // Phone.
    c.save();
    c.translate(hand.dx, hand.dy - 9);
    c.rotate(-.18 + rock);
    c.drawRRect(
      RRect.fromLTRBR(-8, -14, 8, 14, const Radius.circular(3.5)),
      _fill(RiderInk.phone),
    );
    c.drawRRect(
      RRect.fromLTRBR(-6, -11, 6, 11, const Radius.circular(2)),
      _fill(RiderInk.screen),
    );
    c.drawPath(
      Path()
        ..moveTo(-3, 0)
        ..lineTo(-.5, 3)
        ..lineTo(4, -3),
      _stroke(RiderInk.scooterShade, 1.8),
    );
    c.restore();
    c.drawCircle(hand, 5.5, _fill(RiderInk.skin));

    // Sparkles that twinkle around the phone.
    for (var i = 0; i < 4; i++) {
      final t = (phase + i * .25) % 1;
      final a = math.sin(t * math.pi);
      final ang = -math.pi / 2 + (i - 1.5) * .7;
      final p = hand.translate(0, -10) + Offset.fromDirection(ang, 22 + t * 6);
      _sparkle(c, p, 2.4 + a * 1.6, RiderInk.light.withValues(alpha: a));
    }
  }

  void _sparkle(Canvas c, Offset o, double r, Color color) {
    final p = Path()
      ..moveTo(o.dx, o.dy - r * 1.8)
      ..quadraticBezierTo(o.dx, o.dy, o.dx + r * 1.8, o.dy)
      ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy + r * 1.8)
      ..quadraticBezierTo(o.dx, o.dy, o.dx - r * 1.8, o.dy)
      ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy - r * 1.8)
      ..close();
    c.drawPath(p, _fill(color));
  }

  @override
  bool shouldRepaint(RiderPainter old) =>
      old.phase != phase ||
      old.pose != pose ||
      old.speed != speed ||
      old.showBlob != showBlob ||
      old.showShadow != showShadow;
}
