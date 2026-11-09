import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/home/sections/category_strip.dart';
import 'account_providers.dart';
import 'cart_providers.dart';
import 'core_providers.dart';
import 'order_providers.dart';
import 'search_providers.dart';
import 'session_providers.dart';

/// Back to a first launch: every piece of stored state goes, and the seed
/// shows through again, re-stamped to now. Kept next to the providers so a
/// new piece of state is added here in the same change.
Future<void> resetDemoData(WidgetRef ref) async {
  await ref.read(storeProvider).reset();
  for (final p in <ProviderOrFamily>[
    sessionProvider,
    profileProvider,
    cartProvider,
    savedProvider,
    appliedDealProvider,
    placedOrdersProvider,
    seedStampProvider,
    addressesProvider,
    selectedAddressIdProvider,
    readMarksProvider,
    recentSearchesProvider,
    themeModeProvider,
    selectedCategoryProvider,
  ]) {
    ref.invalidate(p);
  }
}
