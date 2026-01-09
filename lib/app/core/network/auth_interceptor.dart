// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/end_points.dart';
import '../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../routes/app_pages.dart';
import '../constants/app_texts.dart';
import '../utils/storage/preference.dart';

class AuthInterceptor extends Interceptor {
  // Flag to prevent multiple popups
  static bool _isShowingSessionExpired = false;
  static bool _isShowingUserNotFound = false;
  static final RxBool _isProcessing = false.obs;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final rawToken = Preference.token;
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
      '/public/event/gallery', // Public gallery endpoint - no auth required
      Endpoints.SEND_LOGIN_OTP.toLowerCase(), // Phone OTP login - send OTP
      Endpoints.VERIFY_LOGIN_OTP.toLowerCase(), // Phone OTP login - verify OTP
      Endpoints.RESEND_LOGIN_OTP.toLowerCase(), // Phone OTP login - resend OTP
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
    // Only handle specific "Token expired (a newer login exists)" message
    if (err.response?.statusCode == 401) {
      final data = err.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? '';
        if (message == "Token expired (a newer login exists)") {
          _showSessionExpiredPopup();
        } else if (message == "User not found") {
          _showUserNotFoundPopup();
        }
      }
    }
    handler.next(err);
  }

  /// Show session expired popup with OK button
  static void _showSessionExpiredPopup() {
    // Prevent multiple popups
    if (_isShowingSessionExpired) return;
    _isShowingSessionExpired = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context == null) {
        _forceLogout();
        return;
      }

      Get.dialog(
        CustomPopup(
          title: AppTexts.SESSION_EXPIRED_TITLE,
          message: AppTexts.SESSION_EXPIRED_MESSAGE,
          confirmText: AppTexts.OK,
          cancelText: null,
          isProcessing: _isProcessing,
          barrierDismissible: false,
          onConfirm: () {
            Get.back();
            _forceLogout();
          },
        ),
      );
    });
  }

  /// Clear data and navigate to login
  static void _forceLogout() {
    print("🚪 Session expired → Force logout");
    Preference.clearAll();
    _isShowingSessionExpired = false;
    Get.offAllNamed(Routes.PHONE_LOGIN);
  }

  /// Show user not found popup with OK button
  static void _showUserNotFoundPopup() {
    // Prevent multiple popups
    if (_isShowingUserNotFound) return;
    _isShowingUserNotFound = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context == null) {
        _forceLogoutUserNotFound();
        return;
      }

      Get.dialog(
        CustomPopup(
          title: AppTexts.USER_NOT_FOUND_TITLE,
          message: AppTexts.USER_NOT_FOUND_MESSAGE,
          confirmText: AppTexts.OK,
          cancelText: null,
          isProcessing: _isProcessing,
          barrierDismissible: false,
          onConfirm: () {
            Get.back();
            _forceLogoutUserNotFound();
          },
        ),
      );
    });
  }

  /// Clear data and navigate to login for user not found
  static void _forceLogoutUserNotFound() {
    print("🚪 User not found → Force logout");
    Preference.clearAll();
    _isShowingUserNotFound = false;
    Get.offAllNamed(Routes.PHONE_LOGIN);
  }
}