import 'dart:typed_data';

import 'package:dishly/providers/core_providers.dart';
import 'package:dishly/providers/media_providers.dart';
import 'package:dishly/providers/session_providers.dart';
import 'package:dishly/screens/profile/avatar_crop_screen.dart';
import 'package:dishly/screens/profile/avatar_sheet.dart';
import 'package:dishly/screens/profile/profile_tab.dart';
import 'package:dishly/services/photo_picker.dart';
import 'package:dishly/services/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import '../helpers.dart';
import '../support/fake_media_store.dart';

Uint8List photo(int width, int height) {
  final image = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      image.setPixelRgb(
          x, y, (x * 255 / width).round(), (y * 255 / height).round(), 90);
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

/// A picker with a scripted answer: no camera, library or permission
/// dialog needed.
class ScriptedPicker implements PhotoPicker {
  ScriptedPicker({this.bytes, this.throws});

  final Uint8List? bytes;
  final Object? throws;
  final List<PhotoOrigin> asked = [];

  @override
  Future<Uint8List?> pick(PhotoOrigin origin) async {
    asked.add(origin);
    if (throws != null) throw throws!;
    return bytes;
  }
}

void main() {
  final seed = readSeed();
  setUpAll(quietMotion);

  Future<ProviderContainer> pump(
    WidgetTester t, {
    required PhotoPicker picker,
    required FakeMediaStore store,
    Map<String, Object> prefs = const {},
  }) async {
    phone(t);
    final (c, _) = await makeContainer(
      seed,
      signedIn: seed.profile,
      prefs: prefs,
      overrides: [
        photoPickerProvider.overrideWithValue(picker),
        mediaStoreProvider.overrideWithValue(store),
      ],
    );
    await pumpScreen(t, c, const ProfileTab());
    return c;
  }

  Future<void> openSheet(WidgetTester t) async {
    await t.tap(find.byKey(AvatarKeys.avatar));
    await t.pumpAndSettle();
  }

  testWidgets(
      'the sheet offers camera, library and remove for the seeded photo',
      (t) async {
    await pump(t, picker: ScriptedPicker(), store: FakeMediaStore());
    await openSheet(t);
    expect(find.text('Profile photo'), findsOneWidget);
    expect(find.byKey(AvatarKeys.camera), findsOneWidget);
    expect(find.byKey(AvatarKeys.choose), findsOneWidget);
    expect(find.byKey(AvatarKeys.remove), findsOneWidget);
  });

  testWidgets(
      'a chosen photo goes through the crop step, then is saved and shown',
      (t) async {
    final store = FakeMediaStore();
    final picker = ScriptedPicker(bytes: photo(1200, 800));
    final c = await pump(t, picker: picker, store: store);
    await openSheet(t);
    await t.tap(find.byKey(AvatarKeys.choose));
    await t.pumpAndSettle();
    expect(picker.asked, [PhotoOrigin.gallery]);
    // Never straight in: the circle is chosen first.
    expect(find.byType(AvatarCropScreen), findsOneWidget);
    await t.tap(find.byKey(AvatarCropScreen.confirmKey));
    await t.pumpAndSettle();
    final avatar = c.read(profileProvider).value!.avatar;
    expect(avatar, startsWith('file:media/avatar_me_'));
    expect(store.files.keys.single, avatar.substring(5));
    // Square, re-encoded, and no bigger than an avatar needs.
    final saved = img.decodeImage(store.files.values.single)!;
    expect(saved.width, saved.height);
    expect(saved.width, lessThanOrEqualTo(512));
    expect(c.read(pendingAvatarProvider), isNotNull);
    expect(find.byType(AvatarCropScreen), findsNothing);
  });

  testWidgets('cancelling the crop leaves the profile as it was', (t) async {
    final store = FakeMediaStore();
    final c = await pump(t,
        picker: ScriptedPicker(bytes: photo(600, 600)), store: store);
    await openSheet(t);
    await t.tap(find.byKey(AvatarKeys.choose));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Cancel'));
    await t.pumpAndSettle();
    expect(c.read(profileProvider).value!.avatar, seed.profile.avatar);
    expect(store.files, isEmpty);
  });

  testWidgets('a refused camera says so and still offers the library',
      (t) async {
    await pump(
      t,
      picker:
          ScriptedPicker(throws: const PhotoAccessDenied(PhotoOrigin.camera)),
      store: FakeMediaStore(),
    );
    await openSheet(t);
    await t.tap(find.byKey(AvatarKeys.camera));
    await t.pumpAndSettle();
    expect(find.textContaining('does not have permission to use the camera'),
        findsOneWidget);
    expect(find.textContaining('You can still choose an existing photo'),
        findsOneWidget);
    final choose = t.widget<ButtonStyleButton>(find.byKey(AvatarKeys.choose));
    expect(choose.onPressed, isNotNull);
  });

  testWidgets('a failed save says so and keeps the old photo', (t) async {
    final store = FakeMediaStore(failWrites: true);
    final c = await pump(t,
        picker: ScriptedPicker(bytes: photo(800, 800)), store: store);
    await openSheet(t);
    await t.tap(find.byKey(AvatarKeys.choose));
    await t.pumpAndSettle();
    await t.tap(find.byKey(AvatarCropScreen.confirmKey));
    await t.pumpAndSettle();
    expect(find.text('Could not save that photo. Your old one is still here.'),
        findsOneWidget);
    expect(c.read(profileProvider).value!.avatar, seed.profile.avatar);
    expect(c.read(pendingAvatarProvider), isNull);
  });

  testWidgets(
      'remove falls back to the initial and never deletes a bundled picture',
      (t) async {
    final store = FakeMediaStore();
    final c = await pump(t, picker: ScriptedPicker(), store: store);
    await openSheet(t);
    await t.tap(find.byKey(AvatarKeys.remove));
    await t.pumpAndSettle();
    expect(c.read(profileProvider).value!.avatar, '');
    expect(find.text('O'), findsOneWidget);
    expect(store.deleted, isEmpty);
  });

  testWidgets('replacing a saved photo deletes the file it replaced',
      (t) async {
    final store = FakeMediaStore();
    final c = await pump(t,
        picker: ScriptedPicker(bytes: photo(700, 500)), store: store);
    for (var i = 0; i < 2; i++) {
      await openSheet(t);
      await t.tap(find.byKey(AvatarKeys.choose));
      await t.pumpAndSettle();
      await t.tap(find.byKey(AvatarCropScreen.confirmKey));
      await t.pumpAndSettle();
    }
    expect(store.files.length, 1);
    expect(store.deleted.length, 1);
    expect(c.read(profileProvider).value!.avatar.substring(5),
        store.files.keys.single);
  });

  testWidgets(
      'reset demo data deletes a chosen photo and brings back the seeded one',
      (t) async {
    final store = FakeMediaStore();
    final c = await pump(t,
        picker: ScriptedPicker(bytes: photo(500, 500)), store: store);
    await openSheet(t);
    await t.tap(find.byKey(AvatarKeys.choose));
    await t.pumpAndSettle();
    await t.tap(find.byKey(AvatarCropScreen.confirmKey));
    await t.pumpAndSettle();
    expect(store.files, hasLength(1));
    await t.scrollUntilVisible(find.text('Reset demo data'), 200);
    await t.drag(find.text('Reset demo data'), const Offset(0, -240));
    await t.pumpAndSettle();
    await t.tap(find.text('Reset demo data'));
    await t.pumpAndSettle();
    expect(store.files, isEmpty);
    expect(c.read(pendingAvatarProvider), isNull);
    expect(c.read(storeProvider).string(Store.profile), isNull);
  });

  testWidgets('the saved photo reference survives a relaunch', (t) async {
    final store = FakeMediaStore();
    final c = await pump(t,
        picker: ScriptedPicker(bytes: photo(500, 500)), store: store);
    await openSheet(t);
    await t.tap(find.byKey(AvatarKeys.choose));
    await t.pumpAndSettle();
    await t.tap(find.byKey(AvatarCropScreen.confirmKey));
    await t.pumpAndSettle();
    final saved = c.read(profileProvider).value!.avatar;
    final (c2, _) = await makeContainer(seed,
        signedIn: seed.profile,
        prefs: {Store.profile: c.read(storeProvider).string(Store.profile)!});
    expect((await c2.read(profileProvider.future))!.avatar, saved);
  });
}
