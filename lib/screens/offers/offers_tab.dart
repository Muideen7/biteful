import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/design_tokens.dart';
import '../../providers/core_providers.dart';
import '../home/sections/deals_strip.dart';
import '../shell/tab_page.dart';

class OffersTab extends ConsumerWidget {
  const OffersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deals = ref.watch(catalogProvider).valueOrNull?.deals ?? const [];
    return TabPage(
      title: 'Offers',
      subtitle: 'One code per order. Apply it here or at checkout.',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              Space.gutter, Space.lg, Space.gutter, 0),
          sliver: SliverList.separated(
            itemCount: deals.length,
            separatorBuilder: (_, __) => const SizedBox(height: Space.md),
            itemBuilder: (_, i) => SizedBox(
                height: 138, child: DealCard(deal: deals[i], showTerms: true)),
          ),
        ),
      ],
    );
  }
}
