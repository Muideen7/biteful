import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_brand.dart';
import 'config/app_theme.dart';
import 'config/app_timing.dart';
import 'providers/session_providers.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/shell/main_shell.dart';
import 'screens/splash/splash_overlay.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class DishlyApp extends ConsumerStatefulWidget {
  const DishlyApp({super.key});

  @override
  ConsumerState<DishlyApp> createState() => _DishlyAppState();
}

class _DishlyAppState extends ConsumerState<DishlyApp> {
  final _appKey = GlobalKey(debugLabel: 'app');

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(splashPhaseProvider);
    return MaterialApp(
      title: AppBrand.name,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      home: const StartGate(),
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        // The Stack keeps one shape for the app's whole life: the app is
        // always its keyed first child and only the splash sibling goes.
        // Returning `child` bare once the splash ends would remount the
        // first screen and replay its entrance.
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Stack(
              children: [
                KeyedSubtree(key: _appKey, child: child!),
                if (phase != SplashPhase.done) const SplashOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The first route. Blank until the splash starts to leave, so the first
/// screen's own entrance plays while the splash dissolves rather than
/// unseen behind it.
class StartGate extends ConsumerWidget {
  const StartGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(splashPhaseProvider);
    if (phase == SplashPhase.intro && AppTiming.scale > 0) {
      return ColoredBox(color: context.palette.paper);
    }
    // Read once: signing in or out later navigates explicitly.
    final signedIn = ref.read(sessionProvider) != null;
    return signedIn ? const MainShell() : const SignInScreen();
  }
}
