// Drives sign in and sign out on a simulator at real speed, so the header
// hand-offs can be recorded and judged frame by frame:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/handoff_test.dart -d <simulator>
import 'package:dishly/app.dart';
import 'package:dishly/providers/core_providers.dart';
import 'package:dishly/screens/shell/main_shell.dart';
import 'package:dishly/services/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Real frames at real time; otherwise the recording measures the harness.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  Future<void> wait(WidgetTester t, int ms) async {
    final end = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(end)) {
      await t.pump(const Duration(milliseconds: 16));
    }
  }

  testWidgets('sign in, then sign out', (t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final store = Store(prefs);
    await t.pumpWidget(ProviderScope(
      overrides: [storeProvider.overrideWithValue(store)],
      child: const DishlyApp(),
    ));
    await wait(t, 5500); // splash, then the sign-in entrance

    Finder field(String k) => find.descendant(of: find.byKey(Key(k)), matching: find.byType(EditableText));
    await t.enterText(field('email'), 'hello@flutterzip.com');
    await t.enterText(field('password'), 'dishly123');
    FocusManager.instance.primaryFocus?.unfocus();
    await wait(t, 800);
    await t.tap(find.text('Log In'));
    await wait(t, 4500); // sign-in wait, header hand-off, Home entrance

    await t.tap(find.text('Profile'));
    await wait(t, 1200);
    final scroll = find.byType(Scrollable).last;
    await t.drag(scroll, const Offset(0, -900));
    await wait(t, 1200);
    await t.tap(find.text('Sign out'));
    await wait(t, 3500);
    expect(find.byType(MainShell), findsNothing);
  });
}
