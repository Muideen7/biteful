import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/core_providers.dart';
import 'services/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Loaded before the first frame so the stored theme and session are
  // known immediately and nothing flips after launch.
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [storeProvider.overrideWithValue(Store(prefs))],
    child: const DishlyApp(),
  ));
}
