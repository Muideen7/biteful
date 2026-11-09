import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/motion.dart';
import '../config/palette.dart';

/// The brand loader: the scooter's wheel, spinning. Used inside busy buttons
/// instead of a stock spinner.
class WheelLoader extends StatefulWidget {
  const WheelLoader({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  State<WheelLoader> createState() => _WheelLoaderState();
}

class _WheelLoaderState extends State<WheelLoader>
    with SingleTickerProviderStateMixin {
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.loops(context)) {
      if (!_spin.isAnimating) _spin.repeat();
    } else {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Palette.of(context).card;
    return Semantics(
      label: 'Loading',
      child: AnimatedBuilder(
        animation: _spin,
        builder: (_, __) => CustomPaint(
          size: Size.square(widget.size),
          painter: _WheelPainter(_spin.value * math.pi * 2, color),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter(this.angle, this.color);

  final double angle;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final ring = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .26;
    canvas.drawCircle(c, r * .82, ring);
    final spoke = Paint()
      ..color = color
      ..strokeWidth = r * .16
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final a = angle + i * math.pi / 3;
      final d = Offset(math.cos(a), math.sin(a)) * r * .62;
      canvas.drawLine(c - d, c + d, spoke);
    }
    canvas.drawCircle(c, r * .2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.angle != angle || old.color != color;
}
