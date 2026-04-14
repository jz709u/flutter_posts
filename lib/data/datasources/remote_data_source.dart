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

  Future<List<PostDto>> fetchPosts() async {
    try {
      final response = await dio.get<List<dynamic>>('/posts');
      return response.data!
          .map((e) => PostDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<PostDto> fetchPost(int id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/posts/$id');
      return PostDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<PostDto>> fetchPostsByUser(int userId) async {
    try {
      final response = await dio.get<List<dynamic>>(
        '/posts',
        queryParameters: {'userId': userId},
      );
      return response.data!
          .map((e) => PostDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<CommentDto>> fetchComments(int postId) async {
    try {
      final response = await dio.get<List<dynamic>>(
        '/comments',
        queryParameters: {'postId': postId},
      );
      return response.data!
          .map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<UserDto> fetchUser(int id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/users/$id');
      return UserDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
