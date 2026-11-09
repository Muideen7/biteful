import 'dart:ui';

import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/design_tokens.dart';

/// The one modal surface in the app. It rises from the bottom, blurs what
/// is behind it, carries a grab handle, lifts above the keyboard and caps
/// itself at 88% of the screen so long content scrolls inside.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: .22),
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (ctx, _, __) => _SheetFrame(title: title, builder: builder),
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: 6 * anim.value, sigmaY: 6 * anim.value),
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero)
              .animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.builder, this.title});

  final WidgetBuilder builder;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final mq = MediaQuery.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: mq.size.height * .88),
          child: Material(
            color: p.card,
            shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(Radii.xl + 4)),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 6),
                      width: 40,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: p.line,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          Space.gutter, Space.sm, Space.gutter, Space.sm),
                      child: Text(title!, style: context.heading),
                    ),
                  Flexible(child: Builder(builder: builder)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
