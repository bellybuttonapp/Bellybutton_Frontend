// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:flutter/material.dart';

const confirm_btn = Color.fromARGB(255, 37, 106, 93);
const status_pending = Color(0xFF7BAAB7);
const status_inprogress = Color(0xFF68838A);
const status_completed = Color(0xFF508E7F);
const gray_textfield = Color(0xFFE5E5E5);
const light_gray_background = Color(0xFFFAFAFA);
const dark_gray_jcpage_ackground = Color(0xFFEDEDED);
const light_blue_jcdetails = Color(0xFFD3D6DD);
const text = Color(0xFF272425);
const text_subtitle = Color(0xFF6F6F6F);
const textfield_bg = Color(0xFFECECEC);
const light = Color(0xFFFFFFFF);
const primary = Color(0xFF2F3B63);
const secondaryappbar = Color(0xFF212B4F);
const tertiary = Color(0xFF578990);
const text_button_tertiary = Color(0xFF666666);
const gradbutton_tertiary_start = Color(0xFFEDEDED);
const gradbutton_tertiary_end = Color(0xFFF3F3F3);
const transparent = Color(0xFF000000);
const green_mild = Color(0xFFB1D8B7);
const green_light = Color(0xFFDDE4E3);
const yellow_light = Color(0xFFFFF59D);
const orange = Color(0xFFE26713);
const green = Color(0xFF1FCC26);
const yellow = Color(0xFFFFB800);
const green_radium = Color(0xFF228B22);
const blue = Color(0xFF0267C1);
const blue_call = Color(0xFF267CBE);
const violet = Color(0xFF322A7F);
const text_refer = Color(0xFF304D48);
const ratingbar = Color(0xFFEFF3F9);
const referboxdec_start = Color(0XFF3A616D);
const referboxdec_end = Color(0XFF3E777E);
const backgroundColor = Color(0xFFF0F0F0);
const referal_header = Color(0xFFE5E5E5);
const referal_body = Color(0xFFF5F5F5);
const addvideo = Color(0xFFE7ECF4);

CustomColors lightCustomColors = const CustomColors(
  sourceStatusPending: Color(0xFF7BAAB7),
  status_pending: Color(0xFF00687A),
  onStatusPending: Color(0xFFFFFFFF),
  statusPendingContainer: Color(0xFFABEDFF),
  onStatusPendingContainer: Color(0xFF001F26),
  sourceStatusInprogress: Color(0xFF68838A),
  status_inprogress: Color(0xFF006878),
  onStatusInprogress: Color(0xFFFFFFFF),
  statusInprogressContainer: Color(0xFFA7EEFF),
  onStatusInprogressContainer: Color(0xFF001F25),
  sourceStatusCompleted: Color(0xFF508E7F),
  status_completed: Color(0xFF006B5A),
  onStatusCompleted: Color(0xFFFFFFFF),
  statusCompletedContainer: Color(0xFF79F8DB),
  onStatusCompletedContainer: Color(0xFF00201A),
  sourceGrayTextfield: Color(0xFFE5E5E5),
  gray_textfield: Color(0xFF006874),
  onGrayTextfield: Color(0xFFFFFFFF),
  grayTextfieldContainer: Color(0xFF97F0FF),
  onGrayTextfieldContainer: Color(0xFF001F24),
  sourceLightGrayBackground: Color(0xFFFAFAFA),
  light_gray_background: Color(0xFF006874),
  onLightGrayBackground: Color(0xFFFFFFFF),
  lightGrayBackgroundContainer: Color(0xFF97F0FF),
  onLightGrayBackgroundContainer: Color(0xFF001F24),
  sourceDarkGrayJcpageAckground: Color(0xFFEDEDED),
  dark_gray_jcpage_ackground: Color(0xFF006874),
  onDarkGrayJcpageAckground: Color(0xFFFFFFFF),
  darkGrayJcpageAckgroundContainer: Color(0xFF97F0FF),
  onDarkGrayJcpageAckgroundContainer: Color(0xFF001F24),
  sourceLightBlueJcdetails: Color(0xFFD3D6DD),
  light_blue_jcdetails: Color(0xFF00629F),
  onLightBlueJcdetails: Color(0xFFFFFFFF),
  lightBlueJcdetailsContainer: Color(0xFFD0E4FF),
  onLightBlueJcdetailsContainer: Color(0xFF001D34),
  sourceText: Color(0xFF272425),
  text: Color(0xFF924274),
  onText: Color(0xFFFFFFFF),
  textContainer: Color(0xFFFFD8EB),
  onTextContainer: Color(0xFF3C002B),
  sourceTextSubtitle: Color(0xFF6F6F6F),
  text_subtitle: Color(0xFF006874),
  onTextSubtitle: Color(0xFFFFFFFF),
  textSubtitleContainer: Color(0xFF97F0FF),
  onTextSubtitleContainer: Color(0xFF001F24),
  sourceLight: Color(0xFFFFFFFF),
  light: Color(0xFF006874),
  onLight: Color(0xFFFFFFFF),
  lightContainer: Color(0xFF97F0FF),
  onLightContainer: Color(0xFF001F24),
  sourcePrimary: Color(0xFF2F3B63),
  primary: Color(0xFF405AA9),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFDCE1FF),
  onPrimaryContainer: Color(0xFF00164D),
  sourceSecondaryappbar: Color(0xFF212B4F),
  secondaryappbar: Color(0xFF4259A9),
  onSecondaryappbar: Color(0xFFFFFFFF),
  secondaryappbarContainer: Color(0xFFDCE1FF),
  onSecondaryappbarContainer: Color(0xFF001550),
  sourceTertiary: Color(0xFF578990),
  tertiary: Color(0xFF006972),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF8FF2FF),
  onTertiaryContainer: Color(0xFF001F23),
  sourceTextButtonTertiary: Color(0xFF666666),
  text_button_tertiary: Color(0xFF006874),
  onTextButtonTertiary: Color(0xFFFFFFFF),
  textButtonTertiaryContainer: Color(0xFF97F0FF),
  onTextButtonTertiaryContainer: Color(0xFF001F24),
  sourceGradbuttonTertiaryStart: Color(0xFFEDEDED),
  gradbutton_tertiary_start: Color(0xFF006874),
  onGradbuttonTertiaryStart: Color(0xFFFFFFFF),
  gradbuttonTertiaryStartContainer: Color(0xFF97F0FF),
  onGradbuttonTertiaryStartContainer: Color(0xFF001F24),
  sourceGradbuttonTertiaryEnd: Color(0xFFF3F3F3),
  gradbutton_tertiary_end: Color(0xFF006874),
  onGradbuttonTertiaryEnd: Color(0xFFFFFFFF),
  gradbuttonTertiaryEndContainer: Color(0xFF97F0FF),
  onGradbuttonTertiaryEndContainer: Color(0xFF001F24),
  sourceTransparent: Color(0xFF000000),
  transparent: Color(0xFF984061),
  onTransparent: Color(0xFFFFFFFF),
  transparentContainer: Color(0xFFFFD9E2),
  onTransparentContainer: Color(0xFF3E001D),
  sourceGreenMild: Color(0xFFB1D8B7),
  green_mild: Color(0xFF006D38),
  onGreenMild: Color(0xFFFFFFFF),
  greenMildContainer: Color(0xFF9BF6B3),
  onGreenMildContainer: Color(0xFF00210D),
  sourceGreenLight: Color(0xFFDDE4E3),
  green_light: Color(0xFF006A69),
  onGreenLight: Color(0xFFFFFFFF),
  greenLightContainer: Color(0xFF6FF7F5),
  onGreenLightContainer: Color(0xFF00201F),
  sourceYellowLight: Color(0xFFFFF59D),
  yellow_light: Color(0xFF676000),
  onYellowLight: Color(0xFFFFFFFF),
  yellowLightContainer: Color(0xFFF2E66A),
  onYellowLightContainer: Color(0xFF1F1C00),
  sourceOrange: Color(0xFFE26713),
  orange: Color(0xFF9E4300),
  onOrange: Color(0xFFFFFFFF),
  orangeContainer: Color(0xFFFFDBCB),
  onOrangeContainer: Color(0xFF341100),
  sourceGreen: Color(0xFF1FCC26),
  green: Color(0xFF006E09),
  onGreen: Color(0xFFFFFFFF),
  greenContainer: Color(0xFF75FF67),
  onGreenContainer: Color(0xFF002201),
  sourceYellow: Color(0xFFFFB800),
  yellow: Color(0xFF7C5800),
  onYellow: Color(0xFFFFFFFF),
  yellowContainer: Color(0xFFFFDEA8),
  onYellowContainer: Color(0xFF271900),
  sourceGreenRadium: Color(0xFF228B22),
  green_radium: Color(0xFF006E0C),
  onGreenRadium: Color(0xFFFFFFFF),
  greenRadiumContainer: Color(0xFF92FA83),
  onGreenRadiumContainer: Color(0xFF002201),
  sourceBlue: Color(0xFF0267C1),
  blue: Color(0xFF005EB2),
  onBlue: Color(0xFFFFFFFF),
  blueContainer: Color(0xFFD5E3FF),
  onBlueContainer: Color(0xFF001B3B),
  sourceBlueCall: Color(0xFF267CBE),
  blue_call: Color(0xFF00629E),
  onBlueCall: Color(0xFFFFFFFF),
  blueCallContainer: Color(0xFFCFE5FF),
  onBlueCallContainer: Color(0xFF001D34),
  sourceViolet: Color(0xFF322A7F),
  violet: Color(0xFF5A53A9),
  onViolet: Color(0xFFFFFFFF),
  violetContainer: Color(0xFFE3DFFF),
  onVioletContainer: Color(0xFF140364),
  sourceTextRefer: Color(0xFF304D48),
  text_refer: Color(0xFF006B60),
  onTextRefer: Color(0xFFFFFFFF),
  textReferContainer: Color(0xFF74F8E5),
  onTextReferContainer: Color(0xFF00201C),
);

CustomColors darkCustomColors = const CustomColors(
  sourceStatusPending: Color(0xFF7BAAB7),
  status_pending: Color(0xFF55D6F3),
  onStatusPending: Color(0xFF003640),
  statusPendingContainer: Color(0xFF004E5C),
  onStatusPendingContainer: Color(0xFFABEDFF),
  sourceStatusInprogress: Color(0xFF68838A),
  status_inprogress: Color(0xFF53D7F1),
  onStatusInprogress: Color(0xFF00363F),
  statusInprogressContainer: Color(0xFF004E5B),
  onStatusInprogressContainer: Color(0xFFA7EEFF),
  sourceStatusCompleted: Color(0xFF508E7F),
  status_completed: Color(0xFF5ADBC0),
  onStatusCompleted: Color(0xFF00382E),
  statusCompletedContainer: Color(0xFF005144),
  onStatusCompletedContainer: Color(0xFF79F8DB),
  sourceGrayTextfield: Color(0xFFE5E5E5),
  gray_textfield: Color(0xFF4FD8EB),
  onGrayTextfield: Color(0xFF00363D),
  grayTextfieldContainer: Color(0xFF004F58),
  onGrayTextfieldContainer: Color(0xFF97F0FF),
  sourceLightGrayBackground: Color(0xFFFAFAFA),
  light_gray_background: Color(0xFF4FD8EB),
  onLightGrayBackground: Color(0xFF00363D),
  lightGrayBackgroundContainer: Color(0xFF004F58),
  onLightGrayBackgroundContainer: Color(0xFF97F0FF),
  sourceDarkGrayJcpageAckground: Color(0xFFEDEDED),
  dark_gray_jcpage_ackground: Color(0xFF4FD8EB),
  onDarkGrayJcpageAckground: Color(0xFF00363D),
  darkGrayJcpageAckgroundContainer: Color(0xFF004F58),
  onDarkGrayJcpageAckgroundContainer: Color(0xFF97F0FF),
  sourceLightBlueJcdetails: Color(0xFFD3D6DD),
  light_blue_jcdetails: Color(0xFF9BCBFF),
  onLightBlueJcdetails: Color(0xFF003256),
  lightBlueJcdetailsContainer: Color(0xFF004A79),
  onLightBlueJcdetailsContainer: Color(0xFFD0E4FF),
  sourceText: Color(0xFF272425),
  text: Color(0xFFFFAEDB),
  onText: Color(0xFF5A1144),
  textContainer: Color(0xFF762A5C),
  onTextContainer: Color(0xFFFFD8EB),
  sourceTextSubtitle: Color(0xFF6F6F6F),
  text_subtitle: Color(0xFF4FD8EB),
  onTextSubtitle: Color(0xFF00363D),
  textSubtitleContainer: Color(0xFF004F58),
  onTextSubtitleContainer: Color(0xFF97F0FF),
  sourceLight: Color(0xFFFFFFFF),
  light: Color(0xFF4FD8EB),
  onLight: Color(0xFF00363D),
  lightContainer: Color(0xFF004F58),
  onLightContainer: Color(0xFF97F0FF),
  sourcePrimary: Color(0xFF2F3B63),
  primary: Color(0xFFB5C4FF),
  onPrimary: Color(0xFF052978),
  primaryContainer: Color(0xFF264190),
  onPrimaryContainer: Color(0xFFDCE1FF),
  sourceSecondaryappbar: Color(0xFF212B4F),
  secondaryappbar: Color(0xFFB6C4FF),
  onSecondaryappbar: Color(0xFF092978),
  secondaryappbarContainer: Color(0xFF284190),
  onSecondaryappbarContainer: Color(0xFFDCE1FF),
  sourceTertiary: Color(0xFF578990),
  tertiary: Color(0xFF4ED8E9),
  onTertiary: Color(0xFF00363C),
  tertiaryContainer: Color(0xFF004F56),
  onTertiaryContainer: Color(0xFF8FF2FF),
  sourceTextButtonTertiary: Color(0xFF666666),
  text_button_tertiary: Color(0xFF4FD8EB),
  onTextButtonTertiary: Color(0xFF00363D),
  textButtonTertiaryContainer: Color(0xFF004F58),
  onTextButtonTertiaryContainer: Color(0xFF97F0FF),
  sourceGradbuttonTertiaryStart: Color(0xFFEDEDED),
  gradbutton_tertiary_start: Color(0xFF4FD8EB),
  onGradbuttonTertiaryStart: Color(0xFF00363D),
  gradbuttonTertiaryStartContainer: Color(0xFF004F58),
  onGradbuttonTertiaryStartContainer: Color(0xFF97F0FF),
  sourceGradbuttonTertiaryEnd: Color(0xFFF3F3F3),
  gradbutton_tertiary_end: Color(0xFF4FD8EB),
  onGradbuttonTertiaryEnd: Color(0xFF00363D),
  gradbuttonTertiaryEndContainer: Color(0xFF004F58),
  onGradbuttonTertiaryEndContainer: Color(0xFF97F0FF),
  sourceTransparent: Color(0xFF000000),
  transparent: Color(0xFFFFB1C8),
  onTransparent: Color(0xFF5E1133),
  transparentContainer: Color(0xFF7B2949),
  onTransparentContainer: Color(0xFFFFD9E2),
  sourceGreenMild: Color(0xFFB1D8B7),
  green_mild: Color(0xFF7FD999),
  onGreenMild: Color(0xFF00391A),
  greenMildContainer: Color(0xFF005229),
  onGreenMildContainer: Color(0xFF9BF6B3),
  sourceGreenLight: Color(0xFFDDE4E3),
  green_light: Color(0xFF4DDAD8),
  onGreenLight: Color(0xFF003736),
  greenLightContainer: Color(0xFF00504F),
  onGreenLightContainer: Color(0xFF6FF7F5),
  sourceYellowLight: Color(0xFFFFF59D),
  yellow_light: Color(0xFFD5C951),
  onYellowLight: Color(0xFF363100),
  yellowLightContainer: Color(0xFF4E4800),
  onYellowLightContainer: Color(0xFFF2E66A),
  sourceOrange: Color(0xFFE26713),
  orange: Color(0xFFFFB691),
  onOrange: Color(0xFF552100),
  orangeContainer: Color(0xFF783100),
  onOrangeContainer: Color(0xFFFFDBCB),
  sourceGreen: Color(0xFF1FCC26),
  green: Color(0xFF42E33E),
  onGreen: Color(0xFF003A02),
  greenContainer: Color(0xFF005305),
  onGreenContainer: Color(0xFF75FF67),
  sourceYellow: Color(0xFFFFB800),
  yellow: Color(0xFFFFBA20),
  onYellow: Color(0xFF412D00),
  yellowContainer: Color(0xFF5E4200),
  onYellowContainer: Color(0xFFFFDEA8),
  sourceGreenRadium: Color(0xFF228B22),
  green_radium: Color(0xFF77DD6A),
  onGreenRadium: Color(0xFF003A03),
  greenRadiumContainer: Color(0xFF005307),
  onGreenRadiumContainer: Color(0xFF92FA83),
  sourceBlue: Color(0xFF0267C1),
  blue: Color(0xFFA7C8FF),
  onBlue: Color(0xFF003060),
  blueContainer: Color(0xFF004788),
  onBlueContainer: Color(0xFFD5E3FF),
  sourceBlueCall: Color(0xFF267CBE),
  blue_call: Color(0xFF9ACBFF),
  onBlueCall: Color(0xFF003355),
  blueCallContainer: Color(0xFF004A78),
  onBlueCallContainer: Color(0xFFCFE5FF),
  sourceViolet: Color(0xFF322A7F),
  violet: Color(0xFFC5C0FF),
  onViolet: Color(0xFF2B2278),
  violetContainer: Color(0xFF423B8F),
  onVioletContainer: Color(0xFFE3DFFF),
  sourceTextRefer: Color(0xFF304D48),
  text_refer: Color(0xFF54DBC9),
  onTextRefer: Color(0xFF003731),
  textReferContainer: Color(0xFF005048),
  onTextReferContainer: Color(0xFF74F8E5),
);

/// Defines a set of custom colors, each comprised of 4 complementary tones.
///
/// See also:
///   * <https://m3.material.io/styles/color/the-color-system/custom-colors>
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.sourceStatusPending,
    required this.status_pending,
    required this.onStatusPending,
    required this.statusPendingContainer,
    required this.onStatusPendingContainer,
    required this.sourceStatusInprogress,
    required this.status_inprogress,
    required this.onStatusInprogress,
    required this.statusInprogressContainer,
    required this.onStatusInprogressContainer,
    required this.sourceStatusCompleted,
    required this.status_completed,
    required this.onStatusCompleted,
    required this.statusCompletedContainer,
    required this.onStatusCompletedContainer,
    required this.sourceGrayTextfield,
    required this.gray_textfield,
    required this.onGrayTextfield,
    required this.grayTextfieldContainer,
    required this.onGrayTextfieldContainer,
    required this.sourceLightGrayBackground,
    required this.light_gray_background,
    required this.onLightGrayBackground,
    required this.lightGrayBackgroundContainer,
    required this.onLightGrayBackgroundContainer,
    required this.sourceDarkGrayJcpageAckground,
    required this.dark_gray_jcpage_ackground,
    required this.onDarkGrayJcpageAckground,
    required this.darkGrayJcpageAckgroundContainer,
    required this.onDarkGrayJcpageAckgroundContainer,
    required this.sourceLightBlueJcdetails,
    required this.light_blue_jcdetails,
    required this.onLightBlueJcdetails,
    required this.lightBlueJcdetailsContainer,
    required this.onLightBlueJcdetailsContainer,
    required this.sourceText,
    required this.text,
    required this.onText,
    required this.textContainer,
    required this.onTextContainer,
    required this.sourceTextSubtitle,
    required this.text_subtitle,
    required this.onTextSubtitle,
    required this.textSubtitleContainer,
    required this.onTextSubtitleContainer,
    required this.sourceLight,
    required this.light,
    required this.onLight,
    required this.lightContainer,
    required this.onLightContainer,
    required this.sourcePrimary,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.sourceSecondaryappbar,
    required this.secondaryappbar,
    required this.onSecondaryappbar,
    required this.secondaryappbarContainer,
    required this.onSecondaryappbarContainer,
    required this.sourceTertiary,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.sourceTextButtonTertiary,
    required this.text_button_tertiary,
    required this.onTextButtonTertiary,
    required this.textButtonTertiaryContainer,
    required this.onTextButtonTertiaryContainer,
    required this.sourceGradbuttonTertiaryStart,
    required this.gradbutton_tertiary_start,
    required this.onGradbuttonTertiaryStart,
    required this.gradbuttonTertiaryStartContainer,
    required this.onGradbuttonTertiaryStartContainer,
    required this.sourceGradbuttonTertiaryEnd,
    required this.gradbutton_tertiary_end,
    required this.onGradbuttonTertiaryEnd,
    required this.gradbuttonTertiaryEndContainer,
    required this.onGradbuttonTertiaryEndContainer,
    required this.sourceTransparent,
    required this.transparent,
    required this.onTransparent,
    required this.transparentContainer,
    required this.onTransparentContainer,
    required this.sourceGreenMild,
    required this.green_mild,
    required this.onGreenMild,
    required this.greenMildContainer,
    required this.onGreenMildContainer,
    required this.sourceGreenLight,
    required this.green_light,
    required this.onGreenLight,
    required this.greenLightContainer,
    required this.onGreenLightContainer,
    required this.sourceYellowLight,
    required this.yellow_light,
    required this.onYellowLight,
    required this.yellowLightContainer,
    required this.onYellowLightContainer,
    required this.sourceOrange,
    required this.orange,
    required this.onOrange,
    required this.orangeContainer,
    required this.onOrangeContainer,
    required this.sourceGreen,
    required this.green,
    required this.onGreen,
    required this.greenContainer,
    required this.onGreenContainer,
    required this.sourceYellow,
    required this.yellow,
    required this.onYellow,
    required this.yellowContainer,
    required this.onYellowContainer,
    required this.sourceGreenRadium,
    required this.green_radium,
    required this.onGreenRadium,
    required this.greenRadiumContainer,
    required this.onGreenRadiumContainer,
    required this.sourceBlue,
    required this.blue,
    required this.onBlue,
    required this.blueContainer,
    required this.onBlueContainer,
    required this.sourceBlueCall,
    required this.blue_call,
    required this.onBlueCall,
    required this.blueCallContainer,
    required this.onBlueCallContainer,
    required this.sourceViolet,
    required this.violet,
    required this.onViolet,
    required this.violetContainer,
    required this.onVioletContainer,
    required this.sourceTextRefer,
    required this.text_refer,
    required this.onTextRefer,
    required this.textReferContainer,
    required this.onTextReferContainer,
  });

  final Color? sourceStatusPending;
  final Color? status_pending;
  final Color? onStatusPending;
  final Color? statusPendingContainer;
  final Color? onStatusPendingContainer;
  final Color? sourceStatusInprogress;
  final Color? status_inprogress;
  final Color? onStatusInprogress;
  final Color? statusInprogressContainer;
  final Color? onStatusInprogressContainer;
  final Color? sourceStatusCompleted;
  final Color? status_completed;
  final Color? onStatusCompleted;
  final Color? statusCompletedContainer;
  final Color? onStatusCompletedContainer;
  final Color? sourceGrayTextfield;
  final Color? gray_textfield;
  final Color? onGrayTextfield;
  final Color? grayTextfieldContainer;
  final Color? onGrayTextfieldContainer;
  final Color? sourceLightGrayBackground;
  final Color? light_gray_background;
  final Color? onLightGrayBackground;
  final Color? lightGrayBackgroundContainer;
  final Color? onLightGrayBackgroundContainer;
  final Color? sourceDarkGrayJcpageAckground;
  final Color? dark_gray_jcpage_ackground;
  final Color? onDarkGrayJcpageAckground;
  final Color? darkGrayJcpageAckgroundContainer;
  final Color? onDarkGrayJcpageAckgroundContainer;
  final Color? sourceLightBlueJcdetails;
  final Color? light_blue_jcdetails;
  final Color? onLightBlueJcdetails;
  final Color? lightBlueJcdetailsContainer;
  final Color? onLightBlueJcdetailsContainer;
  final Color? sourceText;
  final Color? text;
  final Color? onText;
  final Color? textContainer;
  final Color? onTextContainer;
  final Color? sourceTextSubtitle;
  final Color? text_subtitle;
  final Color? onTextSubtitle;
  final Color? textSubtitleContainer;
  final Color? onTextSubtitleContainer;
  final Color? sourceLight;
  final Color? light;
  final Color? onLight;
  final Color? lightContainer;
  final Color? onLightContainer;
  final Color? sourcePrimary;
  final Color? primary;
  final Color? onPrimary;
  final Color? primaryContainer;
  final Color? onPrimaryContainer;
  final Color? sourceSecondaryappbar;
  final Color? secondaryappbar;
  final Color? onSecondaryappbar;
  final Color? secondaryappbarContainer;
  final Color? onSecondaryappbarContainer;
  final Color? sourceTertiary;
  final Color? tertiary;
  final Color? onTertiary;
  final Color? tertiaryContainer;
  final Color? onTertiaryContainer;
  final Color? sourceTextButtonTertiary;
  final Color? text_button_tertiary;
  final Color? onTextButtonTertiary;
  final Color? textButtonTertiaryContainer;
  final Color? onTextButtonTertiaryContainer;
  final Color? sourceGradbuttonTertiaryStart;
  final Color? gradbutton_tertiary_start;
  final Color? onGradbuttonTertiaryStart;
  final Color? gradbuttonTertiaryStartContainer;
  final Color? onGradbuttonTertiaryStartContainer;
  final Color? sourceGradbuttonTertiaryEnd;
  final Color? gradbutton_tertiary_end;
  final Color? onGradbuttonTertiaryEnd;
  final Color? gradbuttonTertiaryEndContainer;
  final Color? onGradbuttonTertiaryEndContainer;
  final Color? sourceTransparent;
  final Color? transparent;
  final Color? onTransparent;
  final Color? transparentContainer;
  final Color? onTransparentContainer;
  final Color? sourceGreenMild;
  final Color? green_mild;
  final Color? onGreenMild;
  final Color? greenMildContainer;
  final Color? onGreenMildContainer;
  final Color? sourceGreenLight;
  final Color? green_light;
  final Color? onGreenLight;
  final Color? greenLightContainer;
  final Color? onGreenLightContainer;
  final Color? sourceYellowLight;
  final Color? yellow_light;
  final Color? onYellowLight;
  final Color? yellowLightContainer;
  final Color? onYellowLightContainer;
  final Color? sourceOrange;
  final Color? orange;
  final Color? onOrange;
  final Color? orangeContainer;
  final Color? onOrangeContainer;
  final Color? sourceGreen;
  final Color? green;
  final Color? onGreen;
  final Color? greenContainer;
  final Color? onGreenContainer;
  final Color? sourceYellow;
  final Color? yellow;
  final Color? onYellow;
  final Color? yellowContainer;
  final Color? onYellowContainer;
  final Color? sourceGreenRadium;
  final Color? green_radium;
  final Color? onGreenRadium;
  final Color? greenRadiumContainer;
  final Color? onGreenRadiumContainer;
  final Color? sourceBlue;
  final Color? blue;
  final Color? onBlue;
  final Color? blueContainer;
  final Color? onBlueContainer;
  final Color? sourceBlueCall;
  final Color? blue_call;
  final Color? onBlueCall;
  final Color? blueCallContainer;
  final Color? onBlueCallContainer;
  final Color? sourceViolet;
  final Color? violet;
  final Color? onViolet;
  final Color? violetContainer;
  final Color? onVioletContainer;
  final Color? sourceTextRefer;
  final Color? text_refer;
  final Color? onTextRefer;
  final Color? textReferContainer;
  final Color? onTextReferContainer;

  @override
  CustomColors copyWith({
    Color? sourceStatusPending,
    Color? status_pending,
    Color? onStatusPending,
    Color? statusPendingContainer,
    Color? onStatusPendingContainer,
    Color? sourceStatusInprogress,
    Color? status_inprogress,
    Color? onStatusInprogress,
    Color? statusInprogressContainer,
    Color? onStatusInprogressContainer,
    Color? sourceStatusCompleted,
    Color? status_completed,
    Color? onStatusCompleted,
    Color? statusCompletedContainer,
    Color? onStatusCompletedContainer,
    Color? sourceGrayTextfield,
    Color? gray_textfield,
    Color? onGrayTextfield,
    Color? grayTextfieldContainer,
    Color? onGrayTextfieldContainer,
    Color? sourceLightGrayBackground,
    Color? light_gray_background,
    Color? onLightGrayBackground,
    Color? lightGrayBackgroundContainer,
    Color? onLightGrayBackgroundContainer,
    Color? sourceDarkGrayJcpageAckground,
    Color? dark_gray_jcpage_ackground,
    Color? onDarkGrayJcpageAckground,
    Color? darkGrayJcpageAckgroundContainer,
    Color? onDarkGrayJcpageAckgroundContainer,
    Color? sourceLightBlueJcdetails,
    Color? light_blue_jcdetails,
    Color? onLightBlueJcdetails,
    Color? lightBlueJcdetailsContainer,
    Color? onLightBlueJcdetailsContainer,
    Color? sourceText,
    Color? text,
    Color? onText,
    Color? textContainer,
    Color? onTextContainer,
    Color? sourceTextSubtitle,
    Color? text_subtitle,
    Color? onTextSubtitle,
    Color? textSubtitleContainer,
    Color? onTextSubtitleContainer,
    Color? sourceLight,
    Color? light,
    Color? onLight,
    Color? lightContainer,
    Color? onLightContainer,
    Color? sourcePrimary,
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? sourceSecondaryappbar,
    Color? secondaryappbar,
    Color? onSecondaryappbar,
    Color? secondaryappbarContainer,
    Color? onSecondaryappbarContainer,
    Color? sourceTertiary,
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    Color? sourceTextButtonTertiary,
    Color? text_button_tertiary,
    Color? onTextButtonTertiary,
    Color? textButtonTertiaryContainer,
    Color? onTextButtonTertiaryContainer,
    Color? sourceGradbuttonTertiaryStart,
    Color? gradbutton_tertiary_start,
    Color? onGradbuttonTertiaryStart,
    Color? gradbuttonTertiaryStartContainer,
    Color? onGradbuttonTertiaryStartContainer,
    Color? sourceGradbuttonTertiaryEnd,
    Color? gradbutton_tertiary_end,
    Color? onGradbuttonTertiaryEnd,
    Color? gradbuttonTertiaryEndContainer,
    Color? onGradbuttonTertiaryEndContainer,
    Color? sourceTransparent,
    Color? transparent,
    Color? onTransparent,
    Color? transparentContainer,
    Color? onTransparentContainer,
    Color? sourceGreenMild,
    Color? green_mild,
    Color? onGreenMild,
    Color? greenMildContainer,
    Color? onGreenMildContainer,
    Color? sourceGreenLight,
    Color? green_light,
    Color? onGreenLight,
    Color? greenLightContainer,
    Color? onGreenLightContainer,
    Color? sourceYellowLight,
    Color? yellow_light,
    Color? onYellowLight,
    Color? yellowLightContainer,
    Color? onYellowLightContainer,
    Color? sourceOrange,
    Color? orange,
    Color? onOrange,
    Color? orangeContainer,
    Color? onOrangeContainer,
    Color? sourceGreen,
    Color? green,
    Color? onGreen,
    Color? greenContainer,
    Color? onGreenContainer,
    Color? sourceYellow,
    Color? yellow,
    Color? onYellow,
    Color? yellowContainer,
    Color? onYellowContainer,
    Color? sourceGreenRadium,
    Color? green_radium,
    Color? onGreenRadium,
    Color? greenRadiumContainer,
    Color? onGreenRadiumContainer,
    Color? sourceBlue,
    Color? blue,
    Color? onBlue,
    Color? blueContainer,
    Color? onBlueContainer,
    Color? sourceBlueCall,
    Color? blue_call,
    Color? onBlueCall,
    Color? blueCallContainer,
    Color? onBlueCallContainer,
    Color? sourceViolet,
    Color? violet,
    Color? onViolet,
    Color? violetContainer,
    Color? onVioletContainer,
    Color? sourceTextRefer,
    Color? text_refer,
    Color? onTextRefer,
    Color? textReferContainer,
    Color? onTextReferContainer,
  }) {
    return CustomColors(
      sourceStatusPending: sourceStatusPending ?? this.sourceStatusPending,
      status_pending: status_pending ?? this.status_pending,
      onStatusPending: onStatusPending ?? this.onStatusPending,
      statusPendingContainer:
          statusPendingContainer ?? this.statusPendingContainer,
      onStatusPendingContainer:
          onStatusPendingContainer ?? this.onStatusPendingContainer,
      sourceStatusInprogress:
          sourceStatusInprogress ?? this.sourceStatusInprogress,
      status_inprogress: status_inprogress ?? this.status_inprogress,
      onStatusInprogress: onStatusInprogress ?? this.onStatusInprogress,
      statusInprogressContainer:
          statusInprogressContainer ?? this.statusInprogressContainer,
      onStatusInprogressContainer:
          onStatusInprogressContainer ?? this.onStatusInprogressContainer,
      sourceStatusCompleted:
          sourceStatusCompleted ?? this.sourceStatusCompleted,
      status_completed: status_completed ?? this.status_completed,
      onStatusCompleted: onStatusCompleted ?? this.onStatusCompleted,
      statusCompletedContainer:
          statusCompletedContainer ?? this.statusCompletedContainer,
      onStatusCompletedContainer:
          onStatusCompletedContainer ?? this.onStatusCompletedContainer,
      sourceGrayTextfield: sourceGrayTextfield ?? this.sourceGrayTextfield,
      gray_textfield: gray_textfield ?? this.gray_textfield,
      onGrayTextfield: onGrayTextfield ?? this.onGrayTextfield,
      grayTextfieldContainer:
          grayTextfieldContainer ?? this.grayTextfieldContainer,
      onGrayTextfieldContainer:
          onGrayTextfieldContainer ?? this.onGrayTextfieldContainer,
      sourceLightGrayBackground:
          sourceLightGrayBackground ?? this.sourceLightGrayBackground,
      light_gray_background:
          light_gray_background ?? this.light_gray_background,
      onLightGrayBackground:
          onLightGrayBackground ?? this.onLightGrayBackground,
      lightGrayBackgroundContainer:
          lightGrayBackgroundContainer ?? this.lightGrayBackgroundContainer,
      onLightGrayBackgroundContainer:
          onLightGrayBackgroundContainer ?? this.onLightGrayBackgroundContainer,
      sourceDarkGrayJcpageAckground:
          sourceDarkGrayJcpageAckground ?? this.sourceDarkGrayJcpageAckground,
      dark_gray_jcpage_ackground:
          dark_gray_jcpage_ackground ?? this.dark_gray_jcpage_ackground,
      onDarkGrayJcpageAckground:
          onDarkGrayJcpageAckground ?? this.onDarkGrayJcpageAckground,
      darkGrayJcpageAckgroundContainer: darkGrayJcpageAckgroundContainer ??
          this.darkGrayJcpageAckgroundContainer,
      onDarkGrayJcpageAckgroundContainer: onDarkGrayJcpageAckgroundContainer ??
          this.onDarkGrayJcpageAckgroundContainer,
      sourceLightBlueJcdetails:
          sourceLightBlueJcdetails ?? this.sourceLightBlueJcdetails,
      light_blue_jcdetails: light_blue_jcdetails ?? this.light_blue_jcdetails,
      onLightBlueJcdetails: onLightBlueJcdetails ?? this.onLightBlueJcdetails,
      lightBlueJcdetailsContainer:
          lightBlueJcdetailsContainer ?? this.lightBlueJcdetailsContainer,
      onLightBlueJcdetailsContainer:
          onLightBlueJcdetailsContainer ?? this.onLightBlueJcdetailsContainer,
      sourceText: sourceText ?? this.sourceText,
      text: text ?? this.text,
      onText: onText ?? this.onText,
      textContainer: textContainer ?? this.textContainer,
      onTextContainer: onTextContainer ?? this.onTextContainer,
      sourceTextSubtitle: sourceTextSubtitle ?? this.sourceTextSubtitle,
      text_subtitle: text_subtitle ?? this.text_subtitle,
      onTextSubtitle: onTextSubtitle ?? this.onTextSubtitle,
      textSubtitleContainer:
          textSubtitleContainer ?? this.textSubtitleContainer,
      onTextSubtitleContainer:
          onTextSubtitleContainer ?? this.onTextSubtitleContainer,
      sourceLight: sourceLight ?? this.sourceLight,
      light: light ?? this.light,
      onLight: onLight ?? this.onLight,
      lightContainer: lightContainer ?? this.lightContainer,
      onLightContainer: onLightContainer ?? this.onLightContainer,
      sourcePrimary: sourcePrimary ?? this.sourcePrimary,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      sourceSecondaryappbar:
          sourceSecondaryappbar ?? this.sourceSecondaryappbar,
      secondaryappbar: secondaryappbar ?? this.secondaryappbar,
      onSecondaryappbar: onSecondaryappbar ?? this.onSecondaryappbar,
      secondaryappbarContainer:
          secondaryappbarContainer ?? this.secondaryappbarContainer,
      onSecondaryappbarContainer:
          onSecondaryappbarContainer ?? this.onSecondaryappbarContainer,
      sourceTertiary: sourceTertiary ?? this.sourceTertiary,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
      sourceTextButtonTertiary:
          sourceTextButtonTertiary ?? this.sourceTextButtonTertiary,
      text_button_tertiary: text_button_tertiary ?? this.text_button_tertiary,
      onTextButtonTertiary: onTextButtonTertiary ?? this.onTextButtonTertiary,
      textButtonTertiaryContainer:
          textButtonTertiaryContainer ?? this.textButtonTertiaryContainer,
      onTextButtonTertiaryContainer:
          onTextButtonTertiaryContainer ?? this.onTextButtonTertiaryContainer,
      sourceGradbuttonTertiaryStart:
          sourceGradbuttonTertiaryStart ?? this.sourceGradbuttonTertiaryStart,
      gradbutton_tertiary_start:
          gradbutton_tertiary_start ?? this.gradbutton_tertiary_start,
      onGradbuttonTertiaryStart:
          onGradbuttonTertiaryStart ?? this.onGradbuttonTertiaryStart,
      gradbuttonTertiaryStartContainer: gradbuttonTertiaryStartContainer ??
          this.gradbuttonTertiaryStartContainer,
      onGradbuttonTertiaryStartContainer: onGradbuttonTertiaryStartContainer ??
          this.onGradbuttonTertiaryStartContainer,
      sourceGradbuttonTertiaryEnd:
          sourceGradbuttonTertiaryEnd ?? this.sourceGradbuttonTertiaryEnd,
      gradbutton_tertiary_end:
          gradbutton_tertiary_end ?? this.gradbutton_tertiary_end,
      onGradbuttonTertiaryEnd:
          onGradbuttonTertiaryEnd ?? this.onGradbuttonTertiaryEnd,
      gradbuttonTertiaryEndContainer:
          gradbuttonTertiaryEndContainer ?? this.gradbuttonTertiaryEndContainer,
      onGradbuttonTertiaryEndContainer: onGradbuttonTertiaryEndContainer ??
          this.onGradbuttonTertiaryEndContainer,
      sourceTransparent: sourceTransparent ?? this.sourceTransparent,
      transparent: transparent ?? this.transparent,
      onTransparent: onTransparent ?? this.onTransparent,
      transparentContainer: transparentContainer ?? this.transparentContainer,
      onTransparentContainer:
          onTransparentContainer ?? this.onTransparentContainer,
      sourceGreenMild: sourceGreenMild ?? this.sourceGreenMild,
      green_mild: green_mild ?? this.green_mild,
      onGreenMild: onGreenMild ?? this.onGreenMild,
      greenMildContainer: greenMildContainer ?? this.greenMildContainer,
      onGreenMildContainer: onGreenMildContainer ?? this.onGreenMildContainer,
      sourceGreenLight: sourceGreenLight ?? this.sourceGreenLight,
      green_light: green_light ?? this.green_light,
      onGreenLight: onGreenLight ?? this.onGreenLight,
      greenLightContainer: greenLightContainer ?? this.greenLightContainer,
      onGreenLightContainer:
          onGreenLightContainer ?? this.onGreenLightContainer,
      sourceYellowLight: sourceYellowLight ?? this.sourceYellowLight,
      yellow_light: yellow_light ?? this.yellow_light,
      onYellowLight: onYellowLight ?? this.onYellowLight,
      yellowLightContainer: yellowLightContainer ?? this.yellowLightContainer,
      onYellowLightContainer:
          onYellowLightContainer ?? this.onYellowLightContainer,
      sourceOrange: sourceOrange ?? this.sourceOrange,
      orange: orange ?? this.orange,
      onOrange: onOrange ?? this.onOrange,
      orangeContainer: orangeContainer ?? this.orangeContainer,
      onOrangeContainer: onOrangeContainer ?? this.onOrangeContainer,
      sourceGreen: sourceGreen ?? this.sourceGreen,
      green: green ?? this.green,
      onGreen: onGreen ?? this.onGreen,
      greenContainer: greenContainer ?? this.greenContainer,
      onGreenContainer: onGreenContainer ?? this.onGreenContainer,
      sourceYellow: sourceYellow ?? this.sourceYellow,
      yellow: yellow ?? this.yellow,
      onYellow: onYellow ?? this.onYellow,
      yellowContainer: yellowContainer ?? this.yellowContainer,
      onYellowContainer: onYellowContainer ?? this.onYellowContainer,
      sourceGreenRadium: sourceGreenRadium ?? this.sourceGreenRadium,
      green_radium: green_radium ?? this.green_radium,
      onGreenRadium: onGreenRadium ?? this.onGreenRadium,
      greenRadiumContainer: greenRadiumContainer ?? this.greenRadiumContainer,
      onGreenRadiumContainer:
          onGreenRadiumContainer ?? this.onGreenRadiumContainer,
      sourceBlue: sourceBlue ?? this.sourceBlue,
      blue: blue ?? this.blue,
      onBlue: onBlue ?? this.onBlue,
      blueContainer: blueContainer ?? this.blueContainer,
      onBlueContainer: onBlueContainer ?? this.onBlueContainer,
      sourceBlueCall: sourceBlueCall ?? this.sourceBlueCall,
      blue_call: blue_call ?? this.blue_call,
      onBlueCall: onBlueCall ?? this.onBlueCall,
      blueCallContainer: blueCallContainer ?? this.blueCallContainer,
      onBlueCallContainer: onBlueCallContainer ?? this.onBlueCallContainer,
      sourceViolet: sourceViolet ?? this.sourceViolet,
      violet: violet ?? this.violet,
      onViolet: onViolet ?? this.onViolet,
      violetContainer: violetContainer ?? this.violetContainer,
      onVioletContainer: onVioletContainer ?? this.onVioletContainer,
      sourceTextRefer: sourceTextRefer ?? this.sourceTextRefer,
      text_refer: text_refer ?? this.text_refer,
      onTextRefer: onTextRefer ?? this.onTextRefer,
      textReferContainer: textReferContainer ?? this.textReferContainer,
      onTextReferContainer: onTextReferContainer ?? this.onTextReferContainer,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      sourceStatusPending:
          Color.lerp(sourceStatusPending, other.sourceStatusPending, t),
      status_pending: Color.lerp(status_pending, other.status_pending, t),
      onStatusPending: Color.lerp(onStatusPending, other.onStatusPending, t),
      statusPendingContainer:
          Color.lerp(statusPendingContainer, other.statusPendingContainer, t),
      onStatusPendingContainer: Color.lerp(
          onStatusPendingContainer, other.onStatusPendingContainer, t),
      sourceStatusInprogress:
          Color.lerp(sourceStatusInprogress, other.sourceStatusInprogress, t),
      status_inprogress:
          Color.lerp(status_inprogress, other.status_inprogress, t),
      onStatusInprogress:
          Color.lerp(onStatusInprogress, other.onStatusInprogress, t),
      statusInprogressContainer: Color.lerp(
          statusInprogressContainer, other.statusInprogressContainer, t),
      onStatusInprogressContainer: Color.lerp(
          onStatusInprogressContainer, other.onStatusInprogressContainer, t),
      sourceStatusCompleted:
          Color.lerp(sourceStatusCompleted, other.sourceStatusCompleted, t),
      status_completed: Color.lerp(status_completed, other.status_completed, t),
      onStatusCompleted:
          Color.lerp(onStatusCompleted, other.onStatusCompleted, t),
      statusCompletedContainer: Color.lerp(
          statusCompletedContainer, other.statusCompletedContainer, t),
      onStatusCompletedContainer: Color.lerp(
          onStatusCompletedContainer, other.onStatusCompletedContainer, t),
      sourceGrayTextfield:
          Color.lerp(sourceGrayTextfield, other.sourceGrayTextfield, t),
      gray_textfield: Color.lerp(gray_textfield, other.gray_textfield, t),
      onGrayTextfield: Color.lerp(onGrayTextfield, other.onGrayTextfield, t),
      grayTextfieldContainer:
          Color.lerp(grayTextfieldContainer, other.grayTextfieldContainer, t),
      onGrayTextfieldContainer: Color.lerp(
          onGrayTextfieldContainer, other.onGrayTextfieldContainer, t),
      sourceLightGrayBackground: Color.lerp(
          sourceLightGrayBackground, other.sourceLightGrayBackground, t),
      light_gray_background:
          Color.lerp(light_gray_background, other.light_gray_background, t),
      onLightGrayBackground:
          Color.lerp(onLightGrayBackground, other.onLightGrayBackground, t),
      lightGrayBackgroundContainer: Color.lerp(
          lightGrayBackgroundContainer, other.lightGrayBackgroundContainer, t),
      onLightGrayBackgroundContainer: Color.lerp(onLightGrayBackgroundContainer,
          other.onLightGrayBackgroundContainer, t),
      sourceDarkGrayJcpageAckground: Color.lerp(sourceDarkGrayJcpageAckground,
          other.sourceDarkGrayJcpageAckground, t),
      dark_gray_jcpage_ackground: Color.lerp(
          dark_gray_jcpage_ackground, other.dark_gray_jcpage_ackground, t),
      onDarkGrayJcpageAckground: Color.lerp(
          onDarkGrayJcpageAckground, other.onDarkGrayJcpageAckground, t),
      darkGrayJcpageAckgroundContainer: Color.lerp(
          darkGrayJcpageAckgroundContainer,
          other.darkGrayJcpageAckgroundContainer,
          t),
      onDarkGrayJcpageAckgroundContainer: Color.lerp(
          onDarkGrayJcpageAckgroundContainer,
          other.onDarkGrayJcpageAckgroundContainer,
          t),
      sourceLightBlueJcdetails: Color.lerp(
          sourceLightBlueJcdetails, other.sourceLightBlueJcdetails, t),
      light_blue_jcdetails:
          Color.lerp(light_blue_jcdetails, other.light_blue_jcdetails, t),
      onLightBlueJcdetails:
          Color.lerp(onLightBlueJcdetails, other.onLightBlueJcdetails, t),
      lightBlueJcdetailsContainer: Color.lerp(
          lightBlueJcdetailsContainer, other.lightBlueJcdetailsContainer, t),
      onLightBlueJcdetailsContainer: Color.lerp(onLightBlueJcdetailsContainer,
          other.onLightBlueJcdetailsContainer, t),
      sourceText: Color.lerp(sourceText, other.sourceText, t),
      text: Color.lerp(text, other.text, t),
      onText: Color.lerp(onText, other.onText, t),
      textContainer: Color.lerp(textContainer, other.textContainer, t),
      onTextContainer: Color.lerp(onTextContainer, other.onTextContainer, t),
      sourceTextSubtitle:
          Color.lerp(sourceTextSubtitle, other.sourceTextSubtitle, t),
      text_subtitle: Color.lerp(text_subtitle, other.text_subtitle, t),
      onTextSubtitle: Color.lerp(onTextSubtitle, other.onTextSubtitle, t),
      textSubtitleContainer:
          Color.lerp(textSubtitleContainer, other.textSubtitleContainer, t),
      onTextSubtitleContainer:
          Color.lerp(onTextSubtitleContainer, other.onTextSubtitleContainer, t),
      sourceLight: Color.lerp(sourceLight, other.sourceLight, t),
      light: Color.lerp(light, other.light, t),
      onLight: Color.lerp(onLight, other.onLight, t),
      lightContainer: Color.lerp(lightContainer, other.lightContainer, t),
      onLightContainer: Color.lerp(onLightContainer, other.onLightContainer, t),
      sourcePrimary: Color.lerp(sourcePrimary, other.sourcePrimary, t),
      primary: Color.lerp(primary, other.primary, t),
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t),
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t),
      onPrimaryContainer:
          Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t),
      sourceSecondaryappbar:
          Color.lerp(sourceSecondaryappbar, other.sourceSecondaryappbar, t),
      secondaryappbar: Color.lerp(secondaryappbar, other.secondaryappbar, t),
      onSecondaryappbar:
          Color.lerp(onSecondaryappbar, other.onSecondaryappbar, t),
      secondaryappbarContainer: Color.lerp(
          secondaryappbarContainer, other.secondaryappbarContainer, t),
      onSecondaryappbarContainer: Color.lerp(
          onSecondaryappbarContainer, other.onSecondaryappbarContainer, t),
      sourceTertiary: Color.lerp(sourceTertiary, other.sourceTertiary, t),
      tertiary: Color.lerp(tertiary, other.tertiary, t),
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t),
      tertiaryContainer:
          Color.lerp(tertiaryContainer, other.tertiaryContainer, t),
      onTertiaryContainer:
          Color.lerp(onTertiaryContainer, other.onTertiaryContainer, t),
      sourceTextButtonTertiary: Color.lerp(
          sourceTextButtonTertiary, other.sourceTextButtonTertiary, t),
      text_button_tertiary:
          Color.lerp(text_button_tertiary, other.text_button_tertiary, t),
      onTextButtonTertiary:
          Color.lerp(onTextButtonTertiary, other.onTextButtonTertiary, t),
      textButtonTertiaryContainer: Color.lerp(
          textButtonTertiaryContainer, other.textButtonTertiaryContainer, t),
      onTextButtonTertiaryContainer: Color.lerp(onTextButtonTertiaryContainer,
          other.onTextButtonTertiaryContainer, t),
      sourceGradbuttonTertiaryStart: Color.lerp(sourceGradbuttonTertiaryStart,
          other.sourceGradbuttonTertiaryStart, t),
      gradbutton_tertiary_start: Color.lerp(
          gradbutton_tertiary_start, other.gradbutton_tertiary_start, t),
      onGradbuttonTertiaryStart: Color.lerp(
          onGradbuttonTertiaryStart, other.onGradbuttonTertiaryStart, t),
      gradbuttonTertiaryStartContainer: Color.lerp(
          gradbuttonTertiaryStartContainer,
          other.gradbuttonTertiaryStartContainer,
          t),
      onGradbuttonTertiaryStartContainer: Color.lerp(
          onGradbuttonTertiaryStartContainer,
          other.onGradbuttonTertiaryStartContainer,
          t),
      sourceGradbuttonTertiaryEnd: Color.lerp(
          sourceGradbuttonTertiaryEnd, other.sourceGradbuttonTertiaryEnd, t),
      gradbutton_tertiary_end:
          Color.lerp(gradbutton_tertiary_end, other.gradbutton_tertiary_end, t),
      onGradbuttonTertiaryEnd:
          Color.lerp(onGradbuttonTertiaryEnd, other.onGradbuttonTertiaryEnd, t),
      gradbuttonTertiaryEndContainer: Color.lerp(gradbuttonTertiaryEndContainer,
          other.gradbuttonTertiaryEndContainer, t),
      onGradbuttonTertiaryEndContainer: Color.lerp(
          onGradbuttonTertiaryEndContainer,
          other.onGradbuttonTertiaryEndContainer,
          t),
      sourceTransparent:
          Color.lerp(sourceTransparent, other.sourceTransparent, t),
      transparent: Color.lerp(transparent, other.transparent, t),
      onTransparent: Color.lerp(onTransparent, other.onTransparent, t),
      transparentContainer:
          Color.lerp(transparentContainer, other.transparentContainer, t),
      onTransparentContainer:
          Color.lerp(onTransparentContainer, other.onTransparentContainer, t),
      sourceGreenMild: Color.lerp(sourceGreenMild, other.sourceGreenMild, t),
      green_mild: Color.lerp(green_mild, other.green_mild, t),
      onGreenMild: Color.lerp(onGreenMild, other.onGreenMild, t),
      greenMildContainer:
          Color.lerp(greenMildContainer, other.greenMildContainer, t),
      onGreenMildContainer:
          Color.lerp(onGreenMildContainer, other.onGreenMildContainer, t),
      sourceGreenLight: Color.lerp(sourceGreenLight, other.sourceGreenLight, t),
      green_light: Color.lerp(green_light, other.green_light, t),
      onGreenLight: Color.lerp(onGreenLight, other.onGreenLight, t),
      greenLightContainer:
          Color.lerp(greenLightContainer, other.greenLightContainer, t),
      onGreenLightContainer:
          Color.lerp(onGreenLightContainer, other.onGreenLightContainer, t),
      sourceYellowLight:
          Color.lerp(sourceYellowLight, other.sourceYellowLight, t),
      yellow_light: Color.lerp(yellow_light, other.yellow_light, t),
      onYellowLight: Color.lerp(onYellowLight, other.onYellowLight, t),
      yellowLightContainer:
          Color.lerp(yellowLightContainer, other.yellowLightContainer, t),
      onYellowLightContainer:
          Color.lerp(onYellowLightContainer, other.onYellowLightContainer, t),
      sourceOrange: Color.lerp(sourceOrange, other.sourceOrange, t),
      orange: Color.lerp(orange, other.orange, t),
      onOrange: Color.lerp(onOrange, other.onOrange, t),
      orangeContainer: Color.lerp(orangeContainer, other.orangeContainer, t),
      onOrangeContainer:
          Color.lerp(onOrangeContainer, other.onOrangeContainer, t),
      sourceGreen: Color.lerp(sourceGreen, other.sourceGreen, t),
      green: Color.lerp(green, other.green, t),
      onGreen: Color.lerp(onGreen, other.onGreen, t),
      greenContainer: Color.lerp(greenContainer, other.greenContainer, t),
      onGreenContainer: Color.lerp(onGreenContainer, other.onGreenContainer, t),
      sourceYellow: Color.lerp(sourceYellow, other.sourceYellow, t),
      yellow: Color.lerp(yellow, other.yellow, t),
      onYellow: Color.lerp(onYellow, other.onYellow, t),
      yellowContainer: Color.lerp(yellowContainer, other.yellowContainer, t),
      onYellowContainer:
          Color.lerp(onYellowContainer, other.onYellowContainer, t),
      sourceGreenRadium:
          Color.lerp(sourceGreenRadium, other.sourceGreenRadium, t),
      green_radium: Color.lerp(green_radium, other.green_radium, t),
      onGreenRadium: Color.lerp(onGreenRadium, other.onGreenRadium, t),
      greenRadiumContainer:
          Color.lerp(greenRadiumContainer, other.greenRadiumContainer, t),
      onGreenRadiumContainer:
          Color.lerp(onGreenRadiumContainer, other.onGreenRadiumContainer, t),
      sourceBlue: Color.lerp(sourceBlue, other.sourceBlue, t),
      blue: Color.lerp(blue, other.blue, t),
      onBlue: Color.lerp(onBlue, other.onBlue, t),
      blueContainer: Color.lerp(blueContainer, other.blueContainer, t),
      onBlueContainer: Color.lerp(onBlueContainer, other.onBlueContainer, t),
      sourceBlueCall: Color.lerp(sourceBlueCall, other.sourceBlueCall, t),
      blue_call: Color.lerp(blue_call, other.blue_call, t),
      onBlueCall: Color.lerp(onBlueCall, other.onBlueCall, t),
      blueCallContainer:
          Color.lerp(blueCallContainer, other.blueCallContainer, t),
      onBlueCallContainer:
          Color.lerp(onBlueCallContainer, other.onBlueCallContainer, t),
      sourceViolet: Color.lerp(sourceViolet, other.sourceViolet, t),
      violet: Color.lerp(violet, other.violet, t),
      onViolet: Color.lerp(onViolet, other.onViolet, t),
      violetContainer: Color.lerp(violetContainer, other.violetContainer, t),
      onVioletContainer:
          Color.lerp(onVioletContainer, other.onVioletContainer, t),
      sourceTextRefer: Color.lerp(sourceTextRefer, other.sourceTextRefer, t),
      text_refer: Color.lerp(text_refer, other.text_refer, t),
      onTextRefer: Color.lerp(onTextRefer, other.onTextRefer, t),
      textReferContainer:
          Color.lerp(textReferContainer, other.textReferContainer, t),
      onTextReferContainer:
          Color.lerp(onTextReferContainer, other.onTextReferContainer, t),
    );
  }

  /// Returns an instance of [CustomColors] in which the following custom
  /// colors are harmonized with [dynamic]'s [ColorScheme.primary].
  ///
  /// See also:
  ///   * <https://m3.material.io/styles/color/the-color-system/custom-colors#harmonization>
  CustomColors harmonized(ColorScheme dynamic) {
    return copyWith();
  }
}
