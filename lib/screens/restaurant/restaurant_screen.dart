import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../providers/core_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/food_art_view.dart';
import '../../widgets/food_card.dart';
import '../actions.dart';
import '../home/sections/restaurants_strip.dart';

/// A restaurant's page: a green header with its dishes, the facts in a row,
/// and its menu in the same grid as Home.
class RestaurantScreen extends ConsumerWidget {
  const RestaurantScreen({super.key, required this.restaurantId});

  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final catalog = ref.watch(catalogProvider).valueOrNull;
    final r = catalog?.restaurantById[restaurantId];
    if (catalog == null || r == null) return Scaffold(backgroundColor: p.paper);
    final menu = catalog.menuOf(r.id);
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            // The green header stretches on a pull-down instead of
            // opening a gap above it.
            stretch: true,
            expandedHeight: 230,
            backgroundColor: p.headerTop,
            foregroundColor: p.card,
            shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(Radii.header)),
            ),
            title: Text(r.name,
                style: TextStyle(color: p.card, fontWeight: FontWeight.w800)),
            flexibleSpace: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(Radii.header)),
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: p.headerGradient),
                child: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Padding(
                    padding: EdgeInsets.only(top: top + 30),
                    child: Center(
                        child: FoodArtView(r.art,
                            size: 150, heroTag: 'restaurant-${r.id}')),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  Space.gutter, Space.xl, Space.gutter, Space.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.cuisine, style: context.body),
                  const SizedBox(height: Space.md),
                  SoftCard(
                    padding: const EdgeInsets.symmetric(vertical: Space.md),
                    child: Row(
                      children: [
                        _Fact(Icons.star_rounded, r.rating.toStringAsFixed(1),
                            'Rating', p.star),
                        _Fact(Icons.schedule_rounded, r.eta, 'Delivery',
                            p.accent),
                        _Fact(
                            Icons.place_outlined, r.distance, 'Away', p.accent),
                      ],
                    ),
                  ),
                  const SizedBox(height: Space.md),
                  FeeBadge(restaurant: r),
                  const SizedBox(height: Space.lg),
                  Text('Menu', style: context.heading),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                Space.gutter, Space.sm, Space.gutter, Sizes.navHeight + 56),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: Space.md,
                crossAxisSpacing: Space.md,
                mainAxisExtent: 222,
              ),
              itemCount: menu.length,
              itemBuilder: (context, i) => FoodCard(
                product: menu[i],
                heroPrefix: 'menu',
                artSize: 96,
                onTap: () => openProduct(context, menu[i]),
                onAdd: (k) => addToCart(context, ref, menu[i], from: k),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.value, this.label, this.color);

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Flexible(
                  child: Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.title)),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: context.caption),
        ],
      ),
    );
  }
}
