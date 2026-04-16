import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/posts/posts_screen.dart';
import '../features/post_detail/post_detail_screen.dart';
import '../features/users/user_screen.dart';

/// Named route constants — use these instead of raw strings when navigating.
abstract class Routes {
  static const postsName = 'posts';
  static const postDetailName = 'post-detail';
  static const userProfileName = 'user-profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: Routes.postsName,
        builder: (_, __) => const PostsScreen(),
      ),
      GoRoute(
        path: '/posts/:postId',
        name: Routes.postDetailName,
        builder: (_, state) =>
            PostDetailScreen(postId: state.requireInt('postId')),
      ),
      GoRoute(
        path: '/users/:userId',
        name: Routes.userProfileName,
        builder: (_, state) =>
            UserScreen(userId: state.requireInt('userId')),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

/// Convenience extension for extracting required integer path parameters.
extension GoRouterStateX on GoRouterState {
  int requireInt(String param) => int.parse(pathParameters[param]!);
}
