import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/design_tokens.dart';
import '../services/auth_repository.dart';
import 'pressable.dart';
import 'wheel_loader.dart';

/// Google and Apple. These are the one sanctioned break from the single
/// green accent: their marks and colours are fixed by each company's
/// guidelines, and restyled ones are not recognised at a glance.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.busy = false,
  });

  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool busy;

  String get label => switch (provider) {
        SocialProvider.google => 'Google',
        SocialProvider.apple => 'Apple',
      };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Pressable(
      onTap: busy ? null : onPressed,
      semanticLabel: 'Continue with $label',
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: onPressed == null && !busy ? .5 : 1,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: p.field,
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
          alignment: Alignment.center,
          child: busy
              ? WheelLoader(size: 22, color: p.ink)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (provider == SocialProvider.google)
                      const CustomPaint(
                          size: Size.square(18), painter: GoogleG())
                    else
                      Icon(Icons.apple,
                          size: 22, color: dark ? Colors.white : Colors.black),
                    const SizedBox(width: Space.sm),
                    Text(label, style: context.title),
                  ],
                ),
        ),
      ),
    );
  }
}

/// The four-colour G, drawn with four arcs and a crossbar.
class GoogleG extends CustomPainter {
  const GoogleG();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final stroke = s * .2;
    final rect = Rect.fromCircle(
        center: size.center(Offset.zero), radius: (s - stroke) / 2);
    Paint arc(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    const deg = math.pi / 180;
    canvas.drawArc(
        rect, -40 * deg, -100 * deg, false, arc(const Color(0xFFEA4335)));
    canvas.drawArc(
        rect, -140 * deg, -90 * deg, false, arc(const Color(0xFFFBBC05)));
    canvas.drawArc(
        rect, 130 * deg, -90 * deg, false, arc(const Color(0xFF34A853)));
    canvas.drawArc(
        rect, 40 * deg, -40 * deg, false, arc(const Color(0xFF4285F4)));
    canvas.drawRect(
      Rect.fromLTWH(s / 2, s / 2 - stroke / 2, s / 2 - stroke * .1, stroke),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
