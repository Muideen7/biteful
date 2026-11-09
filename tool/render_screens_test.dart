// Renders screens to PNG with the real fonts and art, for visual review
// without a device:  OUT=dir flutter test tool/render_screens_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dishly/config/app_theme.dart';
import 'package:dishly/screens/auth/sign_in_screen.dart';
import 'package:dishly/screens/restaurant/restaurant_screen.dart';
import 'package:dishly/screens/profile/profile_tab.dart';
import 'package:dishly/screens/profile/avatar_sheet.dart';
import 'package:dishly/screens/profile/avatar_crop_screen.dart';
import 'package:dishly/screens/search/search_screen.dart';
import 'package:dishly/screens/orders/orders_screen.dart';
import 'package:dishly/screens/orders/order_detail_screen.dart';
import 'package:dishly/screens/profile/addresses_screen.dart';
import 'package:dishly/screens/shell/main_shell.dart';
import 'package:dishly/services/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/helpers.dart';

Future<void> _loadFonts() async {
  final bricolage = FontLoader('Bricolage');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    bricolage.addFont(Future.value(ByteData.sublistView(
        File('assets/fonts/Bricolage-$w.ttf').readAsBytesSync())));
  }
  await bricolage.load();
  final root = Platform.environment['FLUTTER_ROOT']!;
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(File(
            '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf')
        .readAsBytesSync())));
  await icons.load();
}

final _key = GlobalKey();

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pump();
  await tester.runAsync(() async {
    final b = _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 2);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    final out = Platform.environment['OUT'] ?? 'build/shots';
    Directory(out).createSync(recursive: true);
    File('$out/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  });
}

void main() {
  final seed = readSeed();
  setUpAll(() async {
    quietMotion();
    await _loadFonts();
  });

  Future<ProviderContainer> app(WidgetTester tester, Widget home,
      {ThemeMode mode = ThemeMode.light,
      Map<String, Object> prefs = const {},
      DateTime? now}) async {
    phone(tester);
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    final (c, _) = await makeContainer(seed,
        prefs: prefs, signedIn: seed.profile, now: now);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: RepaintBoundary(
        key: _key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: home,
        ),
      ),
    ));
    await tester.pumpAndSettle();
    return c;
  }

  testWidgets('sign in', (t) async {
    await app(t, const SignInScreen());
    await _shot(t, 'signin');
  });

  testWidgets('home scroll', (t) async {
    await app(t, const MainShell());
    await _shot(t, 'home_0');
    for (final y in [640.0, 1300.0, 1900.0]) {
      await t.drag(find.byType(CustomScrollView).first,
          Offset(0, -y + (y == 640 ? 0 : (y == 1300 ? 640 : 1300))));
      await t.pumpAndSettle();
      await _shot(t, 'home_${y.toInt()}');
    }
  });

  testWidgets('home dark', (t) async {
    await app(t, const MainShell(), mode: ThemeMode.dark);
    await _shot(t, 'home_dark');
  });

  testWidgets('cart', (t) async {
    final c = await app(t, const MainShell(), prefs: {
      Store.cart:
          '[{"productId":"p_cheeseburger","qty":2},{"productId":"p_latte","qty":1},{"productId":"p_ribeye","qty":1}]',
      Store.deal: 'd_whole',
    });
    c.read(shellTabProvider.notifier).state = ShellTab.cart;
    await t.pumpAndSettle();
    await _shot(t, 'cart');
  });

  testWidgets('search results', (t) async {
    await app(t, const SearchScreen(initialQuery: 'chicken'));
    await _shot(t, 'search');
  });

  testWidgets('search empty box', (t) async {
    await app(t, const SearchScreen(initialQuery: ''), prefs: {
      Store.recentSearches: ['ramen', 'pizza', 'Umami Bar']
    });
    await _shot(t, 'search_start');
  });

  testWidgets('orders', (t) async {
    await app(t, const OrdersScreen(),
        now: testNow.add(const Duration(minutes: 7)));
    await _shot(t, 'orders');
  });

  testWidgets('order on the way', (t) async {
    await app(t, const OrderDetailScreen(orderId: 'o_live'),
        now: testNow.add(const Duration(minutes: 9)));
    await _shot(t, 'order_live');
  });

  testWidgets('addresses', (t) async {
    await app(t, const AddressesScreen());
    await _shot(t, 'addresses');
  });

  testWidgets('profile and photo', (t) async {
    await app(t, const ProfileTab());
    await _shot(t, 'profile');
    await t.tap(find.byKey(AvatarKeys.avatar));
    await t.pumpAndSettle();
    await _shot(t, 'avatar_sheet');
  });

  testWidgets('crop', (t) async {
    final bytes = File('assets/images/people/olympicson.png').readAsBytesSync();
    await app(t, AvatarCropScreen(bytes: bytes));
    await _shot(t, 'avatar_crop');
  });

  testWidgets('restaurant', (t) async {
    await app(t, const RestaurantScreen(restaurantId: 'r_umami'));
    await _shot(t, 'restaurant');
  });

  testWidgets('product sheet', (t) async {
    await app(t, const MainShell());
    await t.tap(find.text('Tonkotsu Ramen').first);
    await t.pumpAndSettle();
    await _shot(t, 'product');
  });
}
