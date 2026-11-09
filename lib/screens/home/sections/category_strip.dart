import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_theme.dart';
import '../../../config/design_tokens.dart';
import '../../../config/motion.dart';
import '../../../models/catalog.dart';
import '../../../providers/core_providers.dart';
import '../../../widgets/food_art_view.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/section_header.dart';

/// Null means "All".
final selectedCategoryProvider = StateProvider<String?>((_) => null);

const _allArt = FoodArt('fries', 'burger');

/// Categories, with the selected pill in the brand gradient and its dish
/// popping up out of the top, as in the reference. Selecting one filters
/// the grid at the bottom of Home.
class CategoryStrip extends ConsumerWidget {
  const CategoryStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(catalogProvider).valueOrNull?.categories ?? const [];
    final selected = ref.watch(selectedCategoryProvider);
    void pick(String? id) {
      HapticFeedback.selectionClick();
      ref.read(selectedCategoryProvider.notifier).state = id;
    }

    return Column(
      children: [
        SectionHeader('Categories',
            action: 'See All', onAction: () => pick(null)),
        HStrip(
          height: 98,
          spacing: 12,
          itemCount: cats.length + 1,
          itemBuilder: (_, i) => i == 0
              ? CategoryTile(
                  name: 'All',
                  art: _allArt,
                  selected: selected == null,
                  onTap: () => pick(null))
              : CategoryTile(
                  name: cats[i - 1].name,
                  art: cats[i - 1].art,
                  selected: selected == cats[i - 1].id,
                  onTap: () => pick(cats[i - 1].id),
                ),
        ),
      ],
    );
  }
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.name,
    required this.art,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final FoodArt art;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        semanticLabel: name,
        child: SizedBox(
          width: Sizes.categoryTile,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              AnimatedContainer(
                duration: Motion.short,
                curve: Motion.enter,
                height: 76,
                decoration: BoxDecoration(
                  gradient: selected ? p.buttonGradient : null,
                  color: selected ? null : p.card,
                  borderRadius: BorderRadius.circular(Radii.lg),
                  boxShadow: [
                    BoxShadow(
                      color:
                          p.accentDeep.withValues(alpha: selected ? .25 : .05),
                      blurRadius: selected ? 14 : 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: Motion.short,
                curve: Motion.drive,
                // The dish is about 60% of the tile's width and only its top
                // third rises above the tile's edge; the rest sits inside.
                top: selected ? 2 : 6,
                child: AnimatedScale(
                  duration: Motion.short,
                  curve: Motion.drive,
                  scale: selected ? 1.08 : 1,
                  child: FoodArtView(art, size: 46),
                ),
              ),
              Positioned(
                bottom: 9,
                left: 2,
                right: 2,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? p.card : p.inkSoft,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
