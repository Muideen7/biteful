import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../services/store.dart';
import 'core_providers.dart';

final addressesProvider = FutureProvider<List<Address>>(
  (ref) async => (await ref.watch(seedProvider.future)).addresses,
);

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

final notificationsProvider = Provider<List<AppNotification>>((ref) {
  final seed = ref.watch(seedProvider).valueOrNull;
  if (seed == null) return const [];
  final marks = ref.watch(readMarksProvider);
  return [
    for (final n in seed.notifications) n.copyWith(read: marks[n.id] ?? n.read),
  ];
});

final unreadCountProvider = Provider<int>(
  (ref) => ref.watch(notificationsProvider).where((n) => !n.read).length,
);
