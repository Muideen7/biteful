import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_theme.dart';
import '../../../config/design_tokens.dart';
import '../../../config/motion.dart';
import '../../../models/catalog.dart';
import '../../../providers/core_providers.dart';
import '../../../widgets/pressable.dart';
import '../../actions.dart';
import 'promo_art.dart';

/// The banners at the top of Home. They advance on their own every few
/// seconds (only while ambient motion is on), and stop while a finger is on
/// them.
class PromoCarousel extends ConsumerStatefulWidget {
  const PromoCarousel({super.key, required this.banners});

  final List<PromoBanner> banners;

  @override
  ConsumerState<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends ConsumerState<PromoCarousel> {
  final _pages = PageController();
  Timer? _timer;
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _pages.addListener(() => setState(() => _page = _pages.page ?? 0));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restart();
  }

  void _restart() {
    _timer?.cancel();
    if (!Motion.loops(context) || widget.banners.length < 2) return;
    _timer = Timer.periodic(Motion.bannerAutoAdvance, (_) {
      if (!_pages.hasClients) return;
      final next = (_pages.page!.round() + 1) % widget.banners.length;
      _pages.animateToPage(next,
          duration: Motion.long, curve: Curves.easeInOutCubic);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pages.dispose();
    super.dispose();
  }

  Future<void> _tap(PromoBanner b) async {
    final catalog = await ref.read(catalogProvider.future);
    if (!mounted) return;
    if (b.dealId case final id? when catalog.dealById[id] != null) {
      await toggleDeal(context, ref, catalog.dealById[id]!);
    } else if (b.restaurantId case final id?
        when catalog.restaurantById[id] != null) {
      openRestaurant(context, catalog.restaurantById[id]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final width = MediaQuery.sizeOf(context).width - Space.gutter * 2;
    final height = width / Sizes.bannerAspect;
    return Column(
      children: [
        SizedBox(
          height: height,
          child: Listener(
            onPointerDown: (_) => _timer?.cancel(),
            onPointerUp: (_) => _restart(),
            child: PageView.builder(
              controller: _pages,
              itemCount: widget.banners.length,
              itemBuilder: (_, i) {
                final b = widget.banners[i];
                // Content drifts against the swipe for a little parallax.
                final shift = (i - _page).clamp(-1.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
                  child: Pressable(
                    onTap: () => _tap(b),
                    semanticLabel:
                        '${b.lineOne} ${b.lineTwo}. ${b.subtitle}. ${b.cta}',
                    scale: .98,
                    child: PromoBannerCard(
                      banner: b,
                      parallax: shift,
                      riderHero:
                          i == widget.banners.indexWhere((x) => x.showsRider),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: Space.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.banners.length; i++)
                AnimatedContainer(
                  duration: Motion.short,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: (_page.round() == i) ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _page.round() == i ? p.accent : p.line,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
