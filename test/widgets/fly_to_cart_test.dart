import 'package:dishly/config/app_theme.dart';
import 'package:dishly/config/motion.dart';
import 'package:dishly/models/catalog.dart';
import 'package:dishly/widgets/fly_to_cart.dart';
import 'package:dishly/widgets/food_art_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => Motion.ambient = false);

  Future<GlobalKey> pump(WidgetTester t) async {
    final from = GlobalKey();
    await t.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Stack(children: [
          Positioned(left: 20, top: 100, child: FoodArtView(const FoodArt('burger'), key: from, size: 80)),
          Positioned(right: 30, bottom: 30, child: Icon(Icons.shopping_bag, key: cartTargetKey)),
        ]),
      ),
    ));
    return from;
  }

  testWidgets('a copy of the dish flies to the cart, lands, and is cleaned up', (t) async {
    Motion.ambient = true;
    final from = await pump(t);
    final before = cartLanded.value;
    var landed = false;
    flyToCart(t.element(find.byKey(from)), from, const FoodArt('burger')).then((_) => landed = true);
    await t.pump();
    await t.pump(const Duration(milliseconds: 200));
    // The original plus the flying copy and its two trailing ghosts.
    expect(find.byType(FoodArtView), findsNWidgets(4));
    expect(t.takeException(), isNull);
    await t.pump(const Duration(milliseconds: 200));
    expect(landed, isFalse);
    await t.pump(const Duration(milliseconds: 500));
    await t.pump();
    expect(landed, isTrue);
    expect(cartLanded.value, before + 1);
    expect(find.byType(FoodArtView), findsOneWidget);
  });

  testWidgets('with motion off it completes at once and nothing flies', (t) async {
    Motion.ambient = false;
    final from = await pump(t);
    var landed = false;
    flyToCart(t.element(find.byKey(from)), from, const FoodArt('burger')).then((_) => landed = true);
    await t.pump();
    expect(landed, isTrue);
    expect(find.byType(FoodArtView), findsOneWidget);
  });
}
