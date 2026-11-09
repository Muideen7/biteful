import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/design_tokens.dart';
import '../config/motion.dart';

/// The pill-shaped field used across sign-in. A filled wash at rest; on
/// focus the fill lifts and a green outline draws; on error the outline
/// and the icons turn the error colour and a short line appears below.
class BrandField extends StatefulWidget {
  const BrandField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.error,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onBlur,
    this.onChanged,
    this.autofillHints,
    this.focusNode,
    this.fieldKey,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? error;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onBlur;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final Key? fieldKey;

  @override
  State<BrandField> createState() => _BrandFieldState();
}

class _BrandFieldState extends State<BrandField> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();
  bool _hidden = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() {
    if (!_focus.hasFocus) widget.onBlur?.call();
    setState(() {});
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final focused = _focus.hasFocus;
    final hasError = widget.error != null;
    final tone = hasError ? p.error : (focused ? p.accent : p.muted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: Motion.quick,
          height: Sizes.fieldHeight,
          decoration: BoxDecoration(
            color: focused || hasError ? p.card : p.field,
            borderRadius: BorderRadius.circular(Radii.pill),
            border: Border.all(
              color: hasError
                  ? p.error
                  : (focused ? p.accent : Colors.transparent),
              width: 1.4,
            ),
            boxShadow: [
              if (focused)
                BoxShadow(
                  color: (hasError ? p.error : p.accent).withValues(alpha: .14),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: Space.lg),
          child: Row(
            children: [
              Icon(widget.icon, size: 20, color: tone),
              const SizedBox(width: Space.md),
              Expanded(
                child: TextField(
                  key: widget.fieldKey,
                  controller: widget.controller,
                  focusNode: _focus,
                  obscureText: widget.obscure && _hidden,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  onChanged: widget.onChanged,
                  autofillHints: widget.autofillHints,
                  autocorrect: false,
                  enableSuggestions: !widget.obscure,
                  style: context.title.copyWith(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: context.body.copyWith(color: p.muted),
                  ),
                ),
              ),
              if (widget.obscure)
                IconButton(
                  tooltip: _hidden ? 'Show password' : 'Hide password',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _hidden = !_hidden),
                  icon: Icon(
                    _hidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: tone,
                  ),
                ),
            ],
          ),
        ),
        AnimatedSize(
          duration: Motion.quick,
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(left: Space.lg, top: 6),
                  child: Text(
                    widget.error!,
                    style: context.caption
                        .copyWith(color: p.error, fontWeight: FontWeight.w600),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
