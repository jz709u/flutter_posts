import 'package:equatable/equatable.dart';

/// A blog post from the remote API.
class Post extends Equatable {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  /// Returns a copy of this [Post] with the given fields replaced.
  Post copyWith({int? id, int? userId, String? title, String? body}) => Post(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        body: body ?? this.body,
      );

  @override
  List<Object?> get props => [id, userId, title, body];
}

/// A comment on a blog post.
class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
  });

  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;

  /// Returns a copy of this [Comment] with the given fields replaced.
  Comment copyWith({
    int? id,
    int? postId,
    String? name,
    String? email,
    String? body,
  }) =>
      Comment(
        id: id ?? this.id,
        postId: postId ?? this.postId,
        name: name ?? this.name,
        email: email ?? this.email,
        body: body ?? this.body,
      );

  @override
  List<Object?> get props => [id, postId, name, email, body];
}

/// A user / author profile.
class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.website,
    required this.companyName,
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final String website;
  final String companyName;

  /// Returns a copy of this [User] with the given fields replaced.
  User copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    String? website,
    String? companyName,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        username: username ?? this.username,
        email: email ?? this.email,
        website: website ?? this.website,
        companyName: companyName ?? this.companyName,
      );

  @override
  List<Object?> get props => [id, name, username, email, website, companyName];
}
