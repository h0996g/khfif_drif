// lib/core/errors/failures.dart

/// Base class for all domain-level failures.
sealed class Failure {
  const Failure({required this.message});

  final String message;

  @override
  String toString() => '$runtimeType(message: $message)';
}

/// Failures originating from the remote API.
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Failures caused by missing or broken network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Failures from local cache / storage operations.
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Failures caused by invalid user input that reaches the domain layer.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
