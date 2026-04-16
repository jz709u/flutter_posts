import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../providers/providers.dart';
import '../users/user_screen.dart';

/// My-profile screen — delegates entirely to [UserScreen] using the
/// current user's ID so both screens stay in sync automatically.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    return UserScreen(userId: userId);
  }
}
