/// Base exception class for all app exceptions
class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException(this.message, {this.originalError, this.stackTrace});

  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException(super.message, {super.originalError, super.stackTrace});
}

/// Server-side exceptions
class ServerException extends AppException {
  final int? statusCode;

  ServerException(
    super.message, {
    this.statusCode,
    super.originalError,
    super.stackTrace,
  });
}

/// Not found exceptions
class NotFoundException extends AppException {
  NotFoundException(super.message, {super.originalError, super.stackTrace});
}

/// Authentication-related exceptions
class AuthException extends AppException {
  AuthException(super.message, {super.originalError, super.stackTrace});
}

/// Location-related exceptions
class LocationException extends AppException {
  LocationException(super.message, {super.originalError, super.stackTrace});
}
