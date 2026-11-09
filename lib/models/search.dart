import 'catalog.dart';

/// Results for one query: restaurants and dishes, best match first.
class SearchResults {
  const SearchResults({required this.restaurants, required this.dishes});

  final List<Restaurant> restaurants;
  final List<Product> dishes;

  bool get isEmpty => restaurants.isEmpty && dishes.isEmpty;

  static const none = SearchResults(restaurants: [], dishes: []);
}

/// Every word typed must appear somewhere in the item. Among the matches, a
/// name that starts with the query beats one that merely contains it, which
/// beats a match only in the cuisine, category or description. Ties keep
/// the better-rated item first.
SearchResults search(
  String query, {
  required List<Restaurant> restaurants,
  required List<Product> products,
  required Map<String, String> categoryNames,
  required Map<String, Restaurant> restaurantById,
}) {
  final q = _norm(query);
  if (q.isEmpty) return SearchResults.none;
  final words = q.split(' ');

  int? score(String name, List<String> other) {
    final n = _norm(name);
    final hay = '$n ${other.map(_norm).join(' ')}';
    if (!words.every(hay.contains)) return null;
    if (n.startsWith(q)) return 0;
    if (n.split(' ').any((w) => w.startsWith(q))) return 1;
    if (n.contains(q)) return 2;
    return 3;
  }

  List<(T, int)> ranked<T>(
      Iterable<T> items, int? Function(T) s, double Function(T) rating) {
    final hits = [
      for (final i in items)
        if (s(i) case final sc?) (i, sc),
    ]..sort((a, b) => a.$2 != b.$2
        ? a.$2.compareTo(b.$2)
        : rating(b.$1).compareTo(rating(a.$1)));
    return hits;
  }

  final r = ranked<Restaurant>(
    restaurants,
    (x) => score(x.name, [x.cuisine]),
    (x) => x.rating,
  );
  final d = ranked<Product>(
    products,
    (x) => score(x.name, [
      categoryNames[x.categoryId] ?? '',
      restaurantById[x.restaurantId]?.name ?? '',
      x.description,
    ]),
    (x) => x.rating,
  );
  return SearchResults(
    restaurants: [for (final (x, _) in r) x],
    dishes: [for (final (x, _) in d) x],
  );
}

String _norm(String s) => s
    .toLowerCase()
    .replaceAll('&', ' and ')
    .replaceAll(RegExp(r"[^a-z0-9 ]"), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// The recent searches list: newest first, no duplicates, at most [max].
List<String> rememberSearch(List<String> recent, String query, {int max = 6}) {
  final q = query.trim();
  if (q.isEmpty) return recent;
  return [q, ...recent.where((r) => r.toLowerCase() != q.toLowerCase())]
      .take(max)
      .toList();
}
