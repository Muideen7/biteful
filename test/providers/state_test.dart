import 'dart:convert';

import 'package:dishly/providers/account_providers.dart';
import 'package:dishly/providers/cart_providers.dart';
import 'package:dishly/providers/core_providers.dart';
import 'package:dishly/providers/session_providers.dart';
import 'package:dishly/services/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dishly/models/account.dart';
import 'package:dishly/models/order.dart';
import 'package:dishly/providers/order_providers.dart';

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

  test('order again is derived from orders: newest first, each dish once',
      () async {
    final (c, _) = await makeContainer(seed);
    await c.read(orderHistoryProvider.future);
    expect(c.read(orderAgainProvider).first.productId, 'p_ramen');
    await c.read(placedOrdersProvider.notifier).add(Order(
          id: 'o_new',
          reference: 'DL-1',
          placedAt: testNow.add(const Duration(minutes: 1)),
          lines: const [
            OrderLine(productId: 'p_boba', qty: 1, unitCents: 550),
            OrderLine(productId: 'p_ramen', qty: 1, unitCents: 1250),
          ],
          deliveryCents: 0,
          discountCents: 0,
          addressLabel: 'Home',
        ));
    final ids = c.read(orderAgainProvider).map((o) => o.productId).toList();
    expect(ids.take(2), ['p_boba', 'p_ramen']);
    expect(ids.where((i) => i == 'p_ramen').length, 1);
    expect(c.read(ordersProvider).first.id, 'o_new');
  });

  test('seed orders are stamped once, at first launch, and age from there',
      () async {
    final launch = DateTime(2026, 11, 1, 9);
    final (c, store) = await makeContainer(seed, firstLaunch: launch);
    await c.read(orderHistoryProvider.future);
    final live = c.read(ordersProvider).firstWhere((o) => o.id == 'o_live');
    expect(live.placedAt, launch.subtract(const Duration(minutes: 3)));
    // Eight days later it is long delivered: nothing is re-stamped on load.
    expect(live.statusAt(testNow), OrderStatus.delivered);
    expect(store.string(Store.seedStamp), '${launch.millisecondsSinceEpoch}');
  });

  test('addresses: add, edit, remove, and they persist', () async {
    final (c, store) = await makeContainer(seed);
    final n = c.read(addressesProvider.notifier);
    final start = await c.read(addressesProvider.future);
    await n.save(const Address(
        id: 'a_new', label: 'Mum', line: '4 Bode Thomas, Surulere'));
    await n.save(start.first.copyWith(line: '1 New Street, Lekki'));
    await n.remove(start.last.id);
    final list = c.read(addressesProvider).value!;
    expect(list.map((a) => a.id), [start.first.id, start[1].id, 'a_new']);
    expect(list.first.line, '1 New Street, Lekki');
    final (c2, _) = await makeContainer(seed,
        prefs: {Store.addresses: store.string(Store.addresses)!});
    expect((await c2.read(addressesProvider.future)).last.label, 'Mum');
  });

  test('profile edits go through the account repository and are remembered',
      () async {
    final (c, store) = await makeContainer(seed, signedIn: seed.profile);
    final p = (await c.read(profileProvider.future))!;
    await c
        .read(profileProvider.notifier)
        .save(p.copyWith(phone: '+1 555 000 1111'));
    expect(c.read(profileProvider).value!.phone, '+1 555 000 1111');
    expect(store.string(Store.profile), contains('+1 555 000 1111'));
    // The session holds the identity only, never a copy of the profile.
    expect(store.string(Store.session), isNot(contains('555')));
  });

  test('an old session holding a whole profile does not leak its stale details',
      () async {
    // What builds before the split stored: the full profile, old phone included.
    final (c, _) = await makeContainer(seed, prefs: {
      Store.session: jsonEncode({
        'name': 'Olympicson',
        'email': 'hello@flutterzip.com',
        'phone': '+234 000 000 0000',
        'avatar': 'asset:people/man.png',
      }),
    });
    expect(c.read(sessionProvider), 'hello@flutterzip.com');
    final p = (await c.read(profileProvider.future))!;
    expect(p.phone, seed.profile.phone);
    expect(p.avatar, seed.profile.avatar);
  });

  test('signing in keeps saved edits and takes the email used', () async {
    final (c, _) = await makeContainer(seed, signedIn: seed.profile);
    final p = (await c.read(profileProvider.future))!;
    await c
        .read(profileProvider.notifier)
        .save(p.copyWith(phone: '+1 222 333 4444'));
    await c
        .read(profileProvider.notifier)
        .signedInAs(seed.profile.copyWith(email: 'new@x.io'), isNew: false);
    final after = c.read(profileProvider).value!;
    expect(after.email, 'new@x.io');
    expect(after.phone, '+1 222 333 4444');
    await c.read(profileProvider.notifier).signedInAs(
        seed.profile.copyWith(name: 'Ada', email: 'ada@x.io'),
        isNew: true);
    expect(c.read(profileProvider).value!.name, 'Ada');
  });

  test('reset brings back the seed, re-stamped', () async {
    final (c, store) = await makeContainer(seed);
    await c.read(placedOrdersProvider.notifier).add(Order(
        id: 'o_x',
        reference: 'DL-2',
        placedAt: testNow,
        lines: const [],
        deliveryCents: 0,
        discountCents: 0,
        addressLabel: 'Home'));
    await store.reset();
    c.invalidate(placedOrdersProvider);
    c.invalidate(seedStampProvider);
    expect(c.read(placedOrdersProvider), isEmpty);
    expect(c.read(seedStampProvider), testNow);
    expect(store.string(Store.seedStamp), isNotNull);
  });

  test('orders stored by an older version are skipped, not fatal', () async {
    final good = Order(
        id: 'o_ok',
        reference: 'DL-9',
        placedAt: testNow,
        lines: const [],
        deliveryCents: 0,
        discountCents: 0,
        addressLabel: 'Home');
    final (c, _) = await makeContainer(seed, prefs: {
      Store.placedOrders:
          '[{"productId":"p_ramen","daysAgo":0,"paidCents":1250}, ${jsonEncode(good.toJson())}]',
    });
    expect(c.read(placedOrdersProvider).map((o) => o.id), ['o_ok']);
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
    await c.read(notificationFeedProvider.future);
    final unread = c.read(unreadCountProvider);
    expect(unread, seed.notifications.where((n) => !n.read).length);
    await c.read(readMarksProvider.notifier).mark('n1', read: true);
    await c.read(readMarksProvider.notifier).mark('n5', read: false);
    expect(c.read(unreadCountProvider), unread);
    final (c2, _) = await makeContainer(seed, prefs: {
      Store.readNotifications: store.strings(Store.readNotifications)
    });
    await c2.read(notificationFeedProvider.future);
    expect(c2.read(notificationsProvider).firstWhere((n) => n.id == 'n5').read,
        isFalse);
  });

  test('session is remembered only when asked', () async {
    final (c, store) = await makeContainer(seed);
    await c
        .read(sessionProvider.notifier)
        .signedIn(seed.profile.email, remember: false);
    expect(c.read(sessionProvider), isNotNull);
    expect(store.string(Store.session), isNull);
    await c
        .read(sessionProvider.notifier)
        .signedIn(seed.profile.email, remember: true);
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
