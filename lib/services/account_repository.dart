import '../models/account.dart';
import 'seed.dart';
import 'store.dart';

/// The signed-in person's side of the app: their profile, saved addresses
/// and notifications. Async throughout, so a backend drops in without
/// touching a widget.
abstract interface class AccountRepository {
  Future<UserProfile> profile();
  Future<UserProfile> updateProfile(UserProfile profile);

  Future<List<Address>> addresses();
  Future<Address> saveAddress(Address address);
  Future<void> deleteAddress(String id);

  Future<List<AppNotification>> notifications();
}

/// The account on this device: the seed's person until they edit their
/// details, then their own saved copy. Address edits are kept by
/// `AddressesNotifier`, so those methods only hand them back.
class LocalAccountRepository implements AccountRepository {
  LocalAccountRepository(this._seed, this._store);

  final Seed _seed;
  final Store _store;

  @override
  Future<UserProfile> profile() async {
    final saved = _store.json<Map<String, dynamic>>(Store.profile);
    return saved == null ? _seed.profile : UserProfile.fromJson(saved);
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    await _store.setJson(Store.profile, profile.toJson());
    return profile;
  }

  @override
  Future<List<Address>> addresses() async => _seed.addresses;

  @override
  Future<Address> saveAddress(Address address) async => address;

  @override
  Future<void> deleteAddress(String id) async {}

  @override
  Future<List<AppNotification>> notifications() async => _seed.notifications;
}

// A network implementation. The JSON shapes match the seed files, so every
// model's fromJson is reused as it is: nothing else in the app changes.
//
// class RemoteAccountRepository implements AccountRepository {
//   RemoteAccountRepository(this._dio);
//   final Dio _dio;
//
//   @override
//   Future<UserProfile> profile() async =>
//       UserProfile.fromJson((await _dio.get('/me')).data);
//
//   @override
//   Future<UserProfile> updateProfile(UserProfile p) async =>
//       UserProfile.fromJson((await _dio.patch('/me', data: p.toJson())).data);
//
//   @override
//   Future<List<Address>> addresses() async =>
//       [for (final j in (await _dio.get('/me/addresses')).data) Address.fromJson(j)];
//
//   @override
//   Future<Address> saveAddress(Address a) async =>
//       Address.fromJson((await _dio.put('/me/addresses/${a.id}', data: a.toJson())).data);
//
//   @override
//   Future<void> deleteAddress(String id) => _dio.delete('/me/addresses/$id');
//
//   @override
//   Future<List<AppNotification>> notifications() async =>
//       [for (final j in (await _dio.get('/me/notifications')).data) AppNotification.fromJson(j)];
// }
