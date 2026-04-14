import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Generic in-memory cache with TTL
// ---------------------------------------------------------------------------

class CacheEntry<T> {
  CacheEntry(this.value, this.expiresAt);

  final T value;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class InMemoryCache<K, V> {
  final _store = <K, CacheEntry<V>>{};

  /// Store [value] under [key] for [ttl] duration (default 5 min).
  void set(K key, V value, {Duration ttl = const Duration(minutes: 5)}) {
    _store[key] = CacheEntry(value, DateTime.now().add(ttl));
  }

  /// Return the cached value if it exists and hasn't expired.
  V? get(K key) {
    final entry = _store[key];
    if (entry == null || entry.isExpired) {
      _store.remove(key);
      return null;
    }
    return entry.value;
  }

  void invalidate(K key) => _store.remove(key);

  void clear() => _store.clear();

  bool containsKey(K key) => get(key) != null;
}

// ---------------------------------------------------------------------------
// Singleton caches exposed as providers
// ---------------------------------------------------------------------------

final postCacheProvider = Provider<InMemoryCache<String, dynamic>>(
  (_) => InMemoryCache<String, dynamic>(),
);

final userCacheProvider = Provider<InMemoryCache<int, dynamic>>(
  (_) => InMemoryCache<int, dynamic>(),
);
