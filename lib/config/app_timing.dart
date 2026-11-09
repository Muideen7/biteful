/// Every deliberate wait in the app, in one place. A demo whose actions
/// finish in one frame reads as fake, and a loading state nobody sees can
/// not be judged.
///
/// `--dart-define=timingScale=0` skips every wait, the splash included, for
/// automation and screenshot runs.
abstract final class AppTiming {
  static double scale =
      double.tryParse(const String.fromEnvironment('timingScale')) ?? 1.0;

  // Splash phases.
  static Duration get splashDriveIn => _s(900);
  static Duration get splashHold => _s(1500);
  static Duration get splashDriveOut => _s(700);
  static Duration get splashTotal =>
      splashDriveIn + splashHold + splashDriveOut;

  // Simulated network.
  static Duration get signIn => _s(1400);
  static Duration get socialSignIn => _s(1100);
  static Duration get resetPassword => _s(1000);
  static Duration get placeOrder => _s(1600);
  static Duration get refresh => _s(900);

  static Duration _s(int ms) =>
      Duration(microseconds: (ms * 1000 * scale).round());

  static Future<void> wait(Duration d) =>
      d == Duration.zero ? Future.value() : Future.delayed(d);

  /// Runs [work] but never resolves sooner than [d], so a loader never
  /// flashes for a single frame.
  static Future<T> atLeast<T>(Duration d, Future<T> work) async {
    final results = await Future.wait<Object?>([work, wait(d)]);
    return results.first as T;
  }

  /// For `RefreshIndicator.onRefresh`: waits at least [refresh] and never
  /// throws.
  static Future<void> refreshing(Future<void> Function() work) async {
    try {
      await atLeast(refresh, work());
    } catch (_) {}
  }
}
