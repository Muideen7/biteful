import '../config/app_timing.dart';
import '../models/account.dart';
import 'seed.dart';

enum SocialProvider { google, apple }

/// Every outcome a sign-in can have, named, so the screen handles each one.
sealed class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
}

class WrongPassword extends AuthFailure {
  const WrongPassword()
      : super('That password is not right. Try again or reset it.');
}

class SignInCancelled extends AuthFailure {
  const SignInCancelled() : super('Sign in was cancelled.');
}

/// The contract a real backend implements. Every method is async even in the
/// demo, so a network implementation drops in without touching a widget.
abstract interface class AuthRepository {
  Future<UserProfile> signIn({required String email, required String password});
  Future<UserProfile> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<UserProfile> signInWith(SocialProvider provider);
  Future<void> sendPasswordReset(String email);
}

/// Simulates the service. Any well-formed sign-in succeeds as the seeded
/// person, except the seeded wrong password, which shows that state.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository(this._seed, {Duration? latency}) : _latency = latency;

  final Seed _seed;
  final Duration? _latency;

  Future<void> _wait(Duration d) => AppTiming.wait(_latency ?? d);

  @override
  Future<UserProfile> signIn(
      {required String email, required String password}) async {
    await _wait(AppTiming.signIn);
    if (password == _seed.wrongPassword) throw const WrongPassword();
    final e = email.trim().toLowerCase();
    // Everyone signs in as the seeded person (name and photo), so every
    // recording shows the same identity; only the email is the one typed.
    return _seed.profile.copyWith(email: e);
  }

  @override
  Future<UserProfile> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _wait(AppTiming.signIn);
    return _seed.profile
        .copyWith(name: name.trim(), email: email.trim().toLowerCase());
  }

  /// A real app plugs in `google_sign_in` and `sign_in_with_apple` here and
  /// maps a cancel to [SignInCancelled].
  @override
  Future<UserProfile> signInWith(SocialProvider provider) async {
    await _wait(AppTiming.socialSignIn);
    return _seed.profile;
  }

  /// Always succeeds, whether or not the address has an account: saying
  /// otherwise would tell anyone which emails are registered.
  @override
  Future<void> sendPasswordReset(String email) =>
      _wait(AppTiming.resetPassword);
}

// A network implementation, for when the template meets a real backend:
//
// class RemoteAuthRepository implements AuthRepository {
//   RemoteAuthRepository(this._dio);
//   final Dio _dio;
//
//   @override
//   Future<UserProfile> signIn({required String email, required String password}) async {
//     final r = await _dio.post('/auth/sign-in', data: {'email': email, 'password': password});
//     if (r.statusCode == 401) throw const WrongPassword();
//     return UserProfile.fromJson(r.data['user']);
//   }
//   ...
// }
