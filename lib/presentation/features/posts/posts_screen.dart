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
      ),
      body: AsyncValueWidget<List<Post>>(
        value: posts,
        data: (list) => RefreshIndicator(
          onRefresh: () => ref.refresh(postsProvider.future),
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final post = list[index];
              return ListTile(
                title: Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  post.body,
                  maxLines: 1,
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
      ),
    );
  }
}
