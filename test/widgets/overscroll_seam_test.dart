// A green-headed page pulled down on iOS: the gap above the header must be
// green, and the colour must not step across the join (the owner saw a
// fine line when the fill used a different blend from the header).
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dishly/config/app_theme.dart';
import 'package:dishly/providers/core_providers.dart';
import 'package:dishly/screens/saved/saved_tab.dart';
import 'package:dishly/screens/shell/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final seed = readSeed();
  setUpAll(quietMotion);

  testWidgets('no seam between header and fill', (t) async {
    phone(t);
    final key = GlobalKey();
    final (c, _) = await makeContainer(seed, signedIn: seed.profile);
    await c.read(catalogProvider.future);
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: RepaintBoundary(
        key: key,
        child: MaterialApp(theme: AppTheme.light(), home: const MainShell()),
      ),
    ));
    await t.pumpAndSettle();
    c.read(shellTabProvider.notifier).state = ShellTab.saved;
    await t.pumpAndSettle();
    final g = await t.startGesture(const Offset(200, 300));
    await g.moveBy(const Offset(0, 160));
    await t.pump();

    late ByteData bytes;
    late int w;
    await t.runAsync(() async {
      final img = await (key.currentContext!.findRenderObject()
              as RenderRepaintBoundary)
          .toImage();
      w = img.width;
      bytes = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    });
    // Find the join: the first row of the scrolled header. The fill covers
    // rows [0, pullPx); the header starts at pullPx.
    final scroll = t
        .state<ScrollableState>(find
            .descendant(
                of: find.byType(SavedTab), matching: find.byType(Scrollable))
            .first)
        .position
        .pixels;
    final joinY = (-scroll).round();
    int px(int x, int y, int ch) => bytes.getUint8((y * w + x) * 4 + ch);
    var worst = 0;
    for (var x = 2; x < w - 2; x += 7) {
      for (var ch = 0; ch < 3; ch++) {
        final step = (px(x, joinY - 2, ch) - px(x, joinY + 2, ch)).abs();
        if (step > worst) worst = step;
      }
    }
    expect(joinY, greaterThan(100));
    // The gap is green, not paper: green channel well above red.
    expect(px(200, joinY ~/ 2, 1) - px(200, joinY ~/ 2, 0), greaterThan(30));
    expect(worst, lessThanOrEqualTo(3));
    await g.up();
    await t.pumpAndSettle();
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
