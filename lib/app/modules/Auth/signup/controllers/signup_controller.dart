// ignore_for_file: curly_braces_in_flow_control_structures, unrelated_type_equality_checks, avoid_print, prefer_interpolation_to_compose_strings, unused_local_variable

import 'dart:io';
import 'package:bellybutton/app/Controllers/oauth.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers/validation_utils.dart';
import '../../../../core/utils/storage/preference.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/utils/themes/font_style.dart';
import '../../../../global_widgets/CustomBottomSheet/CustomBottomsheet.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../global_widgets/GlobalTextField/GlobalTextField.dart';
import '../../../../routes/app_pages.dart';
import '../../forgot_password/views/forgot_password_view.dart';
import '../../signup_otp/views/signup_otp_view.dart';

class SignupController extends GetxController {
  final AuthService _authService = AuthService();

  // Loader
  final isLoading = false.obs;

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileController = TextEditingController();
  final searchController = TextEditingController();

  // Error fields
  final nameError = RxnString();
  final emailError = RxnString();
  final passwordError = RxnString();
  final mobileError = RxnString();
  final searchError = ''.obs;

  // UI
  final isPasswordHidden = true.obs;
  final rememberMe = false.obs;
  var selectedCountry = Country.parse('IN').obs; // default India
  final filteredCountries = <Country>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  //----------------------------------------------------
  // VALIDATE FIELDS
  //----------------------------------------------------
  void validateName(String value) =>
      nameError.value = Validation.validateName(value);

  void validateEmail(String value) =>
      emailError.value = Validation.validateEmail(value);

  void validatePassword(String value) =>
      passwordError.value = Validation.validatePassword(value);

  void validateMobile(String value) =>
      mobileError.value = Validation.validatePhone(value);

  //----------------------------------------------------
  // REMEMBER ME
  //----------------------------------------------------
  Future<void> saveUserData({String? name, String? email}) async {
    if (rememberMe.value) {
      Preference.userName = name ?? nameController.text.trim();
      Preference.email = email ?? emailController.text.trim();
    } else {
      Preference.userName = '';
      Preference.email = '';
    }
  }

  Future<void> loadUserData() async {
    if (Preference.userName.isNotEmpty && Preference.email.isNotEmpty) {
      nameController.text = Preference.userName;
      emailController.text = Preference.email;
      rememberMe.value = true;
    }
  }

  //----------------------------------------------------
  // UPDATE PREFS
  //----------------------------------------------------
  void _saveUserPreferences({
    required String name,
    required String email,
    String? photo,
  }) {
    Preference.isLoggedIn = true;
    Preference.email = email;
    Preference.userName = name;
    Preference.profileImage = photo;
  }

  //----------------------------------------------------
  // SIGNUP
  //----------------------------------------------------
  Future<void> signup({bool rememberMe = false}) async {
    hideKeyboard(); // << add this at START
    this.rememberMe.value = rememberMe;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final mobile =
        "+${selectedCountry.value.phoneCode}${mobileController.text.trim()}";

    nameError.value = Validation.validateName(name);
    emailError.value = Validation.validateEmail(email);
    passwordError.value = Validation.validatePassword(password);
    mobileError.value = Validation.validatePhone(mobileController.text.trim());

    if (nameError.value != null ||
        emailError.value != null ||
        passwordError.value != null ||
        mobileError.value != null)
      return;

    isLoading.value = true;

    try {
      final emailCheck = await _authService.checkEmailAvailability(email);

      if (emailCheck['headers']?['statusCode'] != 401) {
        if (!(emailCheck['data']?['available'] ?? true)) {
          showCustomSnackBar(
            AppTexts.EMAIL_ALREADY_EXISTS,
            SnackbarState.error,
          );
          return;
        }
      }

      final result = await _authService.registerWithAPI(
        name: name,
        email: email,
        password: password,
        phone: mobile, // <-- passing mobile number
        profilePhoto: null,
      );

      if (result['message'] == "No internet connection.") {
        showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
        return;
      }

      final success = result['headers']?['status'] == 'success';
      final requiresVerification =
          result['data']?['requiresVerification'] ?? false;

      if (success && requiresVerification) {
        if (rememberMe) await saveUserData(name: name, email: email);

        _saveUserPreferences(name: name, email: email, photo: null);
        hideKeyboard(); // ← closes keyboard before processing

        /// ⬇ Navigate to OTP screen instead of Dashboard
        Get.offAll(
          () => SignupOtpView(),
          arguments: email, // Pass email to OTP screen
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      } else {
        showCustomSnackBar(AppTexts.SIGNUP_FAILED, SnackbarState.error);
      }
    } catch (e) {
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  //----------------------------------------------------
  // HIDE KEYBOARD WHILE NAVIGATING 1 SCREEN TO ANOTHER
  //----------------------------------------------------
  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  //----------------------------------------------------
  // SEARCH & COUNTRY PICKER
  //----------------------------------------------------
  void validateSearch(String value) {
    if (value.isEmpty) {
      filteredCountries.value = CountryService().getAll();
    } else {
      final query = value.toLowerCase();
      filteredCountries.value =
          CountryService()
              .getAll()
              .where((c) => c.name.toLowerCase().contains(query))
              .toList();
    }
  }

  void showCountrySheet(BuildContext context) {
    filteredCountries.value = CountryService().getAll();
    searchController.clear();

    CustomBottomSheet.show(
      title: "Select Country",
      subtitle: "Choose your country code",
      showCloseButton: true,
      header: _searchField(),
      footer: Obx(() {
        if (filteredCountries.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "No countries found",
              style: customBoldText.copyWith(
                // fontSize: 14 * textScale,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),
          );
        }

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children:
                  filteredCountries
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Material(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              leading: Text(
                                c.flagEmoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                              title: Text(
                                "${c.name} (+${c.phoneCode})",
                                style: customBoldText.copyWith(
                                  // fontSize: 14 * textScale,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColor,
                                ),
                              ),
                              onTap: () {
                                selectedCountry.value = c;
                                Get.back();
                              },
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        );
      }),
      isScrollControlled: true,
      actions: [],
    );
  }

  Widget _searchField() {
    return Obx(
      () => GlobalTextField(
        controller: searchController,
        hintText: AppTexts.SEARCH,
        prefixIcon: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.search, size: 22),
        ),
        errorText: searchError.value.isEmpty ? null : searchError.value,
        onChanged: validateSearch,
      ),
    );
  }

  //----------------------------------------------------
  // GOOGLE SIGN-IN
  //----------------------------------------------------
  Future<void> signInWithGoogle() async {
    isLoading.value = true;

    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        showCustomSnackBar(
          AppTexts.GOOGLE_SIGNIN_CANCELED,
          SnackbarState.error,
        );
        return;
      }

      final email = user.user?.email ?? "";
      final name = user.user?.displayName ?? "";

      await saveUserData(name: name, email: email);
      _saveUserPreferences(name: name, email: email);

      showCustomSnackBar(AppTexts.GOOGLE_SIGNIN_SUCCESS, SnackbarState.success);
      Get.offAllNamed(Routes.DASHBOARD);
    } on SocketException {
      showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
    } catch (_) {
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  //----------------------------------------------------
  // NAVIGATION
  //----------------------------------------------------
  void navigateToLogin() {
    hideKeyboard();
    Get.toNamed(Routes.LOGIN);
  }

  void forgetPassword() {
    hideKeyboard();
    Get.to(
      () => ForgotPasswordView(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    mobileController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
