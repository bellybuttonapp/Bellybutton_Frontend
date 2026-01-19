// ignore_for_file: avoid_print

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../../Controllers/deviceinfo_controller.dart';
import '../../../../Controllers/oauth.dart';
import '../../../../api/PublicApiService.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/services/deep_link_service.dart';
import '../../../../core/utils/helpers/validation_utils.dart';
import '../../../../core/utils/storage/preference.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../routes/app_pages.dart';

class LoginOtpController extends GetxController with CodeAutoFill {
  final AuthService _authService = AuthService();

  // OTP Controller
  final otpController = TextEditingController();

  // Phone data (received from arguments)
  String phone = '';
  String countryCode = '';
  String phoneNumber = '';

  // State
  var otpError = ''.obs;
  var isLoading = false.obs;
  var canResend = false.obs;
  var resendSeconds = 30.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _loadPhoneData();
    _startResendTimer();
    _startSmsListener();
  }

  //----------------------------------------------------
  // SMS AUTOFILL LISTENER (Android)
  //----------------------------------------------------
  void _startSmsListener() async {
    try {
      // Get app signature for SMS Retriever API (Android only)
      final signature = await SmsAutoFill().getAppSignature;
      print("📱 App Signature for SMS: $signature");

      // Register listener for CodeAutoFill mixin
      listenForCode();

      // Also start SMS autofill listener
      await SmsAutoFill().listenForCode();
      print("📱 SMS Autofill listener started");
    } catch (e) {
      print("⚠️ SMS Autofill error: $e");
    }
  }

  /// Called automatically when OTP code is received from SMS
  @override
  void codeUpdated() {
    if (code != null && code!.isNotEmpty) {
      // Extract only digits (in case SMS contains other text)
      final digits = code!.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length >= 6) {
        final otp = digits.substring(0, 6);
        otpController.text = otp;
        print("📱 OTP auto-filled from SMS: $otp");
        update(); // Refresh UI
        // Auto-verify after filling
        Future.delayed(const Duration(milliseconds: 300), () {
          verifyOtp();
        });
      }
    }
  }

  //----------------------------------------------------
  // LOAD PHONE DATA FROM ARGUMENTS
  //----------------------------------------------------
  void _loadPhoneData() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      phone = args['phone'] ?? '';
      countryCode = args['countryCode'] ?? '';
      phoneNumber = args['phoneNumber'] ?? '';
      print("📱 Login OTP Screen → Phone: $phone");
    }
  }

  //----------------------------------------------------
  // START RESEND TIMER
  //----------------------------------------------------
  void _startResendTimer() {
    canResend.value = false;
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

  //----------------------------------------------------
  // VERIFY OTP
  //----------------------------------------------------
  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    // Validate OTP
    final otpValidation = Validation.validateOtp(otp);
    if (otpValidation != null) {
      otpError.value = otpValidation;
      return;
    }

    otpError.value = '';
    isLoading.value = true;

    try {
      // Get device info
      final deviceInfo = await DeviceController.getDeviceInfoStatic();
      print("📱 Device Info: ${deviceInfo.toJson()}");

      final result = await _authService.verifyLoginOtp(
        phone: phone,
        otp: otp,
        deviceId: deviceInfo.deviceId,
        deviceModel: deviceInfo.deviceModel,
        deviceBrand: deviceInfo.deviceBrand,
        deviceOS: deviceInfo.deviceOS,
        deviceType: deviceInfo.deviceType,
      );

      print("🔵 OTP Verify Result: $result");

      if (result['success'] == true) {
        final data = result['data'] ?? {};

        // Save user data to preferences
        final rawToken = (data['accessToken'] ?? '').toString().trim();
        Preference.token = rawToken;
        Preference.userId = data['userId'] ?? 0;
        Preference.email = data['email'] ?? '';
        Preference.userName = data['name'] ?? '';
        Preference.profileImage = data['profilePhoto'] ?? '';
        Preference.phone = data['phone'] ?? phone;
        Preference.isLoggedIn = true;

        print("🔵 LOGGED IN USER ID → ${Preference.userId}");
        print("🔵 TOKEN STORED → $rawToken");

        // Fetch full profile from API
        await _fetchUserProfile();

        // Accept terms and conditions
        await _acceptTerms();

        // Upload FCM token
        await _uploadFcmToken();

        showCustomSnackBar(AppTexts.LOGIN_OTP_SUCCESS, SnackbarState.success);

        await Future.delayed(const Duration(milliseconds: 200));

        // Check if profile is complete (user has a name)
        // If new user without name, go to profile setup
        if (Preference.userName.isEmpty && !Preference.isProfileComplete) {
          Get.offAllNamed(Routes.PROFILE_SETUP);
        } else {
          Preference.isProfileComplete = true;
          Get.offAllNamed(Routes.DASHBOARD);
          // Process any pending deep link after login
          DeepLinkService.processPendingDeepLink();
        }
      } else {
        otpError.value = result['message'] ?? AppTexts.LOGIN_OTP_INVALID;
      }
    } catch (e) {
      print("verifyOtp() error: $e");
      otpError.value = AppTexts.SOMETHING_WENT_WRONG;
    } finally {
      isLoading.value = false;
    }
  }

  //----------------------------------------------------
  // FETCH USER PROFILE
  //----------------------------------------------------
  Future<void> _fetchUserProfile() async {
    try {
      print("🔵 Fetching profile for userId: ${Preference.userId}");
      final profileResult = await PublicApiService().getProfileById(
        Preference.userId,
      );
      print("🔵 Profile API result: $profileResult");

      if (profileResult["data"] != null) {
        final profileData = profileResult["data"];
        print("🔵 Profile data extracted: $profileData");

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
        if (profileData["email"] != null) {
          Preference.email = profileData["email"];
        }

        print(
          "🔵 Preference updated - userName: ${Preference.userName}, bio: ${Preference.bio}",
        );
      }
    } catch (e, stackTrace) {
      print("⚠️ Failed to fetch profile after login: $e");
      print("⚠️ Stack trace: $stackTrace");
    }
  }

  //----------------------------------------------------
  // ACCEPT TERMS & CONDITIONS
  //----------------------------------------------------
  Future<void> _acceptTerms() async {
    try {
      final termsResp = await PublicApiService().acceptTermsAndConditions();
      if (termsResp["accepted"] == true) {
        Preference.termsAccepted = true;
        print("✅ Terms & Conditions accepted");
      }
    } catch (e) {
      print("⚠️ Terms acceptance failed (non-blocking): $e");
    }
  }

  //----------------------------------------------------
  // UPLOAD FCM TOKEN
  //----------------------------------------------------
  Future<void> _uploadFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        Preference.fcmToken = fcmToken;
        await PublicApiService().updateFcmToken(fcmToken);
      }
    } catch (e) {
      print("⚠️ FCM token error (non-blocking): $e");
    }

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (Preference.token.isNotEmpty) {
        Preference.fcmToken = newToken;
        await PublicApiService().updateFcmToken(newToken);
      }
    });
  }

  //----------------------------------------------------
  // RESEND OTP
  //----------------------------------------------------
  Future<void> resendOtp() async {
    if (!canResend.value) return;

    otpController.clear();
    otpError.value = '';

    try {
      final result = await _authService.resendLoginOtp(phone: phone);

      if (result['success'] == true) {
        showCustomSnackBar(AppTexts.PHONE_LOGIN_OTP_SENT, SnackbarState.success);
        _startResendTimer();
      } else {
        showCustomSnackBar(
          result['message'] ?? AppTexts.PHONE_LOGIN_OTP_FAILED,
          SnackbarState.error,
        );
      }
    } catch (e) {
      print("resendOtp() error: $e");
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
    }
  }

  //----------------------------------------------------
  // GO BACK TO CHANGE NUMBER
  //----------------------------------------------------
  void goBack() {
    Get.back(result: 'clear');
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    SmsAutoFill().unregisterListener(); // Stop SMS listener
    cancel(); // Cancel CodeAutoFill mixin
    super.onClose();
  }
}
