import 'package:dio/dio.dart';

sealed class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, {this.status});
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message, {super.status});
}

class ServerException extends ApiException {
  ServerException(super.message, {super.status});
}

class NetworkException extends ApiException {
  NetworkException(super.message, {super.status});
}

class BadRequestException extends ApiException {
  BadRequestException(super.message, {super.status});
}

class NotFoundException extends ApiException {
  NotFoundException(super.message, {super.status});
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message, {super.status});
}

class ConflictException extends ApiException {
  ConflictException(super.message, {super.status});
}

class ValidationException extends ApiException {
  ValidationException(super.message, {super.status});
}

ApiException mapDioError(Object err) {
  if (err is! DioException) return NetworkException('Unexpected error');
  final status = err.response?.statusCode;
  final msg = (err.response?.data is Map)
      ? (err.response?.data['message']?.toString() ?? err.message)
      : err.message;

  switch (status) {
    case 400:
      return BadRequestException(msg ?? 'Bad request', status: status);
    case 401:
      return UnauthorizedException(msg ?? 'Unauthorized', status: status);
    case 403:
      return ForbiddenException(msg ?? 'Forbidden', status: status);
    case 404:
      return NotFoundException(msg ?? 'Not found', status: status);
    case 409:
      return ConflictException(msg ?? 'Conflict', status: status);
    case 422:
      return ValidationException(msg ?? 'Validation error', status: status);
    default:
      if (status != null && status >= 500) {
        return ServerException(msg ?? 'Server error', status: status);
      }
      return NetworkException(msg ?? 'Network error', status: status);
  }
}
