import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/async_value_widget.dart';
import '../../../domain/models/models.dart';

class UserScreen extends ConsumerWidget {
  const UserScreen({super.key, required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider(userId));
    final posts = ref.watch(postsByUserProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
                    Text(
                      u.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text('@${u.username}'),
                    const SizedBox(height: 4),
                    Text(u.email),
                    const SizedBox(height: 4),
                    Text(u.website),
                    const SizedBox(height: 4),
                    Text(u.companyName,
                        style: const TextStyle(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 24),
                    Text(
                      'Posts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ),
            posts.when(
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
                    onTap: () => context.goNamed(
                      Routes.postDetailName,
                      pathParameters: {'postId': post.id.toString()},
                    ),
                  );
                },
              ),
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(e.toString()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
