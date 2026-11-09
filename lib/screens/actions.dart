import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/catalog.dart';
import '../models/deal.dart';
import '../models/money.dart';
import '../models/order.dart';
import '../providers/cart_providers.dart';
import '../providers/core_providers.dart';
import '../config/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/fly_to_cart.dart';
import 'product/product_sheet.dart';
import 'restaurant/restaurant_screen.dart';
import 'orders/order_detail_screen.dart';
import 'orders/orders_screen.dart';
import 'routes.dart';
import 'search/search_screen.dart';
import 'shell/main_shell.dart';
import '../config/motion.dart';

/// The things many screens do, done one way.

/// Flies the dish from [from] (its image) into the Cart tab, then adds it
/// as it lands, so the badge ticks up on arrival.
Future<void> addToCart(
  BuildContext context,
  WidgetRef ref,
  Product p, {
  int qty = 1,
  GlobalKey? from,
}) async {
  HapticFeedback.selectionClick();
  // The toast goes to the app's messenger: the sheet a flight starts from
  // may already be closed when it lands.
  final messenger = ScaffoldMessenger.maybeOf(context);
  final palette = context.palette;
  final cart = ref.read(cartProvider.notifier);
  if (from != null) await flyToCart(context, from, p.art);
  await cart.add(p.id, qty);
  if (messenger != null) {
    showToastOn(
      messenger,
      palette,
      qty == 1
          ? '${p.name} added to your cart'
          : '$qty x ${p.name} added to your cart',
    );
  }
}

void openProduct(BuildContext context, Product p) =>
    showProductSheet(context, p);

void openRestaurant(BuildContext context, Restaurant r) =>
    tabNavigator(context).push(riseRoute(RestaurantScreen(restaurantId: r.id)));

/// Pages open inside the tab on screen, so the navigation bar stays.
void openOrders(BuildContext context) =>
    tabNavigator(context).push(riseRoute(const OrdersScreen()));

void openOrder(BuildContext context, String orderId) =>
    tabNavigator(context).push(riseRoute(OrderDetailScreen(orderId: orderId)));

void openSearch(BuildContext context) => tabNavigator(context)
    .push(fadeRoute(const SearchScreen(), duration: Motion.medium));

/// Applies [deal], or removes it if it is already applied, and says what
/// happened, including how much more the basket needs.
Future<void> toggleDeal(BuildContext context, WidgetRef ref, Deal deal) async {
  HapticFeedback.selectionClick();
  final wasApplied = ref.read(appliedDealProvider) == deal.id;
  await ref.read(appliedDealProvider.notifier).toggle(deal.id);
  if (!context.mounted) return;
  if (wasApplied) {
    showToast(context, '${deal.code} removed',
        icon: Icons.remove_circle_outline_rounded);
    return;
  }
  final check = ref.read(cartTotalsProvider).dealCheck;
  showToast(
    context,
    switch (check) {
      DealNeedsMore(:final shortByCents) =>
        '${deal.code} applied. Add ${money(shortByCents)} more to use it',
      _ => '${deal.code} applied to your order',
    },
  );
}

/// A dish from Order again goes back in the cart.
Future<void> reorderDish(BuildContext context, WidgetRef ref, RecentDish d,
    {GlobalKey? from}) async {
  final p = (await ref.read(catalogProvider.future)).productById[d.productId];
  if (p != null && context.mounted) {
    await addToCart(context, ref, p, from: from);
  }
}

/// Every line of a past order goes back in the cart, at today's prices.
Future<void> reorderAll(BuildContext context, WidgetRef ref, Order o,
    {GlobalKey? from}) async {
  final catalog = await ref.read(catalogProvider.future);
  final lines = [
    for (final l in o.lines)
      if (catalog.productById[l.productId] != null) l
  ];
  if (lines.isEmpty || !context.mounted) return;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final palette = context.palette;
  final first = catalog.productById[lines.first.productId]!;
  if (from != null) await flyToCart(context, from, first.art);
  final cart = ref.read(cartProvider.notifier);
  for (final l in lines) {
    await cart.add(l.productId, l.qty);
  }
  if (messenger != null) {
    final n = lines.fold(0, (s, l) => s + l.qty);
    showToastOn(messenger, palette,
        '$n ${n == 1 ? 'item' : 'items'} from ${o.reference} added to your cart');
  }
}
