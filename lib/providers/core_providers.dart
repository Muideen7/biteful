import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/account_repository.dart';
import '../services/auth_repository.dart';
import '../services/catalog_repository.dart';
import '../services/order_repository.dart';
import '../services/seed.dart';
import '../services/store.dart';

// ---------------------------------------------------------------------------
// The data switchboard.
//
// Every screen gets its data from one of the four repositories below, and
// nothing else in lib/ reads the seed. To connect a real backend or database,
// write the Remote* class sketched at the bottom of each repository file
// (they reuse every model's fromJson, because the seed files already use
// the API's JSON shapes) and return it here instead of the Local/Demo one.
// No widget, provider or model changes.
// ---------------------------------------------------------------------------

/// Overridden in `main` with the loaded instance, and in tests with one
/// backed by `SharedPreferences.setMockInitialValues`.
final storeProvider = Provider<Store>(
  (_) => throw UnimplementedError('storeProvider must be overridden'),
);

/// The bundled demo data. Only the Local/Demo repositories read it.
final seedProvider = FutureProvider<Seed>((_) => Seed.load());

/// The time, as a provider, so tests can stand anywhere in an order's life.
final clockProvider = Provider<DateTime Function()>((_) => DateTime.now);

/// When the seed's relative times became dates: first launch, or the last
/// reset. Seeded orders age from here like real ones and never go stale.
class SeedStampNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final store = ref.watch(storeProvider);
    final saved = int.tryParse(store.string(Store.seedStamp) ?? '');
    if (saved != null) return DateTime.fromMillisecondsSinceEpoch(saved);
    final now = ref.read(clockProvider)();
    store.setString(Store.seedStamp, '${now.millisecondsSinceEpoch}');
    return now;
  }
}

final seedStampProvider =
    NotifierProvider<SeedStampNotifier, DateTime>(SeedStampNotifier.new);

final catalogRepositoryProvider = FutureProvider<CatalogRepository>(
  (ref) async => LocalCatalogRepository(await ref.watch(seedProvider.future)),
);

final authRepositoryProvider = FutureProvider<AuthRepository>(
  (ref) async => DemoAuthRepository(await ref.watch(seedProvider.future)),
);

final accountRepositoryProvider = FutureProvider<AccountRepository>(
  (ref) async => LocalAccountRepository(
    await ref.watch(seedProvider.future),
    ref.watch(storeProvider),
  ),
);

final orderRepositoryProvider = FutureProvider<OrderRepository>(
  (ref) async => DemoOrderRepository(
    await ref.watch(seedProvider.future),
    firstLaunch: ref.watch(seedStampProvider),
  ),
);

final catalogProvider = FutureProvider<Catalog>(
  (ref) async => (await ref.watch(catalogRepositoryProvider.future)).load(),
);
