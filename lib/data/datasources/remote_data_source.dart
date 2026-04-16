import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../models/dtos.dart';
import 'mock_data_source.dart';

// Toggle this to switch between live API and realistic offline mock data.
const _useMockData = true;

final remoteDataSourceProvider = Provider<RemoteDataSource>(
  (ref) => _useMockData
      ? MockRemoteDataSource()
      : RemoteDataSource(dio: ref.watch(dioProvider)),
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

  Future<CommentDto> createComment({
    required int postId,
    required String name,
    required String email,
    required String body,
    required DateTime createdAt,
  }) =>
      _request(() async {
        final payload = <String, dynamic>{
          'postId': postId,
          'name': name,
          'email': email,
          'body': body,
          'createdAt': createdAt.toIso8601String(),
        };
        final response = await dio.post<Map<String, dynamic>>(
          '/comments',
          data: payload,
        );
        final responseData = response.data ?? const <String, dynamic>{};
        return CommentDto.fromJson({
          ...payload,
          ...responseData,
          'id': responseData['id'] ?? DateTime.now().millisecondsSinceEpoch,
        });
      });

  Future<UserDto> fetchUser(int id) => _request(() async {
        final response = await dio.get<Map<String, dynamic>>('/users/$id');
        return UserDto.fromJson(response.data!);
      });

  Future<UserDto> _updateExistingGoogleUser({
    required UserDto existingUser,
    required String googleId,
    required String email,
    String? name,
    String? photoUrl,
  }) async {
    final trimmedName = name?.trim();
    final normalizedPhotoUrl =
        photoUrl != null && photoUrl.isNotEmpty ? photoUrl : null;
    final needsUpdate = existingUser.googleId != googleId ||
        existingUser.email != email ||
        (trimmedName != null &&
            trimmedName.isNotEmpty &&
            existingUser.name != trimmedName) ||
        existingUser.photoUrl != normalizedPhotoUrl;

    if (!needsUpdate) return existingUser;

    final payload = <String, dynamic>{
      'googleId': googleId,
      'email': email,
      if (trimmedName != null && trimmedName.isNotEmpty) 'name': trimmedName,
      'photoUrl': normalizedPhotoUrl,
    };

    final response = await dio.patch<Map<String, dynamic>>(
      '/users/${existingUser.id}',
      data: payload,
    );

    return UserDto.fromJson({
      'id': existingUser.id,
      'name': trimmedName != null && trimmedName.isNotEmpty
          ? trimmedName
          : existingUser.name,
      'username': existingUser.username,
      'email': email,
      'website': existingUser.website,
      'company': {'name': existingUser.companyName},
      'googleId': googleId,
      'photoUrl': normalizedPhotoUrl,
      ...?response.data,
      'company':
          response.data?['company'] ?? {'name': existingUser.companyName},
    });
  }

  Future<UserDto> ensureGoogleUser({
    required String googleId,
    required String email,
    String? name,
    String? photoUrl,
  }) =>
      _request(() async {
        final byGoogleId = await dio.get<List<dynamic>>(
          '/users',
          queryParameters: {'googleId': googleId},
        );
        if (byGoogleId.data!.isNotEmpty) {
          return _updateExistingGoogleUser(
            existingUser: UserDto.fromJson(
              byGoogleId.data!.first as Map<String, dynamic>,
            ),
            googleId: googleId,
            email: email,
            name: name,
            photoUrl: photoUrl,
          );
        }

        final byEmail = await dio.get<List<dynamic>>(
          '/users',
          queryParameters: {'email': email},
        );
        if (byEmail.data!.isNotEmpty) {
          return _updateExistingGoogleUser(
            existingUser: UserDto.fromJson(
              byEmail.data!.first as Map<String, dynamic>,
            ),
            googleId: googleId,
            email: email,
            name: name,
            photoUrl: photoUrl,
          );
        }

        final trimmedName = name?.trim();
        final payload = <String, dynamic>{
          'googleId': googleId,
          'name': trimmedName != null && trimmedName.isNotEmpty
              ? trimmedName
              : email,
          'username': email.split('@').first,
          'email': email,
          'website': '',
          'company': {'name': ''},
          if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
        };

        final response = await dio.post<Map<String, dynamic>>(
          '/users',
          data: payload,
        );
        final responseData = response.data ?? const <String, dynamic>{};

        return UserDto.fromJson({
          ...payload,
          ...responseData,
          'id': responseData['id'] ?? googleId.hashCode.abs(),
          'company': responseData['company'] ?? payload['company'],
        });
      });
}
