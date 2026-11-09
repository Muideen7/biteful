import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../models/catalog.dart';
import '../../providers/order_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/ticking.dart';
import '../shell/main_shell.dart';
import '../shell/tab_page.dart';
import 'order_widgets.dart';

/// My orders: what is on its way now, then everything before.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    return Ticking(
      builder: (context, now) {
        final active = [
          for (final o in orders)
            if (o.isActiveAt(now)) o
        ];
        final past = [
          for (final o in orders)
            if (!o.isActiveAt(now)) o
        ];
        Widget section(String title, List orders) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  Space.gutter, Space.xl, Space.gutter, 0),
              sliver: SliverList.list(children: [
                Text(title, style: context.heading),
                const SizedBox(height: Space.md),
                for (final o in orders) ...[
                  OrderCard(key: ValueKey(o.id), order: o, now: now),
                  const SizedBox(height: Space.md),
                ],
              ]),
            );
        return TabPage(
          title: 'My orders',
          subtitle: orders.isEmpty
              ? null
              : active.isEmpty
                  ? '${orders.length} orders'
                  : '${active.length} on the way · ${orders.length} in total',
          slivers: [
            if (orders.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  art: const FoodArt('takeout'),
                  title: 'No orders yet',
                  message:
                      'When you order, you can follow it here from the kitchen to your door.',
                  action: 'Find something to eat',
                  onAction: () {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                    ref.read(shellTabProvider.notifier).state = ShellTab.home;
                  },
                ),
              ),
            if (active.isNotEmpty) section('On the way', active),
            if (past.isNotEmpty) section('Past orders', past),
          ],
        );
      },
    );
  }
}
