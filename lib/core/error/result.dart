sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T get data => (this as Success<T>).value;
  Exception get error => (this as Failure<T>).exception;

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
