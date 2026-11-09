import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// User state on top of the seed: the session, cart, saved dishes, applied
/// deal, chosen address, read notifications and placed orders.
///
/// A thin wrapper so every key is named in one place. Reads are synchronous
/// (the instance is loaded before `runApp`), so screens never flash empty
/// state on launch. Not secure storage: no secrets or card data go here.
class Store {
  Store(this._prefs);

  final SharedPreferences _prefs;

  static const session = 'session';
  static const cart = 'cart';
  static const saved = 'saved';
  static const deal = 'deal';
  static const address = 'address';
  static const readNotifications = 'read_notifications';
  static const placedOrders = 'placed_orders';
  static const themeMode = 'theme_mode';

  static const all = [
    session,
    cart,
    saved,
    deal,
    address,
    readNotifications,
    placedOrders,
    themeMode,
  ];

  String? string(String key) => _prefs.getString(key);

  Future<void> setString(String key, String? value) =>
      value == null ? _prefs.remove(key) : _prefs.setString(key, value);

  T? json<T>(String key) {
    final s = _prefs.getString(key);
    return s == null ? null : jsonDecode(s) as T;
  }

  Future<void> setJson(String key, Object value) =>
      _prefs.setString(key, jsonEncode(value));

  List<String> strings(String key) => _prefs.getStringList(key) ?? const [];

  Future<void> setStrings(String key, Iterable<String> v) =>
      _prefs.setStringList(key, v.toList());

  /// Back to a first launch: the seed shows through again.
  Future<void> reset() async {
    for (final k in all) {
      await _prefs.remove(k);
    }
  }
}
