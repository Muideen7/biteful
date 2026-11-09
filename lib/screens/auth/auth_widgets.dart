import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../config/motion.dart';

/// The green rounded tick box with a label, as in the reference.
class CheckRow extends StatelessWidget {
  const CheckRow({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.labelWidget,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;
  final Widget? labelWidget;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      checked: value,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.sm),
          child: Row(
            children: [
              AnimatedContainer(
                duration: Motion.quick,
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: value ? p.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: value ? p.accent : p.line, width: 1.6),
                ),
                child: AnimatedScale(
                  duration: Motion.quick,
                  scale: value ? 1 : 0,
                  child: Icon(Icons.check_rounded, size: 15, color: p.card),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: ExcludeSemantics(
                  child: labelWidget ??
                      Text(label,
                          style: context.caption
                              .copyWith(color: p.inkSoft, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TermsRow extends StatelessWidget {
  const TermsRow({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final link = TextStyle(color: p.accent, fontWeight: FontWeight.w700);
    return CheckRow(
      value: value,
      onChanged: onChanged,
      label: 'I agree to the Terms and Privacy Policy',
      labelWidget: Text.rich(
        TextSpan(
          style: context.caption.copyWith(color: p.inkSoft, fontSize: 13),
          children: [
            const TextSpan(text: 'I agree to the '),
            TextSpan(text: 'Terms', style: link),
            const TextSpan(text: ' and '),
            TextSpan(text: 'Privacy Policy', style: link),
          ],
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.label = 'Or continue with'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(child: Divider(color: p.line, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
          child: Text(label, style: context.caption),
        ),
        Expanded(child: Divider(color: p.line, height: 1)),
      ],
    );
  }
}

/// "Don't have an account? Sign Up". A wrapping line, not a Row, so it
/// never overflows at the largest text sizes.
class ModeSwitch extends StatelessWidget {
  const ModeSwitch({super.key, required this.signUp, required this.onTap});

  final bool signUp;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Text.rich(
        TextSpan(
          style: context.body.copyWith(fontSize: 13.5),
          children: [
            TextSpan(
                text: signUp
                    ? 'Already have an account? '
                    : "Don't have an account? "),
            TextSpan(
              text: signUp ? 'Log In' : 'Sign Up',
              style: TextStyle(color: p.accent, fontWeight: FontWeight.w800),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
