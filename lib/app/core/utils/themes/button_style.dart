// ignore_for_file: non_constant_identifier_names

import 'package:bellybutton/app/core/utils/themes/custom_color.g.dart';
import 'package:flutter/material.dart';

import 'dimensions.dart';

final enabled_confirm_btn = ElevatedButton.styleFrom(
  backgroundColor: confirm_btn, // Set the background color

  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL)),
);

final disabled_confirm_btn = ElevatedButton.styleFrom(
  backgroundColor: green_light, // Set the background color
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL)),
);

final disabled_confirm_btnLarge = ElevatedButton.styleFrom(
  backgroundColor: green_light, // Set the background color
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_OVER_LARGE)),
);

final enabled_confirm_btnLarge = ElevatedButton.styleFrom(
  backgroundColor: confirm_btn, // Set the background color
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_OVER_LARGE)),
);

final skip_button = ElevatedButton.styleFrom(
  backgroundColor: Colors.grey[300], // Set the background color
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
);

final enable_next_button = ElevatedButton.styleFrom(
  backgroundColor: confirm_btn, // Set the background color
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
);

final disable_next_button = ElevatedButton.styleFrom(
  backgroundColor: green_light, // Set the background color
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
);
