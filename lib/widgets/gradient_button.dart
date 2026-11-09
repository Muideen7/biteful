import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/design_tokens.dart';
import 'pressable.dart';
import 'wheel_loader.dart';

/// The primary pill: deep green into leaf green.
///
/// A busy button keeps its colour and height; only the label swaps for the
/// spinning wheel. Greying it out on press reads as "refused", not "working".
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.height = Sizes.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = onPressed != null;
    return Pressable(
      onTap: busy || !enabled ? null : onPressed,
      semanticLabel: label,
      haptic: true,
      child: AnimatedOpacity(
        opacity: enabled || busy ? 1 : .5,
        duration: const Duration(milliseconds: 180),
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: p.buttonGradient,
            borderRadius: BorderRadius.circular(Radii.pill),
            boxShadow: [
              BoxShadow(
                color: p.accentDeep.withValues(alpha: .25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: busy
                ? const WheelLoader(key: ValueKey('busy'), size: 26)
                : Text(
                    label,
                    key: const ValueKey('label'),
                    style: TextStyle(
                      color: p.card,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
