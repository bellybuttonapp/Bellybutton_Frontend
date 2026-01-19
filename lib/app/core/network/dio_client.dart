// ignore_for_file: avoid_print

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constant.dart';
import '../constants/app_texts.dart';
import '../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import 'auth_interceptor.dart';
import 'retry_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.BASE_URL,
        connectTimeout: Duration(seconds: AppConstants.CONNECTION_TIMEOUT),
        receiveTimeout: Duration(seconds: AppConstants.RECEIVE_TIMEOUT),
        sendTimeout: Duration(seconds: AppConstants.SEND_TIMEOUT),

        /// ❗ IMPORTANT: DO NOT SET GLOBAL CONTENT-TYPE HERE
        /// JSON vs Multipart is decided per-request
        headers: {"Accept": "application/json"},
      ),
    );

    _dio.interceptors.add(AuthInterceptor()); // Adds token if needed
    _dio.interceptors.add(RetryInterceptor(_dio));
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );
  }

  Dio get dio => _dio;

  // GET
  Future<Response?> getRequest(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParams);
    } catch (e) {
      _handleError(e as DioException);
      return null;
    }
  }

  // POST
  Future<Response?> postRequest(
    String endpoint, {
    dynamic data,
    ResponseType responseType = ResponseType.json,
    bool rethrowError = false,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        options: Options(responseType: responseType),
      );
    } catch (e) {
      _handleError(e as DioException);
      if (rethrowError) rethrow;
      return null;
    }
  }

  // PUT
  Future<Response?> putRequest(
    String endpoint, {
    dynamic data,
    ResponseType responseType = ResponseType.json,
    Options? options,
    bool rethrowError = false,
  }) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,

        /// ❗ allow overriding content-type for multipart
        options: options ?? Options(responseType: responseType),
      );
    } catch (e) {
      _handleError(e as DioException);
      if (rethrowError) rethrow;
      return null;
    }
  }

  // DELETE
  Future<Response?> deleteRequest(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } catch (e) {
      _handleError(e as DioException);
      return null;
    }
  }

  void _handleError(DioException e) {
    if (e.error is SocketException) {
      showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
    }
    print("Dio Error: ${e.message}");
  }
}
