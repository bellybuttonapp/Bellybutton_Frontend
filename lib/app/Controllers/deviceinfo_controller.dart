// ignore_for_file: unused_local_variable, avoid_print, prefer_final_fields

import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../utils/preference.dart';

class DeviceController extends GetxController {
  // String _deviceId = '';
  // String _deviceModel = '';
  // String _deviceBrand = '';

  // String get deviceId => _deviceId;
  // String get deviceModel => _deviceModel;
  // String get deviceBrand => _deviceBrand;
  String _androidID = '';
  String get androidID => _androidID;
  // set deviceId(String value) {
  //   _deviceId = value;
  //   update();
  // }
  // set androidID(String value) {
  //   _androidID = value;
  //   update();
  // }

  // set deviceModel(String value) {
  //   _deviceModel = value;
  //   update();
  // }

  // set deviceBrand(String value) {
  //   _deviceBrand = value;
  //   update();
  // }

  void getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo;
    // IosDeviceInfo iosInfo;

    try {
      if (GetPlatform.isAndroid) {
        androidInfo = await deviceInfo.androidInfo;
        // _androidID = androidInfo.androidId;
        Preference.androidID = _androidID;
        // deviceId = androidInfo.androidId;
        // deviceModel = androidInfo.model;
        // deviceBrand = androidInfo.brand;

        // Add more properties as needed for Android
      } else if (GetPlatform.isIOS) {
        Preference.androidID = '';
        // iosInfo = await deviceInfo.iosInfo;
        // deviceId = iosInfo.identifierForVendor;
        // deviceModel = iosInfo.model;
        // Add more properties as needed for iOS
      }
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
