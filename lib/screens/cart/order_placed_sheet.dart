import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../models/money.dart';
import '../../widgets/app_sheet.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/rider/rider.dart';

/// The rider sets off with your order.
Future<void> showOrderPlacedSheet(BuildContext context,
    {required String reference, required int total}) {
  HapticFeedback.heavyImpact();
  return showAppSheet(context,
      builder: (_) => _Placed(reference: reference, total: total));
}

class _Placed extends StatelessWidget {
  const _Placed({required this.reference, required this.total});

  final String reference;
  final int total;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.xl),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: -1, end: 0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, t, child) =>
                Transform.translate(offset: Offset(t * 260, 0), child: child),
            child: const Rider(width: 220, speed: 1),
          ),
          const SizedBox(height: Space.md),
          Text('Order placed', style: context.display),
          const SizedBox(height: Space.sm),
          Text(
            'Your food is being prepared. A rider will pick it up shortly.',
            textAlign: TextAlign.center,
            style: context.body,
          ),
          const SizedBox(height: Space.lg),
          Container(
            padding: const EdgeInsets.all(Space.lg),
            decoration: BoxDecoration(
                color: p.accentWash,
                borderRadius: BorderRadius.circular(Radii.lg)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order', style: context.caption),
                      Text(reference, style: context.title),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Paid', style: context.caption),
                    Text(money(total),
                        style: context.title.copyWith(color: p.accent)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          GradientButton(
              label: 'Done', onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
