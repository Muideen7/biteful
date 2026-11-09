import 'package:dishly/services/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final seed = readSeed();
  final repo = DemoAuthRepository(seed, latency: Duration.zero);

  test('any well-formed sign in is the seeded person, with the email typed', () async {
    final p = await repo.signIn(email: 'Dailyflutter.UI@gmail.com', password: 'whatever');
    expect(p.name, seed.profile.name);
    expect(p.avatar, seed.profile.avatar);
    expect(p.email, 'dailyflutter.ui@gmail.com');
  });

  test('the seeded wrong password shows the wrong-password state', () {
    expect(repo.signIn(email: seed.demoEmail, password: seed.wrongPassword), throwsA(isA<WrongPassword>()));
  });

  test('sign up keeps the name given', () async {
    final p = await repo.signUp(
        name: '  Ada Obi ', email: 'Ada@x.io', password: 'secret1');
    expect(p.name, 'Ada Obi');
    expect(p.email, 'ada@x.io');
  });

  test('a reset never reveals whether the email exists', () async {
    await repo.sendPasswordReset('nobody@nowhere.io');
    await repo.sendPasswordReset(seed.demoEmail);
  });

}
