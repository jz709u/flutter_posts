import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/result.dart';
import '../../core/network/cached_data_source.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/repositories.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepositoryImpl(ref.watch(cachedDataSourceProvider)),
);

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepositoryImpl(ref.watch(cachedDataSourceProvider)),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(ref.watch(cachedDataSourceProvider)),
);

// ---------------------------------------------------------------------------
// Shared helper — wraps any async call in a Result, turning thrown exceptions
// into Failure values so callers never need their own try-catch.
// ---------------------------------------------------------------------------

Future<Result<T>> _mapResult<T>(Future<T> Function() fn) async {
  try {
    return Success(await fn());
  } on Exception catch (e) {
    return Failure(e);
  }
}

// ---------------------------------------------------------------------------
// Implementations
// ---------------------------------------------------------------------------

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl(this._ds);

  final CachedDataSource _ds;

  @override
  Future<Result<List<Post>>> getPosts() =>
      _mapResult(() async => (await _ds.fetchPosts()).map((d) => d.toDomain()).toList());

  @override
  Future<Result<Post>> getPost(int id) =>
      _mapResult(() async => (await _ds.fetchPost(id)).toDomain());

  @override
  Future<Result<List<Post>>> getPostsByUser(int userId) =>
      _mapResult(() async => (await _ds.fetchPostsByUser(userId)).map((d) => d.toDomain()).toList());
}

class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(this._ds);

  final CachedDataSource _ds;

  @override
  Future<Result<List<Comment>>> getComments(int postId) =>
      _mapResult(() async => (await _ds.fetchComments(postId)).map((d) => d.toDomain()).toList());
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._ds);

  final CachedDataSource _ds;

  @override
  Future<Result<User>> getUser(int id) =>
      _mapResult(() async => (await _ds.fetchUser(id)).toDomain());
}
