import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/widgets.dart';
import '../../../domain/models/models.dart';

class PostsScreen extends ConsumerWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            tooltip: 'My profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.pushNamed(Routes.myProfileName),
          ),
        ],
      ),
      body: AsyncValueWidget<List<Post>>(
        value: posts,
        data: (list) => RefreshIndicator(
          onRefresh: () => ref.refresh(postsProvider.future),
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) => _PostCard(post: list[index]),
          ),
        ),
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  const _PostCard({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final author = ref.watch(userProvider(post.userId));

    return InkWell(
      onTap: () => context.pushNamed(
        Routes.postDetailName,
        pathParameters: {'postId': post.id.toString()},
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            author.when(
              data: (u) => Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 13, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    u.name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '· ${u.companyName}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              loading: () => SizedBox(
                height: 12,
                width: 120,
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
