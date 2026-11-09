import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/design_tokens.dart';
import '../models/catalog.dart';
import '../models/money.dart';
import 'common.dart';
import 'food_art_view.dart';
import 'pressable.dart';

/// The dish card from the reference: name and price centred on top, the 3D
/// render in the middle, calories and time below with the green "+".
/// One widget for the Fast delivery strip, the Best Sellers grid, the
/// restaurant menu and Saved.
class FoodCard extends StatefulWidget {
  const FoodCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAdd,
    this.artSize = 84,
    this.heroPrefix = 'food',
  });

  final Product product;
  final VoidCallback onTap;

  /// Called with the key of the dish image, for the fly-to-cart flight.
  final ValueChanged<GlobalKey> onAdd;
  final double artSize;
  final String heroPrefix;

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  final _art = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final product = widget.product;
    return Pressable(
      onTap: widget.onTap,
      semanticLabel: '${product.name}, ${money(product.priceCents)}',
      child: SoftCard(
        padding: const EdgeInsets.fromLTRB(
            Space.md, Space.md, Space.md, Space.md - 2),
        child: Column(
          children: [
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.title.copyWith(fontSize: 13.5),
            ),
            const SizedBox(height: 2),
            Text(money(product.priceCents),
                style: context.caption.copyWith(color: p.inkSoft)),
            Expanded(
              child: Center(
                child: FoodArtView(
                  product.art,
                  key: _art,
                  size: widget.artSize,
                  heroTag: '${widget.heroPrefix}-${product.id}',
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: MetaChip(
                Icons.local_fire_department_rounded,
                '${product.calories} Calories',
                iconColor: const Color(0xFFE0713A),
                bold: true,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                    child: MetaChip(
                        Icons.schedule_rounded, '${product.minutes} min')),
                AddButton(
                    onTap: () => widget.onAdd(_art),
                    label: 'Add ${product.name} to cart'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
