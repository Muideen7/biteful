import 'package:flutter/material.dart';

/// One saturated accent (a leafy green) and washes of it. Ink is never pure
/// black and paper is never pure white: both carry a faint green cast.
///
/// Light and dark are defined from the same token names, so a surface can
/// not be styled for one mode and forgotten in the other.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.paper,
    required this.card,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.line,
    required this.field,
    required this.accent,
    required this.accentDeep,
    required this.accentWash,
    required this.headerTop,
    required this.headerBottom,
    required this.dealCard,
    required this.onDeal,
    required this.error,
    required this.star,
  });

  final Color paper;
  final Color card;
  final Color ink;
  final Color inkSoft;
  final Color muted;
  final Color line;
  final Color field;
  final Color accent;
  final Color accentDeep;
  final Color accentWash;
  final Color headerTop;
  final Color headerBottom;
  final Color dealCard;
  final Color onDeal;
  final Color error;
  final Color star;

  static const light = Palette(
    paper: Color(0xFFF2F4EC),
    card: Color(0xFFFDFEFA),
    ink: Color(0xFF1D2316),
    inkSoft: Color(0xFF3B4331),
    muted: Color(0xFF7D8474),
    line: Color(0xFFE3E7DA),
    field: Color(0xFFF0F2EA),
    accent: Color(0xFF7CB342),
    accentDeep: Color(0xFF34501A),
    accentWash: Color(0xFFE5F0D3),
    headerTop: Color(0xFF41671B),
    headerBottom: Color(0xFF8BC34A),
    dealCard: Color(0xFF1F2618),
    onDeal: Color(0xFFF7FAF0),
    error: Color(0xFFC0442C),
    star: Color(0xFFE2A53B),
  );

  static const dark = Palette(
    paper: Color(0xFF12160E),
    card: Color(0xFF1B2115),
    ink: Color(0xFFEFF3E6),
    inkSoft: Color(0xFFCDD4C1),
    muted: Color(0xFF8E9783),
    line: Color(0xFF2B3323),
    field: Color(0xFF232A1C),
    accent: Color(0xFF8CC653),
    accentDeep: Color(0xFF2C4515),
    accentWash: Color(0xFF26331A),
    headerTop: Color(0xFF2C4713),
    headerBottom: Color(0xFF5F8F2C),
    dealCard: Color(0xFF0B0E08),
    onDeal: Color(0xFFF2F6EA),
    error: Color(0xFFE2735C),
    star: Color(0xFFE9B456),
  );

  /// The gradient on the header, the primary button and selected pills.
  LinearGradient get headerGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [headerTop, headerBottom],
      );

  LinearGradient get buttonGradient => LinearGradient(
        colors: [accentDeep, accent],
      );

  static Palette of(BuildContext context) =>
      Theme.of(context).extension<Palette>()!;

  @override
  Palette copyWith() => this;

  @override
  Palette lerp(Palette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return Palette(
      paper: l(paper, other.paper),
      card: l(card, other.card),
      ink: l(ink, other.ink),
      inkSoft: l(inkSoft, other.inkSoft),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      field: l(field, other.field),
      accent: l(accent, other.accent),
      accentDeep: l(accentDeep, other.accentDeep),
      accentWash: l(accentWash, other.accentWash),
      headerTop: l(headerTop, other.headerTop),
      headerBottom: l(headerBottom, other.headerBottom),
      dealCard: l(dealCard, other.dealCard),
      onDeal: l(onDeal, other.onDeal),
      error: l(error, other.error),
      star: l(star, other.star),
    );
  }
}

/// Colours of the hand-drawn rider. These belong to the illustration, not to
/// the UI, so they stay the same in light and dark mode.
abstract final class RiderInk {
  static const scooter = Color(0xFF4E7A22);
  static const scooterShade = Color(0xFF395C17);
  static const scooterLight = Color(0xFF6E9C34);
  static const jacket = Color(0xFF5B8A2A);
  static const jacketShade = Color(0xFF466C1F);
  static const helmet = Color(0xFF5E8F2B);
  static const visor = Color(0xFF26301C);
  static const trousers = Color(0xFF2A2F25);
  static const skin = Color(0xFFF2C9A0);
  static const skinShade = Color(0xFFDDAA80);
  static const tyre = Color(0xFF262A22);
  static const hub = Color(0xFFB9C0AE);
  static const box = Color(0xFF6A9A30);
  static const boxShade = Color(0xFF537A24);
  static const blob = Color(0xFFD6EB9B);
  static const light = Color(0xFFF6F2C8);
  static const phone = Color(0xFF2E3529);
  static const screen = Color(0xFFBFE38A);
}
