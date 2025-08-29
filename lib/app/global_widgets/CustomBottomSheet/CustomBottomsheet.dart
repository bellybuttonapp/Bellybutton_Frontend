// ignore: file_names
// ignore_for_file: file_names, duplicate_ignore

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/themes/Font_style.dart';

/// Action model for bottom sheet
class SheetAction {
  final Widget icon; // <-- accepts any widget (SVG, Icon, Image, etc.)
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  final Widget? trailing;

  SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
    this.trailing,
  });
}

/// Reusable GetX custom bottom sheet
class CustomBottomSheet extends StatelessWidget {
  final String? title;
  final List<SheetAction> actions;
  final Widget? footer;
  final double maxWidth;

  const CustomBottomSheet({
    super.key,
    this.title,
    required this.actions,
    this.footer,
    this.maxWidth = 600,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width; // <-- media query

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // glassmorphic feel
        child: Container(
          decoration: BoxDecoration(
            color:
                isDark
                    // ignore: deprecated_member_use
                    ? Colors.grey[900]!.withOpacity(0.9)
                    // ignore: deprecated_member_use
                    : Colors.white.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (title != null) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title!,
                          style: customBoldText.copyWith(
                            fontSize: screenWidth * 0.045, // responsive
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // actions
                  Flexible(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: actions.length,
                      itemBuilder: (context, i) {
                        final a = actions[i];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Get.back(); // close bottom sheet
                              a.onTap();
                            },
                            splashColor:
                                a.destructive
                                    // ignore: deprecated_member_use
                                    ? theme.colorScheme.error.withOpacity(0.1)
                                    // ignore: deprecated_member_use
                                    : theme.colorScheme.primary.withOpacity(
                                      0.1,
                                    ),
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    isDark
                                        ? Colors.grey[850]
                                        : Colors.grey[100],
                                child: a.icon,
                              ),
                              title: Text(
                                a.label,
                                style: customBoldText.copyWith(
                                  color:
                                      a.destructive
                                          ? theme.colorScheme.error
                                          : AppColors.textColor,
                                  fontSize: screenWidth * 0.035, // responsive
                                ),
                              ),
                              trailing: a.trailing,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // footer
                  if (footer != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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

  /// Helper to show with Get.bottomSheet
  static void show({
    String? title,
    required List<SheetAction> actions,
    Widget? footer,
    bool isScrollControlled = false,
  }) {
    Get.bottomSheet(
      CustomBottomSheet(title: title, actions: actions, footer: footer),
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
    );
  }
}
