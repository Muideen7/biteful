import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../auth/auth_header.dart';

/// The frame for Saved, Cart, Offers and Profile: a short green header with
/// the title, in the same shape as Home's, then the page's slivers.
class TabPage extends StatelessWidget {
  const TabPage(
      {super.key,
      required this.title,
      required this.slivers,
      this.subtitle,
      this.bottom});

  final String title;
  final String? subtitle;
  final List<Widget> slivers;

  /// Pinned above the navigation bar, for a primary action.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: BrandHeaderShape(
                radius: Radii.header * .75,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      Space.gutter, top + Space.md, Space.gutter, Space.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: context.display.copyWith(color: p.card)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(subtitle!,
                            style: TextStyle(
                                color: p.card.withValues(alpha: .85),
                                fontWeight: FontWeight.w500)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            ...slivers,
            SliverToBoxAdapter(
                child: SizedBox(
                    height: Sizes.navHeight + 48 + (bottom == null ? 0 : 140))),
          ],
        ),
        if (bottom != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [p.paper.withValues(alpha: 0), p.paper, p.paper],
                  stops: const [0, .22, 1],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: Space.lg,
                  bottom:
                      Sizes.navHeight + MediaQuery.paddingOf(context).bottom,
                ),
                child: bottom!,
              ),
            ),
          ),
      ],
    );
  }
}
