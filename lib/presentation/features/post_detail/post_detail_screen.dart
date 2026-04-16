import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/widgets.dart';
import '../../../domain/models/models.dart';

class PostDetailScreen extends ConsumerWidget {
  const PostDetailScreen({super.key, required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postProvider(postId));
    final comments = ref.watch(commentsProvider(postId));

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Text(
          post.valueOrNull?.title ?? 'Post',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: context.pop,
              )
            : null,
      ),
      body: AsyncValueWidget<Post>(
        value: post,
        data: (p) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AuthorChip(userId: p.userId),
                    const SizedBox(height: 12),
                    Text(p.body),
                    const SizedBox(height: 24),
                    Text(
                      'Comments',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ),
            SliverAsyncValueWidget<List<Comment>>(
              value: comments,
              data: (list) => SliverList.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => _CommentTile(comment: list[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthorChip extends ConsumerWidget {
  const _AuthorChip({required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider(userId));
    return user.when(
      data: (u) => ActionChip(
        avatar: const Icon(Icons.person_outline, size: 16),
        label: Text(u.name),
        onPressed: () => context.pushNamed(
          Routes.userProfileName,
          pathParameters: {'userId': userId.toString()},
        ),
      ),
      loading: () => const SizedBox(
        height: 32,
        width: 100,
        child: LinearProgressIndicator(),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.name,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(comment.body),
        ],
      ),
    );
  }
}
