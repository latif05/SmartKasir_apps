import 'package:equatable/equatable.dart';

abstract class AppException extends Equatable implements Exception {
  const AppException(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class CacheException extends AppException {
  const CacheException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message, {this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => super.props..add(statusCode);
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message);
}


class ActivationException extends AppException {
  const ActivationException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

