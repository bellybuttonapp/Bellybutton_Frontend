// ignore_for_file: avoid_print, unused_field, file_names

import 'dart:io';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../api/end_points.dart';
import '../core/utils/storage/preference.dart';
import '../database/models/EventModel.dart';
import '../database/models/InvitedEventModel.dart';
import '../database/models/NotificationModel.dart';

class PublicApiService {
  final Dio _dio = DioClient().dio;

  // Common API handler
  Future<Map<String, dynamic>> _handleApiCall(Future<Response?> apiCall) async {
    try {
      final response = await apiCall;

      if (response == null) {
        return {"success": false, "message": "No response"};
      }

      final data = response.data;

      // ✅ If response is a JSON object
      if (data is Map<String, dynamic>) {
        return data;
      }

      // ✅ If response is a list
      if (data is List) {
        return {"success": true, "data": data};
      }

      // ✅ If response is a plain string or number
      if (data is String || data is num) {
        return {"success": true, "message": data.toString()};
      }

      // ❌ Unknown response type
      return {"success": false, "message": "Invalid response type"};
    } on DioException catch (e) {
      if (e.error is SocketException) {
        return {"success": false, "message": "No internet connection"};
      }
      print("DioException: ${e.message}");
      return {"success": false, "message": "Network error"};
    } catch (e) {
      print("Unexpected error: $e");
      return {"success": false, "message": "Unexpected error"};
    }
  }

  Future<Map<String, dynamic>> createEvent({
    required String title,
    required String description,
    required String eventDate,
    required String startTime,
    required String endTime,
    required List<dynamic> invitedPeople,
    String? timezone,
    String? timezoneOffset,
  }) async {
    return await _handleApiCall(
      DioClient().postRequest(
        Endpoints.CREATE_EVENT,
        data: {
          "title": title,
          "description": description,
          "eventDate": eventDate,
          "startTime": startTime,
          "endTime": endTime,
          "invitedPeople": invitedPeople, // MUST be list of objects
          "timezone": timezone,           // Creator's timezone (e.g., "Asia/Kolkata")
          "timezoneOffset": timezoneOffset, // Creator's offset (e.g., "+05:30")
        },
      ),
    );
  }

  // ==========================
  // 2️⃣ View Event by ID
  // ==========================
  Future<Map<String, dynamic>> viewEventById(int id) async {
    return await _handleApiCall(
      DioClient().getRequest('${Endpoints.VIEW_EVENT}/$id'),
    );
  }

  // ==========================
  // 2️⃣.1 Get Event by ID (returns EventModel)
  // ==========================
  Future<EventModel?> getEventById(int eventId) async {
    final response = await viewEventById(eventId);

    try {
      if (response["data"] != null) {
        print("📦 Event fetched: ${response["data"]}");
        return EventModel.fromJson(response["data"]);
      }
      print("❌ No event data found");
      return null;
    } catch (e) {
      print("❌ Error parsing event: $e");
      return null;
    }
  }

  Future<List<EventModel>> getAllEvents() async {
    final response = await _handleApiCall(
      DioClient().getRequest(Endpoints.LIST_ALL_EVENTS),
    );
    try {
      // Extract the "data" array safely
      final List<dynamic> data = response["data"] ?? [];

      print("📦 Parsed Events Count: ${data.length}");

      // Handle both old and new response formats
      return data.map((item) {
        final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item);

        // New format: { event: {...}, invitedPeople: [{id: 1, ...}] }
        if (itemMap.containsKey('event')) {
          print("📦 Using NEW format (with event wrapper)");
          return EventModel.fromCreateResponse(itemMap);
        }
        // Old format: { id: 1, title: ..., invitedPeople: [...] }
        else {
          print("📦 Using OLD format (direct event object)");
          return EventModel.fromJson(itemMap);
        }
      }).toList();
    } catch (e) {
      print("❌ Error parsing events: $e");
      return [];
    }
  }

  // ==========================
  // 4️⃣ Delete Event by ID
  // ==========================
  Future<Map<String, dynamic>> deleteEvent(int id) async {
    final endpoint = Endpoints.DELETE_EVENT.replaceFirst('{id}', id.toString());
    print("🗑️ Sending DELETE request → $endpoint");

    final response = await _handleApiCall(DioClient().deleteRequest(endpoint));

    // If backend returns a plain text message
    if (response["success"] == true &&
        response["message"] == null &&
        response["data"] == null) {
      return {"success": true, "message": "Event deleted successfully"};
    }

    return response;
  }

  // ==========================
  // 5️⃣ Update Event by ID
  // ==========================
  Future<Map<String, dynamic>> updateEvent({
    required int id,
    required String title,
    required String description,
    required String eventDate, // format: YYYY-MM-DD (UTC)
    required String startTime, // format: HH:MM:SS (UTC)
    required String endTime, // format: HH:MM:SS (UTC)
    String? timezone,
    String? timezoneOffset,
  }) async {
    final endpoint = Endpoints.UPDATE_EVENT.replaceFirst('{id}', id.toString());
    print("✏️ Sending PUT request → $endpoint");

    final response = await _handleApiCall(
      DioClient().putRequest(
        endpoint,
        data: {
          "title": title,
          "description": description,
          "eventDate": eventDate,
          "startTime": startTime,
          "endTime": endTime,
          "timezone": timezone,           // Creator's timezone (e.g., "Asia/Kolkata")
          "timezoneOffset": timezoneOffset, // Creator's offset (e.g., "+05:30")
        },
      ),
    );

    return response;
  }

  // ==========================
  // 5️⃣ updateProfile by ID (PUT + Multipart)
  // ==========================
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String email,
    required String fullName,
    required String phone,
    required String address,
    required String bio,
    File? imageFile,
  }) async {
    final endpoint = "${Endpoints.UPDATE_PROFILE}/$userId";

    print("✏️ Sending Multipart PUT → $endpoint");

    final profileString =
        '{"email":"$email","fullName":"$fullName","phone":"$phone","address":"$address","bio":"$bio"}';

    print("📌 RAW PROFILE STRING → $profileString");

    final formData = FormData.fromMap({
      "profile": profileString,
      if (imageFile != null)
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
    });

    // Let AuthInterceptor handle token injection automatically
    final response = await DioClient().dio.put(
      endpoint,
      data: formData,
      options: Options(
        headers: {
          "Accept": "application/json",
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    return response.data;
  }

  // ==========================
  // 5️⃣    Fetch profile by user ID
  // ==========================
  Future<Map<String, dynamic>> getProfileById(int userId) async {
    final endpoint = Endpoints.GET_PROFILE_BY_ID.replaceFirst(
      "{id}",
      userId.toString(),
    );

    // Let AuthInterceptor handle token injection automatically
    return await _handleApiCall(DioClient().getRequest(endpoint));
  }

  // ==========================
  // 5️⃣ getInvitedEvents
  // ==========================

  Future<List<InvitedEventModel>> getInvitedEvents() async {
    final response = await _handleApiCall(
      DioClient().getRequest(Endpoints.LIST_INVITED_EVENTS),
    );

    try {
      final List data = response["data"] ?? [];

      return data.map((e) => InvitedEventModel.fromJson(e)).toList();
    } catch (e) {
      print("Parse error => $e");
      return [];
    }
  }

  // ==========================
  // 6️⃣ Accept Invited Event
  // ==========================
  Future<Map<String, dynamic>> acceptInvitedEvent(int eventId) async {
    final endpoint = Endpoints.ACCEPT_INVITED_EVENT.replaceFirst(
      "{id}",
      eventId.toString(),
    );

    print("👉 Accept request → $endpoint");

    final response = await _handleApiCall(DioClient().putRequest(endpoint));

    return response;
  }

  // ==========================
  // 7️⃣ Deny Invited Event
  // ==========================
  Future<Map<String, dynamic>> denyInvitedEvent(int eventId) async {
    final endpoint = Endpoints.DENY_INVITED_EVENT.replaceFirst(
      "{id}",
      eventId.toString(),
    );

    print("❌ Deny request → $endpoint");

    final response = await _handleApiCall(DioClient().putRequest(endpoint));

    return response;
  }

  // ==========================
  // 8️⃣ Invite Users to Existing Event
  // ==========================
  Future<Map<String, dynamic>> inviteUsersToEvent({
    required int eventId,
    required List<Map<String, dynamic>> invitedPeople,
  }) async {
    final endpoint = Endpoints.INVITE_USERS_TO_EVENT.replaceFirst(
      "{eventId}",
      eventId.toString(),
    );

    print("📨 Invite users → $endpoint");

    final response = await _handleApiCall(
      DioClient().postRequest(
        endpoint,
        data: {"invitedPeople": invitedPeople},
      ),
    );

    return response;
  }

  // ==========================
  // 9️⃣ Remove Invited User from Event
  // ==========================
  Future<Map<String, dynamic>> removeInvitedUser({
    required int eventId,
    required dynamic inviteId, // Can be int (inviteId) or String (phone)
  }) async {
    final endpoint = Endpoints.REMOVE_INVITED_USER
        .replaceFirst("{eventId}", eventId.toString())
        .replaceFirst("{inviteId}", inviteId.toString());

    print("🗑️ Remove invited user → $endpoint");

    final response = await _handleApiCall(
      DioClient().deleteRequest(endpoint),
    );

    return response;
  }

  // ==========================
  // 7️⃣ Upload Invited Event Photos
  // ==========================

  Future<Map<String, dynamic>> uploadEventImagesPost({
    required int eventId,
    required List<File> files,
  }) async {
    final endpoint = Endpoints.UPLOAD_EVENT_PHOTOS;

    // Clean token - remove any newlines or extra whitespace
    final cleanToken = Preference.token.replaceAll('\n', '').replaceAll('\r', '').trim();

    // Debug logging
    print("🔍 Upload Debug - Token length: ${cleanToken.length}");
    print("🔍 Upload Debug - Token preview: ${cleanToken.substring(0, 50)}...");

    // Backend expects: @RequestParam("eventId") - pass as query parameter
    // Backend expects: @RequestPart("files") - pass as multipart file
    final formData = FormData.fromMap({
      "files": [
        for (var f in files)
          await MultipartFile.fromFile(
            f.path,
            filename: f.path.split("/").last,
          ),
      ],
    });

    return await _handleApiCall(
      _dio.post(
        endpoint,
        data: formData,
        queryParameters: {"eventId": eventId},
        options: Options(
          headers: {"Authorization": "Bearer $cleanToken"},
          extra: {"skipAuth": true}, // Skip AuthInterceptor to avoid double-setting
        ),
      ),
    );
  }

  // ==========================
  // 7️⃣ FETCH Invited Event Photos
  // ==========================
  Future<Map<String, dynamic>> fetchEventPhotos(int? eventId) async {
    final endpoint = Endpoints.FETCH_EVENT_PHOTOS.replaceFirst(
      "{id}",
      eventId.toString(),
    );

    return await _handleApiCall(
      _dio.get(
        endpoint,
        options: Options(
          headers: {
            "Authorization": "Bearer ${Preference.token}",
            "Accept": "application/json",
          },
        ),
      ),
    );
  }

  // ==========================
  // 8️⃣ GET Single Media Info (Photo Size/Details)
  // ==========================
  Future<Map<String, dynamic>> getMediaInfo(int mediaId) async {
    final endpoint = Endpoints.GET_MEDIA_INFO.replaceFirst(
      "{id}",
      mediaId.toString(),
    );

    return await _handleApiCall(
      _dio.get(
        endpoint,
        options: Options(
          headers: {
            "Authorization": "Bearer ${Preference.token}",
            "Accept": "application/json",
          },
        ),
      ),
    );
  }
  // ==================================
  // 7️⃣ FETCH Invited Event Axcepted participants
  // ==================================

  Future<Map<String, dynamic>> getJoinedUsers(int eventId) async {
    final endpoint = Endpoints.GET_JOINED_USERS.replaceFirst(
      "{eventId}",
      eventId.toString(),
    );

    return await _handleApiCall(
      _dio.get(
        endpoint,
        options: Options(
          headers: {"Authorization": "Bearer ${Preference.token}"},
        ),
      ),
    );
  }

  // ==================================
  // 8️⃣ FETCH Invited Event Admins List
  // ==================================
  Future<Map<String, dynamic>> getJoinedAdmins(int eventId) async {
    final endpoint = Endpoints.GET_JOINED_ADMINS.replaceFirst(
      "{eventId}",
      eventId.toString(),
    );

    return await _handleApiCall(
      _dio.get(
        endpoint,
        options: Options(
          headers: {"Authorization": "Bearer ${Preference.token}"},
        ),
      ),
    );
  }

  // ==================================
  // 9️⃣ FETCH ALL Invitations (PENDING + ACCEPTED)
  // ==================================
  /// Fetches all invitations for an event (both PENDING and ACCEPTED status)
  /// Returns list of invited people with their status and role
  Future<List<Map<String, dynamic>>> getAllInvitations(int eventId) async {
    final endpoint = Endpoints.GET_ALL_INVITATIONS.replaceFirst(
      "{eventId}",
      eventId.toString(),
    );

    print("📋 Fetching ALL invitations → $endpoint");

    final response = await _handleApiCall(
      _dio.get(
        endpoint,
        options: Options(
          headers: {"Authorization": "Bearer ${Preference.token}"},
        ),
      ),
    );

    try {
      final List<dynamic> data = response["data"] ?? [];
      print("📋 Fetched ${data.length} invitations");
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print("❌ Error parsing invitations: $e");
      return [];
    }
  }

  // ===============================
  // 1️⃣ SHARE EVENT (Generate Link)
  // ===============================

  /// Share event with permission type
  /// [permission] can be "view-only" or "view-sync"
  Future<Map<String, dynamic>> shareEvent(
    int eventId, {
    String permission = "view-only",
  }) async {
    final endpoint = Endpoints.SHARE_EVENT.replaceFirst(
      '{eventId}',
      eventId.toString(),
    );
    final fullUrl = "$endpoint?permission=$permission";
    print("🔗 Share Event → $fullUrl");

    return await _handleApiCall(DioClient().getRequest(fullUrl));
  }

  // ===============================================
  // 2️⃣ OPEN SHARED LINK (App_Links → Open Event)
  // ===============================================
  Future<Map<String, dynamic>> openSharedEvent(String eventLink) async {
    try {
      print("🔍 Opening shared link: $eventLink");

      final uri = Uri.parse(eventLink);

      // Extract event ID
      final segments = uri.pathSegments;
      if (segments.length < 2) {
        return {"success": false, "message": "Invalid event link"};
      }

      final eventId = int.tryParse(segments.last);
      final permission = uri.queryParameters["permission"] ?? "view-only";

      if (eventId == null) {
        return {"success": false, "message": "Invalid event link"};
      }

      print("📌 Event ID: $eventId");
      print("📌 Permission: $permission");

      // Fetch event from backend
      final eventResponse = await viewEventById(eventId);

      if (eventResponse["success"] != true) {
        return {"success": false, "message": "Event not found"};
      }

      return {
        "success": true,
        "event": eventResponse["data"],
        "permission": permission,
      };
    } catch (e) {
      print("❌ Error opening shared link: $e");
      return {"success": false, "message": "Invalid event link"};
    }
  }

  // ===============================================
  // 3️⃣ OPEN SHARED EVENT BY TOKEN (Deep Link Handler)
  // ===============================================
  /// Opens a shared event using the share token
  /// Token format: abc123xyz (from share/event/open/{token})
  /// Returns event data with permission level
  Future<Map<String, dynamic>> openSharedEventByToken(String shareToken) async {
    try {
      print("🔍 Opening shared event by token: $shareToken");

      final endpoint = Endpoints.OPEN_SHARED_EVENT.replaceFirst(
        '{eventId}',
        shareToken,
      );

      print("📌 Endpoint: $endpoint");

      final response = await _handleApiCall(
        _dio.get(
          endpoint,
          options: Options(
            headers: {
              "Authorization": "Bearer ${Preference.token}",
              "Accept": "application/json",
            },
          ),
        ),
      );

      print("📦 Share Token Response: $response");

      // Expected response format from backend:
      // { "event": {...}, "permission": "view-only" | "view-sync", "success": true }
      if (response["event"] != null) {
        return {
          "success": true,
          "event": response["event"],
          "permission": response["permission"] ?? "view-only",
        };
      }

      // Alternative response format: { "data": {...}, "permission": "..." }
      if (response["data"] != null) {
        return {
          "success": true,
          "event": response["data"],
          "permission": response["permission"] ?? "view-only",
        };
      }

      // If response contains event data directly (flat structure)
      if (response["id"] != null && response["title"] != null) {
        return {
          "success": true,
          "event": response,
          "permission": response["permission"] ?? "view-only",
        };
      }

      return {"success": false, "message": response["message"] ?? "Event not found"};
    } catch (e) {
      print("❌ Error opening shared event by token: $e");
      return {"success": false, "message": "Failed to open shared event"};
    }
  }
  // ===============================================
  // 🔔 PUSH NOTIFICATION → Save / Update FCM Token
  // ===============================================

  Future<void> updateFcmToken(String token) async {
    if (Preference.token.isEmpty) {
      print("⛔ Cannot send FCM token → User not logged in");
      return;
    }

    final endpoint = Endpoints.SAVE_FCM_TOKEN;

    try {
      final response = await _dio.put(
        endpoint,
        data: {"fcmToken": token},
        options: Options(
          headers: {"Authorization": "Bearer ${Preference.token}"},
        ),
      );

      print("✅ FCM Token Updated → ${response.data}");
    } catch (e, stacktrace) {
      print("❌ Failed to update FCM Token → $e");
      print("📌 Stacktrace → $stacktrace");
    }
  }

  // ===============================================
  // 📜 TERMS & CONDITIONS
  // ===============================================

  /// Fetch latest terms and conditions content
  Future<Map<String, dynamic>> getTermsAndConditions() async {
    return await _handleApiCall(DioClient().getRequest(Endpoints.TERMS_LATEST));
  }

  // ===============================================
  // 🔔 NOTIFICATIONS
  // ===============================================

  /// Fetch all notifications for the current user
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _handleApiCall(
      DioClient().getRequest(Endpoints.LIST_NOTIFICATIONS),
    );

    try {
      final List<dynamic> data = response["data"] ?? [];
      print("📬 Parsed Notifications Count: ${data.length}");
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      print("❌ Error parsing notifications: $e");
      return [];
    }
  }

  /// Mark a notification as read
  Future<Map<String, dynamic>> markNotificationAsRead(int notificationId) async {
    final endpoint = Endpoints.MARK_NOTIFICATION_READ.replaceFirst(
      "{notificationId}",
      notificationId.toString(),
    );

    print("📬 Mark notification as read → $endpoint");

    return await _handleApiCall(DioClient().putRequest(endpoint));
  }

  // ===============================================
  // 📸 PUBLIC EVENT GALLERY (No Auth Required)
  // ===============================================

  /// Fetch public event gallery photos by token or event ID
  /// Uses PUBLIC_EVENT_GALLERY endpoint - NO authentication required
  /// [tokenOrId] can be a share token (string) or event ID (will be converted to string)
  Future<Map<String, dynamic>> fetchPublicEventGallery(dynamic tokenOrId) async {
    final identifier = tokenOrId.toString();
    print("📸 Fetching PUBLIC gallery for token/id: $identifier");

    try {
      // Always use PUBLIC_EVENT_GALLERY endpoint (accepts both token and eventId)
      final endpoint = Endpoints.PUBLIC_EVENT_GALLERY.replaceFirst("{eventId}", identifier);

      print("📸 Using PUBLIC endpoint: $endpoint");

      // Make request WITHOUT authentication headers
      // Use text/html to bypass backend auth check (server returns HTML for browser, requires auth for JSON)
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
          },
        ),
      );

      if (response.data == null) {
        return {"success": false, "message": "No response"};
      }

      final data = response.data;

      // Check if response is HTML (String)
      if (data is String) {
        print("📸 Response is HTML, parsing image URLs...");

        // Extract title from HTML <title> tag or <h1>
        String title = "";
        final titleMatch = RegExp(r'<title>(.*?)</title>', caseSensitive: false, dotAll: true).firstMatch(data);
        if (titleMatch != null) {
          title = titleMatch.group(1) ?? "";
          // Remove any emoji, extra formatting, and whitespace/newlines
          title = title.replaceAll(RegExp(r'\s+'), ' ').trim();
        }

        // Extract all image URLs from <img> tags
        // Match both single and double quotes
        final imgRegex = RegExp(r'<img[^>]+src="([^"]+)"', caseSensitive: false);
        final imgRegex2 = RegExp(r"<img[^>]+src='([^']+)'", caseSensitive: false);

        List<String> imageUrls = [];

        // Find matches with double quotes
        for (var match in imgRegex.allMatches(data)) {
          final url = match.group(1)?.trim();
          if (url != null && url.isNotEmpty) {
            imageUrls.add(url);
          }
        }

        // Find matches with single quotes
        for (var match in imgRegex2.allMatches(data)) {
          final url = match.group(1)?.trim();
          if (url != null && url.isNotEmpty) {
            imageUrls.add(url);
          }
        }

        print("📸 Found ${imageUrls.length} images in HTML");

        return {
          "success": true,
          "title": title,
          "data": imageUrls,
          "event": {
            "title": title,
          },
        };
      }

      // Handle JSON response format
      if (data is Map<String, dynamic>) {
        // Extract photos from response
        List<dynamic> photos = [];
        if (data["data"] != null) {
          photos = data["data"] is List ? data["data"] : [];
        } else if (data["photos"] != null) {
          photos = data["photos"] is List ? data["photos"] : [];
        }

        // Extract URLs from photo objects
        List<String> imageUrls = [];
        for (var photo in photos) {
          if (photo is String) {
            imageUrls.add(photo);
          } else if (photo is Map) {
            final url = photo["fileUrl"] ?? photo["url"] ?? photo["photo"];
            if (url != null) {
              imageUrls.add(url.toString());
            }
          }
        }

        print("📸 Found ${imageUrls.length} images");

        return {
          "success": true,
          "title": data["title"] ?? "",
          "data": imageUrls,
        };
      }

      // If response is a list directly
      if (data is List) {
        List<String> imageUrls = [];
        for (var photo in data) {
          if (photo is String) {
            imageUrls.add(photo);
          } else if (photo is Map) {
            final url = photo["fileUrl"] ?? photo["url"] ?? photo["photo"];
            if (url != null) {
              imageUrls.add(url.toString());
            }
          }
        }

        print("📸 Found ${imageUrls.length} images (list response)");

        return {
          "success": true,
          "title": "",
          "data": imageUrls,
        };
      }

      return {"success": false, "message": "Invalid response format"};
    } on DioException catch (e) {
      print("❌ DioException fetching gallery: ${e.message}");
      if (e.response?.statusCode == 404) {
        return {"success": false, "message": "Gallery not found"};
      }
      if (e.response?.statusCode == 403) {
        return {"success": false, "message": "Access denied"};
      }
      return {"success": false, "message": "Failed to load gallery"};
    } catch (e) {
      print("❌ Error fetching gallery: $e");
      return {"success": false, "message": "Failed to load gallery"};
    }
  }
}