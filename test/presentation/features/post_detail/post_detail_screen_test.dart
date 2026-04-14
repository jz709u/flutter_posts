import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_demo/core/error/result.dart';
import 'package:flutter_demo/domain/models/models.dart';
import 'package:flutter_demo/domain/repositories/repositories.dart';
import 'package:flutter_demo/data/repositories/repository_impl_v2.dart';
import 'package:flutter_demo/presentation/features/post_detail/post_detail_screen.dart';
import 'package:flutter_demo/presentation/router/app_router.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakePostRepository implements PostRepository {
  _FakePostRepository({required this.post});
  final Post post;

  @override
  Future<Result<List<Post>>> getPosts() async => Success([post]);

  @override
  Future<Result<Post>> getPost(int id) async => Success(post);

  @override
  Future<Result<List<Post>>> getPostsByUser(int userId) async => Success([post]);
}

class _FailingPostRepository implements PostRepository {
  @override
  Future<Result<List<Post>>> getPosts() async =>
      Failure(Exception('failed'));

  @override
  Future<Result<Post>> getPost(int id) async =>
      Failure(Exception('post failed'));

  @override
  Future<Result<List<Post>>> getPostsByUser(int userId) async =>
      Failure(Exception('failed'));
}

class _FakeCommentRepository implements CommentRepository {
  _FakeCommentRepository({this.comments = const [], this.shouldFail = false});
  final List<Comment> comments;
  final bool shouldFail;

  @override
  Future<Result<List<Comment>>> getComments(int postId) async {
    if (shouldFail) return Failure(Exception('comments failed'));
    return Success(comments);
  }
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({required this.user});
  final User user;

  @override
  Future<Result<User>> getUser(int id) async => Success(user);
}

const _post = Post(id: 1, userId: 7, title: 'Test Title', body: 'Test body text');
const _user = User(
  id: 7,
  name: 'Alice',
  username: 'alice',
  email: 'alice@example.com',
  website: 'alice.dev',
  companyName: 'Acme',
);
const _comments = [
  Comment(id: 1, postId: 1, name: 'Reviewer', email: 'r@r.com', body: 'Great post!'),
  Comment(id: 2, postId: 1, name: 'Fan', email: 'f@f.com', body: 'Loved it'),
];

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildApp({
  PostRepository? postRepo,
  CommentRepository? commentRepo,
  UserRepository? userRepo,
}) {
  final router = GoRouter(
    initialLocation: '/posts/1',
    routes: [
      GoRoute(
        path: '/posts/:postId',
        name: Routes.postDetailName,
        builder: (_, state) => PostDetailScreen(
          postId: int.parse(state.pathParameters['postId']!),
        ),
      ),
      GoRoute(
        path: '/users/:userId',
        name: Routes.userProfileName,
        builder: (_, state) =>
            Scaffold(body: Text('User ${state.pathParameters['userId']}')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      if (postRepo != null) postRepositoryProvider.overrideWithValue(postRepo),
      if (commentRepo != null)
        commentRepositoryProvider.overrideWithValue(commentRepo),
      if (userRepo != null) userRepositoryProvider.overrideWithValue(userRepo),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PostDetailScreen', () {
    testWidgets('shows loading indicator while post is fetching',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        postRepo: _FakePostRepository(post: _post),
        commentRepo: _FakeCommentRepository(),
        userRepo: _FakeUserRepository(user: _user),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays post title and body after load', (tester) async {
      await tester.pumpWidget(_buildApp(
        postRepo: _FakePostRepository(post: _post),
        commentRepo: _FakeCommentRepository(),
        userRepo: _FakeUserRepository(user: _user),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test body text'), findsOneWidget);
    });

    testWidgets('shows error when post fails to load', (tester) async {
      await tester.pumpWidget(_buildApp(
        postRepo: _FailingPostRepository(),
        commentRepo: _FakeCommentRepository(),
        userRepo: _FakeUserRepository(user: _user),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('post failed'), findsOneWidget);
    });

    testWidgets('renders a tile for each comment', (tester) async {
      await tester.pumpWidget(_buildApp(
        postRepo: _FakePostRepository(post: _post),
        commentRepo: _FakeCommentRepository(comments: _comments),
        userRepo: _FakeUserRepository(user: _user),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Great post!'), findsOneWidget);
      expect(find.text('Loved it'), findsOneWidget);
    });

    testWidgets('shows author chip with user name', (tester) async {
      await tester.pumpWidget(_buildApp(
        postRepo: _FakePostRepository(post: _post),
        commentRepo: _FakeCommentRepository(),
        userRepo: _FakeUserRepository(user: _user),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('tapping author chip navigates to user screen', (tester) async {
      await tester.pumpWidget(_buildApp(
        postRepo: _FakePostRepository(post: _post),
        commentRepo: _FakeCommentRepository(),
        userRepo: _FakeUserRepository(user: _user),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      expect(find.text('User 7'), findsOneWidget);
    });

    testWidgets('shows error in comments section when comments fail',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        postRepo: _FakePostRepository(post: _post),
        commentRepo: _FakeCommentRepository(shouldFail: true),
        userRepo: _FakeUserRepository(user: _user),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('comments failed'), findsOneWidget);
    });
  });
}
