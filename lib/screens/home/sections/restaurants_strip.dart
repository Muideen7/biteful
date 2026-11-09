import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../../config/design_tokens.dart';
import '../../../models/catalog.dart';
import '../../../models/money.dart';
import '../../../widgets/common.dart';
import '../../../widgets/food_art_view.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/section_header.dart';
import '../../actions.dart';

class RestaurantsStrip extends StatelessWidget {
  const RestaurantsStrip({super.key, required this.restaurants});

  final List<Restaurant> restaurants;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader('Popular restaurants near you'),
        HStrip(
          height: 196,
          itemCount: restaurants.length,
          itemBuilder: (_, i) => SizedBox(
              width: 214, child: RestaurantCard(restaurant: restaurants[i])),
        ),
      ],
    );
  }
}

/// A pale green photo well with the dishes and a delivery-fee badge, then
/// name, rating, cuisine, time and distance.
class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = restaurant;
    return Pressable(
      onTap: () => openRestaurant(context, r),
      semanticLabel: '${r.name}, rated ${r.rating}, ${r.eta}',
      child: SoftCard(
        padding: const EdgeInsets.all(Space.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 96,
              decoration: BoxDecoration(
                  color: p.accentWash,
                  borderRadius: BorderRadius.circular(Radii.md)),
              child: Stack(
                children: [
                  Center(
                      child: FoodArtView(r.art,
                          size: 82, heroTag: 'restaurant-${r.id}')),
                  Positioned(left: 8, top: 8, child: FeeBadge(restaurant: r)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, Space.sm + 2, 4, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(r.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.title.copyWith(fontSize: 15)),
                      ),
                      Icon(Icons.star_rounded, size: 16, color: p.star),
                      const SizedBox(width: 2),
                      Text(r.rating.toStringAsFixed(1), style: context.label),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(r.cuisine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.caption),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(child: MetaChip(Icons.schedule_rounded, r.eta)),
                      const SizedBox(width: Space.md),
                      Flexible(
                          child: MetaChip(Icons.place_outlined, r.distance)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeeBadge extends StatelessWidget {
  const FeeBadge({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: p.card, borderRadius: BorderRadius.circular(Radii.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delivery_dining_rounded, size: 13, color: p.accent),
          const SizedBox(width: 4),
          Text(
            restaurant.freeDelivery
                ? 'Free delivery'
                : '${money(restaurant.deliveryFeeCents)} delivery',
            style: TextStyle(
                fontSize: 10.5, fontWeight: FontWeight.w700, color: p.inkSoft),
          ),
        ],
      ),
    );
  }
}
