import 'dart:io';

import 'package:dishly/config/app_brand.dart';
import 'package:dishly/models/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final seed = readSeed();

  test('every seed file parses', () {
    expect(seed.products, isNotEmpty);
    expect(seed.categories, isNotEmpty);
    expect(seed.restaurants, isNotEmpty);
    expect(seed.deals, isNotEmpty);
    expect(seed.banners, isNotEmpty);
  });

  test('ids are unique', () {
    for (final ids in [
      seed.products.map((p) => p.id),
      seed.categories.map((c) => c.id),
      seed.restaurants.map((r) => r.id),
      seed.deals.map((d) => d.id),
      seed.notifications.map((n) => n.id),
    ]) {
      expect(ids.toSet().length, ids.length);
    }
  });

  test('every reference points at something that exists', () {
    final cats = seed.categories.map((c) => c.id).toSet();
    final rests = seed.restaurants.map((r) => r.id).toSet();
    final prods = seed.products.map((p) => p.id).toSet();
    final deals = seed.deals.map((d) => d.id).toSet();
    for (final p in seed.products) {
      expect(cats, contains(p.categoryId), reason: p.id);
      expect(rests, contains(p.restaurantId), reason: p.id);
    }
    for (final o in seed.pastOrders) {
      expect(prods, contains(o.productId));
    }
    for (final b in seed.banners) {
      if (b.dealId != null) expect(deals, contains(b.dealId));
      if (b.restaurantId != null) expect(rests, contains(b.restaurantId));
    }
  });

  test('every piece of food art is a bundled file', () {
    final arts = <FoodArt>[
      ...seed.products.map((p) => p.art),
      ...seed.categories.map((c) => c.art),
      ...seed.restaurants.map((r) => r.art),
      ...seed.deals.map((d) => d.art),
      for (final b in seed.banners)
        if (b.art != null) b.art!,
    ];
    for (final a in arts) {
      for (final name in [a.main, if (a.side != null) a.side!]) {
        expect(File(FoodArt.path(name)).existsSync(), isTrue, reason: name);
      }
    }
    expect(File(seed.profile.avatarAsset!).existsSync(), isTrue);
  });

  test('the product name placeholder is substituted', () {
    expect(seed.banners.any((b) => b.lineOne.contains(AppBrand.name)), isTrue);
    for (final f in seed.notifications) {
      expect(f.body, isNot(contains('{app}')));
    }
  });

  test(
      'every state is reachable: a category with nothing in it, read and unread notifications',
      () {
    final used = seed.products.map((p) => p.categoryId).toSet();
    expect(seed.categories.any((c) => !used.contains(c.id)), isTrue);
    expect(seed.notifications.any((n) => n.read), isTrue);
    expect(seed.notifications.any((n) => !n.read), isTrue);
    expect(seed.deals.any((d) => d.minSpendCents > 0), isTrue);
  });

  test('seed copy has no em dashes', () {
    for (final f in Directory('assets/data').listSync().whereType<File>()) {
      expect(f.readAsStringSync(), isNot(contains('—')), reason: f.path);
    }
  });
}
