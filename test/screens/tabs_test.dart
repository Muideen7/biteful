import 'package:dishly/providers/cart_providers.dart';
import 'package:dishly/providers/session_providers.dart';
import 'package:dishly/screens/auth/sign_in_screen.dart';
import 'package:dishly/screens/shell/main_shell.dart';
import 'package:dishly/services/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final seed = readSeed();
  setUpAll(quietMotion);

  Future<dynamic> pump(WidgetTester t, ShellTab tab,
      {Map<String, Object> prefs = const {}}) async {
    phone(t);
    final (c, _) =
        await makeContainer(seed, signedIn: seed.profile, prefs: prefs);
    c.read(shellTabProvider.notifier).state = tab;
    await pumpScreen(t, c, const MainShell());
    return c;
  }

  testWidgets('an empty cart says so and leads back to Home', (t) async {
    final c = await pump(t, ShellTab.cart);
    expect(find.text('Your cart is empty'), findsOneWidget);
    await t.tap(find.text('Browse dishes'));
    await t.pumpAndSettle();
    expect(c.read(shellTabProvider), ShellTab.home);
  });

  testWidgets('cart shows lines, a deal short of its minimum, and totals',
      (t) async {
    await pump(t, ShellTab.cart, prefs: {
      Store.cart: '[{"productId":"p_cheeseburger","qty":1}]',
      Store.deal: 'd_whole',
    });
    expect(find.text('TREAT30 applied'), findsOneWidget);
    expect(find.text(r'Add $9.01 more to use it'), findsOneWidget);
    expect(find.text(r'Checkout · $5.99'), findsOneWidget);
    final button = t.getRect(find.text(r'Checkout · $5.99'));
    expect(button.bottom, lessThan(844 - 64));
  });

  testWidgets('stepper and swipe change the cart, with undo', (t) async {
    final c = await pump(t, ShellTab.cart, prefs: {
      Store.cart:
          '[{"productId":"p_cola","qty":1},{"productId":"p_ramen","qty":1}]',
    });
    await t.tap(find.bySemanticsLabel('Increase').first);
    await t.pumpAndSettle();
    expect(c.read(cartProvider).first.qty, 2);
    await t.drag(find.text('Tonkotsu Ramen'), const Offset(-500, 0));
    await t.pumpAndSettle();
    expect(c.read(cartProvider).length, 1);
    await t.tap(find.text('Undo'));
    await t.pumpAndSettle();
    expect(c.read(cartProvider).length, 2);
  });

  testWidgets(
      'checkout places the order, empties the cart and joins Order again',
      (t) async {
    final c = await pump(t, ShellTab.cart, prefs: {
      Store.cart: '[{"productId":"p_boba","qty":2}]',
    });
    await t.tap(find.text(r'Checkout · $11.00'));
    await t.pumpAndSettle();
    expect(find.text('Order placed'), findsOneWidget);
    expect(c.read(cartProvider), isEmpty);
    expect(c.read(orderAgainProvider).first.productId, 'p_boba');
    await t.tap(find.text('Done'));
    await t.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);
  });

  testWidgets('saved is empty, then lists a saved dish', (t) async {
    await pump(t, ShellTab.saved);
    expect(find.text('Nothing saved yet'), findsOneWidget);
    await pump(t, ShellTab.saved, prefs: {
      Store.saved: ['p_cake']
    });
    expect(find.text('Strawberry Shortcake'), findsOneWidget);
  });

  testWidgets('offers lists every deal with its terms', (t) async {
    await pump(t, ShellTab.offers);
    for (final d in seed.deals.take(3)) {
      expect(find.text(d.code), findsOneWidget);
    }
    expect(find.text(seed.deals.first.terms), findsOneWidget);
  });

  testWidgets('profile shows the person and signs out to the sign-in screen',
      (t) async {
    final c = await pump(t, ShellTab.profile);
    expect(find.text(seed.profile.name), findsOneWidget);
    await t.scrollUntilVisible(find.text('Sign out'), 200);
    await t.tap(find.text('Sign out'));
    await t.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(c.read(sessionProvider), isNull);
  });

  testWidgets('reset demo data clears state and returns to sign in', (t) async {
    final c = await pump(t, ShellTab.profile, prefs: {
      Store.saved: ['p_cake'],
      Store.cart: '[{"productId":"p_cola","qty":1}]'
    });
    await t.scrollUntilVisible(find.text('Reset demo data'), 200);
    await t.tap(find.text('Reset demo data'));
    await t.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(c.read(savedProvider), isEmpty);
    expect(c.read(cartProvider), isEmpty);
  });

  testWidgets('theme can be switched to dark', (t) async {
    final c = await pump(t, ShellTab.profile);
    await t.tap(find.text('Dark'));
    await t.pumpAndSettle();
    expect(c.read(themeModeProvider), ThemeMode.dark);
  });
}
