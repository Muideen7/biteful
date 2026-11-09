/// Money is integer cents everywhere. This is the only place it becomes text.
String money(int cents) {
  final negative = cents < 0;
  final abs = cents.abs();
  final whole = (abs ~/ 100).toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
  final frac = (abs % 100).toString().padLeft(2, '0');
  return '${negative ? '-' : ''}\$$whole.$frac';
}
