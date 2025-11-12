// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/themes/Font_style.dart';
import '../loader/global_loader.dart';

class CustomPopup extends StatelessWidget {
  final String title;
  final String? message;
  final RichText? messageWidget;
  final String confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final RxBool isProcessing;

  const CustomPopup({
    super.key,
    required this.title,
    this.message,
    this.messageWidget,
    required this.confirmText,
    this.cancelText,
    required this.onConfirm,
    required this.isProcessing,
  }) : assert(
         message != null || messageWidget != null,
         'Either message or messageWidget must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // detect taps anywhere
      onTap: () => Get.back(), // close dialog on outside tap
      child: Center(
        child: GestureDetector(
          onTap: () {}, // prevent close when tapping inside the popup
          child: Container(
            width: size.width * 0.85,
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
              color: isDark ? AppColors.textColor2 : AppColors.textColor3,
              borderRadius: BorderRadius.circular(size.width * 0.03),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        title,
                        style: customBoldText.copyWith(
                          fontSize: size.width * 0.05,
                          color:
                              isDark
                                  ? AppColors.textColor2
                                  : AppColors.textColor,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    messageWidget ??
                        Text(
                          message ?? '',
                          textAlign: TextAlign.center,
                          style: customBoldText.copyWith(
                            fontSize: size.width * 0.04,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                    SizedBox(height: size.height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (cancelText != null && cancelText!.isNotEmpty)
                          OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.primaryColor1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  size.width * 0.015,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.015,
                                horizontal: size.width * 0.04,
                              ),
                            ),
                            child: Text(
                              cancelText!,
                              style: customBoldText.copyWith(
                                fontSize: size.width * 0.035,
                                color: AppColors.primaryColor1,
                              ),
                            ),
                          ),
                        if (cancelText != null && cancelText!.isNotEmpty)
                          SizedBox(width: size.width * 0.04),
                        ElevatedButton(
                          onPressed: isProcessing.value ? null : onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                size.width * 0.015,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.015,
                              horizontal: size.width * 0.04,
                            ),
                          ),
                          child:
                              isProcessing.value
                                  ? SizedBox(
                                    height: size.width * 0.045,
                                    width: size.width * 0.045,
                                    child: const Global_Loader(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Text(
                                    confirmText,
                                    style: customBoldText.copyWith(
                                      fontSize: size.width * 0.035,
                                      color: AppColors.textColor3,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
