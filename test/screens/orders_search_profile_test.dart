import 'package:dishly/models/order.dart';
import 'package:dishly/providers/account_providers.dart';
import 'package:dishly/providers/cart_providers.dart';
import 'package:dishly/providers/search_providers.dart';
import 'package:dishly/providers/session_providers.dart';
import 'package:dishly/screens/home/home_tab.dart';
import 'package:dishly/screens/orders/order_detail_screen.dart';
import 'package:dishly/screens/orders/orders_screen.dart';
import 'package:dishly/screens/search/search_screen.dart';
import 'package:dishly/screens/shell/main_shell.dart';
import 'package:dishly/services/store.dart';
import 'package:dishly/widgets/fly_to_cart.dart';
import 'package:dishly/widgets/overscroll_fill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final seed = readSeed();
  setUpAll(quietMotion);

  Future<dynamic> shell(WidgetTester t,
      {ShellTab tab = ShellTab.home,
      DateTime? now,
      double height = 844}) async {
    phone(t, size: Size(390, height));
    final (c, _) = await makeContainer(seed, signedIn: seed.profile, now: now);
    c.read(shellTabProvider.notifier).state = tab;
    await pumpScreen(t, c, const MainShell());
    return c;
  }

  Finder inHome(Finder f) =>
      find.descendant(of: find.byType(HomeTab), matching: f);

  group('nested tab navigation', () {
    testWidgets('a restaurant opens inside Home: the nav bar and cart stay',
        (t) async {
      await shell(t, height: 3600);
      await t.tap(inHome(find.text('Umami Bar')));
      await t.pumpAndSettle();
      expect(find.text('Menu'), findsOneWidget);
      expect(find.text('Cart'), findsOneWidget);
      expect(cartTargetKey.currentContext, isNotNull);
      // Tapping Home again goes back to its first page.
      await t.tap(find.text('Home'));
      await t.pumpAndSettle();
      expect(find.text('Menu'), findsNothing);
      expect(inHome(find.text('Categories')), findsOneWidget);
    });
  });

  group('orders', () {
    testWidgets('My orders lists the live order apart from the past ones',
        (t) async {
      final c = await shell(t, tab: ShellTab.profile);
      await t.tap(find.text('My orders'));
      await t.pumpAndSettle();
      expect(find.byType(OrdersScreen), findsOneWidget);
      expect(find.text('On the way'), findsWidgets);
      expect(find.text('Past orders'), findsOneWidget);
      expect(find.text('DL-48213'), findsOneWidget);
      expect(find.text('Track'), findsOneWidget);
      expect(find.text('Reorder'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);
      expect(c.read(cartProvider), isEmpty);
    });

    testWidgets('Reorder on a past order puts all of it back in the cart',
        (t) async {
      final c = await shell(t, tab: ShellTab.profile, height: 1600);
      await t.tap(find.text('My orders'));
      await t.pumpAndSettle();
      await t.tap(find.text('Reorder').first);
      await t.pumpAndSettle();
      final lines = c.read(cartProvider);
      expect(lines.map((l) => '${l.productId}:${l.qty}'),
          ['p_cheeseburger:2', 'p_cola:2']);
    });

    for (final (minutes, status, line) in [
      (3, OrderStatus.preparing, 'The kitchen is preparing your order'),
      (12, OrderStatus.onTheWay, 'Your rider is on the way'),
      (40, OrderStatus.delivered, 'Delivered. Enjoy your meal'),
    ]) {
      testWidgets('order detail when ${status.name}', (t) async {
        phone(t, size: const Size(390, 1400));
        // The live order was placed 3 minutes before launch.
        final (c, _) = await makeContainer(seed,
            signedIn: seed.profile,
            now: testNow.add(Duration(minutes: minutes - 3)));
        await pumpScreen(t, c, const OrderDetailScreen(orderId: 'o_live'));
        expect(find.text(line), findsOneWidget);
        expect(find.text('Order placed'), findsOneWidget);
        expect(find.text('Tonkotsu Ramen'), findsOneWidget);
        expect(find.textContaining('Reorder'), findsOneWidget);
        expect(t.takeException(), isNull);
      });
    }
  });

  group('search', () {
    testWidgets('the pill on Home opens search', (t) async {
      await shell(t);
      await t.tap(find.text('Search dishes or restaurants'));
      await t.pumpAndSettle();
      expect(find.byType(SearchScreen), findsOneWidget);
      expect(find.text('Popular right now'), findsOneWidget);
    });

    testWidgets('typing finds restaurants and dishes; nothing found says so',
        (t) async {
      phone(t, size: const Size(390, 1600));
      final (c, _) = await makeContainer(seed, signedIn: seed.profile);
      await pumpScreen(t, c, const SearchScreen());
      await t.enterText(find.byKey(const Key('search-field')), 'japanese');
      await t.pumpAndSettle();
      expect(find.text('Restaurants · 1'), findsOneWidget);
      expect(find.text('Umami Bar'), findsOneWidget);
      await t.enterText(find.byKey(const Key('search-field')), 'ramen');
      await t.testTextInput.receiveAction(TextInputAction.search);
      await t.pumpAndSettle();
      expect(find.text('Tonkotsu Ramen'), findsOneWidget);
      expect(c.read(recentSearchesProvider).first, 'ramen');
      await t.enterText(find.byKey(const Key('search-field')), 'zzzz');
      await t.pumpAndSettle();
      expect(find.text('No results for "zzzz"'), findsOneWidget);
      await t.tap(find.text('Clear search'));
      await t.pumpAndSettle();
      expect(find.text('Recent searches'), findsOneWidget);
    });

    testWidgets('recent searches can be removed and cleared', (t) async {
      phone(t);
      final (c, _) = await makeContainer(seed, prefs: {
        Store.recentSearches: ['pizza', 'sushi']
      });
      await pumpScreen(t, c, const SearchScreen());
      await t.tap(find.byTooltip('Remove pizza'));
      await t.pumpAndSettle();
      expect(c.read(recentSearchesProvider), ['sushi']);
      await t.tap(find.text('Clear'));
      await t.pumpAndSettle();
      expect(c.read(recentSearchesProvider), isEmpty);
      expect(find.text('Recent searches'), findsNothing);
    });
  });

  group('profile', () {
    testWidgets('edit profile saves name and phone', (t) async {
      final c = await shell(t, tab: ShellTab.profile);
      await t.tap(find.byTooltip('Edit profile'));
      await t.pumpAndSettle();
      expect(find.text('No changes yet'), findsOneWidget);
      Finder f(String k) => find.descendant(
          of: find.byKey(Key(k)), matching: find.byType(EditableText));
      await t.enterText(f('profile-phone'), '12');
      await t.pumpAndSettle();
      await t.tap(find.text('Save changes'));
      await t.pumpAndSettle();
      expect(find.text("That number doesn't look right"), findsOneWidget);
      await t.enterText(f('profile-phone'), '+1 810 555 0199');
      await t.enterText(f('profile-name'), 'Olympicson A.');
      await t.pumpAndSettle();
      await t.tap(find.text('Save changes'));
      await t.pumpAndSettle();
      expect(c.read(sessionProvider)!.phone, '+1 810 555 0199');
      expect(find.text('Olympicson A.'), findsOneWidget);
    });

    testWidgets(
        'addresses: add one, it becomes the delivery address; remove one with undo',
        (t) async {
      final c = await shell(t, tab: ShellTab.profile, height: 1400);
      await t.tap(find.text('Addresses'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Add address'));
      await t.pumpAndSettle();
      await t.tap(find.text('Save address'));
      await t.pumpAndSettle();
      expect(find.text('Give it a name, like Home'), findsOneWidget);
      await t.tap(find.widgetWithText(ChoiceChip, 'Partner'));
      await t.enterText(
          find.descendant(
              of: find.byKey(const Key('address-line')),
              matching: find.byType(EditableText)),
          '7 Glover Road, Ikoyi');
      await t.tap(find.text('Save address'));
      await t.pumpAndSettle();
      expect(c.read(currentAddressProvider)!.label, 'Partner');
      expect(find.text('Delivering here'), findsOneWidget);
      await t.drag(find.text('Gym'), const Offset(-500, 0));
      await t.pumpAndSettle();
      expect(c.read(addressesProvider).value!.any((a) => a.label == 'Gym'),
          isFalse);
      await t.tap(find.text('Undo'));
      await t.pumpAndSettle();
      expect(c.read(addressesProvider).value!.any((a) => a.label == 'Gym'),
          isTrue);
    });
  });

  testWidgets('pulling a green-headed page down fills the gap with green',
      (t) async {
    await shell(t, tab: ShellTab.saved);
    final g = await t.startGesture(const Offset(200, 300));
    await g.moveBy(const Offset(0, 160));
    await t.pump();
    final fill = find.descendant(
        of: find.byType(OverscrollFill), matching: find.byType(CustomPaint));
    expect(fill, findsOneWidget);
    expect(t.getSize(fill).height, greaterThan(20));
    await g.up();
    await t.pumpAndSettle();
    expect(fill, findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
