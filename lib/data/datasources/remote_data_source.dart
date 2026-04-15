import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../models/dtos.dart';

final remoteDataSourceProvider = Provider<RemoteDataSource>(
  (ref) => RemoteDataSource(dio: ref.watch(dioProvider)),
);

class RemoteDataSource {
  RemoteDataSource({required this.dio});

  final Dio dio;

  // Centralised error-mapping so every method stays free of try-catch boiler-plate.
  Future<T> _request<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<PostDto>> fetchPosts() => _request(() async {
        final response = await dio.get<List<dynamic>>('/posts');
        return response.data!
            .map((e) => PostDto.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  Future<PostDto> fetchPost(int id) => _request(() async {
        final response = await dio.get<Map<String, dynamic>>('/posts/$id');
        return PostDto.fromJson(response.data!);
      });

  Future<List<PostDto>> fetchPostsByUser(int userId) => _request(() async {
        final response = await dio.get<List<dynamic>>(
          '/posts',
          queryParameters: {'userId': userId},
        );
        return response.data!
            .map((e) => PostDto.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  Future<List<CommentDto>> fetchComments(int postId) => _request(() async {
        final response = await dio.get<List<dynamic>>(
          '/comments',
          queryParameters: {'postId': postId},
        );
        return response.data!
            .map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  Future<UserDto> fetchUser(int id) => _request(() async {
        final response = await dio.get<Map<String, dynamic>>('/users/$id');
        return UserDto.fromJson(response.data!);
      });
}
