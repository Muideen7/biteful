import 'package:dishly/models/ids.dart';
import 'package:dishly/models/order.dart';
import 'package:dishly/models/search.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final seed = readSeed();

  group('order status is read off the clock', () {
    final placed = DateTime(2026, 11, 9, 12);
    final o = Order(
      id: 'o',
      reference: 'DL-1',
      placedAt: placed,
      lines: const [
        OrderLine(productId: 'a', qty: 2, unitCents: 500),
        OrderLine(productId: 'b', qty: 1, unitCents: 250),
      ],
      deliveryCents: 199,
      discountCents: 100,
      addressLabel: 'Home',
    );
    DateTime at(int min) => placed.add(Duration(minutes: min));

    test('totals', () {
      expect(o.itemCount, 3);
      expect(o.subtotalCents, 1250);
      expect(o.totalCents, 1250 + 199 - 100);
    });

    test('preparing, then on the way, then delivered', () {
      expect(o.statusAt(at(0)), OrderStatus.preparing);
      expect(o.statusAt(at(5)), OrderStatus.preparing);
      expect(o.statusAt(at(6)), OrderStatus.onTheWay);
      expect(o.statusAt(at(19)), OrderStatus.onTheWay);
      expect(o.statusAt(at(20)), OrderStatus.delivered);
      expect(o.isActiveAt(at(25)), isFalse);
    });

    test('progress and minutes left', () {
      expect(o.progressAt(at(0)), 0);
      expect(o.progressAt(at(10)), .5);
      expect(o.progressAt(at(40)), 1);
      expect(o.minutesLeftAt(at(0)), 20);
      expect(o.minutesLeftAt(at(19).add(const Duration(seconds: 1))), 1);
      expect(o.minutesLeftAt(at(30)), 0);
    });

    test('round-trips through JSON', () {
      final back = Order.fromJson(o.toJson());
      expect(back.placedAt, placed);
      expect(back.totalCents, o.totalCents);
      expect(back.lines.length, 2);
    });

    test('recent dishes come newest first, each once', () {
      final older = Order.fromJson({
        ...o.toJson(),
        'id': 'old',
        'placedAt': at(-100).millisecondsSinceEpoch
      });
      final d = RecentDish.from([o, older]);
      expect(d.map((x) => x.productId), ['a', 'b']);
      expect(d.first.orderedAt, placed);
    });

    test('ids never repeat', () {
      expect({for (var i = 0; i < 500; i++) Ids.next('o')}.length, 500);
    });
  });

  group('search', () {
    SearchResults run(String q) => search(
          q,
          restaurants: seed.restaurants,
          products: seed.products,
          categoryNames: {for (final c in seed.categories) c.id: c.name},
          restaurantById: {for (final r in seed.restaurants) r.id: r},
        );

    test('empty or blank finds nothing', () {
      expect(run('').isEmpty, isTrue);
      expect(run('   ').isEmpty, isTrue);
    });

    test('name matches rank above description-only matches, then by rating',
        () {
      final names = run('chick').dishes.map((d) => d.name).toList();
      final inName =
          names.where((n) => n.toLowerCase().contains('chick')).length;
      // Every dish with "chick" in its name comes before any that only
      // mention it in the description or category.
      expect(names.take(inName).every((n) => n.toLowerCase().contains('chick')),
          isTrue);
      // Herb Roast Chicken (4.7) ties on match quality with the 4.6 and 4.4
      // chicken dishes and wins on rating.
      expect(names.first, 'Herb Roast Chicken');
      expect(run('pizza').dishes.first.name, isNot('Cheesy Garlic Bread'));
      expect(run('pep').dishes.first.name, 'Pepperoni Feast');
    });

    test('matches cuisine, category and restaurant, case and punctuation aside',
        () {
      expect(run('JAPANESE').restaurants.map((r) => r.name),
          contains('Umami Bar'));
      expect(
          run('sushi').dishes.map((d) => d.name), contains('Sushi Bento Box'));
      expect(run('stack house').dishes, isNotEmpty);
      expect(run('coal & ember').restaurants.single.name, 'Coal & Ember');
    });

    test('every word must match', () {
      expect(run('salmon avocado').dishes.single.name, 'Salmon Avocado Maki');
      expect(run('salmon pizza').isEmpty, isTrue);
    });

    test('recent searches: newest first, no duplicates, capped', () {
      var r = <String>[];
      for (final q in ['ramen', 'pizza', 'Ramen', 'a', 'b', 'c', 'd', 'e']) {
        r = rememberSearch(r, q);
      }
      expect(r, ['e', 'd', 'c', 'b', 'a', 'Ramen']);
      expect(rememberSearch(r, '  '), r);
    });
  });
}
