import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../config/motion.dart';
import '../../models/account.dart';
import '../../models/catalog.dart';
import '../../models/money.dart';
import '../../models/order.dart';
import '../../providers/account_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/order_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/food_art_view.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/rider/rider.dart';
import '../../widgets/ticking.dart';
import '../actions.dart';
import '../shell/tab_page.dart';
import 'order_widgets.dart';

/// One order, followed live: where it is, each step with its time, where
/// it is going, what is in it and what it cost. Reorder is pinned.
class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  final _art = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final o = ref.watch(orderByIdProvider(widget.orderId));
    if (o == null) {
      return const TabPage(title: 'Order', slivers: [
        SliverToBoxAdapter(
          child: EmptyState(
            art: FoodArt('takeout'),
            title: 'This order is no longer here',
            message: 'It may have been cleared with the demo data.',
          ),
        ),
      ]);
    }
    return Ticking(
      every: const Duration(seconds: 5),
      builder: (context, now) {
        final status = o.statusAt(now);
        return TabPage(
          title: o.reference,
          subtitle: switch (status) {
            OrderStatus.preparing => 'Arriving in ${o.minutesLeftAt(now)} min',
            OrderStatus.onTheWay => 'Arriving in ${o.minutesLeftAt(now)} min',
            OrderStatus.delivered =>
              'Delivered ${whenLabel(o.deliveredAt, now)}',
          },
          trailing: StatusChip(status),
          bottom: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
            child: GradientButton(
              label: 'Reorder · ${money(o.subtotalCents)}',
              onPressed: () => reorderAll(context, ref, o, from: _art),
            ),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  Space.gutter, Space.lg, Space.gutter, 0),
              sliver: SliverList.list(children: [
                _Tracker(order: o, now: now, artKey: _art),
                const SizedBox(height: Space.md),
                _Steps(order: o, now: now),
                const SizedBox(height: Space.md),
                _DeliverTo(label: o.addressLabel),
                const SizedBox(height: Space.md),
                _Items(order: o),
              ]),
            ),
          ],
        );
      },
    );
  }
}

/// Kitchen on the left, your door on the right, and the rider between them
/// at the order's progress. Before pickup the first dish simmers in the
/// kitchen; after delivery a tick sits at the door.
class _Tracker extends ConsumerWidget {
  const _Tracker(
      {required this.order, required this.now, required this.artKey});

  final Order order;
  final DateTime now;
  final GlobalKey artKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final status = order.statusAt(now);
    final first = ref
        .watch(catalogProvider)
        .valueOrNull
        ?.productById[order.lines.first.productId];
    // The ride is the part of the bar the rider travels.
    // One number drives both the bar and the rider, so they never disagree.
    final progress = order.progressAt(now);

    return SoftCard(
      padding:
          const EdgeInsets.fromLTRB(Space.lg, Space.lg, Space.lg, Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            switch (status) {
              OrderStatus.preparing => 'The kitchen is preparing your order',
              OrderStatus.onTheWay => 'Your rider is on the way',
              OrderStatus.delivered => 'Delivered. Enjoy your meal',
            },
            style: context.heading,
          ),
          const SizedBox(height: Space.lg),
          SizedBox(
            height: 92,
            child: LayoutBuilder(builder: (context, c) {
              const riderW = 96.0;
              // The road runs 18px in from each end; the rider's front
              // wheel sits on the bar's leading edge.
              final edge = 18 + (c.maxWidth - 36) * progress;
              final x = (edge - riderW * .82).clamp(0.0, c.maxWidth - riderW);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // The road.
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 14,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        color: p.accent,
                        backgroundColor: p.line,
                      ),
                    ),
                  ),
                  Positioned(
                      left: 0,
                      bottom: 0,
                      child:
                          _End(icon: Icons.soup_kitchen_rounded, done: true)),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: _End(
                        icon: Icons.home_rounded,
                        done: status == OrderStatus.delivered),
                  ),
                  if (status == OrderStatus.preparing && first != null)
                    Positioned(
                      left: 30,
                      bottom: 28,
                      child: _Simmer(
                          child: FoodArtView(first.art, key: artKey, size: 56)),
                    ),
                  if (status == OrderStatus.onTheWay)
                    AnimatedPositioned(
                      duration: Motion.long,
                      curve: Motion.settle,
                      left: x,
                      bottom: 16,
                      child: const Rider(
                          width: riderW, speed: .8, showBlob: false),
                    ),
                  if (status == OrderStatus.delivered)
                    Positioned(
                      right: 44,
                      bottom: 26,
                      child: Icon(Icons.check_circle_rounded,
                          color: p.accent, size: 44),
                    ),
                  if (status != OrderStatus.preparing && first != null)
                    // Keeps a reorder flight's take-off point on screen.
                    Positioned(
                      left: 30,
                      bottom: 28,
                      child: Opacity(
                          opacity: .0,
                          child: FoodArtView(first.art, key: artKey, size: 40)),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _End extends StatelessWidget {
  const _End({required this.icon, required this.done});

  final IconData icon;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: done ? p.accent : p.card,
        shape: BoxShape.circle,
        border: Border.all(color: done ? p.accent : p.line, width: 2),
      ),
      child: Icon(icon, size: 17, color: done ? p.card : p.muted),
    );
  }
}

/// A gentle rise and fall, like something on the stove.
class _Simmer extends StatefulWidget {
  const _Simmer({required this.child});

  final Widget child;

  @override
  State<_Simmer> createState() => _SimmerState();
}

class _SimmerState extends State<_Simmer> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.loops(context)) {
      if (!_c.isAnimating) _c.repeat(reverse: true);
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, -4 * Curves.easeInOut.transform(_c.value)),
          child: Transform.rotate(angle: .06 * (_c.value - .5), child: child),
        ),
        child: widget.child,
      );
}

/// Placed, prepared, picked up, delivered: each with its time once reached.
class _Steps extends StatelessWidget {
  const _Steps({required this.order, required this.now});

  final Order order;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final steps = [
      ('Order placed', order.placedAt),
      ('Being prepared', order.placedAt.add(const Duration(minutes: 1))),
      ('Picked up by your rider', order.pickedUpAt),
      ('Delivered', order.deliveredAt),
    ];
    return SoftCard(
      padding: const EdgeInsets.all(Space.lg),
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            _StepRow(
              title: steps[i].$1,
              time: steps[i].$2,
              reached: !now.isBefore(steps[i].$2),
              current: !now.isBefore(steps[i].$2) &&
                  (i == steps.length - 1 || now.isBefore(steps[i + 1].$2)),
              last: i == steps.length - 1,
              color: p.accent,
            ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.title,
    required this.time,
    required this.reached,
    required this.current,
    required this.last,
    required this.color,
  });

  final String title;
  final DateTime time;
  final bool reached;
  final bool current;
  final bool last;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: Motion.short,
                  width: current ? 18 : 14,
                  height: current ? 18 : 14,
                  margin: EdgeInsets.only(top: current ? 1 : 3),
                  decoration: BoxDecoration(
                    color: reached ? color : p.card,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: reached ? color : p.line, width: 2),
                    boxShadow: [
                      if (current)
                        BoxShadow(
                            color: color.withValues(alpha: .35),
                            blurRadius: 10,
                            spreadRadius: 2)
                    ],
                  ),
                  child: reached && !current
                      ? Icon(Icons.check_rounded, size: 9, color: p.card)
                      : null,
                ),
                if (!last)
                  Expanded(
                    child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        color: reached ? color : p.line),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : Space.lg),
              child: Text(
                title,
                style: context.title.copyWith(
                  color: reached ? p.ink : p.muted,
                  fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
          Text(reached ? clockLabel(time) : 'About ${clockLabel(time)}',
              style: context.caption),
        ],
      ),
    );
  }
}

class _DeliverTo extends ConsumerWidget {
  const _DeliverTo({required this.label});

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final list = ref.watch(addressesProvider).valueOrNull ?? const [];
    final line = list.where((a) => a.label == label).firstOrNull?.line;
    return SoftCard(
      padding: const EdgeInsets.all(Space.lg),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: p.accentWash, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.location_on_rounded, color: p.accent, size: 20),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deliver to $label', style: context.title),
                if (line != null)
                  Text(line,
                      style: context.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Items extends ConsumerWidget {
  const _Items({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final products =
        ref.watch(catalogProvider).valueOrNull?.productById ?? const {};
    Widget row(String label, String value,
            {bool strong = false, Color? color}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                  child: Text(label,
                      style: strong ? context.heading : context.body)),
              Text(value,
                  style: (strong ? context.heading : context.title)
                      .copyWith(color: color)),
            ],
          ),
        );
    return SoftCard(
      padding: const EdgeInsets.all(Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your order', style: context.heading),
          const SizedBox(height: Space.md),
          for (final l in order.lines)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.md),
              child: Row(
                children: [
                  if (products[l.productId] case final prod?)
                    FoodArtView(prod.art, size: 40)
                  else
                    const SizedBox.square(dimension: 40),
                  const SizedBox(width: Space.md),
                  Text('${l.qty} x',
                      style: context.title.copyWith(color: p.accent)),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(products[l.productId]?.name ?? 'Item',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.title),
                  ),
                  Text(money(l.totalCents), style: context.title),
                ],
              ),
            ),
          Divider(color: p.line, height: Space.lg),
          row('Subtotal', money(order.subtotalCents)),
          row('Delivery',
              order.deliveryCents == 0 ? 'Free' : money(order.deliveryCents)),
          if (order.discountCents > 0)
            row(
                order.dealCode == null
                    ? 'Discount'
                    : 'Discount (${order.dealCode})',
                '-${money(order.discountCents)}',
                color: p.accent),
          Divider(color: p.line, height: Space.lg),
          row('Total', money(order.totalCents), strong: true),
        ],
      ),
    );
  }
}
