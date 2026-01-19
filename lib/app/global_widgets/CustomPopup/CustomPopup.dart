// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import 'package:bellybutton/app/core/utils/index.dart';
import '../loader/global_loader.dart';

class CustomPopup extends StatelessWidget {
  final String title;
  final String? message;
  final RichText? messageWidget;
  final String confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final RxBool isProcessing;

  /// For sync download popup only
  final RxInt? savedCount;
  final RxInt? totalCount;
  final bool showProgress;

  /// Whether tapping outside the popup dismisses it
  final bool barrierDismissible;

  /// Custom button colors
  final Color? cancelButtonColor;
  final Color? confirmButtonColor;

  const CustomPopup({
    super.key,
    required this.title,
    this.message,
    this.messageWidget,
    required this.confirmText,
    this.cancelText,
    required this.onConfirm,
    required this.isProcessing,
    this.savedCount,
    this.totalCount,
    this.showProgress = false,
    this.barrierDismissible = true,
    this.cancelButtonColor,
    this.confirmButtonColor,
  }) : assert(
         message != null || messageWidget != null,
         "Provide either message or messageWidget",
       );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    /// 🔥 MediaQuery Added Here
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: barrierDismissible ? () => Get.back() : null,
              child: Container(color: Colors.black54),
            ),
          ),

          Center(
            child: GestureDetector(
              onTap: () {},
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: size.width * 0.85,
                  padding: EdgeInsets.all(size.width * 0.05),
                  decoration: BoxDecoration(
                    color: AppColors.textColor3,
                    borderRadius: BorderRadius.circular(size.width * 0.03),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 8),
                    ],
                  ),

                  child: Obx(
                    () => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Title
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppText.headingLg.copyWith(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: size.height * 0.025),

                        /// Progress mode UI
                        if (showProgress &&
                            savedCount != null &&
                            totalCount != null) ...[
                          Global_Loader(
                            size: 55,
                            strokeWidth: 3,
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(height: 15),

                          Text(
                            "${savedCount!.value}/${totalCount!.value} Saved",
                            style: AppText.headingLg.copyWith(
                              fontSize: size.width * 0.045,
                            ),
                          ),

                          SizedBox(height: 10),

                          LinearProgressIndicator(
                            value:
                                savedCount!.value /
                                (totalCount!.value == 0
                                    ? 1
                                    : totalCount!.value),
                            color: AppColors.primaryColor,
                            minHeight: 6,
                            backgroundColor: Colors.black12,
                          ),

                          SizedBox(height: 10),
                          Text(
                            "Downloading please wait...",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 10),
                        ]
                        /// Normal Popup UI
                        else ...[
                          messageWidget ??
                              Text(
                                message ?? "",
                                textAlign: TextAlign.center,
                                style: AppText.headingLg.copyWith(
                                  fontSize: size.width * 0.04,
                                ),
                              ),

                          SizedBox(height: size.height * 0.03),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              /// Rectangle Cancel Button
                              if (cancelText != null)
                                OutlinedButton(
                                  onPressed: () => Get.back(),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: cancelButtonColor ?? AppColors.error),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(05),
                                    ),
                                  ),
                                  child: Text(
                                    cancelText!,
                                    style: AppText.headingLg.copyWith(
                                      fontSize: size.width * 0.035,
                                      color: cancelButtonColor ?? AppColors.error,
                                    ),
                                  ),
                                ),

                              if (cancelText != null) SizedBox(width: 12),

                              /// Rectangle Confirm Button
                              ElevatedButton(
                                onPressed:
                                    isProcessing.value ? null : onConfirm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: confirmButtonColor ?? AppColors.primaryColor,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(05),
                                  ),
                                ),
                                child:
                                    isProcessing.value
                                        ? Global_Loader(
                                          size: 24,
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        )
                                        : Text(
                                          confirmText,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * 0.035,
                                          ),
                                        ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}