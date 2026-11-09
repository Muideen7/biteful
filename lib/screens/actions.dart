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
import 'routes.dart';

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
    Navigator.of(context).push(riseRoute(RestaurantScreen(restaurantId: r.id)));

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

/// The past order's dish goes back in the cart.
Future<void> reorder(BuildContext context, WidgetRef ref, PastOrder o,
    {GlobalKey? from}) async {
  final p = (await ref.read(catalogProvider.future)).productById[o.productId];
  if (p != null && context.mounted) {
    await addToCart(context, ref, p, from: from);
  }
}
