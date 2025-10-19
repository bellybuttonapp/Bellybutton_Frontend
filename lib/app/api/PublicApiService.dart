// ignore_for_file: avoid_print, unused_field, file_names

import 'dart:io';
import 'package:dio/dio.dart';
import '../api/DioClient.dart';
import '../api/end_points.dart';

class PublicApiService {
  final Dio _dio = DioClient().dio;

  // Common API handler
  Future<Map<String, dynamic>> _handleApiCall(Future<Response?> apiCall) async {
    try {
      final response = await apiCall;

      if (response == null) return {"success": false, "message": "No response"};

      final data = response.data;

      if (data is Map<String, dynamic>) return data;

      if (data is String) return {"success": true, "message": data};

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
        Endpoints.createEvent,
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
}
