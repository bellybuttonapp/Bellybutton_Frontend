// ignore_for_file: file_names, deprecated_member_use

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constant.dart';
import '../../core/constants/app_texts.dart';
import 'package:bellybutton/app/core/utils/index.dart';
import '../CustomBottomSheet/CustomBottomsheet.dart';
import '../GlobalTextField/GlobalTextField.dart';

/// Dialog to select country code for ambiguous phone numbers
/// Shows 2 main options (US & India) + "Other Country" for full list
class CountryPickerDialog extends StatefulWidget {
  final String contactName;
  final String phoneNumber;

  const CountryPickerDialog({
    super.key,
    required this.contactName,
    required this.phoneNumber,
  });

  @override
  State<CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<CountryPickerDialog> {
  String? _selectedCountryCode;

  /// Format phone preview based on country
  String _getFormattedPreview(String countryCode) {
    String digits = widget.phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (countryCode == '1' && digits.length == 10) {
      return '+1 (${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (countryCode == '91' && digits.length == 10) {
      return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
    }
    return '+$countryCode $digits';
  }

  /// Handle country selection with checkbox animation
  void _selectCountry(String countryCode) {
    setState(() {
      _selectedCountryCode = countryCode;
    });
    // Small delay to show the checkbox checked state before closing
    Future.delayed(const Duration(milliseconds: 200), () {
      Get.back(result: countryCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: Stack(
        children: [
          // Dark overlay
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.back(result: null),
              child: Container(color: Colors.black54),
            ),
          ),

          // Dialog content
          Center(
            child: GestureDetector(
              onTap: () {},
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: size.width * 0.85,
                  padding: EdgeInsets.all(size.width * 0.05),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : AppColors.textColor3,
                    borderRadius: BorderRadius.circular(size.width * 0.03),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Phone icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.phone_outlined,
                          size: 28,
                          color: AppColors.primaryColor,
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      // Title
                      Text(
                        AppTexts.COUNTRY_PICKER_TITLE,
                        textAlign: TextAlign.center,
                        style: customBoldText.copyWith(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textColor,
                        ),
                      ),

                      SizedBox(height: size.height * 0.01),

                      // Subtitle
                      Text(
                        AppTexts.COUNTRY_PICKER_MULTIPLE_MATCH,
                        textAlign: TextAlign.center,
                        style: customTextNormal.copyWith(
                          fontSize: size.width * 0.035,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: size.height * 0.025),

                      // Contact info card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primaryColor.withOpacity(0.15),
                              child: Text(
                                widget.contactName.isNotEmpty
                                    ? widget.contactName[0].toUpperCase()
                                    : '?',
                                style: customBoldText.copyWith(
                                  color: AppColors.primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.contactName,
                                    style: customBoldText.copyWith(
                                      fontSize: 14,
                                      color: isDark ? Colors.white : AppColors.textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.phoneNumber,
                                    style: customTextNormal.copyWith(
                                      fontSize: 13,
                                      color: isDark ? Colors.white60 : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      // US Option (Main suggestion 1)
                      _buildCountryOption(
                        context: context,
                        flag: '🇺🇸',
                        countryName: AppTexts.COUNTRY_PICKER_UNITED_STATES,
                        countryCode: '1',
                        preview: _getFormattedPreview('1'),
                        isDark: isDark,
                        isSelected: _selectedCountryCode == '1',
                        onTap: () => _selectCountry('1'),
                      ),

                      SizedBox(height: size.height * 0.012),

                      // India Option (Main suggestion 2)
                      _buildCountryOption(
                        context: context,
                        flag: '🇮🇳',
                        countryName: AppTexts.COUNTRY_PICKER_INDIA,
                        countryCode: '91',
                        preview: _getFormattedPreview('91'),
                        isDark: isDark,
                        isSelected: _selectedCountryCode == '91',
                        onTap: () => _selectCountry('91'),
                      ),

                      SizedBox(height: size.height * 0.012),

                      // Other Countries Option
                      _buildOtherCountryOption(
                        context: context,
                        isDark: isDark,
                        onTap: () {
                          // Return special value to indicate "show full picker"
                          Get.back(result: '_OTHER_');
                        },
                      ),

                      SizedBox(height: size.height * 0.02),

                      // Cancel button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Get.back(result: null),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? Colors.white30 : Colors.grey[400]!,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            AppTexts.CANCEL,
                            style: customBoldText.copyWith(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryOption({
    required BuildContext context,
    required String flag,
    required String countryName,
    required String countryCode,
    required String preview,
    required bool isDark,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.primaryColor.withOpacity(0.3),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // Flag
            Text(
              flag,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            // Country info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$countryName (+$countryCode)',
                    style: customBoldText.copyWith(
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    style: customTextNormal.copyWith(
                      fontSize: 13,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Checkbox
            Checkbox(
              value: isSelected,
              activeColor: AppColors.primaryColor,
              onChanged: (_) => onTap(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build "Other Countries" option with globe icon
  Widget _buildOtherCountryOption({
    required BuildContext context,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Globe icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.public,
                size: 22,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Text(
                AppTexts.COUNTRY_PICKER_OTHER,
                style: customBoldText.copyWith(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.white54 : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

/// Show the country picker dialog
/// Returns the selected country code or null if cancelled
Future<String?> showCountryPickerDialog({
  required BuildContext context,
  required String contactName,
  required String phoneNumber,
}) async {
  // Show the main dialog
  final result = await Get.dialog<String?>(
    CountryPickerDialog(
      contactName: contactName,
      phoneNumber: phoneNumber,
    ),
    barrierDismissible: true,
  );

  // If user selected "Other Country", show the full country picker
  if (result == '_OTHER_') {
    return await _showFullCountryBottomSheet(
      contactName: contactName,
      phoneNumber: phoneNumber,
    );
  }

  return result;
}

/// Show full country picker using CustomBottomSheet (same as phone_login)
Future<String?> _showFullCountryBottomSheet({
  required String contactName,
  required String phoneNumber,
}) async {
  final searchController = TextEditingController();
  final countryScrollController = ScrollController();
  final searchError = ''.obs;
  final selectedCountryCode = Rxn<String>();

  // Get all allowed countries
  final allCountries = CountryService()
      .getAll()
      .where((c) => !AppConstants.BLOCKED_COUNTRY_CODES.contains(c.countryCode))
      .toList();

  final filteredCountries = <Country>[...allCountries].obs;

  void validateSearch(String value) {
    if (value.isEmpty) {
      filteredCountries.value = allCountries;
    } else {
      final query = value.toLowerCase();
      filteredCountries.value = allCountries
          .where((c) => c.name.toLowerCase().contains(query))
          .toList();
    }
  }

  void selectCountry(String phoneCode) {
    selectedCountryCode.value = phoneCode;
    // Small delay to show the checkbox checked state before closing
    Future.delayed(const Duration(milliseconds: 200), () {
      Get.back();
    });
  }

  Widget searchField() {
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

  await CustomBottomSheet.show(
    title: AppTexts.COUNTRY_PICKER_OTHER_TITLE,
    subtitle: "${AppTexts.COUNTRY_PICKER_OTHER_SUBTITLE} for $contactName",
    showCloseButton: true,
    header: searchField(),
    footer: Obx(() {
      final currentContext = Get.context!;

      if (filteredCountries.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            AppTexts.NO_COUNTRIES_FOUND,
            style: customBoldText.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.primaryColor,
            ),
          ),
        );
      }

      final isDarkMode = Theme.of(currentContext).brightness == Brightness.dark;

      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(currentContext).size.height * 0.5,
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
                            style: customBoldText.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor,
                            ),
                          ),
                          trailing: Checkbox(
                            value: selectedCountryCode.value == c.phoneCode,
                            activeColor: AppColors.primaryColor,
                            onChanged: (_) => selectCountry(c.phoneCode),
                          ),
                          onTap: () => selectCountry(c.phoneCode),
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

  // Cleanup
  searchController.dispose();
  countryScrollController.dispose();

  return selectedCountryCode.value;
}
