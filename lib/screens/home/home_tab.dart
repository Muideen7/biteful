import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/app_timing.dart';
import '../../config/design_tokens.dart';
import '../../config/motion.dart';
import '../splash/splash_overlay.dart';
import '../../models/catalog.dart';
import '../../services/catalog_repository.dart';
import '../../providers/core_providers.dart';
import '../../widgets/common.dart';
import '../auth/auth_header.dart';
import '../actions.dart';
import '../search/search_screen.dart';
import 'home_header.dart';
import 'sections/best_sellers.dart';
import 'sections/category_strip.dart';
import 'sections/deals_strip.dart';
import 'sections/fast_delivery_strip.dart';
import 'sections/order_again_strip.dart';
import 'sections/promo_carousel.dart';
import 'sections/restaurants_strip.dart';

/// Home, in the reference's order: header, promo banner, Categories, Order
/// again, Deals for you, Popular restaurants near you, Fast delivery, then
/// the Best Sellers grid.
class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  late final _entrance =
      AnimationController(vsync: this, duration: Motion.homeEntrance);

  @override
  void initState() {
    super.initState();
    startWhenRevealed(ref, _entrance.forward);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _entrance.dispose();
    super.dispose();
  }

  /// One controller, sliced: each section rises in a beat after the last.
  Widget _rise(int i, Widget child) {
    final start = (.12 * i).clamp(0.0, .6);
    final anim = CurvedAnimation(
      parent: _entrance,
      curve: Interval(start, (start + .45).clamp(0, 1), curve: Motion.enter),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, c) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
            offset: Offset(0, 28 * (1 - anim.value)), child: c),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final barH = top + Sizes.homeBar;
    final catalog = ref.watch(catalogProvider);

    return Stack(
      children: [
        // The green blob behind the banner. It scrolls away with the
        // content; it is the Hero the sign-in header morphs into.
        AnimatedBuilder(
          animation: _scroll,
          builder: (_, __) {
            final offset =
                _scroll.hasClients ? _scroll.offset.clamp(0.0, 400.0) : 0.0;
            return Positioned(
              top: -offset,
              left: 0,
              right: 0,
              height: barH + Sizes.homeHeaderReach,
              child: const Hero(tag: brandHeaderTag, child: BrandHeaderShape()),
            );
          },
        ),
        RefreshIndicator(
          edgeOffset: barH,
          color: context.palette.accent,
          onRefresh: () => AppTiming.refreshing(() async {}),
          child: CustomScrollView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: switch (catalog) {
              AsyncData(:final value) => _content(value, barH),
              AsyncError() => [
                  SliverToBoxAdapter(
                      child: SizedBox(height: barH + Sizes.homeHeaderReach)),
                  SliverToBoxAdapter(
                    child: EmptyState(
                      art: const FoodArt('takeout'),
                      title: "We couldn't load the menu",
                      message: 'Check your connection and try again.',
                      action: 'Try again',
                      onAction: () => ref.invalidate(catalogProvider),
                    ),
                  ),
                ],
              _ => [
                  SliverToBoxAdapter(child: SizedBox(height: barH + Space.md)),
                  const SliverToBoxAdapter(child: HomeSkeleton()),
                ],
            },
          ),
        ),
        // The pinned bar. Square-cornered at rest so it joins the blob;
        // it rounds its lower corners as the content slides under it.
        AnimatedBuilder(
          animation: _scroll,
          builder: (_, __) {
            final offset = _scroll.hasClients ? _scroll.offset : 0.0;
            final k = (offset / Sizes.homeHeaderReach).clamp(0.0, 1.0);
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: barH,
              child: _rise(0, HomeHeaderBar(roundness: k, shadow: k)),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _content(Catalog c, double barH) {
    final s = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(
            Space.gutter, 0, Space.gutter, Space.md + 2),
        child: SearchPill(onTap: () => openSearch(context)),
      ),
      PromoCarousel(banners: c.banners),
      const CategoryStrip(),
      const OrderAgainStrip(),
      DealsStrip(deals: c.deals),
      RestaurantsStrip(restaurants: c.popular),
      FastDeliveryStrip(products: c.fastDelivery),
    ];
    return [
      SliverToBoxAdapter(child: SizedBox(height: barH + Space.xs)),
      for (var i = 0; i < s.length; i++)
        SliverToBoxAdapter(child: _rise(i + 1, s[i])),
      ...BestSellers.slivers(context, ref, c, (w) => _rise(s.length + 1, w)),
      const SliverToBoxAdapter(child: SizedBox(height: Sizes.navHeight + 48)),
    ];
  }
}
