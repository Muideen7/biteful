import 'dart:convert';

import 'package:flutter/services.dart';

import '../config/app_brand.dart';
import '../models/account.dart';
import '../models/catalog.dart';
import '../models/deal.dart';
import '../models/order.dart';

/// Everything bundled under assets/data/, parsed once.
///
/// Seed is read-only and edited by whoever uses the template; one JSON file
/// per entity. What the user changes (cart, saved, orders, read state) is
/// state, kept in [Store], never written back here.
class Seed {
  const Seed({
    required this.categories,
    required this.products,
    required this.restaurants,
    required this.deals,
    required this.banners,
    required this.orders,
    required this.profile,
    required this.addresses,
    required this.notifications,
    required this.demoEmail,
    required this.wrongPassword,
  });

  final List<FoodCategory> categories;
  final List<Product> products;
  final List<Restaurant> restaurants;
  final List<Deal> deals;
  final List<PromoBanner> banners;
  final List<SeedOrder> orders;
  final UserProfile profile;
  final List<Address> addresses;
  final List<AppNotification> notifications;
  final String demoEmail;

  /// Typing this password shows the wrong-password state; any other
  /// well-formed sign-in succeeds, so a demo never dead-ends.
  final String wrongPassword;

  static const files = [
    'categories',
    'products',
    'restaurants',
    'deals',
    'banners',
    'orders',
    'profile',
    'auth',
    'addresses',
    'notifications',
  ];

  /// Builds a seed from raw file contents keyed by file name (no extension).
  /// `{app}` and `{APP}` become the product name.
  factory Seed.fromSources(Map<String, String> raw) {
    dynamic read(String name) => jsonDecode(raw[name]!
        .replaceAll('{app}', AppBrand.name)
        .replaceAll('{APP}', AppBrand.name.toUpperCase()));
    List<T> list<T>(String name, T Function(Map<String, dynamic>) f) =>
        (read(name) as List).cast<Map<String, dynamic>>().map(f).toList();
    final auth = read('auth') as Map<String, dynamic>;
    return Seed(
      categories: list('categories', FoodCategory.fromJson),
      products: list('products', Product.fromJson),
      restaurants: list('restaurants', Restaurant.fromJson),
      deals: list('deals', Deal.fromJson),
      banners: list('banners', PromoBanner.fromJson),
      orders: list('orders', SeedOrder.fromJson),
      profile: UserProfile.fromJson(read('profile') as Map<String, dynamic>),
      addresses: list('addresses', Address.fromJson),
      notifications: list('notifications', AppNotification.fromJson),
      demoEmail: auth['demoEmail'] as String,
      wrongPassword: auth['wrongPassword'] as String,
    );
  }

  static Future<Seed> load([AssetBundle? bundle]) async {
    final b = bundle ?? rootBundle;
    final raw = <String, String>{};
    for (final f in files) {
      raw[f] = await b.loadString('assets/data/$f.json');
    }
    return Seed.fromSources(raw);
  }
}
