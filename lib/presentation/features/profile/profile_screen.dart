import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/widgets.dart';
import '../../../domain/models/models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final user = ref.watch(userProvider(userId));
    final posts = ref.watch(postsByUserProvider(userId));

    return Scaffold(
      body: AsyncValueWidget<User>(
        value: user,
        data: (u) => CustomScrollView(
          slivers: [
            _ProfileSliverAppBar(user: u),
            SliverToBoxAdapter(child: _ProfileDetails(user: u)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                child: Row(
                  children: [
                    Text(
                      'Posts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    SliverAsyncValueWidget<List<Post>>(
                      // Show post count badge once loaded
                      value: posts,
                      data: (list) => Text(
                        '${list.length}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
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
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
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
      ),
    );
  }
}

// ── Sliver app bar with avatar hero ──────────────────────────────────────────

class _ProfileSliverAppBar extends StatelessWidget {
  const _ProfileSliverAppBar({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      leading: context.canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: context.pop,
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primaryContainer,
                colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.name,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '@${user.username}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Contact / company detail section ─────────────────────────────────────────

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.email_outlined,
            label: user.email,
            muted: muted,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.language_outlined,
            label: user.website,
            muted: muted,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.business_outlined,
            label: user.companyName,
            muted: muted,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.muted,
  });

  final IconData icon;
  final String label;
  final Color muted;

  @override
  Widget build(BuildContext context) {
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
