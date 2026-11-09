import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/motion.dart';

/// Shrinks a touch under the finger and springs back. Every tappable card in
/// the app goes through this, so they all feel the same.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.scale = .96,
    this.haptic = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double scale;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapCancel: () => _set(false),
        onTapUp: (_) => _set(false),
        onTap: enabled
            ? () {
                if (widget.haptic) HapticFeedback.lightImpact();
                widget.onTap!();
              }
            : null,
        child: AnimatedScale(
          scale: _down ? widget.scale : 1,
          duration: Motion.quick,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
