// ignore_for_file: unused_import

import 'dart:async';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;

  RetryInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // ❌ Do NOT retry email availability endpoint
    if (err.requestOptions.path.contains(
      "/userresource/check/email/availability",
    )) {
      return handler.next(err);
    }

    // Retry only network timeouts
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      try {
        final response = await dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
          ),
        );
        return handler.resolve(response);
      } catch (_) {}
    }

    handler.next(err);
  }
}
