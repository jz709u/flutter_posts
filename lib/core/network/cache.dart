import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/dtos.dart';

// ---------------------------------------------------------------------------
// Generic in-memory cache with TTL
// ---------------------------------------------------------------------------

/// A single cache entry wrapping [value] with a [DateTime] expiry.
class CacheEntry<T> {
  CacheEntry(this.value, this.expiresAt);

  final T value;

  /// The point in time after which this entry is considered stale.
  final DateTime expiresAt;

  /// Returns `true` if the current time is past [expiresAt].
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// A lightweight in-memory key-value store with per-entry TTL expiry.
///
/// Expired entries are lazily evicted on read — no background timer is needed.
/// Intended for short-lived caches (seconds to minutes); not persisted across
/// app restarts.
class InMemoryCache<K, V> {
  final _store = <K, CacheEntry<V>>{};

  /// Stores [value] under [key] and expires it after [ttl] (default 5 min).
  void set(K key, V value, {Duration ttl = const Duration(minutes: 5)}) {
    _store[key] = CacheEntry(value, DateTime.now().add(ttl));
  }

  /// Returns the cached value for [key], or `null` if absent or expired.
  /// Expired entries are removed from the store on access.
  V? get(K key) {
    final entry = _store[key];
    if (entry == null || entry.isExpired) {
      _store.remove(key);
      return null;
    }
    return entry.value;
  }

  /// Removes the entry for [key] regardless of its expiry time.
  void invalidate(K key) => _store.remove(key);

  /// Removes all entries from the cache.
  void clear() => _store.clear();

  /// Returns `true` if a non-expired entry exists for [key].
  bool containsKey(K key) => get(key) != null;
}

// ---------------------------------------------------------------------------
// Singleton caches exposed as providers
// ---------------------------------------------------------------------------

/// Caches `List<PostDto>` — used for all-posts and user-posts lists.
final postListCacheProvider = Provider<InMemoryCache<String, List<PostDto>>>(
  (_) => InMemoryCache<String, List<PostDto>>(),
);

/// Caches a single `PostDto` by string key.
final postCacheProvider = Provider<InMemoryCache<String, PostDto>>(
  (_) => InMemoryCache<String, PostDto>(),
);

/// Caches a single `UserDto` by int id.
final userCacheProvider = Provider<InMemoryCache<int, UserDto>>(
  (_) => InMemoryCache<int, UserDto>(),
);
