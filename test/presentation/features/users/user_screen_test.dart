import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_demo/core/error/result.dart';
import 'package:flutter_demo/domain/models/models.dart';
import 'package:flutter_demo/domain/repositories/repositories.dart';
import 'package:flutter_demo/data/repositories/repository_impl_v2.dart';
import 'package:flutter_demo/presentation/features/users/user_screen.dart';
import 'package:flutter_demo/presentation/router/app_router.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({required this.user, this.shouldFail = false});
  final User user;
  final bool shouldFail;

  @override
  Future<Result<User>> getUser(int id) async {
    if (shouldFail) return Failure(Exception('user failed'));
    return Success(user);
  }
}

class _FakePostRepository implements PostRepository {
  _FakePostRepository({this.posts = const [], this.shouldFail = false});
  final List<Post> posts;
  final bool shouldFail;

  @override
  Future<Result<List<Post>>> getPosts() async => Success(posts);

  @override
  Future<Result<Post>> getPost(int id) async =>
      Success(posts.firstWhere((p) => p.id == id));

  @override
  Future<Result<List<Post>>> getPostsByUser(int userId) async {
    if (shouldFail) return Failure(Exception('posts failed'));
    return Success(posts.where((p) => p.userId == userId).toList());
  }
}

const _user = User(
  id: 3,
  name: 'Bob Smith',
  username: 'bsmith',
  email: 'bob@example.com',
  website: 'bob.dev',
  companyName: 'Initech',
);

const _userPosts = [
  Post(id: 10, userId: 3, title: 'Bob Post One', body: 'Content A'),
  Post(id: 11, userId: 3, title: 'Bob Post Two', body: 'Content B'),
];

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildApp({
  UserRepository? userRepo,
  PostRepository? postRepo,
}) {
  final router = GoRouter(
    initialLocation: '/users/3',
    routes: [
      GoRoute(
        path: '/users/:userId',
        name: Routes.userProfileName,
        builder: (_, state) => UserScreen(
          userId: int.parse(state.pathParameters['userId']!),
        ),
      ),
      GoRoute(
        path: '/posts/:postId',
        name: Routes.postDetailName,
        builder: (_, state) =>
            Scaffold(body: Text('Post ${state.pathParameters['postId']}')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      if (userRepo != null) userRepositoryProvider.overrideWithValue(userRepo),
      if (postRepo != null) postRepositoryProvider.overrideWithValue(postRepo),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('UserScreen', () {
    testWidgets('shows loading indicator while user is fetching',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        userRepo: _FakeUserRepository(user: _user),
        postRepo: _FakePostRepository(posts: _userPosts),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays user name and profile fields', (tester) async {
      await tester.pumpWidget(_buildApp(
        userRepo: _FakeUserRepository(user: _user),
        postRepo: _FakePostRepository(posts: _userPosts),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Bob Smith'), findsOneWidget);
      expect(find.text('@bsmith'), findsOneWidget);
      expect(find.text('bob@example.com'), findsOneWidget);
      expect(find.text('bob.dev'), findsOneWidget);
      expect(find.text('Initech'), findsOneWidget);
    });

    testWidgets('shows error when user fails to load', (tester) async {
      await tester.pumpWidget(_buildApp(
        userRepo: _FakeUserRepository(user: _user, shouldFail: true),
        postRepo: _FakePostRepository(),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('user failed'), findsOneWidget);
    });

    testWidgets('lists the user\'s posts', (tester) async {
      await tester.pumpWidget(_buildApp(
        userRepo: _FakeUserRepository(user: _user),
        postRepo: _FakePostRepository(posts: _userPosts),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Bob Post One'), findsOneWidget);
      expect(find.text('Bob Post Two'), findsOneWidget);
    });

    testWidgets('shows empty post list without error when user has no posts',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        userRepo: _FakeUserRepository(user: _user),
        postRepo: _FakePostRepository(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNothing);
      expect(find.textContaining('error'), findsNothing);
    });

    testWidgets('tapping a post navigates to post detail', (tester) async {
      await tester.pumpWidget(_buildApp(
        userRepo: _FakeUserRepository(user: _user),
        postRepo: _FakePostRepository(posts: _userPosts),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bob Post One'));
      await tester.pumpAndSettle();

      expect(find.text('Post 10'), findsOneWidget);
    });

    testWidgets('shows error in posts section when posts fail', (tester) async {
      await tester.pumpWidget(_buildApp(
        userRepo: _FakeUserRepository(user: _user),
        postRepo: _FakePostRepository(shouldFail: true),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('posts failed'), findsOneWidget);
    });
  });
}
