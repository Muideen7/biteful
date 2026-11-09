import 'package:dishly/providers/account_providers.dart';
import 'package:dishly/providers/cart_providers.dart';
import 'package:dishly/providers/core_providers.dart';
import 'package:dishly/providers/session_providers.dart';
import 'package:dishly/services/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dishly/models/order.dart';

import '../helpers.dart';

void main() {
  final seed = readSeed();

  test('cart adds, keeps line order, removes at zero and persists', () async {
    final (c, store) = await makeContainer(seed);
    final cart = c.read(cartProvider.notifier);
    await cart.add('p_cola');
    await cart.add('p_ramen', 2);
    await cart.add('p_cola');
    expect(c.read(cartProvider).map((l) => '${l.productId}:${l.qty}'),
        ['p_cola:2', 'p_ramen:2']);
    await cart.setQty('p_cola', 0);
    expect(c.read(cartProvider).single.productId, 'p_ramen');
    expect(store.string(Store.cart), contains('p_ramen'));

    final (c2, _) = await makeContainer(seed,
        prefs: {Store.cart: store.string(Store.cart)!});
    expect(c2.read(cartProvider).single.qty, 2);
  });

  test('totals are derived from cart, menu and the applied deal', () async {
    final (c, _) = await makeContainer(seed);
    await c.read(catalogProvider.future);
    await c.read(cartProvider.notifier).add('p_cheeseburger', 2);
    await c.read(appliedDealProvider.notifier).apply('d_whole');
    final t = c.read(cartTotalsProvider);
    expect(t.subtotalCents, 1198);
    expect(t.dealCheck, isA<DealNeedsMore>());
    await c.read(cartProvider.notifier).add('p_ribeye');
    expect(c.read(cartTotalsProvider).dealCheck, isA<DealOk>());
  });

  test('deal toggles on and off', () async {
    final (c, _) = await makeContainer(seed);
    await c.read(appliedDealProvider.notifier).toggle('d_ship');
    expect(c.read(appliedDealProvider), 'd_ship');
    await c.read(appliedDealProvider.notifier).toggle('d_ship');
    expect(c.read(appliedDealProvider), isNull);
  });

  test('order again puts new orders first and shows each dish once', () async {
    final (c, _) = await makeContainer(seed);
    await c.read(seedProvider.future);
    await c.read(placedOrdersProvider.notifier).record(const [
      PastOrder(productId: 'p_ramen', daysAgo: 0, paidCents: 1250),
      PastOrder(productId: 'p_boba', daysAgo: 0, paidCents: 550),
    ]);
    final ids = c.read(orderAgainProvider).map((o) => o.productId).toList();
    expect(ids.take(2), ['p_ramen', 'p_boba']);
    expect(ids.where((i) => i == 'p_ramen').length, 1);
    expect(c.read(orderAgainProvider).first.daysAgo, 0);
  });

  test('saved toggles', () async {
    final (c, _) = await makeContainer(seed);
    await c.read(savedProvider.notifier).toggle('p_cake');
    expect(c.read(savedProvider), {'p_cake'});
    await c.read(savedProvider.notifier).toggle('p_cake');
    expect(c.read(savedProvider), isEmpty);
  });

  test('notification marks override the seed both ways and persist', () async {
    final (c, store) = await makeContainer(seed);
    await c.read(seedProvider.future);
    final unread = c.read(unreadCountProvider);
    expect(unread, seed.notifications.where((n) => !n.read).length);
    await c.read(readMarksProvider.notifier).mark('n1', read: true);
    await c.read(readMarksProvider.notifier).mark('n5', read: false);
    expect(c.read(unreadCountProvider), unread);
    final (c2, _) = await makeContainer(seed, prefs: {
      Store.readNotifications: store.strings(Store.readNotifications)
    });
    await c2.read(seedProvider.future);
    expect(c2.read(notificationsProvider).firstWhere((n) => n.id == 'n5').read,
        isFalse);
  });

  test('session is remembered only when asked', () async {
    final (c, store) = await makeContainer(seed);
    await c
        .read(sessionProvider.notifier)
        .signedIn(seed.profile, remember: false);
    expect(c.read(sessionProvider), isNotNull);
    expect(store.string(Store.session), isNull);
    await c
        .read(sessionProvider.notifier)
        .signedIn(seed.profile, remember: true);
    expect(store.string(Store.session), isNotNull);
    await c.read(sessionProvider.notifier).signOut();
    expect(store.string(Store.session), isNull);
  });

  test('address falls back to the first and follows a selection', () async {
    final (c, _) = await makeContainer(seed);
    await c.read(addressesProvider.future);
    expect(c.read(currentAddressProvider)!.id, 'a_home');
    await c.read(selectedAddressIdProvider.notifier).select('a_work');
    expect(c.read(currentAddressProvider)!.label, 'Work');
  });
}
