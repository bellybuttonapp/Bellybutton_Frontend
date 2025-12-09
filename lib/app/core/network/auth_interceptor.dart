// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import '../../api/end_points.dart';
import '../utils/storage/preference.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final rawToken = Preference.token ?? "";
    final endpoint = options.path.toLowerCase();

    print("🔥 FULL PATH → $endpoint");

    // ✅ Skip if manually handled (e.g., multipart requests with custom auth)
    final skipAuth = options.extra["skipAuth"] == true;
    if (skipAuth) {
      print("⏭ skipAuth=true → Skipping AuthInterceptor");
      return handler.next(options);
    }

    // ❌ Endpoints that NEVER require token
    final noAuthNeeded = [
      Endpoints.LOGIN.toLowerCase(),
      Endpoints.REGISTER.toLowerCase(),
      Endpoints.FORGET_PASSWORD.toLowerCase(),
      Endpoints.VERIFY_OTP.toLowerCase(),
      Endpoints.RESET_PASSWORD.toLowerCase(),
      Endpoints.CHECK_EMAIL_AVAILABILITY.toLowerCase(),
    ];

    // ✅ DO NOT REMOVE TOKEN FOR delete-account
    if (endpoint.contains(Endpoints.DELETE_ACCOUNT.toLowerCase())) {
      print("🛑 DELETE ACCOUNT → TOKEN REQUIRED");
    }
    //
    // If endpoint is in public list → Remove token
    else if (noAuthNeeded.any((e) => endpoint.contains(e))) {
      options.headers.remove("Authorization");
      print("⚠ Removed token for public route");
      return handler.next(options);
    }

    // Add token for all protected routes
    if (rawToken.isNotEmpty) {
      final token = rawToken.replaceAll("\n", "").trim();
      options.headers["Authorization"] = "Bearer $token";
      print("🔐 AUTH HEADER SET → Bearer $token");
    } else {
      print("⚠ NO TOKEN FOUND IN STORAGE");
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
