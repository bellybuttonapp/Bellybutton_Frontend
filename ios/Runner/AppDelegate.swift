import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    // Request notification permission
    UNUserNotificationCenter.current().delegate = self

    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }

    application.registerForRemoteNotifications()

    // Set Firebase Messaging delegate
    Messaging.messaging().delegate = self

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle APNs token registration
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // MARK: - Universal Links Handler
  override func application(_ application: UIApplication,
                            continue userActivity: NSUserActivity,
                            restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    // Handle Universal Links
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let url = userActivity.webpageURL {
      print("📱 Universal Link received: \(url)")
      // Let Flutter handle the deep link via app_links package
      return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }

  // MARK: - Custom URL Scheme Handler
  override func application(_ app: UIApplication,
                            open url: URL,
                            options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    print("📱 Custom URL Scheme received: \(url)")
    return super.application(app, open: url, options: options)
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔥 FCM Token: \(fcmToken ?? "nil")")
  }
}
