import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_theme.dart';
import '../../../config/design_tokens.dart';
import '../../../config/motion.dart';
import '../../../models/deal.dart';
import '../../../providers/cart_providers.dart';
import '../../../widgets/food_art_view.dart';
import '../../../widgets/section_header.dart';
import '../../actions.dart';
import '../../shell/main_shell.dart';

class DealsStrip extends ConsumerWidget {
  const DealsStrip({super.key, required this.deals});

  final List<Deal> deals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SectionHeader(
          'Deals for you',
          action: 'See All',
          onAction: () =>
              ref.read(shellTabProvider.notifier).state = ShellTab.offers,
        ),
        HStrip(
          height: 112,
          itemCount: deals.length,
          itemBuilder: (_, i) =>
              SizedBox(width: 240, child: DealCard(deal: deals[i])),
        ),
      ],
    );
  }
}

/// The dark coupon card: eyebrow, big headline, the code in an outlined
/// chip and an Apply pill, with the dish bleeding off the right edge.
class DealCard extends ConsumerWidget {
  const DealCard({super.key, required this.deal, this.showTerms = false});

  final Deal deal;
  final bool showTerms;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final applied = ref.watch(appliedDealProvider) == deal.id;
    return Semantics(
      container: true,
      label: '${deal.eyebrow}, ${deal.headline}, code ${deal.code}',
      child: Container(
        decoration: BoxDecoration(
          color: p.dealCard,
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -18,
              top: -6,
              bottom: -6,
              child: Center(child: FoodArtView(deal.art, size: 118)),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      p.dealCard,
                      p.dealCard.withValues(alpha: .85),
                      p.dealCard.withValues(alpha: 0)
                    ],
                    stops: const [0, .45, .75],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.md + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.eyebrow.toUpperCase(),
                    style: TextStyle(
                        color: p.onDeal.withValues(alpha: .75),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .6),
                  ),
                  const SizedBox(height: 2),
                  Text(deal.headline,
                      style: TextStyle(
                          color: p.onDeal,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.05)),
                  if (showTerms) ...[
                    const SizedBox(height: 4),
                    Text(deal.terms,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: p.onDeal.withValues(alpha: .7),
                            fontSize: 11.5)),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Radii.pill),
                            border: Border.all(
                                color: p.onDeal.withValues(alpha: .35)),
                          ),
                          child: Text(
                            deal.code,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: p.onDeal,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _ApplyPill(
                          applied: applied,
                          onTap: () => toggleDeal(context, ref, deal)),
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

class _ApplyPill extends StatelessWidget {
  const _ApplyPill({required this.applied, required this.onTap});

  final bool applied;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: applied ? 'Applied, tap to remove' : 'Apply',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Motion.short,
          curve: Motion.enter,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: applied ? p.onDeal : p.accent,
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
          child: AnimatedSwitcher(
            duration: Motion.quick,
            child: Row(
              key: ValueKey(applied),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (applied) ...[
                  Icon(Icons.check_rounded, size: 13, color: p.accentDeep),
                  const SizedBox(width: 3),
                ],
                Text(
                  applied ? 'Applied' : 'Apply',
                  style: TextStyle(
                    color: applied ? p.accentDeep : const Color(0xFF16200C),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
