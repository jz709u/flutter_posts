import '../../domain/models/models.dart';

class PostDto {
  const PostDto({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) => PostDto(
        id: json['id'] as int,
        userId: json['userId'] as int,
        title: json['title'] as String,
        body: json['body'] as String,
      );

  final int id;
  final int userId;
  final String title;
  final String body;

  Post toDomain() => Post(id: id, userId: userId, title: title, body: body);
}

class CommentDto {
  const CommentDto({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) => CommentDto(
        id: json['id'] as int,
        postId: json['postId'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        body: json['body'] as String,
      );

  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;

  Comment toDomain() => Comment(
        id: id,
        postId: postId,
        name: name,
        email: email,
        body: body,
      );
}

class UserDto {
  const UserDto({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.website,
    required this.companyName,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as int,
        name: json['name'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        website: json['website'] as String,
        companyName: (json['company'] as Map<String, dynamic>)['name'] as String,
      );

  final int id;
  final String name;
  final String username;
  final String email;
  final String website;
  final String companyName;

  User toDomain() => User(
        id: id,
        name: name,
        username: username,
        email: email,
        website: website,
        companyName: companyName,
      );
}
