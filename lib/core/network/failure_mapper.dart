import 'package:dio/dio.dart';

import '../errors/failures.dart';

abstract final class FailureMapper {
  static Failure fromDio(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();

      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        return ServerFailure(_serverMessage(exception));

      default:
        return const UnknownFailure();
    }
  }

  static String _serverMessage(DioException exception) {
    final data = exception.response?.data;
    if (data is Map) {
      return data['message']?.toString() ?? '';
    }
    return '';
  }
}
