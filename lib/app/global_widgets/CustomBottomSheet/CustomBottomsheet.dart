// ignore_for_file: file_names, deprecated_member_use, unnecessary_underscores

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import 'package:bellybutton/app/core/utils/index.dart';

/// Action button inside the bottom sheet
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

/// Smooth, modern custom bottom sheet
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final textScale = (width / 375).clamp(0.85, 1.3);

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
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: height * 0.85,
          ),
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
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height * 0.85),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.008),
                      child: Container(
                        width: width * 0.12,
                        height: 5,
                        decoration: BoxDecoration(
                          color: handleColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // Title + Close
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
                                  AppImages.CLOSE_ICON,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                  width: width * 0.05,
                                  height: width * 0.05,
                                ),
                                onPressed: () => Get.back(),
                              ),
                          ],
                        ),
                      ),

                    // Optional header
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
                    ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: height * 0.005),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: actions.length,
                      separatorBuilder:
                          (_, __) => SizedBox(height: height * 0.006),
                      itemBuilder: (_, index) {
                        final a = actions[index];
                        return Material(
                          color: surfaceColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            splashColor: (a.destructive
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary)
                                .withOpacity(0.1),
                            onTap: () async {
                              HapticFeedback.selectionClick();
                              Get.back();
                              await Future.delayed(
                                const Duration(milliseconds: 150),
                              );
                              a.onTap();
                            },
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
                        );
                      },
                    ),

                    // Optional footer
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
      ),
    );
  }

  /// Show bottom sheet easily
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
      enterBottomSheetDuration: Duration.zero, // instant open
      exitBottomSheetDuration: Duration.zero, // instant close
    );
  }
}
