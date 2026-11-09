import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/search.dart';
import '../services/store.dart';
import 'core_providers.dart';

/// What was searched before, newest first. Removable one by one or all.
class RecentSearchesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() =>
      ref.watch(storeProvider).strings(Store.recentSearches);

  Future<void> remember(String query) => _set(rememberSearch(state, query));
  Future<void> remove(String query) => _set([...state]..remove(query));
  Future<void> clear() => _set(const []);

  Future<void> _set(List<String> next) async {
    state = next;
    await ref.read(storeProvider).setStrings(Store.recentSearches, next);
  }
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesNotifier, List<String>>(
        RecentSearchesNotifier.new);

final searchResultsProvider =
    Provider.family<SearchResults, String>((ref, query) {
  final c = ref.watch(catalogProvider).valueOrNull;
  if (c == null) return SearchResults.none;
  return search(
    query,
    restaurants: c.restaurants,
    products: c.products,
    categoryNames: {for (final cat in c.categories) cat.id: cat.name},
    restaurantById: c.restaurantById,
  );
});
