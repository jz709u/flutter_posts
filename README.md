# Flutter Architecture Demo

A Flutter app demonstrating clean architecture, Riverpod state management,
Google sign-in, remote user syncing, post browsing, and inline commenting with
timestamps.

---

## Architecture

```
lib/
├── core/
│   ├── error/
│   │   └── result.dart          # Result<T> type (Success | Failure)
│   └── network/
│       ├── dio_client.dart      # Dio + interceptors + AppException hierarchy
│       ├── cache.dart           # InMemoryCache<K,V> with TTL
│       └── cached_data_source.dart  # Caching wrapper around RemoteDataSource
│
├── data/                        # Data layer — knows about network & JSON
│   ├── datasources/
│   │   └── remote_data_source.dart  # Raw Dio calls, returns DTOs
│   ├── models/
│   │   └── dtos.dart            # JSON ↔ DTO mapping
│   └── repositories/
│       └── repository_impl_v2.dart  # Implements domain interfaces
│
├── domain/                      # Pure Dart — no Flutter, no Dio
│   ├── models/
│   │   └── models.dart          # Post, Comment, User
│   └── repositories/
│       └── repositories.dart    # Abstract interfaces
│
└── presentation/                # Flutter UI layer
    ├── features/
    │   ├── login/               # Google sign-in entry screen
    │   ├── posts/               # Posts list screen
    │   ├── post_detail/         # Post, comments, timestamps, composer
    │   ├── profile/             # Signed-in user's profile
    │   └── users/               # Public user profile + their posts
    ├── providers/
    │   └── providers.dart       # AsyncNotifier providers (Riverpod)
    ├── router/
    │   └── app_router.dart      # GoRouter config
    ├── theme/
    │   └── app_theme.dart       # Material 3 light + dark themes
    └── widgets/
        └── async_value_widget.dart  # Shared loading/error/data handler
```

## Key patterns

### Current app behaviour

- Users authenticate with Google before entering the main app.
- After sign-in, the app ensures a matching remote user exists and stores that
  remote profile for the current session.
- The feed supports optimistic local post creation for the signed-in user.
- Post detail supports inline comment creation with newest comments prepended.
- Comments render localized timestamps when `createdAt` is available.
- The comment composer starts collapsed as an `Add comment` button and returns
  to that collapsed state after a successful send.

### Result<T> — typed error handling

Repository methods return `Result<T>` rather than throwing. The presentation
layer uses `result.when(success:, failure:)` to handle both cases explicitly.

```dart
final result = await repo.getPosts();
return result.when(
  success: (posts) => posts,
  failure: (e) => throw e,   // Let Riverpod catch and surface the error state
);
```

### Three-layer separation

| Layer        | Knows about              | Returns            |
|--------------|--------------------------|--------------------|
| Data         | Dio, JSON, DTOs          | DTOs               |
| Domain       | Nothing external         | Domain models      |
| Presentation | Flutter, Riverpod        | Widgets            |

The domain layer has zero dependencies on Flutter or Dio. You can unit-test
every repository, use-case, and model without a Flutter test runner.

### Caching strategy

`InMemoryCache<K, V>` stores values with a TTL. `CachedDataSource` wraps
`RemoteDataSource` and handles the cache-or-fetch logic transparently —
repositories never need to know whether data came from the network or cache.

| Resource     | TTL         | Rationale                          |
|--------------|-------------|------------------------------------|
| Post list    | 3 minutes   | Refreshable; likely to be paged    |
| Single post  | 10 minutes  | Stable once written                |
| User posts   | 5 minutes   | Mid-frequency changes              |
| User profile | 30 minutes  | Rarely changes                     |
| Comments     | Not cached  | User-generated; freshness matters  |

### Riverpod providers

Every screen watches an `AsyncNotifierProvider` or `FamilyAsyncNotifier`.
Riverpod automatically provides loading / error / data states that map
directly to `AsyncValueWidget`.

```dart
// Family provider — one instance per post ID
final postProvider =
    AsyncNotifierProviderFamily<PostNotifier, Post, int>(PostNotifier.new);

class PostNotifier extends FamilyAsyncNotifier<Post, int> {
  @override
  Future<Post> build(int arg) async {
    final result = await ref.read(postRepositoryProvider).getPost(arg);
    return result.when(success: (p) => p, failure: (e) => throw e);
  }
}
```

### Navigation with GoRouter

Named routes + path parameters. The router is itself a Riverpod provider so
it reacts to auth-state changes and redirects signed-out users to `/login`.

```dart
context.goNamed(
  Routes.postDetailName,
  pathParameters: {'postId': post.id.toString()},
);
```

## Testing

Tests live in `test/` and mirror the `lib/` structure.

```
test/
├── core/
│   ├── result_test.dart         # Result type behaviour
│   └── cache_test.dart          # TTL, invalidation, expiry
├── data/
│   ├── repository_test.dart     # DTO mapping + error propagation
│   └── datasources/             # Mock datasource behaviour
└── presentation/
    ├── providers_test.dart      # ProviderContainer + fake repos
    └── features/                # Screen/widget interaction tests
```

Run all tests:

```bash
flutter test
```

Run a single file:

```bash
flutter test test/core/cache_test.dart
```

## Getting started

```bash
# Install dependencies
flutter pub get

# Generate code (freezed + json_serializable + riverpod_generator)
dart run build_runner build --delete-conflicting-outputs

# Run on a device or simulator
flutter run

# Analyse
flutter analyze

# Test
flutter test
```

## Dependencies

| Package                | Role                          |
|------------------------|-------------------------------|
| `flutter_riverpod`     | State management              |
| `riverpod_annotation`  | Code-gen annotations          |
| `dio`                  | HTTP client                   |
| `pretty_dio_logger`    | Network logging               |
| `freezed_annotation`   | Immutable model annotations   |
| `json_annotation`      | JSON serialisation            |
| `go_router`            | Declarative navigation        |
| `equatable`            | Value equality                |

## Mock vs live data

`RemoteDataSource` currently defaults to mock mode via `_useMockData = true` in
`lib/data/datasources/remote_data_source.dart`.

- Mock mode includes seeded users, posts, comments, avatars, and timestamps.
- Live mode expects the backend to support:
  - `GET /users?googleId=...`
  - `GET /users?email=...`
  - `POST /users`
  - `PATCH /users/:id`
  - `GET /comments?postId=...`
  - `POST /comments`

## What to add for production

- **Authentication hardening** — add `AuthInterceptor` in `dio_client.dart` to
  attach backend auth tokens and refresh them centrally.
- **Persistent cache** — swap `InMemoryCache` for an `Isar` or `Hive` backed
  store so data survives restarts.
- **Pagination** — extend `PostsNotifier` with a `loadMore()` method using
  `CancelToken` to abort in-flight requests when the user navigates away.
- **Offline support** — check connectivity before fetching; serve stale cache
  with a warning banner.
- **Comment persistence rules** — define server ordering, moderation, and edit
  semantics instead of relying on client-side prepend behaviour.
- **Error reporting** — pipe `AppException` to Sentry or Firebase Crashlytics
  in `_ErrorInterceptor`.
- **Flavours** — `dart define` compile-time variables to swap `_baseUrl` and
  log levels for dev / staging / prod.
