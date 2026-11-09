import 'package:dishly/config/motion.dart';
import 'package:dishly/providers/session_providers.dart';
import 'package:dishly/screens/auth/auth_header.dart';
import 'package:dishly/screens/auth/sign_in_screen.dart';
import 'package:dishly/screens/home/home_tab.dart';
import 'package:dishly/screens/home/sections/promo_art.dart';
import 'package:dishly/widgets/rider/rider_hero.dart';
import 'package:dishly/screens/profile/profile_tab.dart';
import 'package:dishly/screens/shell/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Heights of every green header shape on screen, flying or not.
List<double> shapeHeights(WidgetTester t) => [
      for (final e in find.byType(BrandHeaderShape).evaluate())
        if ((e.renderObject as RenderBox?)?.hasSize ?? false)
          (e.renderObject! as RenderBox).size.height,
    ];

void main() {
  final seed = readSeed();
  setUpAll(quietMotion);

  testWidgets('signing in morphs the header into Home, then the page arrives',
      (t) async {
    phone(t);
    final (c, _) = await makeContainer(seed);
    await pumpScreen(t, c, const SignInScreen());
    final from = t.getSize(find.byType(AuthHeader)).height;

    Finder f(String k) => find.descendant(
        of: find.byKey(Key(k)), matching: find.byType(EditableText));
    await t.enterText(f('email'), seed.demoEmail);
    await t.enterText(f('password'), 'anything1');
    await t.tap(find.text('Log In'));
    await t.pump(); // sign in resolves
    await t.pump(); // route pushed
    await t.pump(Motion.handOff * .45);

    // Mid-flight: one shape between the two headers' heights, and Home's
    // content not yet built.
    final heights = shapeHeights(t);
    expect(heights.any((h) => h < from - 4 && h > 150), isTrue,
        reason: '$heights vs $from');
    expect(
        find.descendant(
            of: find.byType(HomeTab), matching: find.text('Categories')),
        findsNothing);
    expect(t.takeException(), isNull);

    await t.pumpAndSettle();
    expect(
        find.descendant(
            of: find.byType(HomeTab), matching: find.text('Categories')),
        findsOneWidget);
    expect(find.byType(SignInScreen), findsNothing);
  });

  testWidgets(
      'the rider flies from the sign-in header into the banner, turning round',
      (t) async {
    phone(t);
    final (c, _) = await makeContainer(seed);
    await pumpScreen(t, c, const SignInScreen());
    final start = t.getCenter(find.byType(RiderHero));
    Finder f(String k) => find.descendant(
        of: find.byKey(Key(k)), matching: find.byType(EditableText));
    await t.enterText(f('email'), seed.demoEmail);
    await t.enterText(f('password'), 'anything1');
    await t.tap(find.text('Log In'));
    await t.pump();
    await t.pump();

    // Partway: one rider in flight (the two ends are hidden), between the
    // two places, and turned partway round the vertical axis.
    await t.pump(Motion.handOff * .3);
    // A turn round the vertical axis is the only transform with an x/z term.
    final flying = find.byWidgetPredicate(
        (w) => w is Transform && w.transform.entry(0, 2).abs() > .05);
    expect(flying, findsWidgets);
    expect(t.takeException(), isNull);

    await t.pumpAndSettle();
    // Landed in the banner, which sits under Home's header: up and left.
    final banner = find.descendant(
        of: find.byType(PromoBannerCard), matching: find.byType(RiderHero));
    expect(banner, findsOneWidget);
    final end = t.getCenter(banner);
    expect(end.dx, lessThan(start.dx));
    expect((t.widget<RiderHero>(banner).child).mirrored, isFalse);
  });

  testWidgets('signing out morphs back with the profile intact, then signs out',
      (t) async {
    phone(t);
    final (c, _) = await makeContainer(seed, signedIn: seed.profile);
    c.read(shellTabProvider.notifier).state = ShellTab.profile;
    await pumpScreen(t, c, const MainShell());
    await t.scrollUntilVisible(find.text('Sign out'), 200);
    await t.drag(find.text('Sign out'), const Offset(0, -240));
    await t.pumpAndSettle();
    await t.tap(find.text('Sign out'));
    await t.pump();
    await t.pump(Motion.handOff * .45);

    // The sign-in header is in place from the start (it morphs, never drops).
    expect(t.getTopLeft(find.byType(AuthHeader)).dy, 0);
    final signIn = t.widget<SignInScreen>(find.byType(SignInScreen));
    expect(signIn.handOff, isTrue);
    // The shell stays on Profile while it fades: Home must not flash under it.
    expect(c.read(shellTabProvider), ShellTab.profile);
    // Still signed in under the morph, so Profile keeps its name and photo.
    expect(c.read(sessionProvider), isNotNull);
    expect(
        find.descendant(
            of: find.byType(ProfileTab),
            matching: find.text(seed.profile.name)),
        findsOneWidget);
    expect(t.takeException(), isNull);

    await t.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
    expect(c.read(sessionProvider), isNull);
    // It does not replay the launch drop: the header was already in place.
    expect(t.getTopLeft(find.byType(AuthHeader)).dy, 0);
  });
}
