import 'package:flutter/material.dart';

import 'palette.dart';

abstract final class AppTheme {
  static const font = 'Bricolage';

  static ThemeData light() => _build(Palette.light, Brightness.light);
  static ThemeData dark() => _build(Palette.dark, Brightness.dark);

  static ThemeData _build(Palette p, Brightness b) {
    final scheme = ColorScheme.fromSeed(
      seedColor: p.accent,
      brightness: b,
    ).copyWith(
      primary: p.accent,
      onPrimary: p.card,
      surface: p.paper,
      onSurface: p.ink,
      error: p.error,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      fontFamily: font,
      scaffoldBackgroundColor: p.paper,
      splashFactory: InkSparkle.splashFactory,
      extensions: [p],
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionColor: p.accent.withValues(alpha: .3),
        selectionHandleColor: p.accent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.ink,
        contentTextStyle: TextStyle(
          fontFamily: font,
          color: p.paper,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

/// Text styles named for what they are, read from the palette in context.
extension AppText on BuildContext {
  Palette get palette => Palette.of(this);

  TextStyle get display => TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -.6,
        color: palette.ink,
      );
  TextStyle get heading => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -.3,
        color: palette.ink,
      );
  TextStyle get title => TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
        letterSpacing: -.1,
        color: palette.ink,
      );
  TextStyle get body => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: palette.inkSoft,
      );
  TextStyle get caption => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: palette.muted,
      );
  TextStyle get label => TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: palette.ink,
      );
}
