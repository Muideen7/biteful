import 'package:flutter/widgets.dart';

/// How things move. Durations sit on the stock ladder the reference clip
/// measured against (180 / 250 / 400 / 600 ms). How long the app *waits* is
/// a different question and lives in `AppTiming`.
abstract final class Motion {
  static const quick = Duration(milliseconds: 180);
  static const short = Duration(milliseconds: 250);
  static const medium = Duration(milliseconds: 400);
  static const long = Duration(milliseconds: 600);

  /// One full idle cycle of the rider: a bob, a wheel turn, a wave.
  static const riderCycle = Duration(milliseconds: 1400);

  /// Login hands over to Home: the header shrinks, the form fades.
  static const handOff = Duration(milliseconds: 700);

  /// Home sections rise in from one controller, staggered by intervals.
  static const homeEntrance = Duration(milliseconds: 900);
  static const authEntrance = Duration(milliseconds: 1300);

  static const bannerAutoAdvance = Duration(seconds: 4);

  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
  static const drive = Curves.easeOutBack;
  static const settle = Curves.easeOutQuart;

  /// Ambient loops (rider idle, banner auto-advance) run only when this is
  /// true. Tests switch it off so `pumpAndSettle` can settle.
  static bool ambient = true;

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static bool loops(BuildContext context) => ambient && !reduced(context);
}
