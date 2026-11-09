import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../models/catalog.dart';
import '../../providers/core_providers.dart';
import '../../providers/search_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/food_art_view.dart';
import '../../widgets/food_card.dart';
import '../../widgets/overscroll_fill.dart';
import '../../widgets/pressable.dart';
import '../actions.dart';
import '../auth/auth_header.dart';
import '../home/sections/category_strip.dart';

/// The Hero shared by Home's search pill and this page's field.
const searchBarTag = 'search-bar';

/// Search across restaurants and dishes as you type. With nothing typed it
/// offers recent searches, popular categories and the top restaurants.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final _field = TextEditingController(text: widget.initialQuery);
  final _focus = FocusNode();
  final _scroll = ScrollController();
  final _header = GlobalKey();

  String get _q => _field.text.trim();

  @override
  void initState() {
    super.initState();
    _field.addListener(() => setState(() {}));
    if (widget.initialQuery.isEmpty) {
      // After the page has arrived, so the keyboard does not race the Hero.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _field.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _searchFor(String q) {
    HapticFeedback.selectionClick();
    _field.text = q;
    _field.selection = TextSelection.collapsed(offset: q.length);
    ref.read(recentSearchesProvider.notifier).remember(q);
  }

  /// Opening a result counts as having searched for it.
  void _opened() => ref.read(recentSearchesProvider.notifier).remember(_q);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final top = MediaQuery.paddingOf(context).top;
    return Material(
      color: p.paper,
      child: Stack(children: [
        CustomScrollView(
          controller: _scroll,
          // Always scrollable, so even a short page bounces like the rest.
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: BrandHeaderShape(
                key: _header,
                radius: Radii.header * .75,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      Space.md, top + Space.sm, Space.gutter, Space.lg),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        color: p.card,
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Expanded(
                        child: Hero(
                          tag: searchBarTag,
                          child: _SearchField(
                            controller: _field,
                            focus: _focus,
                            onSubmitted: (q) => ref
                                .read(recentSearchesProvider.notifier)
                                .remember(q),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_q.isEmpty) ..._suggestions(context) else ..._results(context),
            const SliverToBoxAdapter(
                child: SizedBox(height: Sizes.navHeight + 60)),
          ],
        ),
        OverscrollFill(controller: _scroll, headerKey: _header),
      ]),
    );
  }

  List<Widget> _suggestions(BuildContext context) {
    final p = context.palette;
    final recent = ref.watch(recentSearchesProvider);
    final catalog = ref.watch(catalogProvider).valueOrNull;
    return [
      if (recent.isNotEmpty)
        SliverPadding(
          padding:
              const EdgeInsets.fromLTRB(Space.gutter, Space.xl, Space.sm, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text('Recent searches', style: context.heading)),
                    TextButton(
                      onPressed: () =>
                          ref.read(recentSearchesProvider.notifier).clear(),
                      child: Text('Clear',
                          style: TextStyle(
                              color: p.accent, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: Space.sm),
                Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.sm,
                  children: [
                    for (final r in recent)
                      InputChip(
                        label: Text(r),
                        avatar: Icon(Icons.history_rounded,
                            size: 16, color: p.muted),
                        onPressed: () => _searchFor(r),
                        onDeleted: () =>
                            ref.read(recentSearchesProvider.notifier).remove(r),
                        deleteButtonTooltipMessage: 'Remove $r',
                        backgroundColor: p.card,
                        side: BorderSide(color: p.line),
                        shape: const StadiumBorder(),
                        labelStyle: context.label,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      if (catalog != null) ...[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              Space.gutter, Space.xl, Space.gutter, Space.md),
          sliver: SliverToBoxAdapter(
              child: Text('Popular right now', style: context.heading)),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 98,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
              clipBehavior: Clip.none,
              itemCount: catalog.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => Align(
                alignment: Alignment.bottomCenter,
                child: CategoryTile(
                  name: catalog.categories[i].name,
                  art: catalog.categories[i].art,
                  selected: false,
                  onTap: () => _searchFor(catalog.categories[i].name),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              Space.gutter, Space.xl, Space.gutter, Space.md),
          sliver: SliverToBoxAdapter(
              child: Text('Top restaurants', style: context.heading)),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          sliver: SliverList.separated(
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: Space.sm),
            itemBuilder: (_, i) =>
                RestaurantRow(restaurant: catalog.popular[i]),
          ),
        ),
      ],
    ];
  }

  List<Widget> _results(BuildContext context) {
    final r = ref.watch(searchResultsProvider(_q));
    if (r.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: EmptyState(
            art: const FoodArt('takeout'),
            title: 'No results for "$_q"',
            message:
                'Try a dish, a cuisine or a restaurant, like ramen, Italian or Stack House.',
            action: 'Clear search',
            onAction: () => _field.clear(),
          ),
        ),
      ];
    }
    Widget header(String text) => SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              Space.gutter, Space.xl, Space.gutter, Space.md),
          sliver: SliverToBoxAdapter(child: Text(text, style: context.heading)),
        );
    return [
      if (r.restaurants.isNotEmpty) ...[
        header('Restaurants · ${r.restaurants.length}'),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          sliver: SliverList.separated(
            itemCount: r.restaurants.length,
            separatorBuilder: (_, __) => const SizedBox(height: Space.sm),
            itemBuilder: (_, i) =>
                RestaurantRow(restaurant: r.restaurants[i], onOpened: _opened),
          ),
        ),
      ],
      if (r.dishes.isNotEmpty) ...[
        header('Dishes · ${r.dishes.length}'),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: Space.md,
              crossAxisSpacing: Space.md,
              mainAxisExtent: 222,
            ),
            itemCount: r.dishes.length,
            itemBuilder: (context, i) => FoodCard(
              key: ValueKey(r.dishes[i].id),
              product: r.dishes[i],
              heroPrefix: 'search',
              artSize: 96,
              onTap: () {
                _opened();
                openProduct(context, r.dishes[i]);
              },
              onAdd: (k) {
                _opened();
                addToCart(context, ref, r.dishes[i], from: k);
              },
            ),
          ),
        ),
      ],
    ];
  }
}

/// The white pill: on Home it is a button that opens search; here it is
/// the field. One look, so the Hero between them is seamless.
class _SearchField extends StatelessWidget {
  const _SearchField(
      {required this.controller,
      required this.focus,
      required this.onSubmitted});

  final TextEditingController controller;
  final FocusNode focus;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(Radii.pill),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            const SizedBox(width: Space.lg),
            Icon(Icons.search_rounded, color: p.muted, size: 22),
            const SizedBox(width: Space.sm),
            Expanded(
              child: TextField(
                key: const Key('search-field'),
                controller: controller,
                focusNode: focus,
                textInputAction: TextInputAction.search,
                onSubmitted: onSubmitted,
                style: context.title.copyWith(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Search dishes or restaurants',
                  hintStyle: context.body.copyWith(color: p.muted),
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              IconButton(
                tooltip: 'Clear',
                onPressed: controller.clear,
                icon: Icon(Icons.cancel_rounded, color: p.muted, size: 20),
              )
            else
              const SizedBox(width: Space.md),
          ],
        ),
      ),
    );
  }
}

/// Home's search pill. Looks exactly like the field it turns into.
class SearchPill extends StatelessWidget {
  const SearchPill({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Search dishes or restaurants',
      scale: .98,
      child: Hero(
        tag: searchBarTag,
        child: Material(
          color: p.card,
          borderRadius: BorderRadius.circular(Radii.pill),
          elevation: 0,
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                const SizedBox(width: Space.lg),
                Icon(Icons.search_rounded, color: p.muted, size: 22),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text('Search dishes or restaurants',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.body.copyWith(color: p.muted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A restaurant as a list row: dishes, name, cuisine, rating, time.
class RestaurantRow extends StatelessWidget {
  const RestaurantRow({super.key, required this.restaurant, this.onOpened});

  final Restaurant restaurant;
  final VoidCallback? onOpened;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = restaurant;
    return Pressable(
      onTap: () {
        onOpened?.call();
        openRestaurant(context, r);
      },
      semanticLabel: '${r.name}, ${r.cuisine}, rated ${r.rating}',
      scale: .98,
      child: SoftCard(
        padding: const EdgeInsets.all(Space.sm + 2),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: p.accentWash,
                  borderRadius: BorderRadius.circular(Radii.md)),
              child: Center(child: FoodArtView(r.art, size: 50)),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.title.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(r.cuisine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.caption),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: p.star),
                      const SizedBox(width: 2),
                      Text(r.rating.toStringAsFixed(1), style: context.label),
                      const SizedBox(width: Space.md),
                      Flexible(child: MetaChip(Icons.schedule_rounded, r.eta)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.muted),
          ],
        ),
      ),
    );
  }
}
