import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_brand.dart';
import '../../config/app_theme.dart';
import '../../config/app_timing.dart';
import '../../config/motion.dart';
import '../../models/catalog.dart';
import '../../providers/core_providers.dart';
import '../../services/catalog_repository.dart';
import '../../widgets/rider/rider.dart';
import '../../widgets/wordmark.dart';

/// `intro`: the splash plays over a blank page. `warming`: the first screen
/// is mounted underneath, hidden, so its heavy first build happens while the
/// rider idles; its entrance waits. `leaving`: the rider drives off and the
/// first screen's entrance plays. `done`: the splash is gone.
enum SplashPhase { intro, warming, leaving, done }

final splashPhaseProvider = StateProvider<SplashPhase>(
  (_) => AppTiming.scale == 0 ? SplashPhase.done : SplashPhase.intro,
);

/// The opening shot, measured from the reference clip: the rider drives in
/// from the left and brakes in the middle, the wordmark rises letter by
/// letter, the tagline settles, then the rider pulls away to the right while
/// the wordmark blurs out.
///
/// It leaves only when the intro has played *and* the menu has loaded, so
/// it never dissolves onto a half-loaded screen.
class SplashOverlay extends ConsumerStatefulWidget {
  const SplashOverlay({super.key});

  @override
  ConsumerState<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends ConsumerState<SplashOverlay>
    with TickerProviderStateMixin {
  late final _in =
      AnimationController(vsync: this, duration: AppTiming.splashDriveIn);
  late final _out =
      AnimationController(vsync: this, duration: AppTiming.splashDriveOut);
  bool _hapticDone = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    // The menu, through its repository: with a backend this is the first
    // network call, and the splash covers it.
    final ready = ref.read(catalogProvider.future);
    // Started, never awaited: decoding fills the hold but never extends it.
    ready.then(_warm).ignore();
    _in.addListener(_haptic);
    await _in.forward();
    await ready;
    if (!mounted) return;
    // Mount the first screen now, behind the opaque splash. In a debug build
    // its first frames are heavy; paid here, while the rider idles, they
    // cannot swallow the drive-out.
    ref.read(splashPhaseProvider.notifier).state = SplashPhase.warming;
    await AppTiming.wait(AppTiming.splashHold);
    for (var i = 0; i < 2; i++) {
      await SchedulerBinding.instance.endOfFrame;
    }
    if (!mounted) return;
    ref.read(splashPhaseProvider.notifier).state = SplashPhase.leaving;
    await _out.forward();
    if (!mounted) return;
    ref.read(splashPhaseProvider.notifier).state = SplashPhase.done;
  }

  /// Decodes every food render while the splash holds, so the first screen
  /// does not decode forty images in its first frame.
  Future<void> _warm(Catalog c) async {
    if (!mounted) return;
    final names = <String>{
      for (final a in [
        ...c.products.map((p) => p.art),
        ...c.categories.map((x) => x.art),
        ...c.restaurants.map((r) => r.art),
        ...c.deals.map((d) => d.art),
        for (final b in c.banners)
          if (b.art != null) b.art!,
      ]) ...[a.main, if (a.side != null) a.side!],
    };
    await Future.wait([
      for (final n in names)
        precacheImage(AssetImage(FoodArt.path(n)), context).catchError((_) {}),
    ]);
  }

  void _haptic() {
    if (!_hapticDone && _in.value > .7) {
      _hapticDone = true;
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _in.dispose();
    _out.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final reduced = Motion.reduced(context);
    final width = MediaQuery.sizeOf(context).width;
    final riderWidth = (width * .62).clamp(180.0, 300.0);

    return AnimatedBuilder(
      animation: Listenable.merge([_in, _out]),
      builder: (context, _) {
        final tIn = _in.value;
        final tOut = _out.value;
        final drive = Curves.easeOutCubic.transform(tIn);
        final away = Curves.easeInCubic.transform(tOut);
        final dx = reduced
            ? 0.0
            : -(width / 2 + riderWidth) * (1 - drive) +
                (width / 2 + riderWidth) * away;
        // Speed lines show while moving and fade as the rider brakes.
        final speed =
            reduced ? 0.0 : (tOut > 0 ? 1.0 : (1 - drive).clamp(.25, 1.0));
        final wordIn = reduced ? 1.0 : ((tIn - .45) / .55).clamp(0.0, 1.0);
        final taglineIn =
            Curves.easeOut.transform(((tIn - .8) / .2).clamp(0.0, 1.0));
        final blur = 10 * Curves.easeIn.transform(tOut);
        final textFade =
            1 - Curves.easeIn.transform(((tOut - .1) / .7).clamp(0.0, 1.0));
        final bgFade = 1 - ((tOut - .55) / .45).clamp(0.0, 1.0);

        return IgnorePointer(
          ignoring: tOut > .55,
          child: Opacity(
            opacity: bgFade,
            // A Material, not a bare ColoredBox: the splash sits above the
            // Navigator, where no Scaffold gives text a default style, and
            // Flutter marks unstyled text with a yellow double underline.
            child: Material(
              color: p.paper,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: Offset(dx, 0),
                      child: Rider(width: riderWidth, speed: speed),
                    ),
                    const SizedBox(height: 36),
                    Opacity(
                      opacity: textFade,
                      child: ImageFiltered(
                        imageFilter:
                            ImageFilter.blur(sigmaX: blur, sigmaY: blur * .4),
                        child: Column(
                          children: [
                            Wordmark(size: 44, reveal: wordIn),
                            const SizedBox(height: 12),
                            Opacity(
                              opacity: taglineIn,
                              child: Transform.translate(
                                offset: Offset(0, 8 * (1 - taglineIn)),
                                child: Text(
                                  AppBrand.tagline,
                                  style: context.body
                                      .copyWith(color: p.muted, fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Starts [start] when the splash begins to leave (or at once if it already
/// has), so a first screen mounted early does not play its entrance unseen.
void startWhenRevealed(WidgetRef ref, VoidCallback start) {
  final phase = ref.read(splashPhaseProvider);
  if (phase == SplashPhase.leaving || phase == SplashPhase.done) {
    start();
    return;
  }
  late final ProviderSubscription<SplashPhase> sub;
  sub = ref.listenManual(splashPhaseProvider, (_, next) {
    if (next == SplashPhase.leaving || next == SplashPhase.done) {
      sub.close();
      start();
    }
  });
}
