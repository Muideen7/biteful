import 'package:flutter/material.dart';

import '../config/app_theme.dart';

/// Fills the gap an iOS pull-down bounce opens above a green header.
///
/// It paints the header's own diagonal gradient laid out on the header's
/// own rectangle and simply extended upward, so every pixel just above the
/// join has exactly the colour of the pixel just below it: no seam, and
/// the blend carries on into the gap. Sized to the overscroll, so it is
/// nothing at rest.
class OverscrollFill extends StatelessWidget {
  const OverscrollFill(
      {super.key, required this.controller, required this.headerKey});

  final ScrollController controller;

  /// The header whose gradient continues into the gap.
  final GlobalKey headerKey;

  @override
  Widget build(BuildContext context) {
    final gradient = context.palette.headerGradient;
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final pull = controller.hasClients ? -controller.position.pixels : 0.0;
        if (pull <= 0) return const SizedBox.shrink();
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          // A pixel of overlap so anti-aliasing never opens a hairline.
          height: pull + 1,
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ExtendedGradient(
                  gradient: gradient, headerKey: headerKey, pull: pull),
            ),
          ),
        );
      },
    );
  }
}

class _ExtendedGradient extends CustomPainter {
  _ExtendedGradient(
      {required this.gradient, required this.headerKey, required this.pull});

  final LinearGradient gradient;
  final GlobalKey headerKey;
  final double pull;

  @override
  void paint(Canvas canvas, Size size) {
    // The header's size is read here, at paint time: reading it during
    // build asserts in debug builds.
    final box = headerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    // Where the header sits, in this box's coordinates: just below the gap.
    final headerRect = Rect.fromLTWH(0, pull, box.size.width, box.size.height);
    // TileMode.clamp (the default) carries the gradient past the header
    // rect continuously, so the join has no seam.
    canvas.drawRect(Offset.zero & size,
        Paint()..shader = gradient.createShader(headerRect));
  }

  @override
  bool shouldRepaint(_ExtendedGradient old) =>
      old.pull != pull || old.gradient != gradient;
}
