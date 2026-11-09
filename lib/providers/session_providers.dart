import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../services/media_ref.dart';
import '../services/store.dart';
import 'core_providers.dart';
import 'media_providers.dart';

/// Who is signed in: their email, or null. Remembered across launches only
/// when "Keep me signed in" was ticked.
///
/// Only the identity is kept here, never the profile. A profile copied into
/// the session goes stale the moment the account's details change anywhere
/// else (that is how a removed phone number kept showing). The details come
/// from [profileProvider], through the account repository.
class SessionNotifier extends Notifier<String?> {
  Store get _store => ref.read(storeProvider);

  @override
  String? build() {
    final j =
        ref.watch(storeProvider).json<Map<String, dynamic>>(Store.session);
    // Older builds stored a whole profile here; its email is all we keep.
    return j?['email'] as String?;
  }

  Future<void> signedIn(String email, {required bool remember}) async {
    state = email;
    if (remember) {
      await _store.setJson(Store.session, {'email': email});
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
    NotifierProvider<SessionNotifier, String?>(SessionNotifier.new);

/// The signed-in person's details, from the account repository. Null when
/// nobody is signed in.
class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    if (ref.watch(sessionProvider) == null) return null;
    return (await ref.watch(accountRepositoryProvider.future)).profile();
  }

  Future<UserProfile> _save(UserProfile p) async {
    final saved = await (await ref.read(accountRepositoryProvider.future))
        .updateProfile(p);
    state = AsyncData(saved);
    return saved;
  }

  /// After signing in, the account takes the email that was used. A new
  /// account also takes the name it was created with.
  Future<void> signedInAs(UserProfile fromAuth, {required bool isNew}) async {
    final repo = await ref.read(accountRepositoryProvider.future);
    final current = await repo.profile();
    await _save(current.copyWith(
      email: fromAuth.email,
      name: isNew ? fromAuth.name : null,
    ));
  }

  Future<void> save(UserProfile p) async => _save(p);

  /// Store [bytes] as the profile picture.
  ///
  /// The picture appears at once ([pendingAvatarProvider] carries it) while
  /// it is encoded and written behind it. The file it replaces is deleted
  /// only after the new one is safely on disk. On failure the pending
  /// picture is dropped and the error rethrown, so the sheet can say so and
  /// the profile is left exactly as it was.
  Future<void> setAvatarBytes(Uint8List bytes) async {
    final current = state.valueOrNull;
    if (current == null) return;
    ref.read(pendingAvatarProvider.notifier).state = bytes;
    try {
      final stored = await ref.read(mediaStoreProvider).replace(
            bytes,
            entity: 'avatar',
            id: 'me',
            previous: MediaRef.parse(current.avatar),
          );
      await _save(current.copyWith(avatar: stored.encoded));
    } catch (_) {
      ref.read(pendingAvatarProvider.notifier).state = null;
      rethrow;
    }
  }

  /// Back to the initial, and the file behind the old picture is deleted.
  Future<void> removeAvatar() async {
    final current = state.valueOrNull;
    if (current == null) return;
    ref.read(pendingAvatarProvider.notifier).state = null;
    await _save(current.copyWith(avatar: ''));
    await ref.read(mediaStoreProvider).delete(MediaRef.parse(current.avatar));
  }
}

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfile?>(ProfileNotifier.new);

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
