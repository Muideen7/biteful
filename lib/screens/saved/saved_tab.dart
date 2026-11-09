import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/design_tokens.dart';
import '../../models/catalog.dart';
import '../../providers/cart_providers.dart';
import '../../providers/core_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/food_card.dart';
import '../actions.dart';
import '../shell/main_shell.dart';
import '../shell/tab_page.dart';

class SavedTab extends ConsumerWidget {
  const SavedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(savedProvider);
    final catalog = ref.watch(catalogProvider).valueOrNull;
    final items = [
      for (final p in catalog?.products ?? const <Product>[])
        if (ids.contains(p.id)) p
    ];
    return TabPage(
      title: 'Saved',
      subtitle: items.isEmpty
          ? null
          : '${items.length} ${items.length == 1 ? 'dish' : 'dishes'}',
      slivers: [
        if (items.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              art: const FoodArt('dessert'),
              title: 'Nothing saved yet',
              message: 'Tap the heart on any dish to keep it here for later.',
              action: 'Find something good',
              onAction: () =>
                  ref.read(shellTabProvider.notifier).state = ShellTab.home,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                Space.gutter, Space.lg, Space.gutter, 0),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: Space.md,
                crossAxisSpacing: Space.md,
                mainAxisExtent: 222,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => FoodCard(
                product: items[i],
                heroPrefix: 'saved',
                artSize: 96,
                onTap: () => openProduct(context, items[i]),
                onAdd: (k) => addToCart(context, ref, items[i], from: k),
              ),
            ),
          ),
      ],
    );
  }
}
