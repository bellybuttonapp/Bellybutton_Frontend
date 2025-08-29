import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
class FirebaseApi {
  static final FirebaseApi _singleton = FirebaseApi._internal();

  factory FirebaseApi() {
    return _singleton;
  }

  FirebaseApi._internal();

  // Initialize Firebase and configure Firebase Messaging
  static Future<void> initialize() async {
    await Firebase.initializeApp();

    // // Configure foreground notification presentation options
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   handleForegroundMessage(message);
    // });

    // Request notification permissions for iOS
    // if (Platform.isIOS) {
    //   await FirebaseMessaging.instance.requestPermission(
    //     alert: true,
    //     announcement: false,
    //     badge: true,
    //     carPlay: false,
    //     criticalAlert: false,
    //     provisional: false,
    //     sound: true,
    //   );
    // } else if (Platform.isAndroid) {
    //   await FirebaseMessaging.instance.requestPermission(
    //     sound: true,
    //     badge: true,
    //   );
    // }

    // Request provisional notification permissions for other platforms
    // else {
    //   await FirebaseMessaging.instance.requestPermission(provisional: true);
    // }
  }

  // Get the device token for push notifications
  // static Future<String?> getDeviceToken() async {
  //   return await FirebaseMessaging.instance.getToken();
  // }

  // Configure Firebase Messaging listeners
  // static void setupFirebaseMessaging() async {
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     tapToMoveNotification(message);
  //   });

  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // }

  // static void handleForegroundMessage(RemoteMessage message) async {
  //   print(message.data["data"]);
  //   MainController.instance.fetchNotifications();
  //   inAppNotificationView(message);
  // }

  // static void handleNotificationTap(RemoteMessage message) async {
  //   MainController.instance.fetchNotifications();
  //   tapToMoveNotification(message);
  // }

  // static Future<void> _firebaseMessagingBackgroundHandler(
  //     RemoteMessage message) async {
  //   MainController.instance.fetchNotifications();
  //   tapToMoveNotification(message);
  // }

  // static void requestNotificationPermissions() {
  //   FirebaseMessaging.instance.requestPermission();
  // }

  // static void subscribeToTopic(String topic) {
  //   FirebaseMessaging.instance.subscribeToTopic(topic);
  // }

  // static void unsubscribeFromTopic(String topic) {
  //   FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  // }
}

// inAppNotificationView(RemoteMessage message) {
//   return InAppNotifications.show(
//       title: message.notification?.title ?? '',
//       leading: Icon(
//         Icons.message,
//         color: Colors.green,
//         size: Dimensions.PADDING_SIZE_OVER_LARGE,
//       ),
//       description: message.notification?.body ?? '',
//       onTap: () async {
//         tapToMoveNotification(message);
//       });
// }

// void tapToMoveNotification(RemoteMessage message) async {
//   MainController.instance.fetchNotifications();
//   NotificationJobCard notificationJobCard =
//       parseNotificationJobCardJobCardFromJson(message.data["data"]);
//   if (notificationJobCard.notificationType == "jobcard creation") {
//     JobCardModel jobCard = await Get.find<HomeController>()
//         .getJobcardByID(JobCardId: notificationJobCard.jobCardId ?? 0);
//     int notificationId = await MainController.instance.database.notificationDao
//             .getNotificationIdByCreatedOn(
//                 notificationJobCard.jcCreatedTime ?? '') ??
//         0;
//     Get.to(DetailNotificationView(
//       jobCard: jobCard,
//       notificaitonID: notificationId,
//     ));
//   } else {
//     Get.to(NotificationView());
//   }
//   Preference.isNotificaitonTapped = false;
// }
