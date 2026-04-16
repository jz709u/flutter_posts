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
                    _CommentComposer(postId: postId),
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

class _CommentComposer extends ConsumerStatefulWidget {
  const _CommentComposer({required this.postId});

  final int postId;

  @override
  ConsumerState<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends ConsumerState<_CommentComposer> {
  final _controller = TextEditingController();
  bool _isExpanded = false;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _submitting) return;

    final userId = ref.read(currentUserIdProvider);
    final author = await ref.read(userProvider(userId).future);

    setState(() => _submitting = true);
    try {
      await ref.read(commentsProvider(widget.postId).notifier).submitComment(
            author: author,
            body: text,
          );
      if (!mounted) return;
      setState(() {
        _controller.clear();
        _isExpanded = false;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: $error')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser =
        ref.watch(userProvider(ref.watch(currentUserIdProvider)));

    if (!_isExpanded) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _isExpanded = true),
            icon: const Icon(Icons.add_comment_outlined),
            label: const Text('Add comment'),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          currentUser.whenOrNull(
                  data: (user) => UserAvatar(user: user, radius: 16)) ??
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_outline,
                  size: 16,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Write a comment',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send'),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Cancel comment',
            onPressed: _submitting
                ? null
                : () => setState(() {
                      _controller.clear();
                      _isExpanded = false;
                    }),
            icon: const Icon(Icons.close),
          ),
        ],
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
        avatar: UserAvatar(user: u, radius: 11),
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

  String? _formatTimestamp(BuildContext context) {
    final createdAt = comment.createdAt;
    if (createdAt == null) return null;
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatShortDate(createdAt);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(createdAt),
    );
    return '$date at $time';
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = _formatTimestamp(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  comment.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if (timestamp != null)
                Text(
                  timestamp,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.body),
        ],
      ),
    );
  }
}
