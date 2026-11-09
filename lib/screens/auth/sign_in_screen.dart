import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../config/motion.dart';
import '../shell/brand_header_hero.dart';
import '../splash/splash_overlay.dart';
import '../../models/account.dart';
import '../../providers/core_providers.dart';
import '../../providers/session_providers.dart';
import '../../services/auth_repository.dart';
import '../../widgets/brand_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/social_buttons.dart';
import '../routes.dart';
import '../shell/main_shell.dart';
import 'auth_header.dart';
import 'auth_widgets.dart';
import 'forgot_password_sheet.dart';
import 'validators.dart';

enum _Pending { email, google, apple }

/// Sign in and sign up on one card. The header above stays animated the
/// whole time; switching mode grows a name field and swaps the copy.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.handOff = false});

  /// True when arriving from inside the app (sign out): the green header
  /// morphs in from the page before, so it does not drop in, and the rest
  /// of the screen follows once it lands.
  final bool handOff;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with SingleTickerProviderStateMixin {
  late final _entrance =
      AnimationController(vsync: this, duration: Motion.authEntrance);
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _signUp = false;
  bool _keep = true;
  bool _terms = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _nameTouched = false;
  String? _serverError;
  _Pending? _pending;

  bool _started = false;
  bool get _handOff => widget.handOff;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final arrival = ModalRoute.of(context)?.animation;
    if (_handOff) {
      // Wordmark, rider and form wait until the header has landed.
      // From .2: the first part of the entrance is the header dropping
      // in, which a hand-off skips, so the wordmark starts at once.
      whenRouteArrived(arrival, () {
        if (mounted) _entrance.forward(from: .2);
      });
    } else {
      startWhenRevealed(ref, _entrance.forward);
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? get _emailError => _emailTouched ? validateEmail(_email.text) : null;
  String? get _passwordError =>
      _serverError ??
      (_passwordTouched ? validatePassword(_password.text) : null);
  String? get _nameError =>
      _signUp && _nameTouched ? validateName(_name.text) : null;

  Future<void> _submit() async {
    setState(() {
      _emailTouched = _passwordTouched = true;
      _nameTouched = _signUp;
      _serverError = null;
    });
    if (_emailError != null || _passwordError != null || _nameError != null) {
      HapticFeedback.mediumImpact();
      return;
    }
    if (_signUp && !_terms) {
      _termsNudge();
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await _run(_Pending.email, (repo) {
      return _signUp
          ? repo.signUp(
              name: _name.text, email: _email.text, password: _password.text)
          : repo.signIn(email: _email.text, password: _password.text);
    });
  }

  Future<void> _social(SocialProvider provider) async {
    if (_signUp && !_terms) {
      _termsNudge();
      return;
    }
    await _run(
      provider == SocialProvider.google ? _Pending.google : _Pending.apple,
      (repo) => repo.signInWith(provider),
    );
  }

  void _termsNudge() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
          content: Text('Agree to the Terms to create your account')));
  }

  Future<void> _run(
    _Pending which,
    Future<UserProfile> Function(AuthRepository) action,
  ) async {
    setState(() => _pending = which);
    try {
      final repo = await ref.read(authRepositoryProvider.future);
      final profile = await action(repo);
      await ref
          .read(sessionProvider.notifier)
          .signedIn(profile.email, remember: _keep);
      await ref
          .read(profileProvider.notifier)
          .signedInAs(profile, isNew: _signUp);
      if (!mounted) return;
      HapticFeedback.lightImpact();
      ref.read(shellTabProvider.notifier).state = ShellTab.home;
      Navigator.of(context).pushReplacement(fadeRoute(const MainShell()));
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _pending = null;
        _serverError = e is WrongPassword ? e.message : null;
      });
      if (e is! WrongPassword) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  void _toggleMode() => setState(() {
        _signUp = !_signUp;
        _serverError = null;
        _nameTouched = false;
      });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final size = MediaQuery.sizeOf(context);
    final headerH = (size.height * .32).clamp(250.0, 300.0) +
        MediaQuery.paddingOf(context).top * .3;
    final busy = _pending != null;

    return Scaffold(
      backgroundColor: p.card,
      resizeToAvoidBottomInset: true,
      body: AnimatedBuilder(
        animation: _entrance,
        builder: (context, _) {
          final t = _entrance.value;
          Widget stagger(int i, Widget child) {
            final start = .38 + i * .06;
            final v =
                Motion.enter.transform(((t - start) / .3).clamp(0.0, 1.0));
            return Opacity(
              opacity: v,
              child: Transform.translate(
                  offset: Offset(0, 18 * (1 - v)), child: child),
            );
          }

          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                  child: AuthHeader(
                      t: t, height: headerH, headerInPlace: _handOff)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(Space.gutter + 4,
                    Space.xxl + 4, Space.gutter + 4, Space.xl),
                sliver: SliverList.list(children: [
                  stagger(
                      0,
                      AnimatedSwitcher(
                        duration: Motion.short,
                        transitionBuilder: (c, a) =>
                            FadeTransition(opacity: a, child: c),
                        child: Align(
                          key: ValueKey(_signUp),
                          alignment: Alignment.centerLeft,
                          child: Text(
                              _signUp ? 'Create account' : 'Welcome Back',
                              style: context.display),
                        ),
                      )),
                  const SizedBox(height: Space.xl),
                  AnimatedSize(
                    duration: Motion.medium,
                    curve: Motion.enter,
                    child: _signUp
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: Space.lg),
                            child: BrandField(
                              controller: _name,
                              hint: 'Your name',
                              icon: Icons.person_outline_rounded,
                              error: _nameError,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                              onBlur: () => setState(() => _nameTouched = true),
                              onChanged: (_) => setState(() {}),
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                  stagger(
                      1,
                      BrandField(
                        fieldKey: const Key('email'),
                        controller: _email,
                        hint: 'Email or phone',
                        icon: Icons.mail_outline_rounded,
                        error: _emailError,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                        onBlur: () => setState(() => _emailTouched =
                            _email.text.isNotEmpty || _emailTouched),
                        onChanged: (_) => setState(() {}),
                      )),
                  const SizedBox(height: Space.lg),
                  stagger(
                      2,
                      BrandField(
                        fieldKey: const Key('password'),
                        controller: _password,
                        focusNode: _passwordFocus,
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        error: _passwordError,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _submit(),
                        onBlur: () => setState(() => _passwordTouched =
                            _password.text.isNotEmpty || _passwordTouched),
                        onChanged: (_) => setState(() => _serverError = null),
                      )),
                  const SizedBox(height: Space.md),
                  stagger(
                      3,
                      _signUp
                          ? TermsRow(
                              value: _terms,
                              onChanged: (v) => setState(() => _terms = v))
                          : Row(
                              children: [
                                Expanded(
                                  child: CheckRow(
                                    value: _keep,
                                    label: 'Keep me signed in',
                                    onChanged: (v) => setState(() => _keep = v),
                                  ),
                                ),
                                Flexible(
                                  child: TextButton(
                                    onPressed: busy
                                        ? null
                                        : () => showForgotPasswordSheet(
                                            context, _email.text),
                                    style: TextButton.styleFrom(
                                        foregroundColor: p.accentDeep),
                                    child: Text(
                                      'Forgot Password?',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: p.accent,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                  const SizedBox(height: Space.lg),
                  stagger(
                      4,
                      GradientButton(
                        label: _signUp ? 'Sign Up' : 'Log In',
                        busy: _pending == _Pending.email,
                        onPressed: busy ? null : _submit,
                      )),
                  const SizedBox(height: Space.xl),
                  stagger(5, const OrDivider()),
                  const SizedBox(height: Space.lg),
                  stagger(
                      6,
                      Row(
                        children: [
                          Expanded(
                            child: SocialButton(
                              provider: SocialProvider.google,
                              busy: _pending == _Pending.google,
                              onPressed: busy
                                  ? null
                                  : () => _social(SocialProvider.google),
                            ),
                          ),
                          const SizedBox(width: Space.md),
                          Expanded(
                            child: SocialButton(
                              provider: SocialProvider.apple,
                              busy: _pending == _Pending.apple,
                              onPressed: busy
                                  ? null
                                  : () => _social(SocialProvider.apple),
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: Space.lg),
                  stagger(
                      7,
                      ModeSwitch(
                          signUp: _signUp, onTap: busy ? null : _toggleMode)),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}
