import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/design_tokens.dart';

/// "Categories ........ See All". The title takes the room and ellipsises;
/// the action never gets pushed off at large text sizes.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Space.gutter, Space.xl, Space.sm, Space.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.heading,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: context.palette.accentDeep,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(
                action!,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: context.palette.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A horizontal strip of cards that bleeds off the right edge, as the
/// reference does, so it reads as scrollable.
class HStrip extends StatelessWidget {
  const HStrip({
    super.key,
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = Space.md,
  });

  final double height;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
        clipBehavior: Clip.none,
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
