import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../config/motion.dart';
import '../../providers/cart_providers.dart';
import '../cart/cart_tab.dart';
import '../home/home_tab.dart';
import '../offers/offers_tab.dart';
import '../profile/profile_tab.dart';
import '../saved/saved_tab.dart';
import '../../widgets/fly_to_cart.dart';

enum ShellTab { home, saved, cart, offers, profile }

final shellTabProvider = StateProvider<ShellTab>((_) => ShellTab.home);

/// Home, Saved, Cart, Offers and Profile. Tabs keep their state and scroll
/// position when you move between them.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  /// Tabs are built the first time they are opened, then kept. Building
  /// all five up front made the first frame of Home heavy enough to drop
  /// the splash's whole drive-out in debug builds.
  final _visited = <ShellTab>{};

  static Widget _page(ShellTab t) => switch (t) {
        ShellTab.home => const HomeTab(),
        ShellTab.saved => const SavedTab(),
        ShellTab.cart => const CartTab(),
        ShellTab.offers => const OffersTab(),
        ShellTab.profile => const ProfileTab(),
      };

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(shellTabProvider);
    _visited.add(tab);
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: tab.index,
        children: [
          for (final t in ShellTab.values)
            _visited.contains(t) ? _page(t) : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: const _NavBar(),
    );
  }
}

class _NavBar extends ConsumerWidget {
  const _NavBar();

  static const _items = [
    (ShellTab.home, 'Home', Icons.home_outlined, Icons.home_rounded),
    (
      ShellTab.saved,
      'Saved',
      Icons.favorite_border_rounded,
      Icons.favorite_rounded
    ),
    (
      ShellTab.cart,
      'Cart',
      Icons.shopping_bag_outlined,
      Icons.shopping_bag_rounded
    ),
    (
      ShellTab.offers,
      'Offers',
      Icons.local_offer_outlined,
      Icons.local_offer_rounded
    ),
    (
      ShellTab.profile,
      'Profile',
      Icons.person_outline_rounded,
      Icons.person_rounded
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final current = ref.watch(shellTabProvider);
    final count = ref.watch(cartTotalsProvider).itemCount;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(Radii.xl)),
        boxShadow: [
          BoxShadow(
              color: p.accentDeep.withValues(alpha: .08),
              blurRadius: 24,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: Sizes.navHeight,
          child: Row(
            children: [
              for (final (tab, label, icon, active) in _items)
                Expanded(
                  child: _NavItem(
                    label: label,
                    icon: icon,
                    activeIcon: active,
                    selected: tab == current,
                    badge: tab == ShellTab.cart ? count : 0,
                    isCart: tab == ShellTab.cart,
                    onTap: () =>
                        ref.read(shellTabProvider.notifier).state = tab,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.selected,
    required this.badge,
    required this.onTap,
    this.isCart = false,
  });

  final bool isCart;

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = selected ? p.accent : p.muted;
    return Semantics(
      selected: selected,
      button: true,
      label: badge > 0 ? '$label, $badge items' : label,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: ExcludeSemantics(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    scale: selected ? 1.12 : 1,
                    duration: Motion.short,
                    curve: Motion.drive,
                    child: isCart
                        ? _Squash(
                            child: Icon(selected ? activeIcon : icon,
                                key: cartTargetKey, color: color, size: 25),
                          )
                        : Icon(selected ? activeIcon : icon,
                            color: color, size: 25),
                  ),
                  if (badge > 0)
                    Positioned(
                      right: -9,
                      top: -5,
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(badge),
                        tween: Tween(begin: 1.5, end: 1),
                        duration: Motion.medium,
                        curve: Curves.elasticOut,
                        builder: (_, s, child) =>
                            Transform.scale(scale: s, child: child),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          constraints: const BoxConstraints(minWidth: 18),
                          decoration: BoxDecoration(
                            color: p.accentDeep,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: p.card, width: 1.5),
                          ),
                          child: Text(
                            '$badge',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: p.card,
                                fontSize: 10,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The cart icon's squash and stretch when a dish lands in it.
class _Squash extends StatelessWidget {
  const _Squash({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: cartLanded,
      builder: (_, n, c) => TweenAnimationBuilder<double>(
        key: ValueKey(n),
        tween: Tween(begin: n == 0 ? 1 : 0, end: 1),
        duration: const Duration(milliseconds: 520),
        builder: (_, t, c) {
          // 0..1 -> a squash down, an overshoot up, then rest.
          final k = n == 0 ? 0.0 : (1 - t) * (1 - t);
          final wobble = k * (t < .3 ? -1 : 1) * .32;
          return Transform.scale(
              scaleX: 1 - wobble * .6, scaleY: 1 + wobble, child: c);
        },
        child: c,
      ),
      child: child,
    );
  }
}
