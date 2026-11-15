import 'package:equatable/equatable.dart';
import 'package:raff_app/features/auth/domain/entities/user_entity.dart';

import '../../../../core/errors/failures.dart';

abstract class LoginState extends Equatable {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();

  @override
  List<Object?> get props => [];
}

class LoginLoading extends LoginState {
  const LoginLoading();

  @override
  List<Object?> get props => [];
}

class LoginSuccess extends LoginState {
  final UserEntity user;

  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class LoginFailure extends LoginState {
  final Failure failure;

  const LoginFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
