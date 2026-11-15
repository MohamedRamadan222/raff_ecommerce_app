import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/auth/domain/entities/user_entity.dart';

abstract class LoginRepository {
  Future<Either<Failure, UserEntity>> login(String username, String password);
}
