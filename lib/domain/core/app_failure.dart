/// A typed, project-agnostic failure returned by shared services.
sealed class AppFailure implements Exception {
  const AppFailure(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(
    super.message, {
    this.statusCode,
    super.cause,
    super.stackTrace,
  });

  final int? statusCode;
}

final class StorageFailure extends AppFailure {
  const StorageFailure(super.message, {super.cause, super.stackTrace});
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {super.cause, super.stackTrace});
}
