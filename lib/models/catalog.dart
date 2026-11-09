/// A 3D food render, optionally with a smaller one tucked in front of it
/// (a burger with a cheese wedge, a pizza slice with a chilli). Names refer
/// to files in assets/images/food/.
class FoodArt {
  const FoodArt(this.main, [this.side]);

  final String main;
  final String? side;

  factory FoodArt.fromJson(Map<String, dynamic> j) =>
      FoodArt(j['main'] as String, j['side'] as String?);

  Map<String, dynamic> toJson() =>
      {'main': main, if (side != null) 'side': side};

  static String path(String name) => 'assets/images/food/$name.png';
}

class FoodCategory {
  const FoodCategory({required this.id, required this.name, required this.art});

  final String id;
  final String name;
  final FoodArt art;

  factory FoodCategory.fromJson(Map<String, dynamic> j) => FoodCategory(
        id: j['id'] as String,
        name: j['name'] as String,
        art: FoodArt.fromJson(j['art'] as Map<String, dynamic>),
      );
}

class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.minMinutes,
    required this.maxMinutes,
    required this.distanceKm,
    required this.deliveryFeeCents,
    required this.art,
  });

  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final int minMinutes;
  final int maxMinutes;
  final double distanceKm;
  final int deliveryFeeCents;
  final FoodArt art;

  bool get freeDelivery => deliveryFeeCents == 0;
  String get eta => '$minMinutes-$maxMinutes min';
  String get distance => '${distanceKm.toStringAsFixed(1)} km';

  factory Restaurant.fromJson(Map<String, dynamic> j) => Restaurant(
        id: j['id'] as String,
        name: j['name'] as String,
        cuisine: j['cuisine'] as String,
        rating: (j['rating'] as num).toDouble(),
        minMinutes: j['minMinutes'] as int,
        maxMinutes: j['maxMinutes'] as int,
        distanceKm: (j['distanceKm'] as num).toDouble(),
        deliveryFeeCents: j['deliveryFeeCents'] as int,
        art: FoodArt.fromJson(j['art'] as Map<String, dynamic>),
      );
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.priceCents,
    required this.calories,
    required this.minutes,
    required this.categoryId,
    required this.restaurantId,
    required this.rating,
    required this.bestSeller,
    required this.fastDelivery,
    required this.description,
    required this.art,
  });

  final String id;
  final String name;
  final int priceCents;
  final int calories;
  final int minutes;
  final String categoryId;
  final String restaurantId;
  final double rating;
  final bool bestSeller;
  final bool fastDelivery;
  final String description;
  final FoodArt art;

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        name: j['name'] as String,
        priceCents: j['priceCents'] as int,
        calories: j['calories'] as int,
        minutes: j['minutes'] as int,
        categoryId: j['categoryId'] as String,
        restaurantId: j['restaurantId'] as String,
        rating: (j['rating'] as num).toDouble(),
        bestSeller: j['bestSeller'] as bool? ?? false,
        fastDelivery: j['fastDelivery'] as bool? ?? false,
        description: j['description'] as String? ?? '',
        art: FoodArt.fromJson(j['art'] as Map<String, dynamic>),
      );
}

/// A promo banner at the top of Home. It either applies a deal or opens a
/// restaurant when tapped.
class PromoBanner {
  const PromoBanner({
    required this.id,
    required this.style,
    required this.lineOne,
    required this.lineTwo,
    required this.subtitle,
    required this.cta,
    this.dealId,
    this.restaurantId,
    this.art,
  });

  final String id;

  /// `rider` draws the delivery rider; `art` shows [art].
  final String style;
  final String lineOne;
  final String lineTwo;
  final String subtitle;
  final String cta;
  final String? dealId;
  final String? restaurantId;
  final FoodArt? art;

  bool get showsRider => style == 'rider';

  factory PromoBanner.fromJson(Map<String, dynamic> j) => PromoBanner(
        id: j['id'] as String,
        style: j['style'] as String,
        lineOne: j['lineOne'] as String,
        lineTwo: j['lineTwo'] as String,
        subtitle: j['subtitle'] as String,
        cta: j['cta'] as String,
        dealId: j['dealId'] as String?,
        restaurantId: j['restaurantId'] as String?,
        art: j['art'] == null
            ? null
            : FoodArt.fromJson(j['art'] as Map<String, dynamic>),
      );
}
