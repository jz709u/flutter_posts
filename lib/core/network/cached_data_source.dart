import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cache.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../data/models/dtos.dart';

// A caching wrapper around RemoteDataSource.
// The repository layer uses this instead of RemoteDataSource directly,
// so it never needs to know whether data came from network or cache.

final cachedDataSourceProvider = Provider<CachedDataSource>(
  (ref) => CachedDataSource(
    remote: ref.watch(remoteDataSourceProvider),
    postCache: ref.watch(postCacheProvider),
    userCache: ref.watch(userCacheProvider),
  ),
);

class CachedDataSource {
  CachedDataSource({
    required this.remote,
    required this.postCache,
    required this.userCache,
  });

  final RemoteDataSource remote;
  final InMemoryCache<String, dynamic> postCache;
  final InMemoryCache<int, dynamic> userCache;

  // ── Posts ────────────────────────────────────────────────────────────────

  Future<List<PostDto>> fetchPosts() async {
    const key = 'all_posts';
    final cached = postCache.get(key);
    if (cached != null) {
      return (cached as List).cast<PostDto>();
    }
    final posts = await remote.fetchPosts();
    postCache.set(key, posts, ttl: const Duration(minutes: 3));
    return posts;
  }

  Future<PostDto> fetchPost(int id) async {
    final key = 'post_$id';
    final cached = postCache.get(key);
    if (cached != null) return cached as PostDto;
    final post = await remote.fetchPost(id);
    postCache.set(key, post, ttl: const Duration(minutes: 10));
    return post;
  }

  Future<List<PostDto>> fetchPostsByUser(int userId) async {
    final key = 'user_posts_$userId';
    final cached = postCache.get(key);
    if (cached != null) return (cached as List).cast<PostDto>();
    final posts = await remote.fetchPostsByUser(userId);
    postCache.set(key, posts, ttl: const Duration(minutes: 5));
    return posts;
  }

  // ── Comments ─────────────────────────────────────────────────────────────

  // Comments are not cached — they change frequently
  Future<List<CommentDto>> fetchComments(int postId) =>
      remote.fetchComments(postId);

  // ── Users ─────────────────────────────────────────────────────────────────

  Future<UserDto> fetchUser(int id) async {
    final cached = userCache.get(id);
    if (cached != null) return cached as UserDto;
    final user = await remote.fetchUser(id);
    // Users change rarely — cache for 30 minutes
    userCache.set(id, user, ttl: const Duration(minutes: 30));
    return user;
  }

  // ── Cache control ─────────────────────────────────────────────────────────

  void invalidatePosts() => postCache.clear();
  void invalidateUser(int id) => userCache.invalidate(id);
}
