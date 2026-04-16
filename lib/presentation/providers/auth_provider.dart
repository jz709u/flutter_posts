import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/auth/auth_service.dart';

/// Holds the currently signed-in [GoogleSignInAccount], or `null` when
/// signed out.
///
/// - `AsyncLoading` — checking for a cached session on startup
/// - `AsyncData(account)` — signed in
/// - `AsyncData(null)` — signed out
/// - `AsyncError` — sign-in attempt failed
final authProvider =
    AsyncNotifierProvider<AuthNotifier, GoogleSignInAccount?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<GoogleSignInAccount?> {
  @override
  Future<GoogleSignInAccount?> build() =>
      // Silently restore the previous session on startup.
      ref.watch(authServiceProvider).signInSilently();

  /// Opens the Google account picker.
  Future<void> signIn() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).signIn(),
    );
  }

  /// Signs out and clears the session.
  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
    state = const AsyncData(null);
  }
}
