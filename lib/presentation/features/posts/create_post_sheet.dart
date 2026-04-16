import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../../domain/models/models.dart';
import '../../widgets/widgets.dart';

/// Modal bottom sheet for composing a new post.
///
/// Call via [showCreatePostSheet]; the sheet adds the post to [postsProvider]
/// optimistically and dismisses itself on success.
Future<void> showCreatePostSheet(BuildContext context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CreatePostSheet(),
    );

class _CreatePostSheet extends ConsumerStatefulWidget {
  const _CreatePostSheet();

  @override
  ConsumerState<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<_CreatePostSheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);

    final userId = ref.read(currentUserIdProvider);
    final existing = ref.read(postsProvider).valueOrNull ?? [];
    // Use a local negative ID so it never clashes with server IDs.
    final newId = -(existing.length + 1);

    final post = Post(
      id: newId,
      userId: userId,
      title: _titleCtrl.text.trim(),
      body: _bodyCtrl.text.trim(),
    );

    ref.read(postsProvider.notifier).addPost(post);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(userProvider(ref.watch(currentUserIdProvider)));

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              children: [
                currentUser.whenOrNull(
                      data: (u) => UserAvatar(user: u, radius: 18),
                    ) ??
                    const SizedBox(width: 36, height: 36),
                const SizedBox(width: 10),
                Text(
                  'New post',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Post'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ── Title ────────────────────────────────────────────────────────
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              style: theme.textTheme.titleMedium,
              maxLines: 2,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const Divider(height: 8),
            // ── Body ─────────────────────────────────────────────────────────
            TextFormField(
              controller: _bodyCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
                border: InputBorder.none,
              ),
              style: theme.textTheme.bodyMedium,
              maxLines: 6,
              minLines: 3,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Body is required' : null,
            ),
          ],
        ),
      ),
    );
  }
}
