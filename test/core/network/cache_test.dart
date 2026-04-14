import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_demo/core/network/cache.dart';

void main() {
  group('InMemoryCache', () {
    late InMemoryCache<String, String> cache;

    setUp(() => cache = InMemoryCache());

    test('stores and retrieves a value', () {
      cache.set('key', 'value');
      expect(cache.get('key'), 'value');
    });

    test('returns null for missing keys', () {
      expect(cache.get('missing'), isNull);
    });

    test('containsKey returns true while entry is valid', () {
      cache.set('k', 'v');
      expect(cache.containsKey('k'), isTrue);
    });

    test('expired entries are treated as absent', () async {
      cache.set('k', 'v', ttl: const Duration(milliseconds: 10));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(cache.get('k'), isNull);
      expect(cache.containsKey('k'), isFalse);
    });

    test('invalidate removes a key', () {
      cache.set('k', 'v');
      cache.invalidate('k');
      expect(cache.get('k'), isNull);
    });

    test('clear empties the entire cache', () {
      cache.set('a', '1');
      cache.set('b', '2');
      cache.clear();
      expect(cache.get('a'), isNull);
      expect(cache.get('b'), isNull);
    });

    test('overwriting a key updates the value and resets TTL', () async {
      cache.set('k', 'old', ttl: const Duration(milliseconds: 30));
      cache.set('k', 'new', ttl: const Duration(minutes: 5));
      expect(cache.get('k'), 'new');
      await Future<void>.delayed(const Duration(milliseconds: 40));
      // Should still be there because TTL was reset to 5 min
      expect(cache.get('k'), 'new');
    });
  });
}
