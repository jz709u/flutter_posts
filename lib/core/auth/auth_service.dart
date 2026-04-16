import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authServiceProvider = Provider<AuthService>((_) => AuthService());

/// Thin wrapper around [GoogleSignIn] so auth logic stays out of the UI.
class AuthService {
  final _client = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Attempts a silent sign-in (restores previous session).
  Future<GoogleSignInAccount?> signInSilently() => _client.signInSilently();

  /// Launches the Google account picker.
  Future<GoogleSignInAccount?> signIn() => _client.signIn();

  /// Signs out and clears the cached account.
  Future<void> signOut() => _client.signOut();

  GoogleSignInAccount? get currentUser => _client.currentUser;
}
