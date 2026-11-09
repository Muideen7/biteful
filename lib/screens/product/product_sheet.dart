import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../models/catalog.dart';
import '../../models/money.dart';
import '../../providers/cart_providers.dart';
import '../../providers/core_providers.dart';
import '../../widgets/app_sheet.dart';
import '../../widgets/common.dart';
import '../../widgets/food_art_view.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/qty_stepper.dart';
import '../actions.dart';

Future<void> showProductSheet(BuildContext context, Product p) =>
    showAppSheet(context, builder: (_) => ProductSheet(product: p));

class ProductSheet extends ConsumerStatefulWidget {
  const ProductSheet({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductSheet> createState() => _ProductSheetState();
}

class _ProductSheetState extends ConsumerState<ProductSheet> {
  int _qty = 1;
  final _art = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final product = widget.product;
    final restaurant = ref
        .watch(catalogProvider)
        .valueOrNull
        ?.restaurantById[product.restaurantId];
    final saved = ref.watch(savedProvider).contains(product.id);
    final inCart = ref.watch(cartProvider.select((l) =>
        l.where((x) => x.productId == product.id).firstOrNull?.qty ?? 0));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 190,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: p.accentWash,
                          borderRadius: BorderRadius.circular(Radii.xl)),
                      alignment: Alignment.center,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: .7, end: 1),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutBack,
                        builder: (_, s, child) =>
                            Transform.scale(scale: s, child: child),
                        child: FoodArtView(product.art, key: _art, size: 160),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: IconButton.filled(
                        tooltip: saved ? 'Remove from saved' : 'Save',
                        style: IconButton.styleFrom(backgroundColor: p.card),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          ref.read(savedProvider.notifier).toggle(product.id);
                        },
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (c, a) =>
                              ScaleTransition(scale: a, child: c),
                          child: Icon(
                            saved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(saved),
                            color: saved ? p.error : p.inkSoft,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Space.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Text(product.name,
                            style: context.display.copyWith(fontSize: 22))),
                    const SizedBox(width: Space.md),
                    Text(money(product.priceCents),
                        style: context.display
                            .copyWith(fontSize: 22, color: p.accent)),
                  ],
                ),
                if (restaurant != null) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      openRestaurant(context, restaurant);
                    },
                    child: Text('from ${restaurant.name}',
                        style: context.body.copyWith(
                            color: p.accent, fontWeight: FontWeight.w700)),
                  ),
                ],
                const SizedBox(height: Space.md),
                Wrap(
                  spacing: Space.lg,
                  runSpacing: Space.sm,
                  children: [
                    MetaChip(
                        Icons.star_rounded, product.rating.toStringAsFixed(1),
                        iconColor: p.star, bold: true),
                    MetaChip(Icons.local_fire_department_rounded,
                        '${product.calories} Calories',
                        iconColor: const Color(0xFFE0713A), bold: true),
                    MetaChip(Icons.schedule_rounded, '${product.minutes} min',
                        bold: true),
                  ],
                ),
                const SizedBox(height: Space.lg),
                Text(product.description,
                    style: context.body.copyWith(height: 1.5)),
                if (inCart > 0) ...[
                  const SizedBox(height: Space.md),
                  Text('$inCart already in your cart',
                      style: context.caption.copyWith(
                          color: p.accent, fontWeight: FontWeight.w700)),
                ],
                const SizedBox(height: Space.xl),
              ],
            ),
          ),
        ),
        // Pinned: the action never scrolls away under a long description.
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Space.gutter, Space.sm, Space.gutter, Space.lg),
          child: Row(
            children: [
              QtyStepper(qty: _qty, onChanged: (q) => setState(() => _qty = q)),
              const SizedBox(width: Space.md),
              Expanded(
                child: GradientButton(
                  label: 'Add · ${money(product.priceCents * _qty)}',
                  onPressed: () {
                    // The flight takes off from the sheet's image, then the
                    // sheet gets out of its way.
                    addToCart(context, ref, product, qty: _qty, from: _art);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
