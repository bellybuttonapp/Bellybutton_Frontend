// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, file_names

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_texts.dart';
import '../GlobalTextField/GlobalTextField.dart';
import '../custom_app_bar/custom_app_bar.dart';

String limitWords(String? text, int maxWords) {
  if (text == null) return "";
  final words = text.trim().split(RegExp(r'\s+'));
  if (words.length <= maxWords) return text;
  return words.take(maxWords).join(" ") + "...";
}

class ReusableEventGalleryLayout extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? bottomButton;
  final Widget gridView;
  final Widget? suffixWidget;
  final List<Widget>? floatingButtons;

  final bool showAppBar;
  final String appBarTitle;

  const ReusableEventGalleryLayout({
    this.title,
    this.description,
    this.suffixWidget,
    required this.gridView,
    this.bottomButton,
    this.floatingButtons,
    this.showAppBar = true,
    this.appBarTitle = AppTexts.EVENT,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,

      appBar: showAppBar ? CustomAppBar(title: appBarTitle) : null,

      // ⭐ ⭐ NOW FLOATING BUTTON WORKS ⭐ ⭐
      floatingActionButton:
          floatingButtons != null
              ? Padding(
                padding: const EdgeInsets.only(
                  right: 20,
                  bottom: 80,
                ), // 🔥 Move UP by 25px
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: floatingButtons!,
                ),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            if (title != null && title!.trim().isNotEmpty)
              GlobalTextField(
                readOnly: true,
                hintText: AppTexts.EVENT_TITLE,
                initialValue: limitWords(title, 6),
                suffixIcon: suffixWidget,
              ),

            if (description != null && description!.trim().isNotEmpty)
              GlobalTextField(
                enabled: false,
                hintText: AppTexts.DESCRIPTION,
                initialValue: limitWords(description, 12),
                maxLines: 2,
              ),

            const SizedBox(height: 12),

            Expanded(child: gridView),

            if (bottomButton != null) bottomButton!,
          ],
        ),
      ),
    );
  }
}

Widget buildSuffixWidget({
  required String count,
  required String iconPath,
  required VoidCallback onTap,
  required double screenWidth,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.01,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(40, 166, 216, 233),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: buildSuffixContent(
        count: count,
        iconPath: iconPath,
        width: screenWidth,
      ),
    ),
  );
}

Widget buildSuffixContent({
  required String count,
  required String iconPath,
  required double width,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SvgPicture.asset(iconPath, width: width * 0.045, height: width * 0.045),
      SizedBox(width: width * 0.015),
      Text(
        count,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    ],
  );
}
