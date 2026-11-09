import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure([this.statusCode]);

  @override
  List<Object?> get props => [statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class TimeoutFailure extends Failure {
  const TimeoutFailure();
}

class UnknownFailure extends Failure {
  const UnknownFailure();
}
