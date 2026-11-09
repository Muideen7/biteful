import 'package:flutter/material.dart';

import '../config/app_brand.dart';
import '../config/app_theme.dart';

/// "Dish" + "ly" + "." as one line of type. [reveal] (0..1) lets the splash
/// raise each letter out of a clipped baseline, one after another.
class Wordmark extends StatelessWidget {
  const Wordmark({
    super.key,
    this.size = 40,
    this.onDark = false,
    this.reveal = 1,
  });

  final double size;
  final bool onDark;
  final double reveal;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final base = TextStyle(
      fontFamily: AppTheme.font,
      fontSize: size,
      fontWeight: FontWeight.w800,
      letterSpacing: -size * .035,
      height: 1.1,
      color: onDark ? p.card : p.ink,
    );
    final accent =
        base.copyWith(color: onDark ? const Color(0xFFD7EFA9) : p.accent);
    final letters = <(String, TextStyle)>[
      for (final ch in AppBrand.lead.split('')) (ch, base),
      for (final ch in AppBrand.accent.split('')) (ch, accent),
      (AppBrand.dot, accent),
    ];

    if (reveal >= 1) {
      return Semantics(
        label: AppBrand.name,
        child: ExcludeSemantics(
          child: Text.rich(TextSpan(children: [
            for (final (ch, style) in letters) TextSpan(text: ch, style: style),
          ])),
        ),
      );
    }

    final n = letters.length;
    return Semantics(
      label: AppBrand.name,
      child: ExcludeSemantics(
        child: ClipRect(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < n; i++)
                _Letter(
                  text: letters[i].$1,
                  style: letters[i].$2,
                  t: ((reveal * (n + 3) - i) / 4).clamp(0.0, 1.0),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Letter extends StatelessWidget {
  const _Letter({required this.text, required this.style, required this.t});

  final String text;
  final TextStyle style;
  final double t;

  @override
  Widget build(BuildContext context) {
    final e = Curves.easeOutBack.transform(t);
    return Opacity(
      opacity: t.clamp(0, 1),
      child: Transform.translate(
        offset: Offset(0, (1 - e) * style.fontSize! * .8),
        child: Text(text, style: style),
      ),
    );
  }
}
