import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/widgets.dart';
import '../../../domain/models/models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(authProvider).valueOrNull;
    final userId = ref.watch(currentUserIdProvider);
    final posts = ref.watch(postsByUserProvider(userId));

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(account?.displayName ?? 'Profile'),
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: context.pop,
              )
            : null,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar + name header ──────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        _GoogleAvatar(
                          photoUrl: account?.photoUrl,
                          displayName: account?.displayName,
                          radius: 44,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          account?.displayName ?? '',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Contact details ───────────────────────────────────
                  if (account?.email != null)
                    _DetailRow(
                      icon: Icons.email_outlined,
                      label: account!.email,
                    ),
                  const SizedBox(height: 24),
                  // ── Posts heading ─────────────────────────────────────
                  Text('Posts', style: theme.textTheme.titleMedium),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 1, indent: 16, endIndent: 16),
          ),
          SliverAsyncValueWidget<List<Post>>(
            value: posts,
            data: (list) => SliverList.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final post = list[i];
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        post.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      onTap: () => context.pushNamed(
                        Routes.postDetailName,
                        pathParameters: {'postId': post.id.toString()},
                      ),
                    ),
                    if (i < list.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Google profile photo with initial fallback ────────────────────────────────

class _GoogleAvatar extends StatefulWidget {
  const _GoogleAvatar({
    required this.photoUrl,
    required this.displayName,
    required this.radius,
  });

  final String? photoUrl;
  final String? displayName;
  final double radius;

  @override
  State<_GoogleAvatar> createState() => _GoogleAvatarState();
}

class _GoogleAvatarState extends State<_GoogleAvatar> {
  bool _loadFailed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = widget.displayName?.isNotEmpty == true
        ? widget.displayName![0].toUpperCase()
        : '?';
    final textStyle = TextStyle(
      fontSize: widget.radius * 0.8,
      fontWeight: FontWeight.bold,
      color: colorScheme.onPrimaryContainer,
    );

    final hasPhoto = widget.photoUrl != null && !_loadFailed;

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: colorScheme.primaryContainer,
      backgroundImage: hasPhoto ? NetworkImage(widget.photoUrl!) : null,
      onBackgroundImageError:
          hasPhoto ? (_, __) => setState(() => _loadFailed = true) : null,
      child: hasPhoto ? null : Text(initial, style: textStyle),
    );
  }
}

// ── Shared detail row ─────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: muted),
        ),
      ],
    );
  }
}
