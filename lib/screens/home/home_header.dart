import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../providers/account_providers.dart';
import '../../providers/session_providers.dart';
import '../../widgets/avatar.dart';
import '../../widgets/pressable.dart';
import 'address_sheet.dart';
import 'notifications_sheet.dart';

/// Avatar, "Deliver to" and the address, and the bell. Painted with the
/// same gradient, at the same scale, as the blob below it, so at rest the
/// two read as one shape.
class HomeHeaderBar extends ConsumerWidget {
  const HomeHeaderBar(
      {super.key, required this.roundness, required this.shadow});

  /// 0 at rest, 1 once content has scrolled under the bar.
  final double roundness;
  final double shadow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final top = MediaQuery.paddingOf(context).top;
    final radius = Radius.circular(Radii.header * .75 * roundness);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: radius),
        boxShadow: [
          if (shadow > 0)
            BoxShadow(
              color: p.accentDeep.withValues(alpha: .22 * shadow),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(bottom: radius),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: top + Sizes.homeBar + Sizes.homeHeaderReach,
              child: DecoratedBox(
                  decoration: BoxDecoration(gradient: p.headerGradient)),
            ),
            Positioned(
              left: Space.gutter,
              right: Space.gutter - 4,
              top: top,
              height: Sizes.homeBar,
              child: const _BarContent(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarContent extends ConsumerWidget {
  const _BarContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final profile = ref.watch(profileProvider).valueOrNull;
    final address = ref.watch(currentAddressProvider);
    final unread = ref.watch(unreadCountProvider);
    final onGreen = p.card;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(color: onGreen, shape: BoxShape.circle),
          child: Avatar(profile: profile, size: 40),
        ),
        const SizedBox(width: Space.md),
        Expanded(
          child: Pressable(
            onTap: () => showAddressSheet(context),
            semanticLabel: 'Deliver to ${address?.label ?? ''}, change address',
            scale: .98,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 14, color: const Color(0xFFD7EFA9)),
                    const SizedBox(width: 4),
                    Text(
                      'Deliver to',
                      style: TextStyle(
                          color: onGreen.withValues(alpha: .8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: '${address?.label ?? 'Home'}  ',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: address?.line ?? '',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: onGreen.withValues(alpha: .9)),
                          ),
                        ]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: onGreen, fontSize: 14.5),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        color: onGreen, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: Space.sm),
        Semantics(
          button: true,
          label: unread > 0 ? 'Notifications, $unread unread' : 'Notifications',
          child: Pressable(
            onTap: () => showNotificationsSheet(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: onGreen.withValues(alpha: .16),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      color: onGreen, size: 22),
                  if (unread > 0)
                    Positioned(
                      top: 10,
                      right: 11,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: p.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: onGreen, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shown while the menu loads: the shapes of the sections, still. A static
/// placeholder rather than a looping shimmer, so it never runs forever.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget block(double h, {double? w, double r = Radii.lg}) => Container(
          height: h,
          width: w,
          decoration: BoxDecoration(
              color: p.line.withValues(alpha: .6),
              borderRadius: BorderRadius.circular(r)),
        );
    return Semantics(
      label: 'Loading the menu',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            block(150, r: Radii.xl),
            const SizedBox(height: Space.xxl),
            block(18, w: 120, r: 6),
            const SizedBox(height: Space.md),
            Row(children: [
              for (var i = 0; i < 5; i++) ...[
                block(72, w: 58),
                const SizedBox(width: 10)
              ]
            ]),
            const SizedBox(height: Space.xxl),
            block(18, w: 140, r: 6),
            const SizedBox(height: Space.md),
            block(70),
          ],
        ),
      ),
    );
  }
}
