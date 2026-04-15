sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  /// Returns the value, or null if this is a [Failure].
  T? get dataOrNull => switch (this) {
        Success(:final value) => value,
        Failure() => null,
      };

  /// Returns the exception, or null if this is a [Success].
  Exception? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final exception) => exception,
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(Exception error) failure,
  });
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(Exception error) failure,
  }) =>
      success(value);
}

final class Failure<T> extends Result<T> {
  const Failure(this.exception);

  final Exception exception;

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(Exception error) failure,
  }) =>
      failure(exception);
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

extension ResultUnwrap<T> on Result<T> {
  /// Unwraps to the success value, or rethrows the exception.
  /// Intended for use inside async notifiers where exceptions become
  /// Riverpod error states automatically.
  T unwrap() => when(success: (v) => v, failure: (e) => throw e);
}
