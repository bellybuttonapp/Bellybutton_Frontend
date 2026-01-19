// ignore_for_file: avoid_print, deprecated_member_use

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../../Controllers/oauth.dart';
import '../../../../api/PublicApiService.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/utils/helpers/validation_utils.dart';
import '../../../../core/utils/themes/font_style.dart';
import '../../../../global_widgets/CustomBottomSheet/CustomBottomsheet.dart';
import '../../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../global_widgets/GlobalTextField/GlobalTextField.dart';
import '../../../../routes/app_pages.dart';

class PhoneLoginController extends GetxController {
  final AuthService _authService = AuthService();

  // Controllers
  final phoneController = TextEditingController();
  final searchController = TextEditingController();
  final countryScrollController = ScrollController();

  // Error fields
  final phoneError = RxnString();
  final searchError = ''.obs;

  // UI State
  final isLoading = false.obs;
  var selectedCountry = Country.parse('US').obs;
  final filteredCountries = <Country>[].obs;
  final termsAccepted = false.obs; // Terms & Conditions checkbox

  @override
  void onInit() {
    super.onInit();
    filteredCountries.value = _getAllowedCountries();
    _autoDetectCountry();
    _logAppSignature();
  }

  //----------------------------------------------------
  // LOG APP SIGNATURE FOR SMS AUTOFILL
  //----------------------------------------------------
  void _logAppSignature() async {
    try {
      final signature = await SmsAutoFill().getAppSignature;
      print("📱 App Signature for SMS: $signature");
    } catch (e) {
      print("⚠️ Could not get app signature: $e");
    }
  }

  //----------------------------------------------------
  // AUTO DETECT COUNTRY FROM DEVICE LOCALE
  //----------------------------------------------------
  void _autoDetectCountry() {
    try {
      // Get device locale
      final locale = Get.deviceLocale;
      String? countryCode;

      // Try to get country code from locale
      if (locale != null && locale.countryCode != null) {
        countryCode = locale.countryCode;
        print("📱 Detected country from locale: $countryCode");
      }

      // If we have a country code, find and set the country
      if (countryCode != null && countryCode.isNotEmpty) {
        final allCountries = _getAllowedCountries();
        final detectedCountry = allCountries.firstWhereOrNull(
          (c) => c.countryCode.toUpperCase() == countryCode!.toUpperCase(),
        );

        if (detectedCountry != null) {
          selectedCountry.value = detectedCountry;
          print("📱 Auto-selected country: ${detectedCountry.name} (+${detectedCountry.phoneCode})");
        }
      }
    } catch (e) {
      print("⚠️ Failed to auto-detect country: $e");
      // Keep default (US) if detection fails
    }
  }

  //----------------------------------------------------
  // VALIDATE PHONE
  //----------------------------------------------------
  void validatePhone(String value) {
    phoneError.value = Validation.validatePhoneForCountry(
      value,
      selectedCountry.value.countryCode,
    );
  }

  /// Get max phone length for current country
  int get maxPhoneLength {
    final (_, maxLen) = Validation.getPhoneLengthForCountry(
      selectedCountry.value.countryCode,
    );
    return maxLen;
  }

  //----------------------------------------------------
  // SEND OTP
  //----------------------------------------------------
  Future<void> sendOtp() async {
    hideKeyboard();

    final phoneNumber = phoneController.text.trim();
    phoneError.value = Validation.validatePhoneForCountry(
      phoneNumber,
      selectedCountry.value.countryCode,
    );

    if (phoneError.value != null) return;

    // Check if terms accepted
    if (!termsAccepted.value) {
      showCustomSnackBar(
        AppTexts.TERMS_ACCEPT_REQUIRED,
        SnackbarState.error,
      );
      return;
    }

    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
      return;
    }

    isLoading.value = true;

    try {
      final countryCode = "+${selectedCountry.value.phoneCode}";
      final fullPhone = "$countryCode$phoneNumber";

      final result = await _authService.sendLoginOtp(
        countryCode: countryCode,
        phone: phoneNumber,
      );

      if (result['success'] == true) {
        showCustomSnackBar(
          AppTexts.PHONE_LOGIN_OTP_SENT,
          SnackbarState.success,
        );

        // Navigate to OTP screen with phone number
        final navResult = await Get.toNamed(
          Routes.LOGIN_OTP,
          arguments: {
            'phone': result['phone'] ?? fullPhone, // Use phone from API response
            'countryCode': countryCode,
            'phoneNumber': phoneNumber,
          },
        );

        // Clear phone field if user tapped "Change Number"
        if (navResult == 'clear') {
          phoneController.clear();
          phoneError.value = null;
          termsAccepted.value = false;
        }
      } else {
        showCustomSnackBar(
          result['message'] ?? AppTexts.PHONE_LOGIN_OTP_FAILED,
          SnackbarState.error,
        );
      }
    } catch (e) {
      print("sendOtp() error: $e");
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  //----------------------------------------------------
  // SHOW TERMS & CONDITIONS
  //----------------------------------------------------
  Future<void> showTermsDialog() async {
    try {
      // Hide keyboard before showing dialog to prevent overflow issues
      hideKeyboard();

      // Fetch terms without affecting the Send OTP button loading state
      final resp = await PublicApiService().getTermsAndConditions();

      if (resp["data"] != null || resp["content"] != null) {
        final content = resp["data"]?["content"] ?? resp["content"] ?? "";
        final isProcessing = false.obs;

        // Strip HTML tags from content
        final cleanContent = content.toString().replaceAll(RegExp(r'<[^>]*>'), '');

        // Add small delay to ensure keyboard is dismissed
        await Future.delayed(const Duration(milliseconds: 100));

        Get.dialog(
          CustomPopup(
            title: AppTexts.TERMS_TITLE,
            messageWidget: RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate available height considering keyboard and screen size
                        final screenHeight = MediaQuery.of(context).size.height;
                        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                        final availableHeight = screenHeight - keyboardHeight;

                        // Use 40% of available height, max 400px
                        final maxHeight = (availableHeight * 0.4).clamp(200.0, 400.0);

                        return Container(
                          constraints: BoxConstraints(
                            maxHeight: maxHeight,
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              child: Text(
                                cleanContent,
                                style: AppText.labelLg.copyWith(
                                  fontSize: 14,
                                  color: AppColors.tertiaryColor,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            confirmText: AppTexts.TERMS_I_UNDERSTAND,
            cancelText: null,
            onConfirm: () => Get.back(),
            isProcessing: isProcessing,
            barrierDismissible: true,
            confirmButtonColor: AppColors.primaryColor,
          ),
          barrierDismissible: true,
        );
      } else {
        showCustomSnackBar(
          AppTexts.TERMS_LOAD_ERROR,
          SnackbarState.error,
        );
      }
    } catch (e) {
      print("showTermsDialog() error: $e");
      showCustomSnackBar(
        AppTexts.TERMS_LOAD_FAILED,
        SnackbarState.error,
      );
    }
  }

  //----------------------------------------------------
  // HIDE KEYBOARD
  //----------------------------------------------------
  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  //----------------------------------------------------
  // COUNTRY PICKER
  //----------------------------------------------------
  List<Country> _getAllowedCountries() {
    // Only allow India and US
    const allowedCodes = ['IN', 'US'];
    return CountryService()
        .getAll()
        .where((c) => allowedCodes.contains(c.countryCode))
        .toList();
  }

  void validateSearch(String value) {
    if (value.isEmpty) {
      filteredCountries.value = _getAllowedCountries();
    } else {
      final query = value.toLowerCase();
      filteredCountries.value = _getAllowedCountries()
          .where((c) => c.name.toLowerCase().contains(query))
          .toList();
    }
  }

  void showCountrySheet(BuildContext context) {
    filteredCountries.value = _getAllowedCountries();
    searchController.clear();

    CustomBottomSheet.show(
      title: AppTexts.PHONE_LOGIN_SELECT_COUNTRY,
      subtitle: AppTexts.COUNTRY_PICKER_SUBTITLE,
      showCloseButton: true,
      header: _searchField(),
      footer: Obx(() {
        if (filteredCountries.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppTexts.NO_COUNTRIES_FOUND,
              style: AppText.headingLg.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),
          );
        }

        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: AdaptiveScrollbar(
            controller: countryScrollController,
            position: ScrollbarPosition.right,
            width: 10,
            sliderSpacing: const EdgeInsets.symmetric(vertical: 6),
            sliderDefaultColor: AppColors.primaryColor,
            sliderActiveColor: AppColors.primaryColor.withOpacity(0.8),
            underColor: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            sliderHeight: 100,
            child: SingleChildScrollView(
              controller: countryScrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: filteredCountries
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
                              style: AppText.headingLg.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColor,
                              ),
                            ),
                            onTap: () {
                              selectedCountry.value = c;
                              // Revalidate phone when country changes
                              if (phoneController.text.isNotEmpty) {
                                validatePhone(phoneController.text);
                              }
                              Get.back();
                            },
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
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

  @override
  void onClose() {
    phoneController.dispose();
    searchController.dispose();
    countryScrollController.dispose();
    super.onClose();
  }
}
