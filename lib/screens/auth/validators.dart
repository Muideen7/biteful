final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

String? validateEmail(String v) {
  final s = v.trim();
  if (s.isEmpty) return 'Enter your email';
  if (!_email.hasMatch(s)) return "That email doesn't look right";
  return null;
}

String? validatePassword(String v) {
  if (v.isEmpty) return 'Enter your password';
  if (v.length < 6) return 'Use at least 6 characters';
  return null;
}

String? validateName(String v) =>
    v.trim().length < 2 ? 'Tell us what to call you' : null;
