import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../providers/core_providers.dart';
import '../../widgets/app_sheet.dart';
import '../../widgets/brand_field.dart';
import '../../widgets/food_art_view.dart';
import '../../widgets/gradient_button.dart';
import '../../models/catalog.dart';
import 'validators.dart';

Future<void> showForgotPasswordSheet(BuildContext context, String email) =>
    showAppSheet(context,
        title: 'Reset your password',
        builder: (_) => _ForgotBody(email: email));

class _ForgotBody extends ConsumerStatefulWidget {
  const _ForgotBody({required this.email});
  final String email;

  @override
  ConsumerState<_ForgotBody> createState() => _ForgotBodyState();
}

class _ForgotBodyState extends ConsumerState<_ForgotBody> {
  late final _email = TextEditingController(text: widget.email.trim());
  bool _touched = false;
  bool _busy = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _touched = true);
    if (validateEmail(_email.text) != null) return;
    setState(() => _busy = true);
    final repo = await ref.read(authRepositoryProvider.future);
    await repo.sendPasswordReset(_email.text.trim());
    if (mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.xl),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _sent
            ? Column(
                key: const ValueKey('sent'),
                children: [
                  const SizedBox(height: Space.md),
                  const FoodArtView(FoodArt('takeout'), size: 80),
                  const SizedBox(height: Space.lg),
                  Text(
                    'If an account uses ${_email.text.trim()}, a reset link is on its way.',
                    style: context.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Space.xl),
                  GradientButton(
                      label: 'Back to Log In',
                      onPressed: () => Navigator.pop(context)),
                ],
              )
            : Column(
                key: const ValueKey('form'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                      "Enter the email you signed up with and we'll send a link to set a new password.",
                      style: context.body),
                  const SizedBox(height: Space.lg),
                  BrandField(
                    controller: _email,
                    hint: 'Email',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    error: _touched ? validateEmail(_email.text) : null,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _send(),
                  ),
                  const SizedBox(height: Space.xl),
                  GradientButton(
                      label: 'Send reset link', busy: _busy, onPressed: _send),
                ],
              ),
      ),
    );
  }
}
