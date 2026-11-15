import 'package:dio/dio.dart';
import 'package:raff_app/core/network/dio_clint.dart';
import 'package:raff_app/features/auth/data/models/user_model.dart';

abstract class LoginRemoteDataSource {
  Future<UserModel> login(String username, String password);
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final Dio _dio;

  LoginRemoteDataSourceImpl(DioClint dioClient) : _dio = dioClient.dio;

  @override
  Future<UserModel> login(String username, String password) async {
    final response = await _dio.post(
      'auth/login',
      data: {'username': username, 'password': password},
    );

    return UserModel.fromJson(response.data);
  }
}
