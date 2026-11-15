import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/auth/domain/entities/user_entity.dart';

abstract class RegisterRepository {
  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  });
}
