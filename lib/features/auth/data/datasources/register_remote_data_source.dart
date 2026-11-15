import 'package:dio/dio.dart';
import 'package:raff_app/core/network/dio_clint.dart';
import 'package:raff_app/features/auth/data/models/user_model.dart';

abstract class RegisterRemoteDataSource {
  Future<UserModel> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  });
}

class RegisterRemoteDataSourceImpl implements RegisterRemoteDataSource {
  final Dio _dio;

  RegisterRemoteDataSourceImpl(DioClint dioClint) : _dio = dioClint.dio;

  @override
  Future<UserModel> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) async {
    final nameParts = fullName.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final response = await _dio.post(
      'users/add',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'phone': '+966$phone',
        'username': phone,
        'password': password,
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      },
    );

    return UserModel.fromJson(response.data);
  }
}
