// ignore_for_file: file_names, avoid_print

import 'package:dio/dio.dart';
import '../core/constants/app_constant.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.BASE_URL,
        connectTimeout: const Duration(seconds: 30), // was 10
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    // ✅ Logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );

    // ✅ Error handling interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          // Handle common errors
          if (e.type == DioExceptionType.connectionTimeout) {
            print("⏱️ Connection Timeout");
          } else if (e.type == DioExceptionType.badResponse) {
            print("❌ Server Error: ${e.response?.statusCode}");
          } else {
            print("⚠️ Unexpected Error: ${e.message}");
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // ✅ Example helper methods
  Future<Response> getRequest(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    return await _dio.get(endpoint, queryParameters: queryParams);
  }

  Future<Response> postRequest(String endpoint, {dynamic data}) async {
    return await _dio.post(endpoint, data: data);
  }
}
