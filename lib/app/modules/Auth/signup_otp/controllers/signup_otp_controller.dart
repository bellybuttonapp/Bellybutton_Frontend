// ignore_for_file: deprecated_member_use, unused_field, avoid_print

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Controllers/oauth.dart';
import '../../../../Controllers/deviceinfo_controller.dart';
import '../../../../api/PublicApiService.dart';
import '../../../../core/services/deep_link_service.dart';
import '../../../../core/utils/helpers/validation_utils.dart';
import '../../../../core/utils/storage/preference.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../routes/app_pages.dart';

class SignupOtpController extends GetxController {
  // Controllers & State
  final otpController = TextEditingController();
  var otpError = ''.obs;
  var isLoading = false.obs;
  var resendLoading = false.obs;

  // Timer for resend
  var canResend = true.obs;
  var resendSeconds = 30.obs;
  Timer? _timer;

  // Email from Signup screen
  String email = "";

  @override
  void onInit() {
    super.onInit();

    /// 🔥 Receive Email from Signup Navigation
    email = Get.arguments ?? "";
    print("📩 OTP Screen Email → $email");
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    final error = Validation.validateOtp(otp);
    if (error != null) {
      otpError.value = error;
      return;
    }

    otpError.value = "";
    isLoading.value = true;

    try {
      // ✅ Get device info
      final deviceInfo = await DeviceController.getDeviceInfoStatic();
      print("📱 Device Info: ${deviceInfo.toJson()}");

      final response = await AuthService().verifySignupOtp(
        email: email,
        otp: otp,
        deviceId: deviceInfo.deviceId,
        deviceModel: deviceInfo.deviceModel,
        deviceBrand: deviceInfo.deviceBrand,
        deviceOS: deviceInfo.deviceOS,
        deviceType: deviceInfo.deviceType,
      );

      final status = response['status'] ?? false;
      final message = response['message'] ?? "Something went wrong";

      if (status) {
        // ✅ Check if backend returns token & user data
        final data = response['data'];
        if (data != null && data['accessToken'] != null) {
          // ✅ Save user data to local storage
          Preference.token = data['accessToken'] ?? '';
          Preference.userId = data['userId'] ?? 0;
          Preference.email = data['email'] ?? email;
          Preference.userName = data['name'] ?? data['fullName'] ?? '';
          Preference.profileImage = data['profilePhoto'] ?? data['profileImageUrl'] ?? '';
          Preference.isLoggedIn = true;

          // ✅ Log device info (optional)
          final deviceInfo = data['device'];
          if (deviceInfo != null) {
            print("📱 Device registered: ${deviceInfo['deviceModel']} (${deviceInfo['deviceOS']})");
          }

          // ✅ Fetch full profile from API
          try {
            final profileResult = await PublicApiService().getProfileById(
              Preference.userId,
            );
            if (profileResult["data"] != null) {
              final profileData = profileResult["data"];
              if (profileData["fullName"] != null) {
                Preference.userName = profileData["fullName"];
              }
              if (profileData["bio"] != null) {
                Preference.bio = profileData["bio"];
              }
              if (profileData["profileImageUrl"] != null) {
                Preference.profileImage = profileData["profileImageUrl"];
              }
              if (profileData["phone"] != null) {
                Preference.phone = profileData["phone"];
              }
              if (profileData["address"] != null) {
                Preference.address = profileData["address"];
              }
            }
          } catch (e) {
            print("⚠️ Failed to fetch profile after OTP verification: $e");
          }

          // ✅ Upload FCM token
          try {
            final fcmToken = await FirebaseMessaging.instance.getToken();
            if (fcmToken != null) {
              Preference.fcmToken = fcmToken;
              await PublicApiService().updateFcmToken(fcmToken);
            }
          } catch (e) {
            print("⚠️ FCM token error (non-blocking): $e");
          }

          showCustomSnackBar(message, SnackbarState.success);
          FocusManager.instance.primaryFocus?.unfocus();

          await Future.delayed(const Duration(milliseconds: 300));

          // ✅ Go directly to Dashboard
          Get.offAllNamed(Routes.DASHBOARD);

          // Process any pending deep link
          DeepLinkService.processPendingDeepLink();
        } else {
          // ❌ Backend doesn't return token - fallback to login
          showCustomSnackBar("Please login to continue", SnackbarState.success);
          FocusManager.instance.primaryFocus?.unfocus();

          await Future.delayed(const Duration(milliseconds: 300));
          Get.offAllNamed(Routes.LOGIN);
        }
      } else {
        // Show error as inline text only, no snackbar
        otpError.value = message;
      }
    } catch (e) {
      otpError.value = "Unexpected error occurred.";
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================
  // Resend OTP with timer
  // ==========================
  Future<void> resendOtp() async {
    if (!canResend.value) return;

    /// Clear Pinput fields
    otpController.clear();

    resendLoading.value = true;
    canResend.value = false;
    startResendTimer();

    try {
      final response = await AuthService().resendOtp(email: email);

      final headers = response['headers'];
      final message = headers['message'] ?? "Something went wrong";
      final status = headers['status'] ?? "failed";
      final code = headers['statusCode'] ?? 500;

      if (code == 200 && status == "success") {
        showCustomSnackBar(message, SnackbarState.success);
        // Stay on OTP screen - user will enter new OTP
      } else {
        otpError.value = message;
        showCustomSnackBar(message, SnackbarState.error);
      }
    } catch (e) {
      showCustomSnackBar("Failed to resend OTP.", SnackbarState.error);
    } finally {
      resendLoading.value = false;
    }
    update();
  }

  void startResendTimer() {
    resendSeconds.value = 30;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  // ==========================
  // Dispose
  // ==========================
  @override
  void onClose() {
    otpController.dispose();
    _timer?.cancel();
    super.onClose();
  }
}