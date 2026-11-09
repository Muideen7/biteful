// Walks Dishly through its screens on a simulator for website and store
// screenshots. At each one it prints `SHOT:<name>` and holds still, and
// tool/shots.sh captures the simulator (with its real status bar).
//   tool/shots.sh <out-dir>
import 'package:dishly/app.dart';
import 'package:dishly/providers/core_providers.dart';
import 'package:dishly/screens/home/home_tab.dart';
import 'package:dishly/services/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  Future<void> wait(WidgetTester t, int ms) async {
    final end = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(end)) {
      await t.pump(const Duration(milliseconds: 16));
    }
  }

  // Settle, announce, and hold still while the host captures.
  Future<void> shot(WidgetTester t, String name, {int settle = 1200}) async {
    await wait(t, settle);
    // ignore: avoid_print
    print('SHOT:$name');
    await wait(t, 2200);
  }

  Finder field(String k) => find.descendant(of: find.byKey(Key(k)), matching: find.byType(EditableText));

  // Home's own vertical scroll view (other tabs stay mounted beside it).
  final homeScroll = find
      .descendant(of: find.byType(HomeTab), matching: find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down))
      .first;

  Future<void> scrollTo(WidgetTester t, Finder target, {double by = 300}) =>
      t.scrollUntilVisible(target, by, scrollable: homeScroll);

  /// Puts the heading [text] at the top of Home, just under its pinned
  /// header bar, so every capture frames its section the same way.
  Future<void> bringHome(WidgetTester t, String text) async {
    // From the top every time: the heading may be above or below.
    await t.fling(homeScroll, const Offset(0, 3000), 4000, warnIfMissed: false);
    await wait(t, 900);
    await scrollTo(t, find.text(text));
    await t.pump();
    await t.ensureVisible(find.text(text));
    await wait(t, 400);
    final y = t.getTopLeft(find.text(text)).dy;
    // Just below the header bar (status bar + 64 + a little air).
    final target = MediaQuery.paddingOf(t.element(find.byType(Scaffold).first)).top + 64 + 18;
    await t.drag(homeScroll, Offset(0, target - y), warnIfMissed: false);
    await wait(t, 600);
  }

  testWidgets('screens', (t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // The seeded live order was placed three minutes before first launch;
    // stamping launch nine minutes ago puts it on the road.
    await prefs.setString(Store.seedStamp, '${DateTime.now().subtract(const Duration(minutes: 9)).millisecondsSinceEpoch}');
    await prefs.setString(Store.cart, '[{"productId":"p_cheeseburger","qty":2},{"productId":"p_latte","qty":1},{"productId":"p_ribeye","qty":1}]');
    await prefs.setString(Store.deal, 'd_whole');
    await prefs.setStringList(Store.saved, ['p_ramen', 'p_maki', 'p_cake', 'p_ribeye']);
    await prefs.setStringList(Store.recentSearches, ['ramen', 'pizza', 'Umami Bar']);
    await prefs.setString(Store.themeMode, 'light');

    await t.pumpWidget(ProviderScope(
      overrides: [storeProvider.overrideWithValue(Store(prefs))],
      child: const DishlyApp(),
    ));
    await wait(t, 5600);
    await shot(t, 'sign-in', settle: 300);

    await t.tapOnText(find.textRange.ofSubstring('Sign Up'));
    await shot(t, 'sign-up');
    await t.tapOnText(find.textRange.ofSubstring('Log In'));
    await wait(t, 600);

    await t.enterText(field('email'), 'hello@flutterzip.com');
    await t.enterText(field('password'), 'dishly123');
    FocusManager.instance.primaryFocus?.unfocus();
    await wait(t, 500);
    await t.tap(find.text('Log In'));
    await wait(t, 3200);
    await shot(t, 'home', settle: 1500);

    await bringHome(t, 'Deals for you');
    await shot(t, 'home-restaurants');

    await bringHome(t, 'Best Sellers');
    await shot(t, 'best-sellers');

    await t.tap(find.text('Pepperoni Feast').hitTestable().first);
    await shot(t, 'dish');
    await t.tap(find.text(r'Add · $11.99'));
    await wait(t, 1800); // the dish flies into the cart

    await t.tap(find.text('Home'));
    await wait(t, 400);
    await t.tap(find.text('Home'));
    await wait(t, 900);
    await bringHome(t, 'Popular restaurants near you');
    await t.tap(find.descendant(of: find.byType(HomeTab), matching: find.text('Umami Bar')));
    await shot(t, 'restaurant');
    await t.tap(find.text('Home'));
    await wait(t, 900);

    await t.fling(homeScroll, const Offset(0, 3000), 4000, warnIfMissed: false);
    await wait(t, 900);
    await t.tap(find.text('Search dishes or restaurants').hitTestable());
    await wait(t, 900);
    await t.enterText(find.byKey(const Key('search-field')), 'chicken');
    FocusManager.instance.primaryFocus?.unfocus();
    await shot(t, 'search');
    await t.tap(find.text('Home'));
    await wait(t, 900);

    await t.tap(find.byIcon(Icons.notifications_none_rounded).hitTestable());
    await shot(t, 'notifications');
    await t.tapAt(const Offset(200, 120));
    await wait(t, 700);

    await t.tap(find.text('Cart'));
    await shot(t, 'cart');

    await t.tap(find.text('Offers'));
    await shot(t, 'offers');

    await t.tap(find.text('Saved'));
    await shot(t, 'saved');

    await t.tap(find.text('Profile'));
    await shot(t, 'profile');

    await t.tap(find.text('My orders').hitTestable());
    await shot(t, 'orders');
    await t.tap(find.text('Track').hitTestable());
    await shot(t, 'order-tracking', settle: 1800);
    await t.tap(find.text('Profile'));
    await wait(t, 900);

    await t.tap(find.text('Addresses').hitTestable());
    await shot(t, 'addresses');
    await t.tap(find.text('Profile'));
    await wait(t, 900);

    await t.tap(find.text('Dark').hitTestable());
    await wait(t, 600);
    await t.tap(find.text('Home'));
    await wait(t, 600);
    await t.drag(homeScroll, const Offset(0, 3000));
    await shot(t, 'home-dark', settle: 1500);
  });
}
