import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_demo/core/error/result.dart';
import 'package:flutter_demo/domain/models/models.dart';
import 'package:flutter_demo/domain/repositories/repositories.dart';
import 'package:flutter_demo/data/repositories/repository_impl_v2.dart';
import 'package:flutter_demo/presentation/features/posts/posts_screen.dart';
import 'package:flutter_demo/presentation/router/app_router.dart';

// ---------------------------------------------------------------------------
// Fakes
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
  Future<Result<Post>> getPost(int id) async =>
      Success(posts.firstWhere((p) => p.id == id));

  @override
  Future<Result<List<Post>>> getPostsByUser(int userId) async =>
      Success(posts.where((p) => p.userId == userId).toList());
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<Result<User>> getUser(int id) async => Success(User(
        id: id,
        name: 'Alice',
        username: 'alice',
        email: 'alice@example.com',
        website: 'alice.dev',
        companyName: 'Acme',
      ));
}

const _samplePosts = [
  Post(id: 1, userId: 1, title: 'First Post', body: 'Body one'),
  Post(id: 2, userId: 1, title: 'Second Post', body: 'Body two'),
];

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildApp(PostRepository repo) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const PostsScreen()),
      GoRoute(
        path: '/posts/:postId',
        name: Routes.postDetailName,
        builder: (_, state) =>
            Scaffold(body: Text('Detail ${state.pathParameters['postId']}')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      postRepositoryProvider.overrideWithValue(repo),
      userRepositoryProvider.overrideWithValue(_FakeUserRepository()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PostsScreen', () {
    testWidgets('shows loading indicator while posts are fetching',
        (tester) async {
      await tester.pumpWidget(_buildApp(_FakePostRepository(posts: _samplePosts)));
      // First frame — still loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders a card row for each post', (tester) async {
      await tester.pumpWidget(_buildApp(_FakePostRepository(posts: _samplePosts)));
      await tester.pumpAndSettle();

      expect(find.text('First Post'), findsOneWidget);
      expect(find.text('Second Post'), findsOneWidget);
      // Author name resolved from fake user repository
      expect(find.text('Alice'), findsWidgets);
    });

    testWidgets('shows error message when repository fails', (tester) async {
      await tester.pumpWidget(
          _buildApp(_FakePostRepository(shouldFail: true)));
      await tester.pumpAndSettle();

      expect(find.textContaining('network error'), findsOneWidget);
    });

    testWidgets('shows AppBar with app title', (tester) async {
      await tester.pumpWidget(_buildApp(_FakePostRepository(posts: _samplePosts)));
      await tester.pumpAndSettle();

      expect(find.text('Byline'), findsOneWidget);
    });

    testWidgets('tapping a post navigates to detail screen', (tester) async {
      await tester.pumpWidget(_buildApp(_FakePostRepository(posts: _samplePosts)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('First Post'));
      await tester.pumpAndSettle();

      expect(find.text('Detail 1'), findsOneWidget);
    });

    testWidgets('shows empty list without error when posts is empty',
        (tester) async {
      await tester.pumpWidget(_buildApp(_FakePostRepository()));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('error'), findsNothing);
    });
  });
}
