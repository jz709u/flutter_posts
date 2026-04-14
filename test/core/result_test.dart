import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_demo/core/error/result.dart';

void main() {
  group('Result', () {
    test('Success.isSuccess is true', () {
      const result = Success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
    });

    test('Failure.isFailure is true', () {
      final result = Failure<int>(Exception('err'));
      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
    });

    test('Success.data returns the value', () {
      const result = Success('hello');
      expect(result.data, 'hello');
    });

    test('Failure.error returns the exception', () {
      final ex = Exception('boom');
      final result = Failure<String>(ex);
      expect(result.error, ex);
    });

    test('when calls success branch for Success', () {
      const result = Success(10);
      final out = result.when(success: (v) => v * 2, failure: (_) => -1);
      expect(out, 20);
    });

    test('when calls failure branch for Failure', () {
      final result = Failure<int>(Exception('err'));
      final out = result.when(success: (v) => v, failure: (_) => -1);
      expect(out, -1);
    });
  });
}
