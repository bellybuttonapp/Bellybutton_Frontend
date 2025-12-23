// ignore_for_file: avoid_print

import 'dart:io';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../core/utils/storage/preference.dart';

class DeviceInfoModel {
  final String deviceId;
  final String deviceModel;
  final String deviceBrand;
  final String deviceOS;
  final String deviceType;

  DeviceInfoModel({
    required this.deviceId,
    required this.deviceModel,
    required this.deviceBrand,
    required this.deviceOS,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'deviceModel': deviceModel,
        'deviceBrand': deviceBrand,
        'deviceOS': deviceOS,
        'deviceType': deviceType,
      };
}

class DeviceController extends GetxController {
  String _androidID = '';
  String _deviceModel = '';
  String _deviceBrand = '';
  String _deviceOS = '';
  String _deviceType = '';

  String get androidID => _androidID;
  String get deviceModel => _deviceModel;
  String get deviceBrand => _deviceBrand;
  String get deviceOS => _deviceOS;
  String get deviceType => _deviceType;

  /// Static method to get device info without needing controller instance
  static Future<DeviceInfoModel> getDeviceInfoStatic() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    String deviceId = '';
    String deviceModel = '';
    String deviceBrand = '';
    String deviceOS = '';
    String deviceType = '';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceModel = androidInfo.model;
        deviceBrand = androidInfo.brand;
        deviceOS = 'Android ${androidInfo.version.release}';
        deviceType = 'Android';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
        deviceModel = iosInfo.model;
        deviceBrand = 'Apple';
        deviceOS = '${iosInfo.systemName} ${iosInfo.systemVersion}';
        deviceType = 'iOS';
      } else {
        deviceType = 'Web';
        deviceOS = 'Unknown';
        deviceBrand = 'Unknown';
      }
    } catch (e) {
      print('Error getting device information: $e');
      deviceType = 'Unknown';
      deviceOS = 'Unknown';
      deviceBrand = 'Unknown';
    }

    return DeviceInfoModel(
      deviceId: deviceId,
      deviceModel: deviceModel,
      deviceBrand: deviceBrand,
      deviceOS: deviceOS,
      deviceType: deviceType,
    );
  }

  Future<void> getDeviceInfo() async {
    try {
      final info = await getDeviceInfoStatic();
      _androidID = info.deviceId;
      _deviceModel = info.deviceModel;
      _deviceBrand = info.deviceBrand;
      _deviceOS = info.deviceOS;
      _deviceType = info.deviceType;

      Preference.androidID = _androidID;
      update();
    } catch (e) {
      print('Error getting device information: $e');
    }
  }

  @override
  void onInit() {
    getDeviceInfo();
    super.onInit();
  }
}
