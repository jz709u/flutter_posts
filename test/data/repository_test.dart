import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_demo/core/error/result.dart';
import 'package:flutter_demo/core/network/dio_client.dart';
import 'package:flutter_demo/data/models/dtos.dart';
import 'package:flutter_demo/domain/models/models.dart';

// ---------------------------------------------------------------------------
// Fake data source — no Mockito / Mocktail needed for simple cases
// ---------------------------------------------------------------------------

class _FakeDataSource {
  final List<PostDto> posts;
  final Exception? error;

  _FakeDataSource({this.posts = const [], this.error});

  Future<List<PostDto>> fetchPosts() async {
    if (error != null) throw error!;
    return posts;
  }
}

// A stripped-down inline repository that mirrors PostRepositoryImpl logic.
// In a real project you'd test the actual class with mocktail stubs.
Future<Result<List<Post>>> _getPosts(_FakeDataSource ds) async {
  try {
    final dtos = await ds.fetchPosts();
    return Success(dtos.map((d) => d.toDomain()).toList());
  } catch (e) {
    return Failure(e is Exception ? e : UnknownException(e.toString()));
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  final sampleDtos = [
    PostDto(id: 1, userId: 1, title: 'Hello', body: 'World'),
    PostDto(id: 2, userId: 1, title: 'Dart', body: 'Rocks'),
  ];

  group('PostRepository', () {
    test('returns mapped domain models on success', () async {
      final ds = _FakeDataSource(posts: sampleDtos);
      final result = await _getPosts(ds);

      expect(result.isSuccess, isTrue);
      final posts = result.data;
      expect(posts.length, 2);
      expect(posts.first.title, 'Hello');
      expect(posts.first, isA<Post>());
    });

    test('returns Failure when data source throws', () async {
      final ds = _FakeDataSource(error: const NetworkException('no internet'));
      final result = await _getPosts(ds);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<NetworkException>());
    });

    test('maps DTOs to domain model fields correctly', () async {
      final ds = _FakeDataSource(
        posts: [PostDto(id: 42, userId: 7, title: 'Title', body: 'Body')],
      );
      final result = await _getPosts(ds);
      final post = result.data.first;

      expect(post.id, 42);
      expect(post.userId, 7);
      expect(post.title, 'Title');
      expect(post.body, 'Body');
    });

    test('returns empty list when API returns no posts', () async {
      final ds = _FakeDataSource(posts: []);
      final result = await _getPosts(ds);

      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });
  });

  group('PostDto.toDomain()', () {
    test('correctly maps all fields', () {
      const dto = PostDto(id: 5, userId: 3, title: 'T', body: 'B');
      final post = dto.toDomain();
      expect(post.id, dto.id);
      expect(post.userId, dto.userId);
      expect(post.title, dto.title);
      expect(post.body, dto.body);
    });
  });

  group('UserDto.toDomain()', () {
    test('correctly maps nested company name', () {
      final dto = UserDto.fromJson({
        'id': 1,
        'name': 'Alice',
        'username': 'alice',
        'email': 'alice@example.com',
        'website': 'alice.dev',
        'company': {'name': 'Acme Corp'},
      });
      final user = dto.toDomain();
      expect(user.companyName, 'Acme Corp');
      expect(user.name, 'Alice');
    });
  });
}
