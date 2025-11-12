// ignore_for_file: avoid_print, unused_field, file_names

import 'dart:io';
import 'package:dio/dio.dart';
import '../api/DioClient.dart';
import '../api/end_points.dart';
import '../database/models/EventModel.dart';

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

  // ==========================
  // 1️⃣ Create Event
  // ==========================
  Future<Map<String, dynamic>> createEvent({
    required String title,
    required String description,
    required String eventDate, // format: YYYY-MM-DD
    required String startTime, // format: HH:MM:SS
    required String endTime, // format: HH:MM:SS
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
  // 3️⃣ Get All Events
  // ==========================
  Future<List<EventModel>> getAllEvents() async {
    final response = await _handleApiCall(
      DioClient().getRequest(Endpoints.LIST_ALL_EVENTS),
    );

    if (response["success"] == true && response["data"] is List) {
      final data = response["data"] as List;
      return data.map((e) => EventModel.fromJson(e)).toList();
    } else {
      print("Error fetching events: ${response["message"]}");
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
    required String eventDate, // format: YYYY-MM-DD
    required String startTime, // format: HH:MM:SS
    required String endTime, // format: HH:MM:SS
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
        },
      ),
    );

    return response;
  }

  // ==========================
// 6️⃣ Update Profile
// ==========================
Future<Map<String, dynamic>> updateProfile({
  required String email,
  required String fullName,
  required String phone,
  required String address,
  required String bio,
  required String profileImageUrl,
}) async {
  print("✏️ Sending PUT request → ${Endpoints.UPDATE_PROFILE}");

  final response = await _handleApiCall(
    DioClient().putRequest(
      Endpoints.UPDATE_PROFILE,
      data: {
        "email": email,
        "fullName": fullName,
        "phone": phone,
        "address": address,
        "bio": bio,
        "profileImageUrl": profileImageUrl,
      },
    ),
  );

  return response;
}



}
