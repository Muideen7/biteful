import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_repository.dart';
import '../services/catalog_repository.dart';
import '../services/order_repository.dart';
import '../services/seed.dart';
import '../services/store.dart';

/// Overridden in `main` with the loaded instance, and in tests with one
/// backed by `SharedPreferences.setMockInitialValues`.
final storeProvider = Provider<Store>(
  (_) => throw UnimplementedError('storeProvider must be overridden'),
);

final seedProvider = FutureProvider<Seed>((_) => Seed.load());

final catalogRepositoryProvider = FutureProvider<CatalogRepository>(
  (ref) async => LocalCatalogRepository(await ref.watch(seedProvider.future)),
);

final authRepositoryProvider = FutureProvider<AuthRepository>(
  (ref) async => DemoAuthRepository(await ref.watch(seedProvider.future)),
);

final orderRepositoryProvider = Provider<OrderRepository>(
  (_) => DemoOrderRepository(),
);

final catalogProvider = FutureProvider<Catalog>(
  (ref) async => (await ref.watch(catalogRepositoryProvider.future)).load(),
);
