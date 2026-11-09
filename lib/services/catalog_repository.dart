import '../models/catalog.dart';
import '../models/deal.dart';
import 'seed.dart';

/// The menu side of the app, with lookups built once.
class Catalog {
  Catalog({
    required this.categories,
    required this.products,
    required this.restaurants,
    required this.deals,
    required this.banners,
  })  : productById = {for (final p in products) p.id: p},
        restaurantById = {for (final r in restaurants) r.id: r},
        dealById = {for (final d in deals) d.id: d};

  final List<FoodCategory> categories;
  final List<Product> products;
  final List<Restaurant> restaurants;
  final List<Deal> deals;
  final List<PromoBanner> banners;

  final Map<String, Product> productById;
  final Map<String, Restaurant> restaurantById;
  final Map<String, Deal> dealById;

  List<Product> get bestSellers => [
        for (final p in products)
          if (p.bestSeller) p
      ];
  List<Product> get fastDelivery => [
        for (final p in products)
          if (p.fastDelivery) p
      ];

  List<Product> inCategory(String id) => [
        for (final p in products)
          if (p.categoryId == id) p
      ];

  List<Product> menuOf(String restaurantId) => [
        for (final p in products)
          if (p.restaurantId == restaurantId) p
      ];

  /// Restaurants by rating, best first: "popular near you".
  List<Restaurant> get popular =>
      [...restaurants]..sort((a, b) => b.rating.compareTo(a.rating));
}

abstract interface class CatalogRepository {
  Future<Catalog> load();
}

class LocalCatalogRepository implements CatalogRepository {
  LocalCatalogRepository(this._seed);

  final Seed _seed;

  @override
  Future<Catalog> load() async => Catalog(
        categories: _seed.categories,
        products: _seed.products,
        restaurants: _seed.restaurants,
        deals: _seed.deals,
        banners: _seed.banners,
      );
}

// class RemoteCatalogRepository implements CatalogRepository {
//   RemoteCatalogRepository(this._dio);
//   final Dio _dio;
//
//   @override
//   Future<Catalog> load() async {
//     final r = await _dio.get('/catalog');
//     return Catalog(
//       categories: [for (final j in r.data['categories']) FoodCategory.fromJson(j)],
//       products: [for (final j in r.data['products']) Product.fromJson(j)],
//       restaurants: [for (final j in r.data['restaurants']) Restaurant.fromJson(j)],
//       deals: [for (final j in r.data['deals']) Deal.fromJson(j)],
//       banners: [for (final j in r.data['banners']) PromoBanner.fromJson(j)],
//     );
//   }
// }
