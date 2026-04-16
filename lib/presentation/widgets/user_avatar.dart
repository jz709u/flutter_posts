import 'package:flutter/material.dart';

import '../../domain/models/models.dart';

/// Circular avatar for a [User].
///
/// Shows the user's photo from pravatar.cc (keyed on [user.id] for
/// consistency). If the network request fails the avatar falls back to the
/// user's initial letter, so the widget never throws in test environments.
class UserAvatar extends StatefulWidget {
  const UserAvatar({super.key, required this.user, this.radius = 20});

  final User user;

  /// Radius of the circle in logical pixels.
  final double radius;

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  bool _loadFailed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = (widget.radius * 2).toInt();
    // Prefer an explicit photoUrl (e.g. from Google Sign-In); fall back to
    // a consistent placeholder keyed on the user ID.
    final url = widget.user.photoUrl ??
        'https://i.pravatar.cc/$size?u=user${widget.user.id}';
    final initial = widget.user.name[0].toUpperCase();
    final textStyle = TextStyle(
      fontSize: widget.radius * 0.8,
      fontWeight: FontWeight.bold,
      color: colorScheme.onPrimaryContainer,
    );

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: colorScheme.primaryContainer,
      // backgroundImage is cleared after a failure so we only show the initial.
      backgroundImage: _loadFailed ? null : NetworkImage(url),
      onBackgroundImageError:
          _loadFailed ? null : (_, __) => setState(() => _loadFailed = true),
      child: _loadFailed ? Text(initial, style: textStyle) : null,
    );
  }
}
