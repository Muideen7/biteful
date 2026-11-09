import 'dart:io';

import 'package:dishly/app.dart';
import 'package:dishly/config/app_brand.dart';
import 'package:dishly/config/app_timing.dart';
import 'package:dishly/screens/auth/sign_in_screen.dart';
import 'package:dishly/screens/shell/main_shell.dart';
import 'package:dishly/screens/splash/splash_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Pumps in frames up to the splash's own length plus a margin. One long
/// pump would run the splash's controllers only once.
Future<void> pumpPastSplash(WidgetTester t) async {
  final total = AppTiming.splashTotal + const Duration(milliseconds: 600);
  for (var e = Duration.zero;
      e < total;
      e += const Duration(milliseconds: 50)) {
    await t.pump(const Duration(milliseconds: 50));
  }
  await t.pumpAndSettle();
}

void main() {
  final seed = readSeed();
  setUp(quietMotion);

  Future<void> launch(WidgetTester t, {bool signedIn = false}) async {
    phone(t);
    AppTiming.scale = 1;
    addTearDown(() => AppTiming.scale = 0);
    final (c, _) =
        await makeContainer(seed, signedIn: signedIn ? seed.profile : null);
    await t.pumpWidget(
        UncontrolledProviderScope(container: c, child: const DishlyApp()));
  }

  testWidgets('the splash plays, then hands over to sign in', (t) async {
    await launch(t);
    await t.pump(AppTiming.splashDriveIn);
    expect(find.byType(SplashOverlay), findsOneWidget);
    expect(find.byType(SignInScreen), findsNothing);
    await pumpPastSplash(t);
    expect(find.byType(SplashOverlay), findsNothing);
    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('splash text has a real text style, not the unstyled fallback',
      (t) async {
    await launch(t);
    await t.pump(AppTiming.splashDriveIn + const Duration(milliseconds: 300));
    final tagline = find.text(AppBrand.tagline);
    expect(tagline, findsOneWidget);
    // Without a Material above it, text inherits the debug fallback style:
    // a yellow double underline.
    final style = DefaultTextStyle.of(t.element(tagline)).style;
    expect(style.decoration, isNot(TextDecoration.underline));
    await pumpPastSplash(t);
  });

  testWidgets('a remembered session goes straight to Home after the splash',
      (t) async {
    await launch(t, signedIn: true);
    await pumpPastSplash(t);
    expect(find.byType(MainShell), findsOneWidget);
  });

  testWidgets('the first screen is not rebuilt when the splash leaves',
      (t) async {
    await launch(t);
    // Into the drive-out: sign in is mounted underneath the dissolving splash.
    await t.pump(AppTiming.splashDriveIn);
    for (var e = Duration.zero;
        e < AppTiming.splashHold + const Duration(milliseconds: 200);
        e += const Duration(milliseconds: 50)) {
      await t.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(SplashOverlay), findsOneWidget);
    final before = t.state(find.byType(SignInScreen));
    await pumpPastSplash(t);
    expect(identical(t.state(find.byType(SignInScreen)), before), isTrue);
  });

  test('no em dashes in on-screen strings', () {
    final literal = RegExp(r'''(['"])(?:(?!\1).)*—(?:(?!\1).)*\1''');
    for (final f
        in Directory('lib').listSync(recursive: true).whereType<File>()) {
      for (final line in f.readAsLinesSync()) {
        if (line.trimLeft().startsWith('//')) continue;
        expect(literal.hasMatch(line), isFalse, reason: '${f.path}: $line');
      }
    }
  });
}
