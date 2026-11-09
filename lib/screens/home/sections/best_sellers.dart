import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/design_tokens.dart';
import '../../../models/catalog.dart';
import '../../../services/catalog_repository.dart';
import '../../../widgets/common.dart';
import '../../../widgets/food_card.dart';
import '../../../widgets/section_header.dart';
import '../../actions.dart';
import 'category_strip.dart';

/// The two-column grid that ends Home. "All" shows the best sellers; a
/// category shows everything in it, and an empty category says so.
abstract final class BestSellers {
  static List<Widget> slivers(
    BuildContext context,
    WidgetRef ref,
    Catalog catalog,
    Widget Function(Widget) wrap,
  ) {
    final selected = ref.watch(selectedCategoryProvider);
    final category = selected == null
        ? null
        : catalog.categories.where((c) => c.id == selected).firstOrNull;
    final items = category == null
        ? catalog.bestSellers
        : catalog.inCategory(category.id);
    final title = category == null ? 'Best Sellers' : category.name;

    return [
      SliverToBoxAdapter(
        child: wrap(SectionHeader(
          title,
          action: category == null ? null : 'Show all',
          onAction: () =>
              ref.read(selectedCategoryProvider.notifier).state = null,
        )),
      ),
      if (items.isEmpty)
        SliverToBoxAdapter(
          child: EmptyState(
            art: category?.art ?? const FoodArt('takeout'),
            title: 'No ${title.toLowerCase()} near you right now',
            message: 'Kitchens close by have sold out. Try another category.',
            action: 'Show best sellers',
            onAction: () =>
                ref.read(selectedCategoryProvider.notifier).state = null,
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: Space.md,
              crossAxisSpacing: Space.md,
              mainAxisExtent: 222,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => wrap(FoodCard(
              key: ValueKey(items[i].id),
              product: items[i],
              heroPrefix: 'grid',
              artSize: 96,
              onTap: () => openProduct(context, items[i]),
              onAdd: (k) => addToCart(context, ref, items[i], from: k),
            )),
          ),
        ),
    ];
  }
}
