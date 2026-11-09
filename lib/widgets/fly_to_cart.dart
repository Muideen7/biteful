import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/motion.dart';
import '../models/catalog.dart';
import 'food_art_view.dart';

/// The Cart tab's icon. The flight aims at it.
final cartTargetKey = GlobalKey(debugLabel: 'cart-target');

/// Ticks each time a flight lands, so the cart icon can squash.
final cartLanded = ValueNotifier<int>(0);

/// Flies a copy of [art] from the widget at [from] into the Cart tab: up in
/// an arc, shrinking and tilting, with two fading copies trailing behind,
/// and a little squash of the cart icon as it lands.
///
/// Completes when it lands. With reduce-motion, or when either end is not
/// on screen, it completes at once and nothing flies.
Future<void> flyToCart(
    BuildContext context, GlobalKey from, FoodArt art) async {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  final src = from.currentContext?.findRenderObject() as RenderBox?;
  final dst = cartTargetKey.currentContext?.findRenderObject() as RenderBox?;
  if (overlay == null ||
      src == null ||
      dst == null ||
      !src.attached ||
      !dst.attached ||
      !Motion.ambient ||
      Motion.reduced(context)) {
    return;
  }
  final start = src.localToGlobal(Offset.zero) & src.size;
  final end = dst.localToGlobal(dst.size.center(Offset.zero));

  final landed = Completer<void>();
  final entry = OverlayEntry(
    builder: (_) =>
        _Flight(start: start, end: end, art: art, onLanded: landed.complete),
  );
  overlay.insert(entry);
  await landed.future;
  entry.remove();
  HapticFeedback.lightImpact();
  cartLanded.value++;
}

class _Flight extends StatefulWidget {
  const _Flight({
    required this.start,
    required this.end,
    required this.art,
    required this.onLanded,
  });

  final Rect start;
  final Offset end;
  final FoodArt art;
  final VoidCallback onLanded;

  @override
  State<_Flight> createState() => _FlightState();
}

class _FlightState extends State<_Flight> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 780))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onLanded();
    })
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// A quadratic Bézier from the dish to the cart, bowed up above both.
  Offset _at(double t) {
    final a = widget.start.center;
    final b = widget.end;
    final lift = math.max(120.0, (a.dy - b.dy).abs() * .35);
    final ctrl = Offset(
        (a.dx + b.dx) / 2 + (a.dx - b.dx) * .15, math.min(a.dy, b.dy) - lift);
    final u = 1 - t;
    return a * (u * u) + ctrl * (2 * u * t) + b * (t * t);
  }

  Widget _copy(double raw, double alpha) {
    // The trailing ghosts start late: before their time they are not drawn.
    if (raw <= 0) return const SizedBox.shrink();
    raw = raw.clamp(0.0, 1.0);
    final t = Curves.easeInOutCubic.transform(raw.clamp(0.0, 1.0));
    // A quick pop up off the card before the dish heads for the cart.
    final pop = raw < .18 ? Curves.easeOut.transform(raw / .18) : 1.0;
    final size = widget.start.shortestSide;
    final scale = lerpDouble(1, .22, t)! * (1 + .12 * math.sin(pop * math.pi));
    final angle = -.5 * t + .15 * math.sin(raw * math.pi * 2);
    final fade = raw > .88 ? 1 - (raw - .88) / .12 : 1.0;
    final p = _at(t);
    return Positioned(
      left: p.dx - size / 2,
      top: p.dy - size / 2,
      width: size,
      height: size,
      child: Opacity(
        opacity: (alpha * fade).clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: angle,
          child: Transform.scale(
              scale: scale, child: FoodArtView(widget.art, size: size)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final v = _c.value;
          return Stack(
            children: [
              // A soft landing ring that swells where the cart is.
              if (v > .8)
                Positioned(
                  left: widget.end.dx - 26,
                  top: widget.end.dy - 26,
                  width: 52,
                  height: 52,
                  child: Opacity(
                    opacity: (1 - (v - .8) / .2) * .6,
                    child: Transform.scale(
                      scale: .5 + (v - .8) / .2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
              _copy(v - .12, .18),
              _copy(v - .06, .35),
              _copy(v, 1),
            ],
          );
        },
      ),
    );
  }
}
