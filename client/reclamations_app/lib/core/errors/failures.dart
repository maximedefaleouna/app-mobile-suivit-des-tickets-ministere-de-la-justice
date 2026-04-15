import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message}) : super(statusCode: -1);
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message}) : super(statusCode: 400);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message}) : super(statusCode: 404);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({required super.message}) : super(statusCode: 403);
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message}) : super(statusCode: -1);
}
