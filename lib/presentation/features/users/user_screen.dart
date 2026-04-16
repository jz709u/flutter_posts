import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/widgets.dart';
import '../../../domain/models/models.dart';

class UserScreen extends ConsumerWidget {
  const UserScreen({super.key, required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider(userId));
    final posts = ref.watch(postsByUserProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(user.valueOrNull?.name ?? 'Profile'),
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: context.pop,
              )
            : null,
      ),
      body: AsyncValueWidget<User>(
        value: user,
        data: (u) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile header ──────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          UserAvatar(user: u, radius: 44),
                          const SizedBox(height: 10),
                          Text(
                            u.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '@${u.username}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // ── Contact details ─────────────────────────────────
                    _DetailRow(
                      icon: Icons.email_outlined,
                      label: u.email,
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.language_outlined,
                      label: u.website,
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.business_outlined,
                      label: u.companyName,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Posts',
                      style: Theme.of(context).textTheme.titleMedium,
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
                  return ListTile(
                    title: Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => context.pushNamed(
                      Routes.postDetailName,
                      pathParameters: {'postId': post.id.toString()},
                    ),
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
