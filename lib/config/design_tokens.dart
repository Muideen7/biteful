/// Spacing, radii and sizes. Widgets read these instead of inlining numbers.
abstract final class Space {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 28.0;

  /// The page gutter used by every screen.
  static const gutter = 20.0;
}

abstract final class Radii {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 24.0;
  static const header = 36.0;
  static const pill = 999.0;
}

abstract final class Sizes {
  static const fieldHeight = 54.0;
  static const buttonHeight = 54.0;
  static const navHeight = 64.0;

  /// Height of the home header bar when collapsed, below the status bar.
  static const homeBar = 64.0;

  /// How far the green header reaches behind the promo banner at rest.
  static const homeHeaderReach = 96.0;

  static const bannerAspect = 2.25;
  static const categoryTile = 74.0;
}
