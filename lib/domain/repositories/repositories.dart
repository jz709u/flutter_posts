import '../models/models.dart';
import '../../core/error/result.dart';

/// Provides access to blog post data.
abstract class PostRepository {
  /// Returns all available posts.
  Future<Result<List<Post>>> getPosts();

  /// Returns a single post by [id].
  Future<Result<Post>> getPost(int id);

  /// Returns all posts authored by [userId].
  Future<Result<List<Post>>> getPostsByUser(int userId);
}

/// Provides access to comment data.
abstract class CommentRepository {
  /// Returns all comments for the post identified by [postId].
  Future<Result<List<Comment>>> getComments(int postId);
}

/// Provides access to user profile data.
abstract class UserRepository {
  /// Returns the user identified by [id].
  Future<Result<User>> getUser(int id);
}
