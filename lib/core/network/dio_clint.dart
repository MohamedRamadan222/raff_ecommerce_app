import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:raff_app/core/network/api_constants.dart';

import 'error_interceptor.dart';

class DioClint {
  final Dio dio;

  DioClint()
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Accept': 'kkkkkk'},
        ),
      ) {
    dio.interceptors.addAll([
      if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
      ErrorInterceptor(),
    ]);
  }
}
