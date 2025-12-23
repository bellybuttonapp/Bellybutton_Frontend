// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bellybutton/app/core/constants/app_colors.dart';
import 'package:bellybutton/app/core/constants/app_images.dart';
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

  String formatEventDate(String date, String time) {
    try {
      return DateFormat(
        "EEE, d MMMM - hh:mm a",
      ).format(DateTime.parse("$date $time"));
    } catch (_) {
      return "$date $time";
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
                  style: customBoldText.copyWith(
                    fontSize: w * .045,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),

                SizedBox(height: h * .005),

                /// DATE
                Text(
                  formatEventDate(event.eventDate, event.startTime),
                  style: customBoldText.copyWith(
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
                    style: customBoldText.copyWith(
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
                                "View Photos",
                                style: customBoldText.copyWith(
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
                            title: "Deny",
                            onTap: onDenyTap,
                            removeMargin: true,
                            textColor: Colors.red,
                            backgroundColor: Colors.red.withOpacity(.10),
                          ),
                        ),
                        SizedBox(width: w * .03),
                        Expanded(
                          child: global_button(
                            title: "Accept",
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
      ),
    );
  }
}
