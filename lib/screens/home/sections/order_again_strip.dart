import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_theme.dart';
import '../../../config/design_tokens.dart';
import '../../../models/account.dart';
import '../../../models/money.dart';
import '../../../providers/cart_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../widgets/common.dart';
import '../../../widgets/food_art_view.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/section_header.dart';
import '../../actions.dart';

/// "Cheese Burger · Yesterday · $4.99" with a one-tap reorder. Orders you
/// place in the app join the front of this strip.
class OrderAgainStrip extends ConsumerWidget {
  const OrderAgainStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final orders = ref.watch(orderAgainProvider);
    final products =
        ref.watch(catalogProvider).valueOrNull?.productById ?? const {};
    final visible = [
      for (final o in orders)
        if (products[o.productId] != null) o
    ];
    if (visible.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        const SectionHeader('Order again'),
        HStrip(
          height: 74,
          itemCount: visible.length,
          itemBuilder: (_, i) {
            final o = visible[i];
            final product = products[o.productId]!;
            return Pressable(
              onTap: () => openProduct(context, product),
              semanticLabel:
                  '${product.name}, ordered ${daysAgoLabel(o.daysAgo)}',
              child: SoftCard(
                padding: const EdgeInsets.fromLTRB(
                    Space.md, Space.sm, Space.sm, Space.sm),
                child: SizedBox(
                  width: 196,
                  child: Row(
                    children: [
                      FoodArtView(product.art,
                          key: GlobalObjectKey('again-${o.productId}'),
                          size: 44),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.title.copyWith(fontSize: 13.5)),
                            const SizedBox(height: 2),
                            Text(
                              '${daysAgoLabel(o.daysAgo)} · ${money(o.paidCents)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.caption,
                            ),
                          ],
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Order ${product.name} again',
                        child: Material(
                          color: p.accentWash,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => reorder(context, ref, o,
                                from: GlobalObjectKey('again-${o.productId}')),
                            child: SizedBox.square(
                              dimension: 34,
                              child: Icon(Icons.replay_rounded,
                                  size: 18, color: p.accent),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
