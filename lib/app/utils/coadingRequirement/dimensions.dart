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
