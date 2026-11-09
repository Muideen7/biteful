import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../models/account.dart';
import '../../models/catalog.dart';
import '../../models/money.dart';
import '../../models/order.dart';
import '../../providers/core_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/food_art_view.dart';
import '../../widgets/pressable.dart';
import '../actions.dart';

extension OrderStatusText on OrderStatus {
  String get label => switch (this) {
        OrderStatus.preparing => 'Preparing',
        OrderStatus.onTheWay => 'On the way',
        OrderStatus.delivered => 'Delivered',
      };

  IconData get icon => switch (this) {
        OrderStatus.preparing => Icons.soup_kitchen_rounded,
        OrderStatus.onTheWay => Icons.delivery_dining_rounded,
        OrderStatus.delivered => Icons.check_circle_rounded,
      };
}

/// The status as a small pill. Live orders are in the accent; delivered
/// ones go quiet. The icon and word carry the meaning, not the colour.
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final live = status != OrderStatus.delivered;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: live ? p.accent : p.field,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 13, color: live ? p.card : p.muted),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: live ? p.card : p.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

/// "2 x Tonkotsu Ramen, Pork Dumplings".
String itemsSummary(Order o, Map<String, String> names) => o.lines
    .map((l) =>
        '${l.qty > 1 ? '${l.qty} x ' : ''}${names[l.productId] ?? 'Item'}')
    .join(', ');

/// One order in the list: its dishes, reference, status, what was in it,
/// when, the total, and Track or Reorder.
class OrderCard extends ConsumerStatefulWidget {
  const OrderCard({super.key, required this.order, required this.now});

  final Order order;
  final DateTime now;

  @override
  ConsumerState<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<OrderCard> {
  final _art = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final o = widget.order;
    final status = o.statusAt(widget.now);
    final catalog = ref.watch(catalogProvider).valueOrNull;
    final names = <String, String>{
      for (final x in catalog?.products ?? const <Product>[]) x.id: x.name
    };
    final arts = [
      for (final l in o.lines.take(2))
        if (catalog?.productById[l.productId] case final prod?) prod.art,
    ];
    final live = status != OrderStatus.delivered;

    return Pressable(
      onTap: () => openOrder(context, o.id),
      semanticLabel:
          'Order ${o.reference}, ${status.label}, ${money(o.totalCents)}',
      scale: .98,
      child: SoftCard(
        padding: const EdgeInsets.all(Space.md + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  key: _art,
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                      color: p.accentWash,
                      borderRadius: BorderRadius.circular(Radii.md)),
                  child: Stack(
                    children: [
                      if (arts.isNotEmpty)
                        Positioned(
                            left: 4,
                            top: 4,
                            child: FoodArtView(arts.first, size: 40)),
                      if (arts.length > 1)
                        Positioned(
                            right: 3,
                            bottom: 3,
                            child: FoodArtView(arts[1], size: 26)),
                    ],
                  ),
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(o.reference, style: context.title)),
                          StatusChip(status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        itemsSummary(o, names),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.body.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        live
                            ? 'Arriving in ${o.minutesLeftAt(widget.now)} min'
                            : whenLabel(o.placedAt, widget.now),
                        style: context.caption.copyWith(
                          color: live ? p.accent : p.muted,
                          fontWeight: live ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(color: p.line, height: Space.xl),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${o.itemCount} ${o.itemCount == 1 ? 'item' : 'items'} · ${money(o.totalCents)}',
                    style: context.title.copyWith(fontSize: 13.5),
                  ),
                ),
                if (live)
                  _Action(
                      label: 'Track',
                      icon: Icons.near_me_rounded,
                      filled: true,
                      onTap: () => openOrder(context, o.id))
                else
                  _Action(
                    label: 'Reorder',
                    icon: Icons.replay_rounded,
                    onTap: () => reorderAll(context, ref, o, from: _art),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(
      {required this.label,
      required this.icon,
      required this.onTap,
      this.filled = false});

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: filled ? p.accent : p.accentWash,
      borderRadius: BorderRadius.circular(Radii.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.pill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: filled ? p.card : p.accentDeep),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: filled ? p.card : p.accentDeep),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
