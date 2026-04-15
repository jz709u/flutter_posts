import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/repository_impl_v2.dart';
import '../../domain/models/models.dart';

// ---------------------------------------------------------------------------
// Posts
// ---------------------------------------------------------------------------

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<Post>>(
  PostsNotifier.new,
);

class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final result = await ref.watch(postRepositoryProvider).getPosts();
    return result.when(
      success: (posts) => posts,
      failure: (e) => throw e,
    );
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
    final result = await ref.watch(postRepositoryProvider).getPost(arg);
    return result.when(success: (p) => p, failure: (e) => throw e);
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
  Future<List<Comment>> build(int arg) async {
    final result =
        await ref.watch(commentRepositoryProvider).getComments(arg);
    return result.when(success: (c) => c, failure: (e) => throw e);
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
    final result = await ref.watch(userRepositoryProvider).getUser(arg);
    return result.when(success: (u) => u, failure: (e) => throw e);
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
    final result =
        await ref.watch(postRepositoryProvider).getPostsByUser(arg);
    return result.when(success: (p) => p, failure: (e) => throw e);
  }
}
