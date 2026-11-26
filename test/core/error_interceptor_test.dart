import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/core/network/error_interceptor.dart';

class _CaptureHandler extends ErrorInterceptorHandler {
  DioException? rejected;

  @override
  void reject(DioException error, [bool callFollowing = false]) =>
      rejected = error;
}

void main() {
  Failure failureFor(DioExceptionType type) {
    final handler = _CaptureHandler();
    ErrorInterceptor().onError(
      DioException(
        requestOptions: RequestOptions(path: 'x'),
        type: type,
      ),
      handler,
    );
    return handler.rejected!.error as Failure;
  }

  test('timeouts become TimeoutFailure', () {
    expect(
      failureFor(DioExceptionType.connectionTimeout),
      isA<TimeoutFailure>(),
    );
    expect(failureFor(DioExceptionType.sendTimeout), isA<TimeoutFailure>());
    expect(failureFor(DioExceptionType.receiveTimeout), isA<TimeoutFailure>());
  });

  test('connection error becomes NetworkFailure', () {
    expect(failureFor(DioExceptionType.connectionError), isA<NetworkFailure>());
  });

  test('bad response becomes ServerFailure', () {
    expect(failureFor(DioExceptionType.badResponse), isA<ServerFailure>());
  });

  test('anything else becomes UnknownFailure', () {
    expect(failureFor(DioExceptionType.cancel), isA<UnknownFailure>());
  });
}
