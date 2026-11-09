import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../services/store.dart';
import 'core_providers.dart';

/// Who is signed in, or null. Remembered across launches only when "Keep
/// me signed in" was ticked.
class SessionNotifier extends Notifier<UserProfile?> {
  Store get _store => ref.read(storeProvider);

  @override
  UserProfile? build() {
    final j =
        ref.watch(storeProvider).json<Map<String, dynamic>>(Store.session);
    return j == null ? null : UserProfile.fromJson(j);
  }

  Future<void> signedIn(UserProfile profile, {required bool remember}) async {
    state = profile;
    if (remember) {
      await _store.setJson(Store.session, profile.toJson());
    } else {
      await _store.setString(Store.session, null);
    }
  }

  Future<void> signOut() async {
    state = null;
    await _store.setString(Store.session, null);
  }
}

final sessionProvider =
    NotifierProvider<SessionNotifier, UserProfile?>(SessionNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final s = ref.watch(storeProvider).string(Store.themeMode);
    return ThemeMode.values.asNameMap()[s] ?? ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(storeProvider).setString(Store.themeMode, mode.name);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
