import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// ---------------------------------------------------------------------------
// Exception hierarchy
// ---------------------------------------------------------------------------

class AppException implements Exception {
  const AppException(this.message);

  final String message;

  /// Human-readable string suitable for display in the UI.
  /// Subclasses override this to include extra context (e.g. status code).
  String get userMessage => 'Something went wrong. Please try again.';

  @override
  String toString() => message;
}


class NetworkException extends AppException {
  const NetworkException(super.message);

  @override
  String get userMessage => 'No internet connection. Please try again.';
}

class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});

  final int? statusCode;

  @override
  String get userMessage => statusCode != null
      ? 'Server error ($statusCode). Please try again later.'
      : 'Server error. Please try again later.';
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}

// ---------------------------------------------------------------------------
// Dio client
// ---------------------------------------------------------------------------

const _baseUrl = 'https://jsonplaceholder.typicode.com';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    _ErrorInterceptor(),
    PrettyDioLogger(
      requestHeader: false,
      requestBody: false,
      responseBody: false,
    ),
  ]);

  return dio;
});

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException mapped;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        mapped = NetworkException(err.message ?? 'Connection error');
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode;
        mapped = ServerException(
          err.response?.statusMessage ?? 'Server error',
          statusCode: code,
        );
      default:
        mapped = UnknownException(err.message ?? 'Unknown error');
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: mapped,
        type: err.type,
        response: err.response,
      ),
    );
  }
}

AppException mapDioError(DioException e) {
  if (e.error is AppException) return e.error as AppException;
  return UnknownException(e.message ?? 'Unknown error');
}
