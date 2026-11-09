import 'catalog.dart';
import 'deal.dart';

class CartLine {
  const CartLine({required this.productId, required this.qty});

  final String productId;
  final int qty;

  CartLine withQty(int q) => CartLine(productId: productId, qty: q);

  factory CartLine.fromJson(Map<String, dynamic> j) =>
      CartLine(productId: j['productId'] as String, qty: j['qty'] as int);

  Map<String, dynamic> toJson() => {'productId': productId, 'qty': qty};
}

class PastOrder {
  const PastOrder({
    required this.productId,
    required this.daysAgo,
    required this.paidCents,
  });

  final String productId;
  final int daysAgo;

  /// What it cost then, which need not be today's price.
  final int paidCents;

  factory PastOrder.fromJson(Map<String, dynamic> j) => PastOrder(
        productId: j['productId'] as String,
        daysAgo: j['daysAgo'] as int,
        paidCents: j['paidCents'] as int,
      );

  Map<String, dynamic> toJson() =>
      {'productId': productId, 'daysAgo': daysAgo, 'paidCents': paidCents};
}

/// Why a deal does not apply to the current basket, if it does not.
sealed class DealCheck {
  const DealCheck();
}

class DealOk extends DealCheck {
  const DealOk();
}

class DealNeedsMore extends DealCheck {
  const DealNeedsMore(this.shortByCents);
  final int shortByCents;
}

/// Everything on the checkout summary, derived from the lines and the
/// applied deal. Nothing here is stored, so two screens can never disagree.
class CartTotals {
  const CartTotals({
    required this.itemCount,
    required this.subtotalCents,
    required this.deliveryCents,
    required this.discountCents,
    required this.dealCheck,
  });

  final int itemCount;
  final int subtotalCents;
  final int deliveryCents;
  final int discountCents;
  final DealCheck? dealCheck;

  int get totalCents => subtotalCents + deliveryCents - discountCents;
  bool get isEmpty => itemCount == 0;

  static const empty = CartTotals(
    itemCount: 0,
    subtotalCents: 0,
    deliveryCents: 0,
    discountCents: 0,
    dealCheck: null,
  );

  /// Delivery is the highest fee among the restaurants in the basket: one
  /// rider, one trip, priced by the furthest stop.
  static CartTotals of({
    required List<CartLine> lines,
    required Map<String, Product> products,
    required Map<String, Restaurant> restaurants,
    Deal? deal,
  }) {
    var count = 0;
    var subtotal = 0;
    var delivery = 0;
    for (final line in lines) {
      final p = products[line.productId];
      if (p == null || line.qty <= 0) continue;
      count += line.qty;
      subtotal += p.priceCents * line.qty;
      final fee = restaurants[p.restaurantId]?.deliveryFeeCents ?? 0;
      if (fee > delivery) delivery = fee;
    }
    if (count == 0) return empty;

    DealCheck? check;
    var discount = 0;
    if (deal != null) {
      if (subtotal < deal.minSpendCents) {
        check = DealNeedsMore(deal.minSpendCents - subtotal);
      } else {
        check = const DealOk();
        switch (deal.kind) {
          case DealKind.percent:
            discount = (subtotal * deal.value / 100).round();
          case DealKind.flat:
            discount = deal.value > subtotal ? subtotal : deal.value;
          case DealKind.freeDelivery:
            discount = delivery;
        }
      }
    }
    return CartTotals(
      itemCount: count,
      subtotalCents: subtotal,
      deliveryCents: delivery,
      discountCents: discount,
      dealCheck: check,
    );
  }
}
