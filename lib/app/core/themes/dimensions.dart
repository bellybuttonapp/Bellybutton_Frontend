// ignore_for_file: constant_identifier_names
import 'package:get/get.dart';

class Dimensions {
  static double fontSizeExtraSmall = Get.context!.width >= 1300
      ? 14
      : Get.context!.width <= 360
          ? 8
          : 10;
  static double fontSizeSmall = Get.context!.width >= 1300
      ? 16
      : Get.context!.width <= 360
          ? 10
          : 12;
  static double fontSizeDefault = Get.context!.width >= 1300
      ? 18
      : Get.context!.width <= 360
          ? 12
          : 14;
  static double fontSizeLarge = Get.context!.width >= 1300
      ? 20
      : Get.context!.width <= 360
          ? 14
          : 16;

  static double popupheight = Get.context!.height >= 932
      ? Get.context!.height / 1.8
      : Get.context!.height / 1.5;

  static double fontSizeExtraLarge = Get.context!.width >= 1300 ? 22 : 18;
  static double fontSizeOverLarge = Get.context!.width >= 1300 ? 28 : 24;

  static const double PADDING_SIZE_EXTRA_SMALL = 5.0;
  static const double PADDING_SIZE_SMALL = 10.0;
  static const double PADDING_SIZE_DEFAULT = 15.0;
  static const double PADDING_SIZE_LARGE = 20.0;
  static const double PADDING_SIZE_EXTRA_LARGE = 25.0;
  static const double PADDING_SIZE_OVER_LARGE = 30.0;

  static const double RADIUS_SMALL = 5.0;
  static const double RADIUS_DEFAULT = 10.0;
  static const double RADIUS_LARGE = 15.0;
  static const double RADIUS_EXTRA_LARGE = 20.0;
  static const double ButtonRadius = 30.0;

  static const double WEB_MAX_WIDTH = 1170;
  static const int MESSAGE_INPUT_LENGTH = 250;
  static double totalScreensize = Get.context!.width;
}
// This class provides responsive dimensions for font sizes, padding, and radii based on the screen width and height.
// It adjusts sizes for different screen widths, ensuring a consistent user interface across devices.
// The dimensions are defined as static constants, making them easily accessible throughout the application.
// The font sizes are categorized into extra small, small, default, large, extra large, and over large.
// The padding sizes are categorized into extra small, small, default, large, extra large, and over large.
// The radii sizes are categorized into small, default, large, extra large, and button radius.
// The popup height is calculated based on the screen height, providing a responsive design for popups.
// The class uses the GetX package for responsive design, allowing for easy access to the current context.
// The WEB_MAX_WIDTH constant defines the maximum width for web applications, ensuring a consistent layout.
// The MESSAGE_INPUT_LENGTH constant defines the maximum length for message input fields, promoting consistency in user input.