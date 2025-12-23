// ignore_for_file: deprecated_member_use, file_names

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NotificationShimmer extends StatelessWidget {
  final int count;

  const NotificationShimmer({
    super.key,
    this.count = 5,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.02,
      ),
      children: [
        // Section header shimmer
        // _buildSectionHeaderShimmer(baseColor, highlightColor, size),
        // SizedBox(height: size.height * 0.015),

        // Notification items shimmer
        ...List.generate(
          count,
          (index) => _buildNotificationItemShimmer(
            baseColor,
            highlightColor,
            size,
            isDark,
          ),
        ),
      ],
    );
  }

  // Widget _buildSectionHeaderShimmer(
  //   Color baseColor,
  //   Color highlightColor,
  //   Size size,
  // ) {
  //   return Shimmer.fromColors(
  //     baseColor: baseColor,
  //     highlightColor: highlightColor,
  //     child: Container(
  //       width: size.width * 0.15,
  //       height: size.height * 0.02,
  //       decoration: BoxDecoration(
  //         color: baseColor,
  //         borderRadius: BorderRadius.circular(4),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildNotificationItemShimmer(
    Color baseColor,
    Color highlightColor,
    Size size,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.015),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(size.width * 0.03),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blue dot placeholder
          SizedBox(width: size.width * 0.055),

          // Avatar shimmer
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: size.width * 0.13,
              height: size.width * 0.13,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
              ),
            ),
          ),

          SizedBox(width: size.width * 0.035),

          // Content shimmer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message line 1
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: double.infinity,
                    height: size.height * 0.018,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.008),

                // Message line 2
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: size.width * 0.5,
                    height: size.height * 0.018,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.012),

                // Time shimmer
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: size.width * 0.2,
                    height: size.height * 0.015,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
