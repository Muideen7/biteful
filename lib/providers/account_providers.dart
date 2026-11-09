import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../services/store.dart';
import 'core_providers.dart';

/// Saved addresses. They come from the account repository until the person
/// edits them; from then on their own list is kept, and each change is also
/// sent to the repository.
class AddressesNotifier extends AsyncNotifier<List<Address>> {
  @override
  Future<List<Address>> build() async {
    final saved = ref.watch(storeProvider).json<List<dynamic>>(Store.addresses);
    if (saved != null) {
      return [
        for (final j in saved) Address.fromJson(j as Map<String, dynamic>)
      ];
    }
    return (await ref.watch(accountRepositoryProvider.future)).addresses();
  }

  /// Adds [a], or replaces the address with the same id.
  Future<void> save(Address a) async {
    final saved =
        await (await ref.read(accountRepositoryProvider.future)).saveAddress(a);
    final list = await future;
    final exists = list.any((x) => x.id == saved.id);
    await _set([
      for (final x in list) x.id == saved.id ? saved : x,
      if (!exists) saved,
    ]);
  }

  Future<void> remove(String id) async {
    await (await ref.read(accountRepositoryProvider.future)).deleteAddress(id);
    await _set([
      for (final x in await future)
        if (x.id != id) x
    ]);
  }

  Future<void> _set(List<Address> next) async {
    state = AsyncData(next);
    await ref
        .read(storeProvider)
        .setJson(Store.addresses, [for (final a in next) a.toJson()]);
  }
}

final addressesProvider =
    AsyncNotifierProvider<AddressesNotifier, List<Address>>(
        AddressesNotifier.new);

class SelectedAddressNotifier extends Notifier<String?> {
  @override
  String? build() => ref.watch(storeProvider).string(Store.address);

  Future<void> select(String id) async {
    state = id;
    await ref.read(storeProvider).setString(Store.address, id);
  }
}

final selectedAddressIdProvider =
    NotifierProvider<SelectedAddressNotifier, String?>(
        SelectedAddressNotifier.new);

/// The chosen address, falling back to the first one.
final currentAddressProvider = Provider<Address?>((ref) {
  final list = ref.watch(addressesProvider).valueOrNull;
  if (list == null || list.isEmpty) return null;
  final id = ref.watch(selectedAddressIdProvider);
  return list.firstWhere((a) => a.id == id, orElse: () => list.first);
});

/// The user's read and unread marks, laid over the seed's own flags. Stored
/// as `id:1` / `id:0`, so marking a seeded read item unread is remembered too.
class ReadMarksNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => {
        for (final s
            in ref.watch(storeProvider).strings(Store.readNotifications))
          s.substring(0, s.length - 2): s.endsWith(':1'),
      };

  Future<void> mark(String id, {required bool read}) =>
      _set({...state, id: read});

  Future<void> markAll(Iterable<String> ids) =>
      _set({...state, for (final id in ids) id: true});

  Future<void> _set(Map<String, bool> next) async {
    state = next;
    await ref.read(storeProvider).setStrings(
      Store.readNotifications,
      [for (final e in next.entries) '${e.key}:${e.value ? 1 : 0}'],
    );
  }
}

final readMarksProvider =
    NotifierProvider<ReadMarksNotifier, Map<String, bool>>(
        ReadMarksNotifier.new);

final notificationFeedProvider = FutureProvider<List<AppNotification>>(
  (ref) async =>
      (await ref.watch(accountRepositoryProvider.future)).notifications(),
);

final notificationsProvider = Provider<List<AppNotification>>((ref) {
  final feed = ref.watch(notificationFeedProvider).valueOrNull;
  if (feed == null) return const [];
  final marks = ref.watch(readMarksProvider);
  return [
    for (final n in feed) n.copyWith(read: marks[n.id] ?? n.read),
  ];
});

final unreadCountProvider = Provider<int>(
  (ref) => ref.watch(notificationsProvider).where((n) => !n.read).length,
);
