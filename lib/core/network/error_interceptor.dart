import 'package:dio/dio.dart';

import 'failure_mapper.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: FailureMapper.fromDio(err),
      ),
    );
  }
}
