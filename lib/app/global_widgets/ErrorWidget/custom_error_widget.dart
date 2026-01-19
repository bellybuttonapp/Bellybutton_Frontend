import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_texts.dart';
import '../../core/utils/themes/font_style.dart';

/// A friendly error widget to show instead of the default red/black error screen.
/// Use this in main.dart's ErrorWidget.builder for production builds.
class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;
  final String? message;
  final VoidCallback? onRetry;

  const CustomErrorWidget({
    super.key,
    this.errorDetails,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF121212) : Colors.white,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error illustration
                Container(
                  padding: EdgeInsets.all(size.width * 0.06),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: size.width * 0.15,
                    color: AppColors.primaryColor,
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                // Title
                Text(
                  AppTexts.ERROR_TITLE,
                  textAlign: TextAlign.center,
                  style: AppText.headingLg.copyWith(
                    fontSize: size.width * 0.05,
                    color: isDark ? Colors.white : AppColors.textColor,
                  ),
                ),

                SizedBox(height: size.height * 0.015),

                // Message
                Text(
                  message ?? AppTexts.ERROR_DEFAULT_MESSAGE,
                  textAlign: TextAlign.center,
                  style: AppText.bodyMd.copyWith(
                    fontSize: size.width * 0.035,
                    color: isDark ? Colors.grey.shade400 : AppColors.tertiaryColor,
                  ),
                ),

                SizedBox(height: size.height * 0.04),

                // Retry button (if callback provided)
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: Text(
                      AppTexts.ERROR_TRY_AGAIN,
                      style: AppText.headingLg.copyWith(
                        color: Colors.white,
                        fontSize: size.width * 0.04,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.08,
                        vertical: size.height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A minimal error widget for use in smaller spaces (like list items)
class MinimalErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const MinimalErrorWidget({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.primaryColor.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? AppTexts.ERROR_MINIMAL_MESSAGE,
              textAlign: TextAlign.center,
              style: AppText.bodyMd.copyWith(
                fontSize: 14,
                color: AppColors.tertiaryColor,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(AppTexts.ERROR_RETRY),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
