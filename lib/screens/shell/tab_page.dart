import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../widgets/overscroll_fill.dart';
import '../auth/auth_header.dart';

/// The frame for Saved, Cart, Offers and Profile: a short green header with
/// the title, in the same shape as Home's, then the page's slivers.
class TabPage extends StatefulWidget {
  const TabPage(
      {super.key,
      required this.title,
      required this.slivers,
      this.subtitle,
      this.bottom,
      this.trailing});

  final String title;
  final String? subtitle;
  final List<Widget> slivers;

  /// Pinned above the navigation bar, for a primary action.
  final Widget? bottom;

  /// Sits at the right of the title, on the green.
  final Widget? trailing;

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  final _scroll = ScrollController();
  final _header = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final top = MediaQuery.paddingOf(context).top;
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    // Opaque: pages pushed inside a tab must cover the page beneath them.
    return Material(
      color: p.paper,
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            // Always scrollable, so even a short page bounces like the rest.
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: BrandHeaderShape(
                  key: _header,
                  radius: Radii.header * .75,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        Space.gutter, top + Space.md, Space.gutter, Space.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (canPop) ...[
                              IconButton.filled(
                                tooltip: 'Back',
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      p.card.withValues(alpha: .18),
                                  foregroundColor: p.card,
                                ),
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                              const SizedBox(width: Space.sm),
                            ],
                            Expanded(
                              child: Text(widget.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      context.display.copyWith(color: p.card)),
                            ),
                            if (widget.trailing != null) widget.trailing!,
                          ],
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(widget.subtitle!,
                              style: TextStyle(
                                  color: p.card.withValues(alpha: .85),
                                  fontWeight: FontWeight.w500)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              ...widget.slivers,
              SliverToBoxAdapter(
                  child: SizedBox(
                      height: Sizes.navHeight +
                          48 +
                          (widget.bottom == null ? 0 : 140))),
            ],
          ),
          OverscrollFill(controller: _scroll, headerKey: _header),
          if (widget.bottom != null)
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
                  child: widget.bottom!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
