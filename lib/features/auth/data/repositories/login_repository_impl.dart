import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:raff_app/core/errors/failures.dart';

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
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const Left(TimeoutFailure());

        case DioExceptionType.connectionError:
          return const Left(NetworkFailure());

        case DioExceptionType.badResponse:
          final errorMessage = e.response?.data['message'] ?? 'خطأ في السيرفر';
          return Left(ServerFailure(errorMessage));

        default:
          return const Left(UnknownFailure());
      }
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
