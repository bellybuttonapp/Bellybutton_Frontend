// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bellybutton/app/core/constants/app_colors.dart';
import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:bellybutton/app/core/constants/app_texts.dart';
import '../../../core/utils/themes/font_style.dart';
import '../../../database/models/InvitedEventModel.dart';
import '../../Button/global_button.dart';

class InvitedEventCard extends StatelessWidget {
  final InvitedEventModel event;
  final bool isDarkMode;
  final VoidCallback? onAcceptTap;
  final VoidCallback? onDenyTap;
  final VoidCallback? onTap;

  const InvitedEventCard({
    super.key,
    required this.event,
    required this.isDarkMode,
    this.onAcceptTap,
    this.onDenyTap,
    this.onTap,
  });

  /// Formats event date and time in user's LOCAL timezone
  /// Converts from UTC (stored) to local time for display
  /// Shows both start and end time: "Mon, 20 January - 10:00 AM to 2:00 PM"
  String formatEventDateTime() {
    try {
      // Use InvitedEventModel's built-in local time conversion
      // This converts UTC stored time to user's local timezone
      final localStartDateTime = event.localStartDateTime;
      final localEndDateTime = event.localEndDateTime;

      final formattedDate = DateFormat("EEE, d MMMM").format(localStartDateTime);
      final formattedStartTime = DateFormat("hh:mm a").format(localStartDateTime);
      final formattedEndTime = DateFormat("hh:mm a").format(localEndDateTime);

      return "$formattedDate - $formattedStartTime to $formattedEndTime";
    } catch (_) {
      // Fallback to raw display if conversion fails
      try {
        final startDateTime = DateTime.parse("${event.eventDate} ${event.startTime}");
        final formattedDate = DateFormat("EEE, d MMMM").format(startDateTime);
        final formattedStartTime = DateFormat("hh:mm a").format(startDateTime);

        // Try to parse end time as well
        if (event.endTime.isNotEmpty) {
          final endDateTime = DateTime.parse("${event.eventDate} ${event.endTime}");
          final formattedEndTime = DateFormat("hh:mm a").format(endDateTime);
          return "$formattedDate - $formattedStartTime to $formattedEndTime";
        }

        return "$formattedDate - $formattedStartTime";
      } catch (_) {
        return "${event.eventDate} ${event.startTime}";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final w = size.width;
    final h = size.height;

    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final imageSize = w * .18;

    final cardColor =
        isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF7FBFF);
    final borderColor =
        isDarkMode ? Colors.white10 : AppColors.primaryColor.withOpacity(.2);

    // Accent color for invited events - uses pending blue
    final accentColor = AppColors.pending;

    return Padding(
      padding: EdgeInsets.only(bottom: h * .015),
      child: Material(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(w * .035),
          side: BorderSide(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(w * .035),
          splashColor: AppColors.primaryColor.withOpacity(0.15),
          onTap: () {},
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left accent bar for invited events
                Container(
                  width: w * 0.012,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(w * .035),
                      bottomLeft: Radius.circular(w * .035),
                    ),
                  ),
                ),
                // Main content
                Expanded(
                  child: Padding(
            padding: EdgeInsets.all(w * .04),
            child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// image
          ClipRRect(
            borderRadius: BorderRadius.circular(w * .04),
            child:
                event.imagePath?.isNotEmpty == true
                    ? Image.network(
                      event.imagePath!,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    )
                    : Image.asset(
                      AppImages.EVENTPOPUP_DP,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
          ),

          SizedBox(width: w * .04),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                Text(
                  event.title,
                  style: AppText.headingLg.copyWith(
                    fontSize: w * .045,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),

                SizedBox(height: h * .005),

                /// DATE
                Text(
                  formatEventDateTime(),
                  style: AppText.headingLg.copyWith(
                    fontSize: w * .036,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),

                SizedBox(height: h * .005),

                /// DESCRIPTION
                if (event.description != null &&
                    event.description!.trim().isNotEmpty)
                  Text(
                    event.description!,
                    style: AppText.headingLg.copyWith(
                      fontSize: w * .032,
                      fontWeight: FontWeight.w500,
                      color:
                          isDarkMode
                              ? Colors.white70
                              : Colors.black.withOpacity(.7),
                    ),
                  ),

                SizedBox(height: h * .015),

                /// ACTION BUTTONS
                event.isAccepted
                    ? Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: w * .06,
                            vertical: h * .009,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(
                              isDarkMode ? .20 : .15,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppTexts.GO_FOR_SHOOT,
                                style: AppText.headingLg.copyWith(
                                  fontSize: w * .032,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(width: w * 0.01),
                              SvgPicture.asset(
                                AppImages.arrow_forward_ios_rounded,
                                width: w * .035,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    :
                    /// accept + deny
                    Row(
                      children: [
                        Expanded(
                          child: global_button(
                            title: AppTexts.DENY,
                            onTap: onDenyTap,
                            removeMargin: true,
                            textColor: Colors.red,
                            backgroundColor: Colors.red.withOpacity(.10),
                          ),
                        ),
                        SizedBox(width: w * .03),
                        Expanded(
                          child: global_button(
                            title: AppTexts.ACCEPT,
                            onTap: onAcceptTap,
                            removeMargin: true,
                            backgroundColor: AppColors.success.withOpacity(.12),
                            textColor: AppColors.success,
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ],
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
