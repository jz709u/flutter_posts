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
