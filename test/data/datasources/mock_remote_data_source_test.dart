import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_demo/data/datasources/mock_data_source.dart';

void main() {
  group('MockRemoteDataSource.fetchUser', () {
    test('returns a seeded user photo url', () async {
      final dataSource = MockRemoteDataSource();

      final user = await dataSource.fetchUser(1);

      expect(user.photoUrl, isNotNull);
      expect(user.photoUrl, contains('mock-user-1'));
    });
  });

  group('MockRemoteDataSource.fetchComments', () {
    test('returns seeded comments with timestamps', () async {
      final dataSource = MockRemoteDataSource();

      final comments = await dataSource.fetchComments(1);

      expect(comments, isNotEmpty);
      expect(comments.every((comment) => comment.createdAt != null), isTrue);
    });
  });

  group('MockRemoteDataSource.ensureGoogleUser', () {
    test('creates a new user when the google account is not present', () async {
      final dataSource = MockRemoteDataSource();

      final user = await dataSource.ensureGoogleUser(
        googleId: 'google-123',
        email: 'new.user@example.com',
        name: 'New User',
        photoUrl: 'https://example.com/avatar.png',
      );

      expect(user.id, greaterThan(10));
      expect(user.googleId, 'google-123');
      expect(user.email, 'new.user@example.com');
      expect(user.name, 'New User');
      expect(user.photoUrl, 'https://example.com/avatar.png');
    });

    test('returns the existing user when the email already exists', () async {
      final dataSource = MockRemoteDataSource();

      final user = await dataSource.ensureGoogleUser(
        googleId: 'google-existing',
        email: 'sarah@techcorpsolutions.io',
        name: 'Sarah Chen',
      );

      expect(user.id, 1);
      expect(user.googleId, 'google-existing');
      expect(user.email, 'sarah@techcorpsolutions.io');
    });

    test('updates photo url for an existing user', () async {
      final dataSource = MockRemoteDataSource();

      final user = await dataSource.ensureGoogleUser(
        googleId: 'google-existing',
        email: 'sarah@techcorpsolutions.io',
        name: 'Sarah Chen',
        photoUrl: 'https://example.com/updated-avatar.png',
      );

      expect(user.id, 1);
      expect(user.photoUrl, 'https://example.com/updated-avatar.png');
      expect(user.googleId, 'google-existing');
    });
  });
}
