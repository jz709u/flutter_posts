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
    postListCache: ref.watch(postListCacheProvider),
    postCache: ref.watch(postCacheProvider),
    userCache: ref.watch(userCacheProvider),
  ),
);

// ── Cache key helpers ─────────────────────────────────────────────────────────

/// Compile-time cache key constants and factories.
///
/// Using a centralised class prevents typo-prone magic strings scattered
/// across the codebase. The private constructor ensures this class is never
/// instantiated accidentally.
final class CacheKeys {
  CacheKeys._();

  static const allPosts = 'all_posts';
  static String post(int id) => 'post_$id';
  static String userPosts(int userId) => 'user_posts_$userId';
}

class CachedDataSource {
  CachedDataSource({
    required this.remote,
    required this.postListCache,
    required this.postCache,
    required this.userCache,
  });

  final RemoteDataSource remote;

  /// Caches keyed by string; values are `List<PostDto>` (all-posts & user-posts).
  final InMemoryCache<String, List<PostDto>> postListCache;

  /// Caches a single PostDto by string key.
  final InMemoryCache<String, PostDto> postCache;

  /// Caches a single UserDto by int id.
  final InMemoryCache<int, UserDto> userCache;

  // ── Posts ────────────────────────────────────────────────────────────────

  Future<List<PostDto>> fetchPosts() async {
    final cached = postListCache.get(CacheKeys.allPosts);
    if (cached != null) return cached;
    final posts = await remote.fetchPosts();
    postListCache.set(CacheKeys.allPosts, posts, ttl: const Duration(minutes: 3));
    return posts;
  }

  Future<PostDto> fetchPost(int id) async {
    final key = CacheKeys.post(id);
    final cached = postCache.get(key);
    if (cached != null) return cached;
    final post = await remote.fetchPost(id);
    postCache.set(key, post, ttl: const Duration(minutes: 10));
    return post;
  }

  Future<List<PostDto>> fetchPostsByUser(int userId) async {
    final key = CacheKeys.userPosts(userId);
    final cached = postListCache.get(key);
    if (cached != null) return cached;
    final posts = await remote.fetchPostsByUser(userId);
    postListCache.set(key, posts, ttl: const Duration(minutes: 5));
    return posts;
  }

  // ── Comments ─────────────────────────────────────────────────────────────

  // Comments are not cached — they change frequently
  Future<List<CommentDto>> fetchComments(int postId) =>
      remote.fetchComments(postId);

  // ── Users ─────────────────────────────────────────────────────────────────

  Future<UserDto> fetchUser(int id) async {
    final cached = userCache.get(id);
    if (cached != null) return cached;
    final user = await remote.fetchUser(id);
    // Users change rarely — cache for 30 minutes
    userCache.set(id, user, ttl: const Duration(minutes: 30));
    return user;
  }

  // ── Cache control ─────────────────────────────────────────────────────────

  void invalidatePosts() {
    postListCache.clear();
    postCache.clear();
  }

  void invalidateUser(int id) => userCache.invalidate(id);
}
