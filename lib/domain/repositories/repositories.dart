import '../models/models.dart';
import '../../core/error/result.dart';

abstract class PostRepository {
  Future<Result<List<Post>>> getPosts();
  Future<Result<Post>> getPost(int id);
  Future<Result<List<Post>>> getPostsByUser(int userId);
}

abstract class CommentRepository {
  Future<Result<List<Comment>>> getComments(int postId);
}

abstract class UserRepository {
  Future<Result<User>> getUser(int id);
}
