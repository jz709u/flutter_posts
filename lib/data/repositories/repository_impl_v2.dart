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
// Implementations
// ---------------------------------------------------------------------------

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl(this._ds);

  final CachedDataSource _ds;

  @override
  Future<Result<List<Post>>> getPosts() async {
    try {
      final dtos = await _ds.fetchPosts();
      return Success(dtos.map((d) => d.toDomain()).toList());
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<Post>> getPost(int id) async {
    try {
      final dto = await _ds.fetchPost(id);
      return Success(dto.toDomain());
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<List<Post>>> getPostsByUser(int userId) async {
    try {
      final dtos = await _ds.fetchPostsByUser(userId);
      return Success(dtos.map((d) => d.toDomain()).toList());
    } on Exception catch (e) {
      return Failure(e);
    }
  }
}

class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(this._ds);

  final CachedDataSource _ds;

  @override
  Future<Result<List<Comment>>> getComments(int postId) async {
    try {
      final dtos = await _ds.fetchComments(postId);
      return Success(dtos.map((d) => d.toDomain()).toList());
    } on Exception catch (e) {
      return Failure(e);
    }
  }
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._ds);

  final CachedDataSource _ds;

  @override
  Future<Result<User>> getUser(int id) async {
    try {
      final dto = await _ds.fetchUser(id);
      return Success(dto.toDomain());
    } on Exception catch (e) {
      return Failure(e);
    }
  }
}
