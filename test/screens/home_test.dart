import 'package:dishly/providers/cart_providers.dart';
import 'package:dishly/screens/home/home_tab.dart';
import 'package:dishly/screens/shell/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final seed = readSeed();
  setUpAll(quietMotion);

  // Tall enough that every lazy sliver on Home is built.
  Future<dynamic> pump(WidgetTester t, {double height = 844}) async {
    phone(t, size: Size(390, height));
    final (c, _) = await makeContainer(seed, signedIn: seed.profile);
    await pumpScreen(t, c, const MainShell());
    return c;
  }

  // The other tabs stay mounted in the IndexedStack; look only at Home.
  Finder home(Finder f) =>
      find.descendant(of: find.byType(HomeTab), matching: f);

  testWidgets('sections appear in the reference order', (t) async {
    await pump(t, height: 3600);
    const order = [
      'Categories',
      'Order again',
      'Deals for you',
      'Popular restaurants near you',
      'Fast delivery · 15 min or less',
      'Best Sellers',
    ];
    final ys = [
      for (final title in order) t.getTopLeft(home(find.text(title))).dy
    ];
    expect(ys, orderedEquals([...ys]..sort()));
    expect(t.takeException(), isNull);
  });

  testWidgets('header shows the address and opens the address sheet',
      (t) async {
    await pump(t);
    expect(find.text('Deliver to'), findsOneWidget);
    await t.tap(find.text('Deliver to'));
    await t.pumpAndSettle();
    await t.tap(find.text('Work'));
    await t.pumpAndSettle();
    expect(find.textContaining('Adeola Odeku'), findsOneWidget);
  });

  testWidgets('the bell opens notifications and opening one marks it read',
      (t) async {
    await pump(t);
    await t.tap(find.byIcon(Icons.notifications_none_rounded));
    await t.pumpAndSettle();
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Mark all read'), findsOneWidget);
    await t.tap(find.text('Mark all read'));
    await t.pumpAndSettle();
    expect(find.text('Mark all read'), findsNothing);
  });

  testWidgets('a category filters the grid and an empty one says so',
      (t) async {
    await pump(t, height: 3600);
    await t.tap(home(find.text('Pizza')).first);
    await t.pumpAndSettle();
    expect(home(find.text('Pepperoni Feast')), findsWidgets);
    expect(home(find.text('Best Sellers')), findsNothing);
    await t.drag(home(find.text('Burger')).first, const Offset(-600, 0));
    await t.pumpAndSettle();
    await t.tap(home(find.text('Salads')));
    await t.pumpAndSettle();
    expect(home(find.text('No salads near you right now')), findsOneWidget);
    await t.tap(home(find.text('Show best sellers')));
    await t.pumpAndSettle();
    expect(home(find.text('Best Sellers')), findsOneWidget);
  });

  testWidgets('plus adds to the cart and the nav badge counts it', (t) async {
    final c = await pump(t, height: 3600);
    await t.tap(find.bySemanticsLabel('Add Cheesy Garlic Bread to cart').first);
    await t.pumpAndSettle();
    expect(c.read(cartProvider).single.productId, 'p_garlicbread');
    expect(find.text('1'), findsWidgets);
    expect(find.text('Cheesy Garlic Bread added to your cart'), findsOneWidget);
  });

  testWidgets('apply on a deal card applies it and shows Applied', (t) async {
    final c = await pump(t, height: 3600);
    await t.tap(home(find.text('Apply')).first);
    await t.pumpAndSettle();
    expect(c.read(appliedDealProvider), 'd_whole');
    expect(home(find.text('Applied')), findsOneWidget);
    await t.tap(home(find.text('Applied')));
    await t.pumpAndSettle();
    expect(c.read(appliedDealProvider), isNull);
  });

  testWidgets('reorder puts the past dish back in the cart', (t) async {
    final c = await pump(t);
    // The live order's ramen is the most recent dish.
    await t.tap(find.bySemanticsLabel('Order Tonkotsu Ramen again'));
    await t.pumpAndSettle();
    expect(c.read(cartProvider).single.productId, 'p_ramen');
  });

  testWidgets(
      'a dish opens its sheet; Add puts the chosen quantity in the cart',
      (t) async {
    final c = await pump(t, height: 3600);
    await t.tap(home(find.text('Cheese Burger')).last);
    await t.pumpAndSettle();
    expect(find.text('from Stack House'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Increase'));
    await t.pumpAndSettle();
    await t.tap(find.text(r'Add · $11.98'));
    await t.pumpAndSettle();
    expect(c.read(cartProvider).single.qty, 2);
  });

  testWidgets('a restaurant card opens its menu', (t) async {
    await pump(t, height: 3600);
    await t.tap(home(find.text('Umami Bar')));
    await t.pumpAndSettle();
    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Sushi Bento Box'), findsOneWidget);
  });

  testWidgets('renders in dark mode without errors', (t) async {
    phone(t);
    final (c, _) = await makeContainer(seed, signedIn: seed.profile);
    await pumpScreen(t, c, const MainShell(), mode: ThemeMode.dark);
    expect(t.takeException(), isNull);
  });
}
