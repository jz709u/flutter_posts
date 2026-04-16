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
    this.createdAt,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) => CommentDto(
        id: json['id'] as int,
        postId: json['postId'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        body: json['body'] as String,
        createdAt: _parseDateTime(json['createdAt']),
      );

  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;
  final DateTime? createdAt;

  CommentDto copyWith({
    int? id,
    int? postId,
    String? name,
    String? email,
    String? body,
    DateTime? createdAt,
  }) =>
      CommentDto(
        id: id ?? this.id,
        postId: postId ?? this.postId,
        name: name ?? this.name,
        email: email ?? this.email,
        body: body ?? this.body,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'name': name,
        'email': email,
        'body': body,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  Comment toDomain() => Comment(
        id: id,
        postId: postId,
        name: name,
        email: email,
        body: body,
        createdAt: createdAt,
      );
}

DateTime? _parseDateTime(Object? value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

class UserDto {
  const UserDto({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.website,
    required this.companyName,
    this.googleId,
    this.photoUrl,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as int,
        name: json['name'] as String,
        username: (json['username'] as String?) ??
            (json['email'] as String).split('@').first,
        email: json['email'] as String,
        website: (json['website'] as String?) ?? '',
        companyName:
            ((json['company'] as Map<String, dynamic>?)?['name'] as String?) ??
                '',
        googleId: json['googleId'] as String?,
        photoUrl: json['photoUrl'] as String?,
      );

  factory UserDto.fromGoogleAccount({
    required int id,
    required String googleId,
    required String email,
    String? name,
    String? photoUrl,
  }) {
    final trimmedName = name?.trim();
    return UserDto(
      id: id,
      name: trimmedName != null && trimmedName.isNotEmpty ? trimmedName : email,
      username: email.split('@').first,
      email: email,
      website: '',
      companyName: '',
      googleId: googleId,
      photoUrl: photoUrl,
    );
  }

  UserDto copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    String? website,
    String? companyName,
    String? googleId,
    String? photoUrl,
  }) {
    return UserDto(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      website: website ?? this.website,
      companyName: companyName ?? this.companyName,
      googleId: googleId ?? this.googleId,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  final int id;
  final String name;
  final String username;
  final String email;
  final String website;
  final String companyName;
  final String? googleId;
  final String? photoUrl;

  User toDomain() => User(
        id: id,
        name: name,
        username: username,
        email: email,
        website: website,
        companyName: companyName,
        googleId: googleId,
        photoUrl: photoUrl,
      );
}
