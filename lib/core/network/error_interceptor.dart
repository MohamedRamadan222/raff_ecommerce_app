import 'package:dio/dio.dart';

import '../errors/failures.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final Failure failure;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        failure = const TimeoutFailure();
      case DioExceptionType.connectionError:
        failure = const NetworkFailure();
      case DioExceptionType.badResponse:
        failure = ServerFailure(err.response?.statusCode);
      default:
        failure = const UnknownFailure();
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: failure,
      ),
    );
  }
}
