import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_demo/core/network/dio_client.dart';

// Helper — build a minimal DioException with the given type and optional
// wrapped error, without needing a real HTTP response.
DioException _dioEx(
  DioExceptionType type, {
  Object? error,
  String? message,
  Response<dynamic>? response,
}) =>
    DioException(
      requestOptions: RequestOptions(path: '/test'),
      type: type,
      error: error,
      message: message,
      response: response,
    );

void main() {
  // ── Exception hierarchy ──────────────────────────────────────────────────

  group('AppException', () {
    test('toString returns the message', () {
      const e = AppException('something broke');
      expect(e.toString(), 'something broke');
    });

    test('message is stored correctly', () {
      const e = AppException('msg');
      expect(e.message, 'msg');
    });
  });

  group('NetworkException', () {
    test('is a subtype of AppException', () {
      const e = NetworkException('no internet');
      expect(e, isA<AppException>());
    });

    test('toString returns the message', () {
      const e = NetworkException('timeout');
      expect(e.toString(), 'timeout');
    });
  });

  group('ServerException', () {
    test('is a subtype of AppException', () {
      const e = ServerException('not found', statusCode: 404);
      expect(e, isA<AppException>());
    });

    test('stores statusCode', () {
      const e = ServerException('error', statusCode: 500);
      expect(e.statusCode, 500);
    });

    test('statusCode defaults to null', () {
      const e = ServerException('error');
      expect(e.statusCode, isNull);
    });

    test('toString returns the message', () {
      const e = ServerException('bad gateway', statusCode: 502);
      expect(e.toString(), 'bad gateway');
    });
  });

  group('UnknownException', () {
    test('is a subtype of AppException', () {
      const e = UnknownException('???');
      expect(e, isA<AppException>());
    });

    test('toString returns the message', () {
      const e = UnknownException('mystery');
      expect(e.toString(), 'mystery');
    });
  });

  // ── mapDioError ──────────────────────────────────────────────────────────

  group('mapDioError', () {
    test('returns wrapped AppException unchanged', () {
      const inner = NetworkException('wrapped');
      final ex = _dioEx(DioExceptionType.unknown, error: inner);
      expect(mapDioError(ex), same(inner));
    });

    test('returns wrapped ServerException unchanged', () {
      const inner = ServerException('server broke', statusCode: 503);
      final ex = _dioEx(DioExceptionType.badResponse, error: inner);
      final result = mapDioError(ex);
      expect(result, isA<ServerException>());
      expect((result as ServerException).statusCode, 503);
    });

    test('wraps non-AppException error in UnknownException', () {
      final ex = _dioEx(
        DioExceptionType.unknown,
        error: Exception('raw'),
        message: 'raw error',
      );
      final result = mapDioError(ex);
      expect(result, isA<UnknownException>());
    });

    test('uses message when error is null', () {
      final ex = _dioEx(
        DioExceptionType.unknown,
        message: 'fallback message',
      );
      final result = mapDioError(ex);
      expect(result, isA<UnknownException>());
      expect(result.message, 'fallback message');
    });

    test('falls back to "Unknown error" when both error and message are null',
        () {
      final ex = DioException(requestOptions: RequestOptions(path: '/'));
      final result = mapDioError(ex);
      expect(result, isA<UnknownException>());
      expect(result.message, 'Unknown error');
    });
  });
}
