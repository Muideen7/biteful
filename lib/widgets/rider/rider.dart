import 'package:flutter/material.dart';

import '../../config/motion.dart';
import 'rider_painter.dart';

/// The rider, idling on its own loop: wheels turning, body bobbing and (in
/// the waving pose) the phone rocking with sparkles around it.
///
/// The loop runs only while ambient motion is wanted, so tests settle and
/// reduce-motion gets a still drawing.
class Rider extends StatefulWidget {
  const Rider({
    super.key,
    this.pose = RiderPose.riding,
    this.speed = 0,
    this.showBlob = true,
    this.showShadow = true,
    this.mirrored = false,
    this.width = 240,
  });

  final RiderPose pose;
  final double speed;
  final bool showBlob;
  final bool showShadow;

  /// Faces left instead of right.
  final bool mirrored;
  final double width;

  @override
  State<Rider> createState() => _RiderState();
}

class _RiderState extends State<Rider> with SingleTickerProviderStateMixin {
  late final _loop =
      AnimationController(vsync: this, duration: Motion.riderCycle);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.loops(context)) {
      if (!_loop.isAnimating) _loop.repeat();
    } else {
      _loop.stop();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = Size(
      widget.width,
      widget.width * RiderPainter.design.height / RiderPainter.design.width,
    );
    Widget art = AnimatedBuilder(
      animation: _loop,
      builder: (_, __) => CustomPaint(
        size: size,
        painter: RiderPainter(
          phase: _loop.value,
          pose: widget.pose,
          speed: widget.speed,
          showBlob: widget.showBlob,
          showShadow: widget.showShadow,
        ),
      ),
    );
    if (widget.mirrored) {
      art = Transform.flip(flipX: true, child: art);
    }
    return Semantics(
      label: 'Delivery rider on a scooter',
      image: true,
      child: ExcludeSemantics(child: RepaintBoundary(child: art)),
    );
  }
}
