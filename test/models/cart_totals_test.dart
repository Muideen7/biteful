import 'package:dishly/models/catalog.dart';
import 'package:dishly/models/deal.dart';
import 'package:dishly/models/order.dart';
import 'package:flutter_test/flutter_test.dart';

Product _p(String id, int price, String r) => Product(
      id: id,
      name: id,
      priceCents: price,
      calories: 1,
      minutes: 1,
      categoryId: 'c',
      restaurantId: r,
      rating: 4,
      bestSeller: false,
      fastDelivery: false,
      description: '',
      art: const FoodArt('burger'),
    );

Restaurant _r(String id, int fee) => Restaurant(
      id: id,
      name: id,
      cuisine: '',
      rating: 4,
      minMinutes: 1,
      maxMinutes: 2,
      distanceKm: 1,
      deliveryFeeCents: fee,
      art: const FoodArt('burger'),
    );

Deal _d(DealKind kind, int value, {int min = 0}) => Deal(
      id: 'd',
      code: 'CODE',
      eyebrow: '',
      headline: '',
      kind: kind,
      value: value,
      minSpendCents: min,
      art: const FoodArt('pizza'),
      terms: '',
    );

void main() {
  final products = {'a': _p('a', 1000, 'r1'), 'b': _p('b', 450, 'r2')};
  final restaurants = {'r1': _r('r1', 0), 'r2': _r('r2', 250)};
  CartTotals totals(List<CartLine> lines, [Deal? deal]) => CartTotals.of(
      lines: lines, products: products, restaurants: restaurants, deal: deal);

  const two = [
    CartLine(productId: 'a', qty: 2),
    CartLine(productId: 'b', qty: 1)
  ];

  test('an empty basket has no delivery and no total', () {
    expect(totals(const []).isEmpty, isTrue);
    expect(totals(const []).totalCents, 0);
  });

  test('subtotal sums lines and delivery is the highest fee in the basket', () {
    final t = totals(two);
    expect(t.itemCount, 3);
    expect(t.subtotalCents, 2450);
    expect(t.deliveryCents, 250);
    expect(t.totalCents, 2700);
  });

  test('a free-delivery restaurant alone costs nothing to deliver', () {
    expect(totals(const [CartLine(productId: 'a', qty: 1)]).deliveryCents, 0);
  });

  test('lines for unknown dishes or zero quantity are ignored', () {
    final t = totals(const [
      CartLine(productId: 'gone', qty: 3),
      CartLine(productId: 'a', qty: 0)
    ]);
    expect(t.isEmpty, isTrue);
  });

  test('percent deal discounts the subtotal, rounded to the cent', () {
    final t = totals(two, _d(DealKind.percent, 30));
    expect(t.discountCents, 735);
    expect(t.dealCheck, isA<DealOk>());
    expect(t.totalCents, 2450 + 250 - 735);
  });

  test('flat deal never discounts more than the subtotal', () {
    final t = totals(
        const [CartLine(productId: 'b', qty: 1)], _d(DealKind.flat, 900));
    expect(t.discountCents, 450);
  });

  test('free delivery removes exactly the delivery fee', () {
    final t = totals(two, _d(DealKind.freeDelivery, 0));
    expect(t.discountCents, 250);
    expect(t.totalCents, 2450);
  });

  test(
      'a deal under its minimum says how much more is needed and gives nothing',
      () {
    final t = totals(const [CartLine(productId: 'b', qty: 1)],
        _d(DealKind.percent, 30, min: 1500));
    expect(t.discountCents, 0);
    expect(t.dealCheck, isA<DealNeedsMore>());
    expect((t.dealCheck! as DealNeedsMore).shortByCents, 1050);
  });
}
