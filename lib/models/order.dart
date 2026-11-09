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

class OrderLine {
  const OrderLine(
      {required this.productId, required this.qty, required this.unitCents});

  final String productId;
  final int qty;

  /// The price when it was ordered, which need not be today's.
  final int unitCents;

  int get totalCents => unitCents * qty;

  factory OrderLine.fromJson(Map<String, dynamic> j) => OrderLine(
        productId: j['productId'] as String,
        qty: j['qty'] as int,
        unitCents: j['unitCents'] as int,
      );

  Map<String, dynamic> toJson() =>
      {'productId': productId, 'qty': qty, 'unitCents': unitCents};
}

enum OrderStatus { preparing, onTheWay, delivered }

/// A placed order. Its status is never stored: it is read off the clock,
/// so the list, the detail screen and Order again always agree.
class Order {
  const Order({
    required this.id,
    required this.reference,
    required this.placedAt,
    required this.lines,
    required this.deliveryCents,
    required this.discountCents,
    required this.addressLabel,
    this.dealCode,
  });

  final String id;
  final String reference;
  final DateTime placedAt;
  final List<OrderLine> lines;
  final int deliveryCents;
  final int discountCents;
  final String addressLabel;
  final String? dealCode;

  /// The kitchen's time, then the ride.
  static const prepTime = Duration(minutes: 6);
  static const rideTime = Duration(minutes: 14);

  int get itemCount => lines.fold(0, (n, l) => n + l.qty);
  int get subtotalCents => lines.fold(0, (n, l) => n + l.totalCents);
  int get totalCents => subtotalCents + deliveryCents - discountCents;

  DateTime get pickedUpAt => placedAt.add(prepTime);
  DateTime get deliveredAt => pickedUpAt.add(rideTime);

  OrderStatus statusAt(DateTime now) {
    if (now.isBefore(pickedUpAt)) return OrderStatus.preparing;
    if (now.isBefore(deliveredAt)) return OrderStatus.onTheWay;
    return OrderStatus.delivered;
  }

  bool isActiveAt(DateTime now) => statusAt(now) != OrderStatus.delivered;

  /// 0..1 from placed to delivered.
  double progressAt(DateTime now) {
    final total = deliveredAt.difference(placedAt).inSeconds;
    final done = now.difference(placedAt).inSeconds;
    return (done / total).clamp(0.0, 1.0);
  }

  /// Whole minutes until delivery, at least 1 while it is still coming.
  int minutesLeftAt(DateTime now) {
    final s = deliveredAt.difference(now).inSeconds;
    return s <= 0 ? 0 : (s / 60).ceil();
  }

  factory Order.fromJson(Map<String, dynamic> j, {DateTime? placedAt}) => Order(
        id: j['id'] as String,
        reference: j['reference'] as String,
        placedAt: placedAt ??
            DateTime.fromMillisecondsSinceEpoch(j['placedAt'] as int),
        lines: [
          for (final l in j['lines'] as List)
            OrderLine.fromJson(l as Map<String, dynamic>),
        ],
        deliveryCents: j['deliveryCents'] as int,
        discountCents: j['discountCents'] as int,
        addressLabel: j['addressLabel'] as String,
        dealCode: j['dealCode'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'placedAt': placedAt.millisecondsSinceEpoch,
        'lines': [for (final l in lines) l.toJson()],
        'deliveryCents': deliveryCents,
        'discountCents': discountCents,
        'addressLabel': addressLabel,
        if (dealCode != null) 'dealCode': dealCode,
      };
}

/// A seeded order: its age, not its date, so the seed never goes stale.
/// Stamped into a real [Order] against the first-launch time.
class SeedOrder {
  const SeedOrder(this.minutesAgo, this.json);

  final int minutesAgo;
  final Map<String, dynamic> json;

  Order stampedAt(DateTime firstLaunch) => Order.fromJson(json,
      placedAt: firstLaunch.subtract(Duration(minutes: minutesAgo)));

  factory SeedOrder.fromJson(Map<String, dynamic> j) =>
      SeedOrder(j['minutesAgo'] as int, j);
}

/// One card per dish in Order again: the dish, when it was last ordered and
/// what it cost then.
class RecentDish {
  const RecentDish(
      {required this.productId,
      required this.orderedAt,
      required this.unitCents});

  final String productId;
  final DateTime orderedAt;
  final int unitCents;

  /// Most recent order first, each dish once.
  static List<RecentDish> from(List<Order> newestFirst) {
    final seen = <String>{};
    return [
      for (final o in newestFirst)
        for (final l in o.lines)
          if (seen.add(l.productId))
            RecentDish(
                productId: l.productId,
                orderedAt: o.placedAt,
                unitCents: l.unitCents),
    ];
  }
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
