import 'package:dishly/providers/session_providers.dart';
import 'package:dishly/screens/auth/sign_in_screen.dart';
import 'package:dishly/screens/shell/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final seed = readSeed();
  setUpAll(quietMotion);

  Future<dynamic> pump(WidgetTester t) async {
    phone(t);
    final (c, _) = await makeContainer(seed);
    await pumpScreen(t, c, const SignInScreen());
    return c;
  }

  Finder field(String key) => find.descendant(
      of: find.byKey(Key(key)), matching: find.byType(EditableText));

  testWidgets('shows the header, form, social buttons and sign-up link',
      (t) async {
    await pump(t);
    for (final s in [
      'Welcome Back',
      'Keep me signed in',
      'Forgot Password?',
      'Log In',
      'Google',
      'Apple',
      'Or continue with'
    ]) {
      expect(find.text(s), findsOneWidget, reason: s);
    }
    expect(
        find.bySemanticsLabel('Delivery rider on a scooter'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('a bad email is flagged after leaving the field, then live',
      (t) async {
    await pump(t);
    await t.enterText(field('email'), 'dailyflutt');
    await t.pump();
    expect(find.text("That email doesn't look right"), findsNothing);
    await t.tap(field('password'));
    await t.pumpAndSettle();
    expect(find.text("That email doesn't look right"), findsOneWidget);
    await t.enterText(field('email'), 'dailyflutter@gmail.com');
    await t.pumpAndSettle();
    expect(find.text("That email doesn't look right"), findsNothing);
  });

  testWidgets('submitting empty names every problem', (t) async {
    await pump(t);
    await t.tap(find.text('Log In'));
    await t.pumpAndSettle();
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('the demo account with a wrong password says so under the field',
      (t) async {
    final c = await pump(t);
    await t.enterText(field('email'), seed.demoEmail);
    await t.enterText(field('password'), seed.wrongPassword);
    await t.tap(find.text('Log In'));
    await t.pumpAndSettle();
    expect(find.textContaining('That password is not right'), findsOneWidget);
    expect(c.read(sessionProvider), isNull);
  });

  testWidgets('a good sign in hands over to the main shell', (t) async {
    final c = await pump(t);
    await t.enterText(field('email'), seed.demoEmail);
    await t.enterText(field('password'), 'anything1');
    await t.tap(find.text('Log In'));
    await t.pumpAndSettle();
    expect(find.byType(MainShell), findsOneWidget);
    expect(c.read(sessionProvider)!.name, seed.profile.name);
  });

  testWidgets('sign up grows a name field and needs the terms', (t) async {
    await pump(t);
    await t.tapOnText(find.textRange.ofSubstring('Sign Up'));
    await t.pumpAndSettle();
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Your name'), findsOneWidget);
    await t.tap(find.text('Google'));
    await t.pump();
    expect(
        find.text('Agree to the Terms to create your account'), findsOneWidget);
    await t.pumpAndSettle(const Duration(seconds: 2));
  });

  testWidgets(
      'forgot password opens the reset sheet and confirms without revealing the account',
      (t) async {
    await pump(t);
    await t.enterText(field('email'), 'someone@x.io');
    await t.tap(find.text('Forgot Password?'));
    await t.pumpAndSettle();
    expect(find.text('Reset your password'), findsOneWidget);
    await t.tap(find.text('Send reset link'));
    await t.pumpAndSettle();
    expect(
        find.textContaining('If an account uses someone@x.io'), findsOneWidget);
  });

  testWidgets('fits a small phone at a large text size', (t) async {
    phone(t, size: const Size(360, 690));
    final (c, _) = await makeContainer(seed);
    t.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpScreen(t, c, const SignInScreen());
    expect(t.takeException(), isNull);
  });
}
