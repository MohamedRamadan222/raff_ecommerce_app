import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/auth/domain/entities/user_entity.dart';
import 'package:raff_app/features/auth/domain/repositories/register_repository.dart';

class RegisterUseCase {
  final RegisterRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) {
    return _repository.register(
      fullName: fullName,
      phone: phone,
      password: password,
      email: email,
    );
  }
}
