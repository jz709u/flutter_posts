import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/auth/auth_service.dart';
import 'current_user_provider.dart';

/// Holds the currently signed-in [GoogleSignInAccount], or `null` when
/// signed out.
///
/// - `AsyncLoading` — checking for a cached session on startup
/// - `AsyncData(account)` — signed in
/// - `AsyncData(null)` — signed out
/// - `AsyncError` — sign-in attempt failed
final authProvider = AsyncNotifierProvider<AuthNotifier, GoogleSignInAccount?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<GoogleSignInAccount?> {
  @override
  Future<GoogleSignInAccount?> build() async {
    final account = await ref.watch(authServiceProvider).signInSilently();
    if (account != null) {
      await ref
          .read(currentRemoteUserProvider.notifier)
          .syncFromGoogleAccount(account);
    }
    return account;
  }

  /// Opens the Google account picker.
  Future<void> signIn() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final account = await ref.read(authServiceProvider).signIn();
      if (account != null) {
        await ref
            .read(currentRemoteUserProvider.notifier)
            .syncFromGoogleAccount(account);
      }
      return account;
    });
  }

  /// Signs out and clears the session.
  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
    ref.read(currentRemoteUserProvider.notifier).clear();
    state = const AsyncData(null);
  }
}
