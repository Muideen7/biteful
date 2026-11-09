import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../models/catalog.dart';
import '../../models/money.dart';
import '../../models/ids.dart';
import '../../models/order.dart';
import '../../providers/cart_providers.dart';
import '../../providers/account_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/order_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/food_art_view.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/qty_stepper.dart';
import '../shell/main_shell.dart';
import '../shell/tab_page.dart';
import 'order_placed_sheet.dart';

class CartTab extends ConsumerStatefulWidget {
  const CartTab({super.key});

  @override
  ConsumerState<CartTab> createState() => _CartTabState();
}

class _CartTabState extends ConsumerState<CartTab> {
  bool _placing = false;

  Future<void> _checkout() async {
    final lines = ref.read(cartProvider);
    final catalog = await ref.read(catalogProvider.future);
    final deal = ref.read(appliedDealObjectProvider);
    final totals = ref.read(cartTotalsProvider);
    setState(() => _placing = true);
    final reference =
        await (await ref.read(orderRepositoryProvider.future)).place(
      lines,
      dealCode: totals.dealCheck is DealOk ? deal?.code : null,
    );
    final order = Order(
      id: Ids.next('o'),
      reference: reference,
      placedAt: ref.read(clockProvider)(),
      lines: [
        for (final l in lines)
          OrderLine(
              productId: l.productId,
              qty: l.qty,
              unitCents: catalog.productById[l.productId]!.priceCents),
      ],
      deliveryCents: totals.deliveryCents,
      discountCents: totals.discountCents,
      addressLabel: ref.read(currentAddressProvider)?.label ?? 'Home',
      dealCode: totals.dealCheck is DealOk ? deal?.code : null,
    );
    await ref.read(placedOrdersProvider.notifier).add(order);
    await ref.read(cartProvider.notifier).clear();
    if (totals.dealCheck is DealOk) {
      await ref.read(appliedDealProvider.notifier).apply(null);
    }
    if (!mounted) return;
    setState(() => _placing = false);
    await showOrderPlacedSheet(context, order: order);
  }

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(cartProvider);
    final catalog = ref.watch(catalogProvider).valueOrNull;
    final totals = ref.watch(cartTotalsProvider);
    final items = [
      for (final l in lines)
        if (catalog?.productById[l.productId] case final p?) (l, p),
    ];

    if (items.isEmpty) {
      return TabPage(title: 'Cart', slivers: [
        SliverToBoxAdapter(
          child: EmptyState(
            art: const FoodArt('takeout'),
            title: 'Your cart is empty',
            message: 'Add a dish or two and they will wait for you here.',
            action: 'Browse dishes',
            onAction: () =>
                ref.read(shellTabProvider.notifier).state = ShellTab.home,
          ),
        ),
      ]);
    }

    return TabPage(
      title: 'Cart',
      subtitle:
          '${totals.itemCount} ${totals.itemCount == 1 ? 'item' : 'items'}',
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(
            Space.gutter, Space.md, Space.gutter, Space.md),
        child: GradientButton(
          label: 'Checkout · ${money(totals.totalCents)}',
          busy: _placing,
          onPressed: _checkout,
        ),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              Space.gutter, Space.lg, Space.gutter, 0),
          sliver: SliverList.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: Space.md),
            itemBuilder: (_, i) =>
                _CartRow(line: items[i].$1, product: items[i].$2),
          ),
        ),
        const SliverToBoxAdapter(child: _PromoRow()),
        SliverToBoxAdapter(child: _Summary(totals: totals)),
      ],
    );
  }
}

class _CartRow extends ConsumerWidget {
  const _CartRow({required this.line, required this.product});

  final CartLine line;
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final cart = ref.read(cartProvider.notifier);
    return Dismissible(
      key: ValueKey(line.productId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        cart.remove(product.id);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text('${product.name} removed'),
            action: SnackBarAction(
                label: 'Undo',
                textColor: p.accent,
                onPressed: () => cart.setQty(product.id, line.qty)),
          ));
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: Space.xl),
        decoration: BoxDecoration(
            color: p.error, borderRadius: BorderRadius.circular(Radii.lg)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: p.card),
            const SizedBox(width: 6),
            Text('Remove',
                style: TextStyle(color: p.card, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      child: SoftCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: p.accentWash,
                  borderRadius: BorderRadius.circular(Radii.md)),
              child: FoodArtView(product.art, size: 52),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.title),
                  const SizedBox(height: 4),
                  Text(money(product.priceCents * line.qty),
                      style: context.title.copyWith(color: p.accent)),
                ],
              ),
            ),
            QtyStepper(
              qty: line.qty,
              compact: true,
              canRemove: true,
              onChanged: (q) => cart.setQty(product.id, q),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoRow extends ConsumerWidget {
  const _PromoRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final deal = ref.watch(appliedDealObjectProvider);
    final check = ref.watch(cartTotalsProvider).dealCheck;
    final note = switch (check) {
      DealNeedsMore(:final shortByCents) =>
        'Add ${money(shortByCents)} more to use it',
      DealOk() => deal?.terms,
      null => 'See this week\'s deals',
    };
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Space.gutter, Space.xl, Space.gutter, 0),
      child: Material(
        color: p.accentWash,
        borderRadius: BorderRadius.circular(Radii.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.lg),
          onTap: () =>
              ref.read(shellTabProvider.notifier).state = ShellTab.offers,
          child: Padding(
            padding: const EdgeInsets.all(Space.lg),
            child: Row(
              children: [
                Icon(Icons.local_offer_rounded, color: p.accent),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          deal == null
                              ? 'Add a promo code'
                              : '${deal.code} applied',
                          style: context.title),
                      if (note != null) ...[
                        const SizedBox(height: 2),
                        Text(note,
                            style: context.caption.copyWith(
                                color: check is DealNeedsMore
                                    ? p.error
                                    : p.muted)),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: p.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.totals});

  final CartTotals totals;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget row(String label, String value,
            {bool strong = false, Color? color}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
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
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Space.gutter, Space.lg, Space.gutter, 0),
      child: SoftCard(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          children: [
            row('Subtotal', money(totals.subtotalCents)),
            row(
                'Delivery',
                totals.deliveryCents == 0
                    ? 'Free'
                    : money(totals.deliveryCents)),
            if (totals.discountCents > 0)
              row('Discount', '-${money(totals.discountCents)}',
                  color: p.accent),
            Divider(color: p.line, height: Space.xl),
            row('Total', money(totals.totalCents), strong: true),
          ],
        ),
      ),
    );
  }
}
