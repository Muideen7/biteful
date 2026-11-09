import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/palette.dart';
import '../config/design_tokens.dart';
import '../models/catalog.dart';
import 'food_art_view.dart';

/// A small icon + text pair: "15 min", "540 Calories", "1.2 km".
class MetaChip extends StatelessWidget {
  const MetaChip(this.icon, this.text,
      {super.key, this.iconColor, this.bold = false});

  final IconData icon;
  final String text;
  final Color? iconColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: iconColor ?? p.muted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.caption.copyWith(
              fontSize: 11.5,
              color: bold ? p.inkSoft : p.muted,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// The green "+" on every food card.
class AddButton extends StatelessWidget {
  const AddButton({super.key, required this.onTap, this.label = 'Add to cart'});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: p.accent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 28,
            child: Icon(Icons.add_rounded, size: 20, color: p.card),
          ),
        ),
      ),
    );
  }
}

/// A card surface: the paper card with a soft, green-cast shadow.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.md),
    this.radius = Radii.lg,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? p.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: p.accentDeep.withValues(alpha: .06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Empty states name the situation and show a dish, never a generic icon.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.art,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });

  final FoodArt art;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Space.xxl, vertical: Space.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(Space.lg),
            decoration:
                BoxDecoration(color: p.accentWash, shape: BoxShape.circle),
            child: Opacity(opacity: .9, child: FoodArtView(art, size: 64)),
          ),
          const SizedBox(height: Space.lg),
          Text(title, style: context.heading, textAlign: TextAlign.center),
          const SizedBox(height: Space.sm),
          Text(message, style: context.body, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: Space.lg),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: p.accent,
                foregroundColor: p.card,
                textStyle: const TextStyle(
                    fontFamily: AppTheme.font, fontWeight: FontWeight.w700),
                shape: const StadiumBorder(),
              ),
              child: Text(action!),
            ),
          ],
        ],
      ),
    );
  }
}

/// A quiet floating confirmation, used for "Added to cart" and friends.
void showToast(BuildContext context, String message,
        {IconData icon = Icons.check_circle_rounded}) =>
    showToastOn(ScaffoldMessenger.of(context), context.palette, message,
        icon: icon);

void showToastOn(ScaffoldMessengerState messenger, Palette p, String message,
    {IconData icon = Icons.check_circle_rounded}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      duration: const Duration(milliseconds: 1600),
      margin:
          const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.md),
      content: Row(
        children: [
          Icon(icon, color: p.accent, size: 20),
          const SizedBox(width: Space.sm),
          Expanded(child: Text(message)),
        ],
      ),
    ));
}
