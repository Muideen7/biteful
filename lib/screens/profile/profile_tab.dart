import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../providers/account_providers.dart';
import '../../providers/cart_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/order_providers.dart';
import '../../providers/reset.dart';
import '../../providers/session_providers.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../auth/sign_in_screen.dart';
import '../actions.dart';
import 'addresses_screen.dart';
import 'avatar_sheet.dart';
import 'edit_profile_sheet.dart';
import '../routes.dart';
import '../shell/brand_header_hero.dart';
import '../shell/main_shell.dart';
import '../shell/tab_page.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  /// Morphs the green header back into the sign-in screen, and only then
  /// runs [then]. Signing out first would blank this page (name, photo)
  /// while it is still on screen under the morph.
  Future<void> _toSignIn(BuildContext context,
      Future<void> Function(ProviderContainer) then) async {
    // The container, not this widget's ref: this page is disposed when the
    // sign-in route replaces the shell.
    final container = ProviderScope.containerOf(context, listen: false);
    final nav = Navigator.of(context, rootNavigator: true);
    nav.popUntil((r) => r.isFirst);
    final route = fadeRoute<void>(const SignInScreen(handOff: true));
    // A replacement, not pushAndRemoveUntil: the old route stays alive
    // under the transition, which is what lets the header Hero fly.
    nav.pushReplacement(route);
    // Wait for the whole transition: the old page is still fading out
    // until the very end, and must not change under it.
    final arrived = Completer<void>();
    whenRouteArrived(route.animation, arrived.complete, settled: 1);
    await arrived.future;
    await then(container);
  }

  Future<void> _signOut(BuildContext context) =>
      _toSignIn(context, (c) => c.read(sessionProvider.notifier).signOut());

  /// Back to a first launch: cart, saved, orders, deal, address, read marks
  /// and the session all go, so the whole flow can be shown again.
  Future<void> _reset(BuildContext context) =>
      _toSignIn(context, resetDemoData);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final profile = ref.watch(profileProvider).valueOrNull;
    final address = ref.watch(currentAddressProvider);
    final mode = ref.watch(themeModeProvider);
    final orders = ref.watch(ordersProvider);
    final live =
        orders.where((o) => o.isActiveAt(ref.watch(clockProvider)())).length;
    final saved = ref.watch(savedProvider).length;

    return TabPage(
      title: 'Profile',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              Space.gutter, Space.lg, Space.gutter, 0),
          sliver: SliverList.list(children: [
            SoftCard(
              padding: const EdgeInsets.all(Space.lg),
              child: Row(
                children: [
                  // The photo is the button: tap it to change it, as people
                  // expect, with a camera badge saying so.
                  Semantics(
                    button: true,
                    label: 'Change profile photo',
                    child: GestureDetector(
                      key: AvatarKeys.avatar,
                      onTap: profile == null
                          ? null
                          : () => showAvatarSheet(context,
                              hasPhoto: profile.avatar.isNotEmpty),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Avatar(profile: profile, size: 64),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: p.accent,
                                shape: BoxShape.circle,
                                border: Border.all(color: p.card, width: 2.5),
                              ),
                              child: Icon(Icons.photo_camera_rounded,
                                  size: 13, color: p.card),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile?.name ?? '', style: context.heading),
                        const SizedBox(height: 2),
                        Text(profile?.email ?? '',
                            style: context.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (profile != null)
                    IconButton.filledTonal(
                      tooltip: 'Edit profile',
                      onPressed: () => showEditProfileSheet(context, profile),
                      icon: Icon(Icons.edit_outlined,
                          color: p.accentDeep, size: 20),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Space.md),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => openOrders(context),
                    child: _Stat(value: '${orders.length}', label: 'Orders'),
                  ),
                ),
                const SizedBox(width: Space.md),
                Expanded(child: _Stat(value: '$saved', label: 'Saved')),
              ],
            ),
            const SizedBox(height: Space.xl),
            Text('Account', style: context.heading),
            const SizedBox(height: Space.sm),
            _Row(
              icon: Icons.receipt_long_outlined,
              title: 'My orders',
              value: live > 0 ? '$live on the way' : '${orders.length} orders',
              onTap: () => openOrders(context),
            ),
            _Row(
              icon: Icons.location_on_outlined,
              title: 'Addresses',
              value: address == null
                  ? null
                  : 'Delivering to ${address.label}, ${address.line}',
              onTap: () => tabNavigator(context)
                  .push(riseRoute(const AddressesScreen())),
            ),
            _Row(
              icon: Icons.person_outline_rounded,
              title: 'Personal details',
              value:
                  profile == null ? null : '${profile.name} · ${profile.phone}',
              onTap: profile == null
                  ? null
                  : () => showEditProfileSheet(context, profile),
            ),
            const SizedBox(height: Space.xl),
            Text('Appearance', style: context.heading),
            const SizedBox(height: Space.md),
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: p.accent,
                selectedForegroundColor: p.card,
                foregroundColor: p.inkSoft,
                side: BorderSide(color: p.line),
                textStyle: const TextStyle(
                    fontFamily: AppTheme.font, fontWeight: FontWeight.w700),
              ),
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('Auto')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {mode},
              onSelectionChanged: (s) =>
                  ref.read(themeModeProvider.notifier).set(s.first),
            ),
            const SizedBox(height: Space.xl),
            Text('Demo settings', style: context.heading),
            const SizedBox(height: Space.sm),
            _Row(
              icon: Icons.restart_alt_rounded,
              title: 'Reset demo data',
              value: 'Clears your cart, saved dishes, orders and edits',
              onTap: () => _reset(context),
            ),
            _Row(
              icon: Icons.logout_rounded,
              title: 'Sign out',
              danger: true,
              onTap: () => _signOut(context),
            ),
          ]),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: context.display.copyWith(color: context.palette.accent)),
          Text(label, style: context.caption),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(
      {required this.icon,
      required this.title,
      this.value,
      this.onTap,
      this.danger = false});

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = danger ? p.error : p.ink;
    return InkWell(
      borderRadius: BorderRadius.circular(Radii.md),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: danger ? p.error.withValues(alpha: .1) : p.accentWash,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: danger ? p.error : p.accent, size: 20),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.title.copyWith(color: color)),
                  if (value != null)
                    Text(value!,
                        style: context.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: p.muted),
          ],
        ),
      ),
    );
  }
}
