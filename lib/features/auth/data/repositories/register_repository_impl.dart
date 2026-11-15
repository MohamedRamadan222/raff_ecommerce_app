import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/auth/data/datasources/register_remote_data_source.dart';
import 'package:raff_app/features/auth/domain/entities/user_entity.dart';
import 'package:raff_app/features/auth/domain/repositories/register_repository.dart';

import '../datasources/auth_local_data_source.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  RegisterRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        fullName: fullName,
        phone: phone,
        password: password,
        email: email,
      );
      await _localDataSource.cacheUser(user);
      return Right(user);
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const Left(TimeoutFailure());

        case DioExceptionType.connectionError:
          return const Left(NetworkFailure());

        case DioExceptionType.badResponse:
          (e.response?.data is Map ? e.response?.data['message'] : null) ??
              'خطأ في';
          return Left(ServerFailure(e.toString()));

        default:
          return const Left(UnknownFailure());
      }
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
