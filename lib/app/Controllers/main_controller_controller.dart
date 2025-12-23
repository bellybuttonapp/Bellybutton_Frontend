import 'package:get/get.dart';

class MainController extends GetxController {
  // Singleton instance
  static MainController get instance => Get.find<MainController>();

  // Private constructor
  MainController._();

  // Factory constructor to create a new instance if not found
  factory MainController() => _instance;

  static final MainController _instance = MainController._();

  // AppDatabase database = Get.find();

  // Your existing methods and variables
  // Future<void> updateDeviceDetails() async {
  //   var connectivityResult = await Connectivity().checkConnectivity();
  //   if (connectivityResult != ConnectivityResult.none) {
  //     var token = await FirebaseApi.getDeviceToken();
  //     Preference.token = token ?? '';
  //     // logWhite('Device Token From Firebase : $token');
  //     Map input = {
  //       "id": Preference.userId,
  //       "os_type": GetPlatform.isAndroid
  //           ? 'Android'
  //           : GetPlatform.isIOS
  //               ? 'iOS'
  //               : '',
  //       "device_token": Preference.token,
  //       "longitude": Preference.longitude,
  //       "latitude": Preference.latitude,
  //       "selected_language": Preference.selectedLanguage,
  //       "language": Preference.languageCode,
  //       "app_version": AppConstants.APP_VERSION_TO_USER
  //     };
  //     try {
  //       Map<String, dynamic> response = await hitapi().request(
  //         endpoints.updateDeviceDetails,
  //         input: input,
  //         method: HttpMethod.POST,
  //       );
  //       if (response['status'] == 1) {
  //         // Handle success
  //       } else {
  //         // Handle failure
  //       }
  //     } catch (error) {
  //       // Handle API call error
  //       print('API call failed: $error');
  //     }
  //   } else {
  //     showCustomSnackBar(
  //         LocaleKeys.nointernetconnected.tr, SnackbarState.warning);
  //   }
  // }

  // Future<List<String>> uploadToS3MultipleImage(List<XFile> files) async {
  //   var connectivityResult = await Connectivity().checkConnectivity();
  //   List<String> imageList = [];
  //   Loader.show();

  //   if (connectivityResult != ConnectivityResult.none) {
  //     try {
  //       for (var file in files) {
  //         logWhite(file.path);
  //         Map<String, dynamic> response = await hitapi().uploadFile(
  //           endpoints.addAnyFile,
  //           file: File(file.path),
  //         );
  //         if (response['status'] == 1) {
  //           // Handle success
  //           imageList.add(response['file_url']);
  //         } else {
  //           // Handle failure
  //           // You might want to throw an exception or handle this case differently
  //           print('API call failed for file: $file');
  //         }
  //       }
  //       // Update UI after all files are processed
  //       update();
  //       Loader.dismiss();
  //       logWhite(imageList.toString());
  //     } catch (error) {
  //       // Handle API call error
  //       print('API call failed: $error');
  //       Loader.dismiss();
  //     }
  //   } else {
  //     showCustomSnackBar(
  //         LocaleKeys.nointernetconnected.tr, SnackbarState.warning);
  //     Loader.dismiss();
  //   }

  //   return imageList;
  // }

  // Future<String> uploadToS3ToGetUrl(File file) async {
  //   String image = '';
  //   var connectivityResult = await Connectivity().checkConnectivity();

  //   if (connectivityResult != ConnectivityResult.none) {
  //     Loader.show();
  //     try {
  //       Map<String, dynamic> response = await hitapi().uploadFile(
  //         endpoints.addAnyFile,
  //         file: file,
  //       );
  //       if (response['status'] == 1) {
  //         // Handle success
  //         image = response['file_url'];
  //         logWhite('file url value' + image);
  //         Loader.dismiss();
  //       } else {
  //         // Handle failure
  //         Loader.dismiss();
  //         showCustomSnackBar(
  //             LocaleKeys.somethingwentwrong.tr, SnackbarState.warning);
  //       }
  //     } catch (error) {
  //       // Handle API call error
  //       print('API call failed: $error');
  //       Loader.dismiss();
  //       showCustomSnackBar(
  //           LocaleKeys.somethingwentwrong.tr, SnackbarState.warning);
  //     }
  //     Loader.dismiss();
  //   } else {
  //     showCustomSnackBar(
  //         LocaleKeys.nointernetconnected.tr, SnackbarState.warning);
  //   }
  //   return image;
  // }

  // var vdoUploadProgress = 0.0.obs;
  // Future<String> uploadVideoToS3AndGetUrl(
  //     File file, bool dontHaveThumnail) async {
  //   String image = '';
  //   var connectivityResult = await Connectivity().checkConnectivity();

  //   if (connectivityResult != ConnectivityResult.none) {
  //     try {
  //       vdoUploadProgress.value = 0;
  //       progressLoader(
  //           text: 'Video Uploading....', vdoUploadProgress: vdoUploadProgress);
  //       Map<String, dynamic> response = await hitapi().uploadFile(
  //           isVideo: true,
  //           endpoints.uploadVideo,
  //           file: file, onSendProgress: (sent, total) {
  //         int progress = ((sent / total) * 100).toInt();
  //         // Ensure progress is within 0 to 100 range
  //         progress = progress.clamp(0, 100);
  //         vdoUploadProgress.value = progress.toDouble();
  //       });
  //       if (dontHaveThumnail) {
  //         Get.find<VideoLibraryController>().thumbnailimage =
  //             await Get.find<VideoLibraryController>()
  //                     .getVideoThumbnail(file.path) ??
  //                 '';
  //       }
  //       if (response['status'] == 1) {
  //         // Handle success
  //         image = response['file_url'];
  //         logWhite('file url value' + image);
  //         Get.back();
  //       } else {
  //         Get.back();
  //         // Handle failure

  //         showCustomSnackBar(
  //             LocaleKeys.somethingwentwrong.tr, SnackbarState.warning);
  //       }
  //     } catch (error) {
  //       Get.back();
  //       // Handle API call error
  //       print('API call failed: $error');
  //       showCustomSnackBar(
  //           LocaleKeys.somethingwentwrong.tr, SnackbarState.warning);
  //     }
  //   } else {
  //     showCustomSnackBar(
  //         LocaleKeys.nointernetconnected.tr, SnackbarState.warning);
  //   }
  //   return image;
  // }

  // void accActivateDeactivate(ChangeAccountStatus changeAccountStatus) async {
  //   var connectivityResult = await Connectivity().checkConnectivity();
  //   Loader.show();
  //   if (connectivityResult != ConnectivityResult.none) {
  //     String status = changeAccountStatus == ChangeAccountStatus.activate
  //         ? 'A'
  //         : changeAccountStatus == ChangeAccountStatus.deactivate
  //             ? 'IN'
  //             : '';
  //     Map input = {
  //       "mobile_number":
  //           '${Preference.countryCode}${Preference.userNumber.trimCountryCode(Preference.countryCode)}',
  //       "status": status
  //     };
  //     print(input);
  //     try {
  //       Map<String, dynamic> response = await hitapi().request(
  //         endpoints.changeStatus,
  //         input: input,
  //         method: HttpMethod.POST,
  //       );
  //       if (response['status'] == 1) {
  //         // Handle success
  //         if (changeAccountStatus == ChangeAccountStatus.deactivate) {
  //           Preference.clearAllExceptCountryData();
  //           Preference.isLogined = false;
  //           database.jobcarddao.deleteAllJobCards();
  //           database.customerDetailsDao.deleteAllCustomer();
  //           database.garageServiceDao.getAllGarageServices();
  //           Get.offAllNamed(Routes.LOGIN);
  //         } else if (changeAccountStatus == ChangeAccountStatus.activate) {
  //           Get.back();
  //           showCustomSnackBar('You can login now', SnackbarState.success);
  //         }
  //         Loader.dismiss();
  //       } else {
  //         // Handle failure
  //         showCustomSnackBar(
  //             LocaleKeys.somethingwentwrong.tr, SnackbarState.warning);
  //         Loader.dismiss();
  //       }
  //     } catch (error) {
  //       // Handle API call error
  //       logError('API call failed: error');
  //       Loader.dismiss();
  //       showCustomSnackBar(
  //           LocaleKeys.somethingwentwrong.tr, SnackbarState.warning);
  //     }
  //   } else {
  //     // Network error
  //     Loader.dismiss();
  //     showCustomSnackBar(
  //         LocaleKeys.nointernetconnected.tr, SnackbarState.warning);
  //   }
  // }

  // void fetchNotifications() async {
  //   var connectivityResult = await Connectivity().checkConnectivity();
  //   Loader.show();
  //   if (connectivityResult != ConnectivityResult.none) {
  //     Map input = {
  //       "mechanic_id": Preference.userId,
  //     };
  //     try {
  //       Map<String, dynamic> response = await hitapi().request(
  //         endpoints.fetchNotifications,
  //         input: input,
  //         method: HttpMethod.POST,
  //       );
  //       if (response['status'] == 1) {
  //         // Handle success
  //         List<NotificationModel> modelList = (response['data'] as List)
  //             .map((item) => NotificationModel.fromJson(item))
  //             .toList();
  //         await database.notificationDao.deleteAllNotificationModel();
  //         database.notificationDao.insertAllNotificationModel(modelList);
  //       } else {
  //         // Handle failure
  //         showCustomSnackBar(
  //             LocaleKeys.somethingwentwrong.tr, SnackbarState.warning);
  //       }
  //     } catch (error) {
  //       // Handle API call error
  //       logError('API call failed: $error');

  //       showCustomSnackBar(
  //           LocaleKeys.somethingwentwrong.tr, SnackbarState.warning);
  //     }
  //   } else {
  //     // Network error
  //     ;
  //     showCustomSnackBar(
  //         LocaleKeys.nointernetconnected.tr, SnackbarState.warning);
  //   }
  //   Loader.dismiss();
  //   update();
  // }

  // void insertAllUserData(UserData data) {
  //   print('Insert All user data');
  //   Preference.shopBoard = data.shopLogo ?? '';
  //   Preference.userAddress = data.address ?? ''.decode;
  //   Preference.userId = data.id.toString();
  //   Preference.subMechanicID = data.childUser ?? '0';
  //   Preference.shopid = data.shopId.toString();
  //   Preference.companyId = data.companyId.toString();
  //   Preference.companyId = data.companyId.toString();
  //   Preference.userName = data.name.toString().decode;
  //   Preference.shopname = data.shopName.toString().decode;
  //   Preference.userNumber = data.phone ?? '';
  //   Preference.email = data.email ?? '';
  //   Preference.vehicleHandleType = data.userCategory ?? 'two wheeler';
  //   Preference.locationAccessCredit = data.locationAccess.toString();
  //   Preference.garageInfoCredit = data.garageInfo.toString();
  //   Preference.garageImageCredit = data.garageImage.toString();
  //   Preference.serviceDetailsCredit = data.serviceDetails.toString();
  //   Preference.countryCode = data.code ?? '+91';
  //   Preference.countryCodeName = data.countryCode ?? 'IN';
  //   Preference.selectedCountry = data.countryName ?? 'INDIA';
  //   Preference.ownerDetailsEntered = true;
  //   Preference.currency = data.currency ?? '';
  //   Preference.totalJobcardAmount = data.unitCharge ?? '0';
  //   Preference.numberofjobcards = data.noOfCredits ?? '0';
  //   Preference.profileImage = data.profilePicture ?? '';
  //   Preference.yearofexperience = data.yearOfExperience ?? '';
  // }

  // AdvancePay parseAdvancePay(String? jsonString) {
  //   Map<String, dynamic> jsonMap = parseJson(jsonString);
  //   return AdvancePay.fromJson(jsonMap);
  // }

  // Map<String, dynamic> parseJson(String? jsonString) {
  //   Map<String, dynamic> jsonMap = {};
  //   if (jsonString != null && jsonString.isNotEmpty) {
  //     try {
  //       jsonString = jsonString.replaceAll("'", '"');
  //       jsonMap = json.decode(jsonString);
  //     } catch (e) {
  //       print("Error parsing JSON: $e");
  //     }
  //   }
  //   return jsonMap;
  // }
}
