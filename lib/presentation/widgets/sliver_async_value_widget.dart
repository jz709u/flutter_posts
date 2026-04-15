import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';

/// A sliver-aware async widget for use inside [CustomScrollView.slivers].
///
/// Shows a centered spinner while loading, an error message on failure,
/// and delegates to [data] on success — which must return a sliver widget
/// (e.g. [SliverList], [SliverGrid]).
class SliverAsyncValueWidget<T> extends StatelessWidget {
  const SliverAsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            e is AppException ? e.userMessage : e.toString(),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }
}
