import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/deal.dart';
import '../models/order.dart';
import '../services/store.dart';
import 'core_providers.dart';

class CartNotifier extends Notifier<List<CartLine>> {
  Store get _store => ref.read(storeProvider);

  @override
  List<CartLine> build() {
    final raw =
        ref.watch(storeProvider).json<List<dynamic>>(Store.cart) ?? const [];
    return [for (final j in raw) CartLine.fromJson(j as Map<String, dynamic>)];
  }

  int qtyOf(String productId) {
    for (final l in state) {
      if (l.productId == productId) return l.qty;
    }
    return 0;
  }

  Future<void> add(String productId, [int qty = 1]) =>
      setQty(productId, qtyOf(productId) + qty);

  /// Zero or less removes the line. A line keeps its place when changed.
  Future<void> setQty(String productId, int qty) async {
    final exists = state.any((l) => l.productId == productId);
    final next = <CartLine>[
      for (final l in state)
        if (l.productId != productId) l else if (qty > 0) l.withQty(qty),
      if (!exists && qty > 0) CartLine(productId: productId, qty: qty),
    ];
    await _save(next);
  }

  Future<void> remove(String productId) => setQty(productId, 0);

  Future<void> clear() => _save(const []);

  Future<void> _save(List<CartLine> next) async {
    state = next;
    await _store.setJson(Store.cart, [for (final l in next) l.toJson()]);
  }
}

final cartProvider =
    NotifierProvider<CartNotifier, List<CartLine>>(CartNotifier.new);

/// The id of the deal applied at checkout. One at a time.
class AppliedDealNotifier extends Notifier<String?> {
  @override
  String? build() => ref.watch(storeProvider).string(Store.deal);

  Future<void> apply(String? dealId) async {
    state = dealId;
    await ref.read(storeProvider).setString(Store.deal, dealId);
  }

  Future<void> toggle(String dealId) => apply(state == dealId ? null : dealId);
}

final appliedDealProvider =
    NotifierProvider<AppliedDealNotifier, String?>(AppliedDealNotifier.new);

final appliedDealObjectProvider = Provider<Deal?>((ref) {
  final id = ref.watch(appliedDealProvider);
  final catalog = ref.watch(catalogProvider).valueOrNull;
  return id == null ? null : catalog?.dealById[id];
});

/// Derived on every read from the lines, the menu and the deal.
final cartTotalsProvider = Provider<CartTotals>((ref) {
  final catalog = ref.watch(catalogProvider).valueOrNull;
  if (catalog == null) return CartTotals.empty;
  return CartTotals.of(
    lines: ref.watch(cartProvider),
    products: catalog.productById,
    restaurants: catalog.restaurantById,
    deal: ref.watch(appliedDealObjectProvider),
  );
});

class SavedNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.watch(storeProvider).strings(Store.saved).toSet();

  Future<void> toggle(String productId) async {
    final next = {...state};
    if (!next.remove(productId)) next.add(productId);
    state = next;
    await ref.read(storeProvider).setStrings(Store.saved, next);
  }
}

final savedProvider =
    NotifierProvider<SavedNotifier, Set<String>>(SavedNotifier.new);

/// Orders placed in this app, newest first. Seeded history is not copied in
/// here: [orderAgainProvider] merges the two on read.
class PlacedOrdersNotifier extends Notifier<List<PastOrder>> {
  @override
  List<PastOrder> build() {
    final raw =
        ref.watch(storeProvider).json<List<dynamic>>(Store.placedOrders) ??
            const [];
    return [for (final j in raw) PastOrder.fromJson(j as Map<String, dynamic>)];
  }

  Future<void> record(List<PastOrder> orders) async {
    final next = [...orders, ...state];
    state = next;
    await ref
        .read(storeProvider)
        .setJson(Store.placedOrders, [for (final o in next) o.toJson()]);
  }
}

final placedOrdersProvider =
    NotifierProvider<PlacedOrdersNotifier, List<PastOrder>>(
        PlacedOrdersNotifier.new);

/// One card per dish, most recent order of it first.
final orderAgainProvider = Provider<List<PastOrder>>((ref) {
  final seed = ref.watch(seedProvider).valueOrNull;
  final all = [...ref.watch(placedOrdersProvider), ...?seed?.pastOrders];
  final seen = <String>{};
  return [
    for (final o in all)
      if (seen.add(o.productId)) o
  ];
});
