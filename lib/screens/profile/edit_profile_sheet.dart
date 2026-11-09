import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../models/account.dart';
import '../../providers/session_providers.dart';
import '../../widgets/app_sheet.dart';
import '../../widgets/brand_field.dart';
import '../../widgets/common.dart';
import '../../widgets/gradient_button.dart';
import '../auth/validators.dart';

Future<void> showEditProfileSheet(BuildContext context, UserProfile profile) =>
    showAppSheet(context,
        title: 'Edit profile', builder: (_) => _EditProfile(profile: profile));

String? validatePhone(String v) {
  final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return 'Enter your phone number';
  if (digits.length < 7 || digits.length > 15) {
    return "That number doesn't look right";
  }
  return null;
}

class _EditProfile extends ConsumerStatefulWidget {
  const _EditProfile({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<_EditProfile> {
  late final _name = TextEditingController(text: widget.profile.name);
  late final _email = TextEditingController(text: widget.profile.email);
  late final _phone = TextEditingController(text: widget.profile.phone);
  bool _tried = false;
  bool _busy = false;

  String? get _nameError => _tried ? validateName(_name.text) : null;
  String? get _emailError => _tried ? validateEmail(_email.text) : null;
  String? get _phoneError => _tried ? validatePhone(_phone.text) : null;

  bool get _changed =>
      _name.text.trim() != widget.profile.name ||
      _email.text.trim() != widget.profile.email ||
      _phone.text.trim() != widget.profile.phone;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _tried = true);
    if (_nameError != null || _emailError != null || _phoneError != null) {
      return;
    }
    setState(() => _busy = true);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final palette = context.palette;
    await ref
        .read(sessionProvider.notifier)
        .updateProfile(widget.profile.copyWith(
          name: _name.text.trim(),
          email: _email.text.trim().toLowerCase(),
          phone: _phone.text.trim(),
        ));
    nav.pop();
    showToastOn(messenger, palette, 'Profile updated');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                Space.gutter, Space.sm, Space.gutter, 0),
            child: Column(
              children: [
                BrandField(
                  fieldKey: const Key('profile-name'),
                  controller: _name,
                  hint: 'Your name',
                  icon: Icons.person_outline_rounded,
                  error: _nameError,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: Space.md),
                BrandField(
                  fieldKey: const Key('profile-email'),
                  controller: _email,
                  hint: 'Email',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  error: _emailError,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: Space.md),
                BrandField(
                  fieldKey: const Key('profile-phone'),
                  controller: _phone,
                  hint: 'Phone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  error: _phoneError,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Space.gutter, Space.xl, Space.gutter, Space.lg),
          child: GradientButton(
            label: _changed ? 'Save changes' : 'No changes yet',
            busy: _busy,
            onPressed: _changed ? _save : null,
          ),
        ),
      ],
    );
  }
}
