import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/network/cache.dart';
import 'package:flutter_demo/core/network/cached_data_source.dart';
import 'package:flutter_demo/data/datasources/remote_data_source.dart';
import 'package:flutter_demo/data/models/dtos.dart';

// ---------------------------------------------------------------------------
// Fake RemoteDataSource — counts calls so we can assert cache behaviour
// ---------------------------------------------------------------------------

class _FakeRemote extends RemoteDataSource {
  _FakeRemote() : super(dio: Dio());

  int fetchPostsCount = 0;
  int fetchPostCount = 0;
  int fetchPostsByUserCount = 0;
  int fetchCommentsCount = 0;
  int fetchUserCount = 0;

  static const _posts = [
    PostDto(id: 1, userId: 1, title: 'A', body: 'a'),
    PostDto(id: 2, userId: 1, title: 'B', body: 'b'),
  ];
  static const _post = PostDto(id: 1, userId: 1, title: 'A', body: 'a');
  static const _comment = CommentDto(
      id: 1, postId: 1, name: 'N', email: 'e@e.com', body: 'comment');
  static final _user = UserDto.fromJson({
    'id': 1,
    'name': 'Alice',
    'username': 'alice',
    'email': 'a@a.com',
    'website': 'a.dev',
    'company': {'name': 'Acme'},
  });

  @override
  Future<List<PostDto>> fetchPosts() async {
    fetchPostsCount++;
    return _posts;
  }

  @override
  Future<PostDto> fetchPost(int id) async {
    fetchPostCount++;
    return _post;
  }

  @override
  Future<List<PostDto>> fetchPostsByUser(int userId) async {
    fetchPostsByUserCount++;
    return _posts;
  }

  @override
  Future<List<CommentDto>> fetchComments(int postId) async {
    fetchCommentsCount++;
    return [_comment];
  }

  @override
  Future<UserDto> fetchUser(int id) async {
    fetchUserCount++;
    return _user;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

CachedDataSource _build(_FakeRemote remote) => CachedDataSource(
      remote: remote,
      postListCache: InMemoryCache<String, List<PostDto>>(),
      postCache: InMemoryCache<String, PostDto>(),
      userCache: InMemoryCache<int, UserDto>(),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CachedDataSource — fetchPosts', () {
    test('cache miss calls remote and returns posts', () async {
      final remote = _FakeRemote();
      final ds = _build(remote);

      final posts = await ds.fetchPosts();

      expect(posts.length, 2);
      expect(remote.fetchPostsCount, 1);
    });

    test('cache hit skips remote on second call', () async {
      final remote = _FakeRemote();
      final ds = _build(remote);

      await ds.fetchPosts();
      await ds.fetchPosts();

      expect(remote.fetchPostsCount, 1);
    });

    test('after TTL expires, remote is called again', () async {
      final remote = _FakeRemote();
      final postListCache = InMemoryCache<String, List<PostDto>>();
      final ds = CachedDataSource(
        remote: remote,
        postListCache: postListCache,
        postCache: InMemoryCache<String, PostDto>(),
        userCache: InMemoryCache<int, UserDto>(),
      );

      await ds.fetchPosts();
      postListCache.invalidate(CacheKeys.allPosts); // simulate expiry
      await ds.fetchPosts();

      expect(remote.fetchPostsCount, 2);
    });
  });

  group('CachedDataSource — fetchPost', () {
    test('cache miss calls remote', () async {
      final remote = _FakeRemote();
      final ds = _build(remote);

      final post = await ds.fetchPost(1);

      expect(post.id, 1);
      expect(remote.fetchPostCount, 1);
    });

    test('cache hit skips remote on second call', () async {
      final remote = _FakeRemote();
      final ds = _build(remote);

      await ds.fetchPost(1);
      await ds.fetchPost(1);

      expect(remote.fetchPostCount, 1);
    });

    test('different ids are cached independently', () async {
      final remote = _FakeRemote();
      final ds = _build(remote);

      await ds.fetchPost(1);
      await ds.fetchPost(2);

      expect(remote.fetchPostCount, 2);
    });
  });

  group('CachedDataSource — fetchPostsByUser', () {
    test('cache miss calls remote', () async {
      final remote = _FakeRemote();
      final ds = _build(remote);

      final posts = await ds.fetchPostsByUser(1);

      expect(posts.length, 2);
      expect(remote.fetchPostsByUserCount, 1);
    });

    test('cache hit skips remote on second call', () async {
      final remote = _FakeRemote();
      final ds = _build(remote);

      await ds.fetchPostsByUser(1);
      await ds.fetchPostsByUser(1);

      expect(remote.fetchPostsByUserCount, 1);
    });

    test('different user ids are cached independently', () async {
      final remote = _FakeRemote();
      final ds = _build(remote);

      await ds.fetchPostsByUser(1);
      await ds.fetchPostsByUser(2);

      expect(remote.fetchPostsByUserCount, 2);
    });
  });

  group('CachedDataSource — fetchComments', () {
    test('always calls remote — comments are never cached', () async {
      final remote = _FakeRemote();
      final ds = _build(remote);

      await ds.fetchComments(1);
      await ds.fetchComments(1);
      await ds.fetchComments(1);

      expect(remote.fetchCommentsCount, 3);
    });
  });

  group('CachedDataSource — fetchUser', () {
    test('cache miss calls remote', () async {
      final remote = _FakeRemote();
      final ds = _build(remote);

      final user = await ds.fetchUser(1);

      expect(user.name, 'Alice');
      expect(remote.fetchUserCount, 1);
    });

    test('cache hit skips remote on second call', () async {
      final remote = _FakeRemote();
      final ds = _build(remote);

      await ds.fetchUser(1);
      await ds.fetchUser(1);

      expect(remote.fetchUserCount, 1);
    });

    test('different user ids are cached independently', () async {
      final remote = _FakeRemote();
      final ds = _build(remote);

      await ds.fetchUser(1);
      await ds.fetchUser(2);

      expect(remote.fetchUserCount, 2);
    });
  });

  group('CachedDataSource — cache invalidation', () {
    test('invalidatePosts clears all post cache entries', () async {
      final remote = _FakeRemote();
      final ds = _build(remote);

      await ds.fetchPosts();
      await ds.fetchPost(1);
      await ds.fetchPostsByUser(1);

      ds.invalidatePosts();

      await ds.fetchPosts();
      await ds.fetchPost(1);
      await ds.fetchPostsByUser(1);

      expect(remote.fetchPostsCount, 2);
      expect(remote.fetchPostCount, 2);
      expect(remote.fetchPostsByUserCount, 2);
    });

    test('invalidateUser forces re-fetch for that user only', () async {
      final remote = _FakeRemote();
      final ds = _build(remote);

      await ds.fetchUser(1);
      await ds.fetchUser(2);

      ds.invalidateUser(1);

      await ds.fetchUser(1); // should re-fetch
      await ds.fetchUser(2); // still cached

      expect(remote.fetchUserCount, 3);
    });
  });
}
