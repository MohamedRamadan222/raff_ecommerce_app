import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/auth/domain/entities/user_entity.dart';
import 'package:raff_app/features/auth/domain/repositories/login_repository.dart';

class LoginUseCase {
  final LoginRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(String username, String password) {
    return _repository.login(username, password);
  }
}
