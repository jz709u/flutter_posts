import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/network/cached_data_source.dart';
import '../../domain/models/models.dart';

final currentRemoteUserProvider =
    NotifierProvider<CurrentRemoteUserNotifier, User?>(
  CurrentRemoteUserNotifier.new,
);

class CurrentRemoteUserNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  Future<User> syncFromGoogleAccount(GoogleSignInAccount account) async {
    final user = await ref.read(cachedDataSourceProvider).ensureGoogleUser(
          googleId: account.id,
          email: account.email,
          name: account.displayName,
          photoUrl: account.photoUrl,
        );
    final domainUser = user.toDomain();
    state = domainUser;
    return domainUser;
  }

  void clear() => state = null;
}
