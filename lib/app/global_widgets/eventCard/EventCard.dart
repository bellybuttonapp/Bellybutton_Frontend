// ignore_for_file: file_names, deprecated_member_use

import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:bellybutton/app/core/constants/app_colors.dart';
import '../../core/themes/Font_style.dart';
import '../../core/themes/dimensions.dart';
import '../../database/models/EventModel.dart';
import '../CustomBottomSheet/CustomBottomsheet.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final bool isDarkMode;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;

  const EventCard({
    super.key,
    required this.event,
    required this.isDarkMode,
    this.onTap,
    this.onEditTap,
    this.onDeleteTap,
  });

  String _formatEventDateTime(DateTime eventDate, String? rawTime) {
    try {
      final formattedDate = DateFormat('E, d MMMM').format(eventDate);
      if (rawTime != null && rawTime.isNotEmpty) {
        final time = DateFormat('HH:mm:ss').parse(rawTime);
        final formattedTime = DateFormat('hh:mm a').format(time);
        return "$formattedDate - $formattedTime";
      }
      return formattedDate;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final textScale = (width / 375).clamp(0.85, 1.25);

    final textColor = isDarkMode ? AppColors.textColor3 : AppColors.textColor;
    final secondaryTextColor =
        isDarkMode
            ? AppColors.textColor3.withOpacity(0.7)
            : AppColors.textColor2;

    final cardColor =
        isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF4FBFF);

    final borderColor =
        isDarkMode
            ? Colors.white.withOpacity(0.08)
            : AppColors.primaryColor.withOpacity(0.2);

    final shadowColor =
        isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.grey.withOpacity(0.2);

    final imageSize = width * 0.18;
    final spacing = width * 0.03;

    return Padding(
      padding: EdgeInsets.only(bottom: height * 0.012),
      child: Material(
        color: cardColor,
        elevation: isDarkMode ? 0 : 1,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(width * 0.025),
          side: BorderSide(color: borderColor, width: 0.6),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(width * 0.025),
          splashColor: AppColors.primaryColor.withOpacity(0.15),
          onTap: () {}, // tap to open details if needed
          onLongPress: () {
            // 👇 Long press anywhere on the card
            HapticFeedback.selectionClick();
            _showBottomSheet(context, width);
          },
          child: Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEventImage(imageSize),
                    SizedBox(width: spacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitle(width, textScale, textColor),
                          SizedBox(height: height * 0.005),
                          _buildDateTime(width, textScale),
                          SizedBox(height: height * 0.005),
                          _buildDescription(textScale, secondaryTextColor),
                        ],
                      ),
                    ),
                    // Replace it with this:
                    InkWell(
                      borderRadius: BorderRadius.circular(width * 0.06),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _showBottomSheet(context, width);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.01),
                        child: Icon(
                          Icons.more_vert,
                          size: width * 0.06,
                          color:
                              isDarkMode
                                  ? Colors.white70
                                  : AppColors.textColor2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_buildViewPhotosButton(width, height, textScale)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------- Components ----------------------------

  void _showBottomSheet(BuildContext context, double width) {
    CustomBottomSheet.show(
      title: event.title.isNotEmpty ? event.title : 'Untitled Event',
      subtitle: _formatEventDateTime(event.eventDate, event.startTime),
      showCloseButton: true,
      header: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: width * 0.03),
          ClipRRect(
            borderRadius: BorderRadius.circular(width * 0.04),
            child:
                event.imagePath != null && event.imagePath!.isNotEmpty
                    ? Image.network(
                      event.imagePath!,
                      width: width * 0.2,
                      height: width * 0.2,
                      fit: BoxFit.cover,
                    )
                    : Image.asset(
                      AppImages.EVENTPOPUP_DP,
                      width: width * 0.2,
                      height: width * 0.2,
                      fit: BoxFit.cover,
                      color: isDarkMode ? Colors.white24 : null,
                      colorBlendMode: isDarkMode ? BlendMode.softLight : null,
                    ),
          ),
        ],
      ),
      actions: [
        SheetAction(
          trailing: SvgPicture.asset(
            AppImages.arrow_forward_ios_rounded,
            width: width * 0.05,
            height: width * 0.05,
            colorFilter: ColorFilter.mode(
              isDarkMode ? Colors.white70 : Colors.black54,
              BlendMode.srcIn,
            ),
          ),
          label: AppTexts.EDIT_EVENT,
          onTap: () => onEditTap?.call(),
        ),
        SheetAction(
          trailing: SvgPicture.asset(
            AppImages.arrow_forward_ios_rounded,
            width: width * 0.05,
            height: width * 0.05,
            colorFilter: ColorFilter.mode(
              isDarkMode ? Colors.white70 : Colors.black54,
              BlendMode.srcIn,
            ),
          ),
          label: AppTexts.DELETE_EVENT,
          destructive: true,
          onTap: () => onDeleteTap?.call(),
        ),
      ],
    );
  }

  Widget _buildEventImage(double imageSize) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(imageSize * 0.25),
      child:
          event.imagePath != null && event.imagePath!.isNotEmpty
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
                color: isDarkMode ? Colors.white10 : null,
                colorBlendMode: isDarkMode ? BlendMode.softLight : null,
              ),
    );
  }

  Widget _buildTitle(double width, double textScale, Color textColor) {
    return Text(
      event.title.isNotEmpty ? event.title : 'Untitled Event',
      style: customBoldText.copyWith(
        fontSize: Dimensions.fontSizeExtraLarge * textScale,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildDateTime(double width, double textScale) {
    return Text(
      _formatEventDateTime(event.eventDate, event.startTime),
      style: customBoldText.copyWith(
        fontSize: Dimensions.fontSizeDefault * textScale,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildDescription(double textScale, Color color) {
    return Text(
      event.description,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: customBoldText.copyWith(
        fontSize: Dimensions.fontSizeDefault * textScale,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  Widget _buildViewPhotosButton(double width, double height, double textScale) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(width * 0.08),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: height * 0.008,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(isDarkMode ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(width * 0.08),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "View Photos",
              style: customBoldText.copyWith(
                fontSize: Dimensions.fontSizeDefault * textScale,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(width: width * 0.012),
            SvgPicture.asset(
              AppImages.arrow_forward_ios_rounded,
              width: width * 0.040,
              height: width * 0.040,
              colorFilter: ColorFilter.mode(
                isDarkMode ? Colors.white70 : Colors.black54,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
