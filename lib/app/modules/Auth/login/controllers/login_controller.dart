// ignore_for_file: unrelated_type_equality_checks, curly_braces_in_flow_control_structures, avoid_print, unnecessary_type_check

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../Controllers/oauth.dart';
import '../../../../Controllers/deviceinfo_controller.dart';
import '../../../../api/PublicApiService.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/services/deep_link_service.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../global_widgets/loader/global_loader.dart';
import '../../../../core/utils/index.dart';
import '../../../../routes/app_pages.dart';
import '../../forgot_password/views/forgot_password_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();
  final storage = GetStorage();

  final isGoogleLoading = false.obs;
  final isLoading = false.obs;

  // controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // error fields
  final emailError = RxnString();
  final passwordError = RxnString();

  final rememberMe = false.obs;
  final isPasswordHidden = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRememberedUser();
  }

  //----------------------------------------------------
  // LOAD SAVED EMAIL
  //----------------------------------------------------
  void _loadRememberedUser() {
    final savedEmail = storage.read('email');
    final savedRemember = storage.read('rememberMe') ?? false;

    if (savedRemember && savedEmail != null) {
      emailController.text = savedEmail;
      rememberMe.value = true;
    }
  }

  //----------------------------------------------------
  // VALIDATE FIELDS
  //----------------------------------------------------
  void validateEmail(String value) =>
      emailError.value = Validation.validateEmail(value);

  void validatePassword(String value) =>
      passwordError.value = Validation.validatePassword(value);

  //----------------------------------------------------
  // LOGIN FUNCTION
  //----------------------------------------------------
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    emailError.value = Validation.validateEmail(email);
    passwordError.value = Validation.validatePassword(password);

    if (emailError.value != null || passwordError.value != null) return;

    isLoading.value = true;

    try {
      // Get device info
      final deviceInfo = await DeviceController.getDeviceInfoStatic();
      print("📱 Device Info: ${deviceInfo.toJson()}");

      final result = await _authService.loginWithAPI(
        email: email,
        password: password,
        deviceId: deviceInfo.deviceId,
        deviceModel: deviceInfo.deviceModel,
        deviceBrand: deviceInfo.deviceBrand,
        deviceOS: deviceInfo.deviceOS,
        deviceType: deviceInfo.deviceType,
      );

      final headers = result['headers'] ?? {};
      final isSuccess =
          headers['status'] == 'success' || headers['statusCode'] == 200;

      if (isSuccess) {
        _handleRememberMe(email);

        final data = result['data'];

        // set values
        final rawToken = data['accessToken']?.trim() ?? '';
        Preference.token = rawToken;
        Preference.userId = data['userId'];
        Preference.email = data['email'];
        Preference.userName = (data['message'] ?? '').split(':').last.trim();
        Preference.profileImage = data['profilePhoto'] ?? '';
        Preference.isLoggedIn = true;

        print("🔵 LOGGED IN USER ID → ${Preference.userId}");
        print("🔵 TOKEN STORED → $rawToken");

        // ✅ Fetch full profile from API to get bio, phone, address, etc.
        try {
          print("🔵 Fetching profile for userId: ${Preference.userId}");
          final profileResult = await PublicApiService().getProfileById(
            Preference.userId,
          );
          print("🔵 Profile API result: $profileResult");

          // Check if data exists (API returns {data: {...}, message: "..."})
          if (profileResult["data"] != null) {
            final profileData = profileResult["data"];
            print("🔵 Profile data extracted: $profileData");
            if (profileData["fullName"] != null) {
              Preference.userName = profileData["fullName"];
              print("🔵 Set userName to: ${profileData["fullName"]}");
            }
            if (profileData["bio"] != null) {
              Preference.bio = profileData["bio"];
              print("🔵 Set bio to: ${profileData["bio"]}");
            }
            if (profileData["profileImageUrl"] != null) {
              Preference.profileImage = profileData["profileImageUrl"];
              print(
                "🔵 Set profileImage to: ${profileData["profileImageUrl"]}",
              );
            }
            if (profileData["phone"] != null) {
              Preference.phone = profileData["phone"];
            }
            if (profileData["address"] != null) {
              Preference.address = profileData["address"];
            }
            print(
              "🔵 Preference updated - userName: ${Preference.userName}, bio: ${Preference.bio}",
            );
          } else {
            print("⚠️ Profile result has no 'data' key: $profileResult");
          }
        } catch (e, stackTrace) {
          print("⚠️ Failed to fetch profile after login: $e");
          print("⚠️ Stack trace: $stackTrace");
        }

        // ✅ Upload FCM token AFTER login
        try {
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            Preference.fcmToken = fcmToken;
            await PublicApiService().updateFcmToken(fcmToken);
          }
        } catch (e) {
          print("⚠️ FCM token error (non-blocking): $e");
        }

        // ✅ Listen for token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
          if (Preference.token.isNotEmpty) {
            Preference.fcmToken = newToken;
            await PublicApiService().updateFcmToken(newToken);
          }
        });

        showCustomSnackBar(AppTexts.LOGIN_SUCCESS, SnackbarState.success);

        await Future.delayed(const Duration(milliseconds: 200));
        Get.offAllNamed(Routes.DASHBOARD);

        // Process any pending deep link after login
        DeepLinkService.processPendingDeepLink();
        return;
      }

      showCustomSnackBar(
        headers['message'] ?? AppTexts.LOGIN_INVALID_CREDENTIAL,
        SnackbarState.error,
      );
    } catch (_) {
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  //----------------------------------------------------
  // REMEMBER ME
  //----------------------------------------------------
  void _handleRememberMe(String email) {
    if (rememberMe.value) {
      storage.write('email', email);
      storage.write('rememberMe', true);
    } else {
      storage.remove('email');
      storage.write('rememberMe', false);
    }
  }

  //----------------------------------------------------
  // GOOGLE LOGIN (with Backend API)
  //----------------------------------------------------
  Future<void> onSigninWithGoogle() async {
    isGoogleLoading.value = true;

    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
        return;
      }

      // Show loader popup
      _showGoogleSignInLoader();

      // 1️⃣ First, get Google user info without full login
      final googleUserResult = await _authService.getGoogleUserInfo();

      if (googleUserResult['success'] != true) {
        if (Get.isDialogOpen ?? false) Get.back();
        final message = googleUserResult['message'] ?? AppTexts.GOOGLE_SIGNIN_FAILED;
        if (message.contains('canceled')) {
          showCustomSnackBar(AppTexts.GOOGLE_SIGNIN_CANCELED, SnackbarState.error);
        } else {
          showCustomSnackBar(message, SnackbarState.error);
        }
        return;
      }

      final String googleEmail = googleUserResult['email'] ?? '';
      final String googleName = googleUserResult['name'] ?? '';
      final String googlePhoto = googleUserResult['photoUrl'] ?? '';
      final String? googleIdToken = googleUserResult['idToken'];

      // 2️⃣ Check if email already exists in our system
      final emailCheck = await _authService.checkEmailAvailability(googleEmail);
      final bool isNewUser = emailCheck['data']?['available'] ?? true;

      if (Get.isDialogOpen ?? false) Get.back();

      if (isNewUser) {
        // 3️⃣ New user → Navigate to Signup with pre-filled Google data
        showCustomSnackBar(
          "Please complete your registration",
          SnackbarState.warning,
        );

        Get.toNamed(
          Routes.SIGNUP,
          arguments: {
            'googleName': googleName,
            'googleEmail': googleEmail,
            'googlePhoto': googlePhoto,
            'isGoogleSignup': true,
          },
        );
      } else {
        // 4️⃣ Existing user → Proceed with Google login
        _showGoogleSignInLoader();

        final result = await _authService.signInWithGoogleAPIWithToken(googleIdToken!);

        if (Get.isDialogOpen ?? false) Get.back();

        if (result['success'] == true) {
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
            print("⚠️ Failed to fetch profile after Google login: $e");
          }

          // ✅ Upload FCM token AFTER login
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            Preference.fcmToken = fcmToken;
            await PublicApiService().updateFcmToken(fcmToken);
          }

          showCustomSnackBar(
            AppTexts.GOOGLE_SIGNIN_SUCCESS,
            SnackbarState.success,
          );

          Get.offAllNamed(Routes.DASHBOARD);

          // Process any pending deep link after Google login
          DeepLinkService.processPendingDeepLink();
        } else {
          final message = result['message'] ?? AppTexts.GOOGLE_SIGNIN_FAILED;
          showCustomSnackBar(message, SnackbarState.error);
        }
      }
    } catch (_) {
      // Close loader popup on error
      if (Get.isDialogOpen ?? false) Get.back();
      showCustomSnackBar(AppTexts.GOOGLE_SIGNIN_FAILED, SnackbarState.error);
    } finally {
      isGoogleLoading.value = false;
    }
  }

  //----------------------------------------------------
  // SHOW GOOGLE SIGN-IN LOADER POPUP
  //----------------------------------------------------
  void _showGoogleSignInLoader() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Builder(
          builder: (context) {
            final size = MediaQuery.of(context).size;
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.all(size.width * 0.06),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(size.width * 0.03),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Global_Loader(size: size.width * 0.1, strokeWidth: 3),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          AppTexts.GOOGLE_SIGNIN_LOADING,
                          style: customMediumText.copyWith(
                            fontSize: size.width * 0.04,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
      useSafeArea: true,
    );
  }

  //----------------------------------------------------
  // NAVIGATION
  //----------------------------------------------------
  void navigateToSignup() => Get.toNamed(Routes.SIGNUP);

  void forgetPassword() => Get.to(
    () => ForgotPasswordView(),
    transition: Transition.rightToLeft,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}