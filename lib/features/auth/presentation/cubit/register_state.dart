import 'package:equatable/equatable.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/auth/domain/entities/user_entity.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  final UserEntity user;

  const RegisterSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class RegisterFailure extends RegisterState {
  final Failure failure;

  const RegisterFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
