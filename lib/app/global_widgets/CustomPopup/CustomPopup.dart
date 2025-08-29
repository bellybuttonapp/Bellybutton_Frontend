// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/themes/Font_style.dart';
import '../loader/global_loader.dart';

class CustomPopup extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final RxBool isProcessing;

  const CustomPopup({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Center(
      child: Container(
        width: size.width * 0.85,
        padding: EdgeInsets.all(size.width * 0.05),
        decoration: BoxDecoration(
          color: isDark ? AppColors.textColor2 : AppColors.textColor3,
          borderRadius: BorderRadius.circular(size.width * 0.03),
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
                      color:
                          isDark ? AppColors.textColor2 : AppColors.textColor,
                      fontSize: size.width * 0.05,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  message,
                  style: customBoldText.copyWith(
                    color: AppColors.textColor2,
                    fontSize: size.width * 0.04,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryColor1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            size.width * 0.015,
                          ),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: customBoldText.copyWith(
                          color: AppColors.primaryColor1,
                          fontSize: size.width * 0.035,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.05),
                    ElevatedButton(
                      onPressed: isProcessing.value ? null : onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            size.width * 0.015,
                          ),
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
                                  color: AppColors.textColor3,
                                  fontSize: size.width * 0.035,
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
    );
  }
}
