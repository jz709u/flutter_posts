import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/result.dart';
import '../../data/repositories/repository_impl_v2.dart';
import '../../domain/models/models.dart';
import 'auth_provider.dart';
import 'current_user_provider.dart';

// ---------------------------------------------------------------------------
// Current user
// ---------------------------------------------------------------------------

/// A stable local integer ID derived from the signed-in Google account's ID.
///
/// Using [hashCode] of the Google user ID string gives a consistent int for
/// the same account across sessions. Returns 0 when signed out.
final currentUserIdProvider = Provider<int>((ref) {
  final remoteUser = ref.watch(currentRemoteUserProvider);
  if (remoteUser != null) return remoteUser.id;

  final account = ref.watch(authProvider).valueOrNull;
  return account?.id.hashCode.abs() ?? 0;
});

// ---------------------------------------------------------------------------
// Posts
// ---------------------------------------------------------------------------

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<Post>>(
  PostsNotifier.new,
);

class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async =>
      (await ref.watch(postRepositoryProvider).getPosts()).unwrap();

  /// Prepends [post] to the feed without a round-trip to the server.
  void addPost(Post post) {
    final current = state.valueOrNull ?? [];
    state = AsyncData([post, ...current]);
  }
}

// ---------------------------------------------------------------------------
// Single post (family)
// ---------------------------------------------------------------------------

final postProvider =
    AsyncNotifierProvider.family<PostNotifier, Post, int>(PostNotifier.new);

class PostNotifier extends FamilyAsyncNotifier<Post, int> {
  @override
  Future<Post> build(int arg) async {
    // Check the local feed first so optimistically-added posts (negative IDs)
    // resolve without a repository round-trip.
    final local = ref
        .watch(postsProvider)
        .valueOrNull
        ?.where((p) => p.id == arg)
        .firstOrNull;
    if (local != null) return local;
    return (await ref.watch(postRepositoryProvider).getPost(arg)).unwrap();
  }
}

// ---------------------------------------------------------------------------
// Comments (family)
// ---------------------------------------------------------------------------

final commentsProvider =
    AsyncNotifierProvider.family<CommentsNotifier, List<Comment>, int>(
  CommentsNotifier.new,
);

class CommentsNotifier extends FamilyAsyncNotifier<List<Comment>, int> {
  @override
  Future<List<Comment>> build(int arg) async =>
      (await ref.watch(commentRepositoryProvider).getComments(arg)).unwrap();

  Future<void> submitComment({
    required User author,
    required String body,
  }) async {
    final createdAt = DateTime.now();
    final created = await ref.read(commentRepositoryProvider).createComment(
          postId: arg,
          name: author.name,
          email: author.email,
          body: body,
          createdAt: createdAt,
        );
    final comment = created.unwrap();
    final current = state.valueOrNull ?? <Comment>[];
    state = AsyncData([comment, ...current]);
  }
}

// ---------------------------------------------------------------------------
// User (family)
// ---------------------------------------------------------------------------

final userProvider =
    AsyncNotifierProvider.family<UserNotifier, User, int>(UserNotifier.new);

class UserNotifier extends FamilyAsyncNotifier<User, int> {
  @override
  Future<User> build(int arg) async {
    // For the signed-in user, return their real Google account info so every
    // widget that shows the current user (post cards, author chips, profile)
    // reflects the actual account rather than mock data.
    if (arg == ref.watch(currentUserIdProvider)) {
      final remoteUser = ref.watch(currentRemoteUserProvider);
      if (remoteUser != null) return remoteUser;

      final account = ref.watch(authProvider).valueOrNull;
      if (account != null) {
        return User(
          id: arg,
          name: account.displayName ?? 'Me',
          username: account.email.split('@').first,
          email: account.email,
          website: '',
          companyName: '',
          googleId: account.id,
          photoUrl: account.photoUrl,
        );
      }
    }
    return (await ref.watch(userRepositoryProvider).getUser(arg)).unwrap();
  }
}

// ---------------------------------------------------------------------------
// Posts by user (family)
// ---------------------------------------------------------------------------

final postsByUserProvider =
    AsyncNotifierProvider.family<PostsByUserNotifier, List<Post>, int>(
  PostsByUserNotifier.new,
);

class PostsByUserNotifier extends FamilyAsyncNotifier<List<Post>, int> {
  @override
  Future<List<Post>> build(int arg) async {
    final repoPosts =
        (await ref.watch(postRepositoryProvider).getPostsByUser(arg)).unwrap();

    // Also include locally-created posts (negative IDs) that belong to this
    // user — they live only in postsProvider's in-memory state and won't
    // appear in the repository. This ensures the profile page shows posts
    // composed by the signed-in Google user.
    final localPosts = ref
            .watch(postsProvider)
            .valueOrNull
            ?.where((p) => p.userId == arg && p.id < 0)
            .toList() ??
        [];

    return [...localPosts, ...repoPosts];
  }
}
