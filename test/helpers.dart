import 'dart:io';

import 'package:dishly/config/app_timing.dart';
import 'package:dishly/config/app_theme.dart';
import 'package:dishly/config/motion.dart';
import 'package:dishly/models/account.dart';
import 'package:dishly/providers/core_providers.dart';
import 'package:dishly/services/seed.dart';
import 'package:dishly/services/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The real seed, read from disk with dart:io. Call from setUpAll, outside
/// the fake-async zone: an asset-bundle load inside testWidgets hangs every
/// test after the first in a file.
Seed readSeed() => Seed.fromSources({
      for (final f in Seed.files)
        f: File('assets/data/$f.json').readAsStringSync(),
    });

/// No ambient loops (so pumpAndSettle settles) and no deliberate waits.
void quietMotion() {
  Motion.ambient = false;
  AppTiming.scale = 0;
}

/// An iPhone-sized surface. The 800x600 default hides phone layout bugs.
void phone(WidgetTester tester, {Size size = const Size(390, 844)}) {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<(ProviderContainer, Store)> makeContainer(
  Seed seed, {
  Map<String, Object> prefs = const {},
  UserProfile? signedIn,
}) async {
  SharedPreferences.setMockInitialValues({...prefs});
  final store = Store(await SharedPreferences.getInstance());
  if (signedIn != null) await store.setJson(Store.session, signedIn.toJson());
  final container = ProviderContainer(overrides: [
    storeProvider.overrideWithValue(store),
    seedProvider.overrideWith((_) async => seed),
  ]);
  return (container, store);
}

/// Pumps [child] in a themed MaterialApp inside [container], with the menu
/// already loaded.
Future<void> pumpScreen(
  WidgetTester tester,
  ProviderContainer container,
  Widget child, {
  ThemeMode mode = ThemeMode.light,
}) async {
  await container.read(catalogProvider.future);
  await container.read(seedProvider.future);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      home: child,
    ),
  ));
  await tester.pump();
  await tester.pumpAndSettle();
}
