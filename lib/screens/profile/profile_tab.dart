import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../providers/account_providers.dart';
import '../../providers/cart_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/session_providers.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../auth/sign_in_screen.dart';
import '../home/address_sheet.dart';
import '../home/sections/category_strip.dart';
import '../routes.dart';
import '../shell/main_shell.dart';
import '../shell/tab_page.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(sessionProvider.notifier).signOut();
    ref.read(shellTabProvider.notifier).state = ShellTab.home;
    if (context.mounted) {
      Navigator.of(context)
          .pushAndRemoveUntil(fadeRoute(const SignInScreen()), (_) => false);
    }
  }

  /// Back to a first launch: cart, saved, orders, deal, address, read marks
  /// and the session all go, so the whole flow can be shown again.
  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    await ref.read(storeProvider).reset();
    for (final p in [
      sessionProvider,
      cartProvider,
      savedProvider,
      appliedDealProvider,
      placedOrdersProvider,
      selectedAddressIdProvider,
      readMarksProvider,
      themeModeProvider,
    ]) {
      ref.invalidate(p);
    }
    ref.invalidate(selectedCategoryProvider);
    ref.read(shellTabProvider.notifier).state = ShellTab.home;
    if (context.mounted) {
      Navigator.of(context)
          .pushAndRemoveUntil(fadeRoute(const SignInScreen()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final profile = ref.watch(sessionProvider);
    final address = ref.watch(currentAddressProvider);
    final mode = ref.watch(themeModeProvider);
    final orders = ref.watch(orderAgainProvider).length;
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
                  Avatar(profile: profile, size: 60),
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
                ],
              ),
            ),
            const SizedBox(height: Space.md),
            Row(
              children: [
                Expanded(
                    child: _Stat(value: '$orders', label: 'Dishes ordered')),
                const SizedBox(width: Space.md),
                Expanded(child: _Stat(value: '$saved', label: 'Saved')),
              ],
            ),
            const SizedBox(height: Space.xl),
            Text('Account', style: context.heading),
            const SizedBox(height: Space.sm),
            _Row(
              icon: Icons.location_on_outlined,
              title: 'Delivery address',
              value:
                  address == null ? null : '${address.label}, ${address.line}',
              onTap: () => showAddressSheet(context),
            ),
            _Row(
                icon: Icons.phone_outlined,
                title: 'Phone',
                value: profile?.phone),
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
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
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
              value: 'Clears your cart, saved dishes and orders',
              onTap: () => _reset(context, ref),
            ),
            _Row(
              icon: Icons.logout_rounded,
              title: 'Sign out',
              danger: true,
              onTap: () => _signOut(context, ref),
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
