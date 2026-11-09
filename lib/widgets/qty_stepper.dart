import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_theme.dart';
import '../config/design_tokens.dart';

/// − qty +. The minus becomes a bin at one when [canRemove] is set.
class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.qty,
    required this.onChanged,
    this.min = 1,
    this.canRemove = false,
    this.compact = false,
  });

  final int qty;
  final ValueChanged<int> onChanged;
  final int min;
  final bool canRemove;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final size = compact ? 28.0 : 38.0;
    final removing = canRemove && qty <= 1;
    Widget btn(IconData icon, String label, VoidCallback? onTap,
            {bool filled = false}) =>
        Semantics(
          button: true,
          label: label,
          child: Material(
            color: filled ? p.accent : p.card,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onTap();
                    },
              child: SizedBox.square(
                dimension: size,
                child: Icon(icon,
                    size: compact ? 16 : 20,
                    color: filled ? p.card : (onTap == null ? p.line : p.ink)),
              ),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: p.field, borderRadius: BorderRadius.circular(Radii.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(
            removing ? Icons.delete_outline_rounded : Icons.remove_rounded,
            removing ? 'Remove' : 'Decrease',
            removing
                ? () => onChanged(0)
                : (qty > min ? () => onChanged(qty - 1) : null),
          ),
          SizedBox(
            width: compact ? 26 : 36,
            child: Text('$qty',
                textAlign: TextAlign.center,
                style: context.title.copyWith(fontSize: compact ? 13.5 : 16)),
          ),
          btn(Icons.add_rounded, 'Increase',
              qty < 20 ? () => onChanged(qty + 1) : null,
              filled: true),
        ],
      ),
    );
  }
}
