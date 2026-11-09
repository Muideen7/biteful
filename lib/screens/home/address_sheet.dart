import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../providers/account_providers.dart';
import '../../widgets/app_sheet.dart';

Future<void> showAddressSheet(BuildContext context) => showAppSheet(context,
    title: 'Deliver to', builder: (_) => const _AddressList());

class _AddressList extends ConsumerWidget {
  const _AddressList();

  static IconData _icon(String label) => switch (label.toLowerCase()) {
        'home' => Icons.home_rounded,
        'work' => Icons.work_rounded,
        _ => Icons.place_rounded,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final list = ref.watch(addressesProvider).valueOrNull ?? const [];
    final current = ref.watch(currentAddressProvider);
    return ListView(
      shrinkWrap: true,
      padding:
          const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.xl),
      children: [
        for (final a in list)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: Material(
              color: a.id == current?.id ? p.accentWash : p.field,
              borderRadius: BorderRadius.circular(Radii.lg),
              child: InkWell(
                borderRadius: BorderRadius.circular(Radii.lg),
                onTap: () async {
                  HapticFeedback.selectionClick();
                  await ref
                      .read(selectedAddressIdProvider.notifier)
                      .select(a.id);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(Space.lg),
                  child: Row(
                    children: [
                      Icon(_icon(a.label), color: p.accent),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.label, style: context.title),
                            const SizedBox(height: 2),
                            Text(a.line,
                                style: context.caption,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      if (a.id == current?.id)
                        Icon(Icons.check_circle_rounded, color: p.accent),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
