// // ignore_for_file: avoid_print

// import 'package:app_links/app_links.dart';
// import 'package:get/get.dart';
// import '../../modules/Dashboard/Innermodule/EventInvitations/views/event_invitations_view.dart';

// class DeepLinkService {
//   static final AppLinks _appLinks = AppLinks();

//   /// MUST be called in main() before runApp()
//   static Future<void> init() async {
//     try {z
//       // 🔥 Trigger when app opened from terminated state
//       final Uri? initialLink = await _appLinks.getInitialLink();
//       if (initialLink != null) _handleLink(initialLink);

//       // 🔥 Trigger when app already running in background/foreground
//       _appLinks.uriLinkStream.listen(
//         (uri) => _handleLink(uri),
//         onError: (err) => print("❌ DeepLink Stream Error: $err"),
//       );
//     } catch (e) {
//       print("❌ DeepLink init failed: $e");
//     }
//   }

//   /// Main Link Routing Logic (SAFE)
//   static void _handleLink(Uri uri) {
//     print("🚀 DeepLink Triggered → $uri");

//     // Accept formats:
//     // https://yourdomain.com/event?eventId=179
//     // https://yourdomain.com/event/179
//     if (uri.path.contains("event")) {
//       String? eventId;

//       // Query Param: ?eventId=179
//       eventId = uri.queryParameters["eventId"];

//       // Path Format: /event/179
//       if (eventId == null && uri.pathSegments.length > 1) {
//         final nextSegment = uri.pathSegments[1];
//         if (int.tryParse(nextSegment) != null) {
//           eventId = nextSegment;
//         }
//       }

//       if (eventId != null) {
//         print("📌 Navigating to Event ID → $eventId");
//         Get.to(() => EventInvitationsView(eventId: eventId));
//       } else {
//         print("⚠ Event ID missing in link → $uri");
//       }
//     } else {
//       print("ℹ Non-event link received. Ignored.");
//     }
//   }
// }
