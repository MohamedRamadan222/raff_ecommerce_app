import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/core/network/failure_mapper.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/login_remote_data_source.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource localDataSource;

  LoginRepositoryImpl(this._remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, UserEntity>> login(
    String username,
    String password,
  ) async {
    try {
      final userModel = await _remoteDataSource.login(username, password);
      await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } on DioException catch (e) {
      return Left(FailureMapper.fromDio(e));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
