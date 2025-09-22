class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException: $message';
}

// Storage Exceptions
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.details,
  });
}

class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.details,
  });
}

// Network Exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.details,
  });
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.details,
  });
}

// Validation Exceptions
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
  });
}

// Authentication Exceptions
class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.code,
    super.details,
  });
}

// Permission Exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.details,
  });
}
