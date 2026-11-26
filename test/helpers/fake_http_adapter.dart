import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Adapter وهمي بدل النت: بيرجع الرد اللي احنا محددينه ويحفظ آخر request.
class FakeHttpAdapter implements HttpClientAdapter {
  final int statusCode;
  final Object? body;
  RequestOptions? lastRequest;

  FakeHttpAdapter({this.statusCode = 200, this.body});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
