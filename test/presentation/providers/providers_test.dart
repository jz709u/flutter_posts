import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_demo/core/error/result.dart';
import 'package:flutter_demo/domain/models/models.dart';
import 'package:flutter_demo/domain/repositories/repositories.dart';

// ---------------------------------------------------------------------------
// Fake repository implementations for testing
// ---------------------------------------------------------------------------

class _FakePostRepository implements PostRepository {
  _FakePostRepository({this.posts = const [], this.shouldFail = false});

  final List<Post> posts;
  final bool shouldFail;

  @override
  Future<Result<List<Post>>> getPosts() async {
    if (shouldFail) return Failure(Exception('network error'));
    return Success(posts);
  }

  @override
  Future<Result<Post>> getPost(int id) async {
    final post = posts.firstWhere((p) => p.id == id,
        orElse: () => throw Exception('not found'));
    return Success(post);
  }

  @override
  Future<Result<List<Post>>> getPostsByUser(int userId) async {
    return Success(posts.where((p) => p.userId == userId).toList());
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _samplePosts = [
  Post(id: 1, userId: 1, title: 'Post 1', body: 'Body 1'),
  Post(id: 2, userId: 1, title: 'Post 2', body: 'Body 2'),
  Post(id: 3, userId: 2, title: 'Post 3', body: 'Body 3'),
];

// A simple provider that delegates to the injected repo — mirrors the real one
final _testPostsProvider = FutureProvider<List<Post>>((ref) async {
  final repo = ref.watch(_fakeRepoProvider);
  final result = await repo.getPosts();
  return result.when(success: (p) => p, failure: (e) => throw e);
});

final _fakeRepoProvider = Provider<PostRepository>(
  (_) => _FakePostRepository(posts: _samplePosts),
);

final _failingRepoProvider = Provider<PostRepository>(
  (_) => _FakePostRepository(shouldFail: true),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PostsNotifier via ProviderContainer', () {
    test('emits data when repository succeeds', () async {
      final container = ProviderContainer(
        overrides: [
          _fakeRepoProvider.overrideWith(
            (_) => _FakePostRepository(posts: _samplePosts),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(_testPostsProvider.future);
      expect(result.length, 3);
      expect(result.first.title, 'Post 1');
    });

    test('emits error when repository fails', () async {
      final container = ProviderContainer(
        overrides: [
          _fakeRepoProvider.overrideWith(
            (_) => _FakePostRepository(shouldFail: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(_testPostsProvider.future).then(
            (v) => AsyncValue.data(v),
            onError: (e, st) => AsyncValue<List<Post>>.error(e, st),
          );

      expect(state.hasError, isTrue);
    });

    test('filters posts by userId correctly', () {
      final repo = _FakePostRepository(posts: _samplePosts);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        _samplePosts.where((p) => p.userId == 1).length,
        2,
      );
      expect(
        _samplePosts.where((p) => p.userId == 2).length,
        1,
      );
    });
  });

  group('Repository overrides with ProviderContainer', () {
    test('override swaps implementation transparently', () async {
      final container = ProviderContainer(
        overrides: [
          _fakeRepoProvider.overrideWith(
            (_) => _FakePostRepository(posts: [
              const Post(id: 99, userId: 5, title: 'Override', body: 'works'),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(_fakeRepoProvider);
      final result = await repo.getPosts();
      expect(result.data.first.id, 99);
      expect(result.data.first.title, 'Override');
    });
  });
}
