// ignore_for_file: file_names, avoid_print

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../core/constants/app_constant.dart';
import '../global_widgets/CustomSnackbar/CustomSnackbar.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.BASE_URL,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    // Add Pretty Dio Logger with emojis
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    // Error interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          _handleDioError(e);
          handler.next(e); // continue
        },
      ),
    );
  }

  Dio get dio => _dio;

  // Generic GET request
  Future<Response?> getRequest(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParams);
    } on DioException catch (e) {
      _handleDioError(e);
      return null;
    }
  }

  // Generic POST request
  Future<Response?> postRequest(
    String endpoint, {
    dynamic data,
    ResponseType responseType = ResponseType.json,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        options: Options(responseType: responseType),
      );
    } on DioException catch (e) {
      _handleDioError(e);
      return null;
    }
  }

  // Only show "No Internet" to the user
  void _handleDioError(DioException e) {
    if (e.error is SocketException) {
      showCustomSnackBar("No internet connection", SnackbarState.error);
    }

    // Other errors are ignored for the user
    print("Dio Error: ${e.message}");
  }
}
