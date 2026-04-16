import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/login/login_screen.dart';
import '../features/posts/posts_screen.dart';
import '../features/post_detail/post_detail_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/users/user_screen.dart';
import '../providers/auth_provider.dart';

/// Named route constants — use these instead of raw strings when navigating.
abstract class Routes {
  static const loginName = 'login';
  static const postsName = 'posts';
  static const postDetailName = 'post-detail';
  static const userProfileName = 'user-profile';
  static const myProfileName = 'my-profile';
}

// ---------------------------------------------------------------------------
// RouterNotifier — bridges Riverpod auth state → GoRouter refresh
// ---------------------------------------------------------------------------

/// Listens to [authProvider] and calls [notifyListeners] so GoRouter
/// re-evaluates its [redirect] whenever the auth state changes.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final auth = _ref.read(authProvider);

    // Don't redirect while the initial silent sign-in is still in flight.
    if (auth.isLoading) return null;

    final isLoggedIn = auth.valueOrNull != null;
    final isOnLogin = state.matchedLocation == '/login';

    if (!isLoggedIn && !isOnLogin) return '/login';
    if (isLoggedIn && isOnLogin) return '/';
    return null;
  }
}

final _routerNotifierProvider = Provider<RouterNotifier>(
  (ref) => RouterNotifier(ref),
);

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/login',
        name: Routes.loginName,
        builder: (_, __) => const LoginScreen(),
      ),
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
      GoRoute(
        path: '/profile',
        name: Routes.myProfileName,
        builder: (_, __) => const ProfileScreen(),
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
