import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../services/store.dart';
import 'core_providers.dart';

/// Orders placed in the app, newest first.
class PlacedOrdersNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() {
    final raw =
        ref.watch(storeProvider).json<List<dynamic>>(Store.placedOrders) ??
            const [];
    // Stored state outlives app versions. An entry written by an older
    // build in another shape is dropped rather than crashing Home.
    return [
      for (final j in raw)
        if (_tryParse(j) case final o?) o,
    ];
  }

  static Order? _tryParse(Object? j) {
    try {
      return Order.fromJson(j! as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(Order order) async {
    final next = [order, ...state];
    state = next;
    await ref
        .read(storeProvider)
        .setJson(Store.placedOrders, [for (final o in next) o.toJson()]);
  }
}

final placedOrdersProvider =
    NotifierProvider<PlacedOrdersNotifier, List<Order>>(
        PlacedOrdersNotifier.new);

/// Orders from before (the repository's history).
final orderHistoryProvider = FutureProvider<List<Order>>(
  (ref) async => (await ref.watch(orderRepositoryProvider.future)).history(),
);

/// Every order, placed here and from history, newest first.
final ordersProvider = Provider<List<Order>>((ref) {
  final placed = ref.watch(placedOrdersProvider);
  final ids = {for (final o in placed) o.id};
  return [
    ...placed,
    for (final o
        in ref.watch(orderHistoryProvider).valueOrNull ?? const <Order>[])
      if (!ids.contains(o.id)) o,
  ]..sort((a, b) => b.placedAt.compareTo(a.placedAt));
});

final orderByIdProvider = Provider.family<Order?, String>(
  (ref, id) => ref.watch(ordersProvider).where((o) => o.id == id).firstOrNull,
);

/// Order again: each dish once, most recently ordered first. Derived from
/// the orders, so it can never disagree with them.
final orderAgainProvider = Provider<List<RecentDish>>(
  (ref) => RecentDish.from(ref.watch(ordersProvider)),
);
