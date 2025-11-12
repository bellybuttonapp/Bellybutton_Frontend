// ignore_for_file: file_names, deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/themes/Font_style.dart';

class SheetAction {
  final Widget? icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  final Widget? trailing;

  const SheetAction({
    this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
    this.trailing,
  });
}

class CustomBottomSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? header;
  final Widget? headerImage;
  final bool showCloseButton;
  final List<SheetAction> actions;
  final Widget? footer;
  final double maxWidth;

  const CustomBottomSheet({
    super.key,
    this.title,
    this.subtitle,
    this.header,
    this.headerImage,
    this.showCloseButton = false,
    required this.actions,
    this.footer,
    this.maxWidth = 600,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ Responsive scaling based on screen width
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final double textScale = (width / 375).clamp(
      0.85,
      1.3,
    ); // base on iPhone 12 width

    final Color backgroundColor =
        isDark
            ? const Color(0xFF121212).withOpacity(0.95)
            : const Color(0xFFF9FAFB).withOpacity(0.95);

    final Color surfaceColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6);

    final Color handleColor = isDark ? Colors.grey[700]! : Colors.grey[400]!;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(width * 0.06)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(maxWidth: maxWidth),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(width * 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.15),
                blurRadius: 30,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: height * 0.02,
                top: height * 0.01,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: width * 0.1,
                      height: 5,
                      margin: EdgeInsets.only(bottom: height * 0.015),
                      decoration: BoxDecoration(
                        color: handleColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // Title + optional close button
                  if (title != null || showCloseButton)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (title != null)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title!,
                                    style: customBoldText.copyWith(
                                      fontSize: 18 * textScale,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          isDark
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                  if (subtitle != null)
                                    Text(
                                      subtitle!,
                                      style: customBoldText.copyWith(
                                        fontSize: 14 * textScale,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          if (showCloseButton)
                            IconButton(
                              icon: SvgPicture.asset(
                                AppImages
                                    .CLOSE_ICON, // 👈 replace with your close icon
                                color: isDark ? Colors.white70 : Colors.black54,
                                width: width * 0.05,
                                height: width * 0.05,
                              ),
                              onPressed: () => Get.back(),
                            ),
                        ],
                      ),
                    ),

                  // Optional custom header
                  if (header != null) ...[
                    SizedBox(height: height * 0.015),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: header!,
                    ),
                    SizedBox(height: height * 0.015),
                  ],

                  // Optional header image
                  if (headerImage != null) ...[
                    SizedBox(height: height * 0.015),
                    Center(child: headerImage!),
                    SizedBox(height: height * 0.015),
                  ],

                  // Actions list
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: height * 0.005),
                      child: Column(
                        children:
                            actions
                                .map(
                                  (a) => Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.03,
                                      vertical: height * 0.006,
                                    ),
                                    child: Material(
                                      color: surfaceColor.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(14),
                                      child: InkWell(
                                        onTap: () async {
                                          HapticFeedback.selectionClick();
                                          Get.back();
                                          await Future.delayed(
                                            const Duration(milliseconds: 150),
                                          );
                                          a.onTap();
                                        },
                                        borderRadius: BorderRadius.circular(14),
                                        splashColor: (a.destructive
                                                ? theme.colorScheme.error
                                                : theme.colorScheme.primary)
                                            .withOpacity(0.1),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: width * 0.04,
                                            vertical: height * 0.005,
                                          ),
                                          leading:
                                              a.icon != null
                                                  ? CircleAvatar(
                                                    radius: width * 0.06,
                                                    backgroundColor:
                                                        isDark
                                                            ? Colors.grey[850]
                                                            : Colors.grey[200],
                                                    child: a.icon,
                                                  )
                                                  : null,
                                          title: Text(
                                            a.label,
                                            style: customBoldText.copyWith(
                                              color:
                                                  a.destructive
                                                      ? theme.colorScheme.error
                                                      : (isDark
                                                          ? Colors.white
                                                          : Colors.black87),
                                              fontSize: 15 * textScale,
                                            ),
                                          ),
                                          trailing: a.trailing,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),

                  // Footer
                  if (footer != null) ...[
                    SizedBox(height: height * 0.015),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: footer!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper for easy show
  static Future<void> show({
    String? title,
    String? subtitle,
    Widget? header,
    Widget? headerImage,
    bool showCloseButton = false,
    required List<SheetAction> actions,
    Widget? footer,
    bool isScrollControlled = false,
  }) async {
    await Get.bottomSheet(
      CustomBottomSheet(
        title: title,
        subtitle: subtitle,
        header: header,
        headerImage: headerImage,
        showCloseButton: showCloseButton,
        actions: actions,
        footer: footer,
      ),
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      enterBottomSheetDuration: const Duration(milliseconds: 280),
      exitBottomSheetDuration: const Duration(milliseconds: 220),
    );
  }
}
