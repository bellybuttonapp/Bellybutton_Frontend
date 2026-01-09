// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../api/end_points.dart';
import '../core/utils/storage/preference.dart';
import '../core/constants/app_constant.dart';

class AuthService {
  Future<Map<String, dynamic>> _handleApiCall(Future<Response?> apiCall) async {
    try {
      final response = await apiCall;

      if (response == null) return {"result": false};

      // Handle JSON
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }

      // Handle plain text
      if (response.data is String) {
        return {"result": true, "message": response.data};
      }

      return {"result": false};
    } on DioException catch (e) {
      if (e.error is SocketException) {
        return {"result": false, "message": "No internet connection."};
      }
      print("DioException: ${e.message}");

      // Extract error message from response if available
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          final headers = data['headers'];
          if (headers is Map<String, dynamic> && headers['message'] != null) {
            return {
              "result": false,
              "headers": headers,
              "message": headers['message'],
            };
          }
          return {"result": false, ...data};
        }
      }

      return {"result": false, "message": "Something went wrong. Please try again."};
    } catch (e) {
      print("Unexpected error: $e");
      return {"result": false, "message": "Something went wrong. Please try again."};
    }
  }

  // ==========================
  // API Signup
  // ==========================
  Future<Map<String, dynamic>> registerWithAPI({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? profilePhoto,
  }) async {
    return await _handleApiCall(
      DioClient().postRequest(
        Endpoints.REGISTER,
        data: {
          "name": name,
          "email": email,
          "password": password,
          "phone": phone,
          "profilePhoto": profilePhoto,
        },
        rethrowError: true,
      ),
    );
  }

  // ==========================
  // Verify OTP API (Signup) - Production Ready
  // ==========================
  Future<Map<String, dynamic>> verifySignupOtp({
    required String email,
    required String otp,
    String? deviceId,
    String? deviceModel,
    String? deviceBrand,
    String? deviceOS,
    String? deviceType,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        "email": email.trim(),
        "otp": otp.trim(),
      };

      // Add device info if provided
      if (deviceId != null && deviceId.isNotEmpty) {
        requestData["deviceId"] = deviceId;
      }
      if (deviceModel != null && deviceModel.isNotEmpty) {
        requestData["deviceModel"] = deviceModel;
      }
      if (deviceBrand != null && deviceBrand.isNotEmpty) {
        requestData["deviceBrand"] = deviceBrand;
      }
      if (deviceOS != null && deviceOS.isNotEmpty) {
        requestData["deviceOS"] = deviceOS;
      }
      if (deviceType != null && deviceType.isNotEmpty) {
        requestData["deviceType"] = deviceType;
      }

      final response = await DioClient().postRequest(
        Endpoints.REGISTER_VERIFY_OTP,
        data: requestData,
      );

      if (response?.data == null) {
        return _errorResponse("Something went wrong. Please try again.");
      }

      final responseData = response?.data;

      final status = responseData["status"]?.toString().toLowerCase();
      bool success = status == "success";

      return {
        "status": success,
        "message": success
            ? "OTP verified successfully."
            : (responseData["message"] ?? "Invalid OTP. Please try again."),
        "data": success ? responseData : null,
      };
    } on DioException catch (e) {
      debugPrint("DIO ERROR → ${e.message} | ${e.response?.statusCode}");

      if (e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'] ??
                         responseData['headers']?['message'] ??
                         "Invalid OTP. Please try again.";
          return _errorResponse(message.toString());
        }
      }

      return _errorResponse(
        e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.receiveTimeout
            ? "Network timeout. Please check your connection."
            : "Unable to verify OTP right now. Please try again.",
      );
    } catch (e) {
      debugPrint("UNKNOWN ERROR: $e");
      return _errorResponse("Something went wrong. Please try again later.");
    }
  }

  // Reusable error response
  Map<String, dynamic> _errorResponse(String message) {
    return {"status": false, "message": message};
  }

  // ==========================
  // Resend OTP API
  // ==========================
  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    try {
      final response = await DioClient().postRequest(
        Endpoints.REQUEST_OTP,
        data: {"email": email.trim()},
      );

      if (response == null || response.data == null) {
        return {
          "headers": {
            "statusCode": 500,
            "status": "failed",
            "message": "No response from server.",
          },
        };
      }

      final data = response.data;

      return {
        "headers": {
          "statusCode": response.statusCode ?? 200,
          "status": (data["status"] ?? "failed").toString(),
          "message": data["message"] ?? "No message from server",
        },
      };
    } on DioException catch (e) {
      return {
        "headers": {
          "statusCode": e.response?.statusCode ?? 500,
          "status": "failed",
          "message": e.response?.statusMessage ?? "Network or server error",
        },
      };
    } catch (e) {
      return {
        "headers": {
          "statusCode": 500,
          "status": "failed",
          "message": "Unexpected error: $e",
        },
      };
    }
  }

  // ==========================
  // Check Email Availability
  // ==========================
  Future<Map<String, dynamic>> checkEmailAvailability(String email) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.BASE_URL,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ));

      print('📧 Calling checkEmailAvailability: ${AppConstants.BASE_URL}${Endpoints.CHECK_EMAIL_AVAILABILITY}/$email');

      final response = await dio.get(
        "${Endpoints.CHECK_EMAIL_AVAILABILITY}/$email",
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('📧 checkEmailAvailability response: $data');

        final headers = data['headers'] ?? {};
        final responseData = data['data'] ?? {};
        final bool isAvailable = responseData['available'] == true;

        return {
          "available": isAvailable,
          "message": headers['message'] ?? (isAvailable ? "Email not found" : "Email already exists"),
        };
      }

      return {
        "available": false,
        "message": "Unexpected server response (${response.statusCode}).",
      };
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {
          "available": false,
          "message": "Connection timed out. Try again.",
        };
      } else if (e.error is SocketException) {
        return {"available": false, "message": "No internet connection."};
      } else if (e.response != null) {
        return {
          "available": false,
          "message":
              "Server error: ${e.response?.statusMessage ?? 'Unknown error'}",
        };
      } else {
        return {
          "available": false,
          "message": "Something went wrong. Please retry.",
        };
      }
    } catch (e, s) {
      print("checkEmailAvailability() error: $e\n$s");
      return {"available": false, "message": "Unexpected error occurred."};
    }
  }

  // ==========================
  // API Login
  // ==========================
  Future<Map<String, dynamic>> loginWithAPI({
    required String email,
    required String password,
    String? deviceId,
    String? deviceModel,
    String? deviceBrand,
    String? deviceOS,
    String? deviceType,
  }) async {
    final Map<String, dynamic> data = {
      "email": email,
      "password": password,
    };

    // Add device info if provided
    if (deviceId != null && deviceId.isNotEmpty) {
      data["deviceId"] = deviceId;
    }
    if (deviceModel != null && deviceModel.isNotEmpty) {
      data["deviceModel"] = deviceModel;
    }
    if (deviceBrand != null && deviceBrand.isNotEmpty) {
      data["deviceBrand"] = deviceBrand;
    }
    if (deviceOS != null && deviceOS.isNotEmpty) {
      data["deviceOS"] = deviceOS;
    }
    if (deviceType != null && deviceType.isNotEmpty) {
      data["deviceType"] = deviceType;
    }

    return await _handleApiCall(
      DioClient().postRequest(
        Endpoints.LOGIN,
        data: data,
        rethrowError: true,
      ),
    );
  }

  // ==========================
  // AuthService: Forgot Password via API (Production Ready)
  // ==========================
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await DioClient().postRequest(
        Endpoints.FORGET_PASSWORD,
        data: {"email": email.trim()},
        responseType: ResponseType.plain,
      );

      if (response == null) {
        return {"result": false, "message": "No response from server."};
      }

      final data = response.data;

      if (data == null) {
        return {"result": false, "message": "Empty response from server."};
      }

      // Case 1: Plain text from backend
      if (data is String) {
        final msg = data.trim();
        if (msg.toLowerCase().contains("otp") ||
            msg.toLowerCase().contains("sent")) {
          return {"result": true, "message": msg};
        } else {
          return {"result": false, "message": msg};
        }
      }

      // Case 2: JSON object from backend
      if (data is Map<String, dynamic>) {
        return {
          "result": data["result"] ?? data["success"] ?? false,
          "message": data["message"]?.toString() ?? "No message from server.",
          "otp": data["otp"],
        };
      }

      // Case 3: Unexpected data type
      return {"result": false, "message": "Unexpected server response type."};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {"result": false, "message": "Connection timed out. Try again."};
      } else if (e.error is SocketException) {
        return {"result": false, "message": "No internet connection."};
      } else if (e.response != null) {
        return {
          "result": false,
          "message":
              "Server error: ${e.response?.statusMessage ?? 'Unknown error'} (${e.response?.statusCode ?? ''})",
        };
      } else {
        return {
          "result": false,
          "message": "Something went wrong. Please retry.",
        };
      }
    } catch (e, s) {
      print("forgotPassword() error: $e\n$s");
      return {"result": false, "message": "Unexpected error occurred."};
    }
  }

  // ==========================
  // AuthService: Verify OTP via API
  // ==========================
  Future<Map<String, dynamic>> verifyOtpApi({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await DioClient().postRequest(
        Endpoints.VERIFY_OTP,
        data: {"email": email.trim(), "otp": otp.trim()},
        responseType: ResponseType.plain,
      );

      if (response == null) {
        return {"success": false, "message": "No response from server."};
      }

      final data = response.data;

      // Case 1: Plain text response
      if (data is String) {
        final msg = data.trim();
        if (msg.toLowerCase().contains("verified")) {
          return {"success": true, "message": msg};
        } else {
          return {"success": false, "message": msg};
        }
      }

      // Case 2: JSON object response
      if (data is Map<String, dynamic>) {
        return {
          "success": data["success"] ?? data["result"] ?? false,
          "message": data["message"]?.toString() ?? "No message from server.",
        };
      }
      // Unexpected data type
      return {"success": false, "message": "Unexpected server response type."};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {
          "success": false,
          "message": "Connection timed out. Try again.",
        };
      } else if (e.error is SocketException) {
        return {"success": false, "message": "No internet connection."};
      } else if (e.response != null) {
        return {
          "success": false,
          "message":
              "Server error: ${e.response?.statusMessage ?? 'Unknown error'} (${e.response?.statusCode ?? ''})",
        };
      } else {
        return {
          "success": false,
          "message": "Something went wrong. Please retry.",
        };
      }
    } catch (e, s) {
      print("verifyOtpApi() error: $e\n$s");
      return {"success": false, "message": "Unexpected error occurred."};
    }
  }

  // ==========================
  // AuthService: Reset Password via API
  // ==========================
  Future<Map<String, dynamic>> sendResetPasswordEmail({
    required String email,
  }) async {
    try {
      final response = await Dio().post(
        Endpoints.RESET_PASSWORD,
        data: {"email": email.trim()},
      );

      if (response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return {
            "success": data["success"] ?? false,
            "message": data["message"] ?? "No message from server",
          };
        }
        if (data is String && data.toLowerCase().contains("success")) {
          return {"success": true, "message": data};
        }
      }

      return {"success": false, "message": "Unexpected server response."};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {
          "success": false,
          "message": "Connection timed out. Try again.",
        };
      } else if (e.error is SocketException) {
        return {"success": false, "message": "No internet connection."};
      } else if (e.response != null) {
        return {
          "success": false,
          "message":
              "Server error: ${e.response?.statusMessage ?? 'Unknown error'} (${e.response?.statusCode ?? ''})",
        };
      }
      return {
        "success": false,
        "message": "Something went wrong. Please retry.",
      };
    } catch (e) {
      return {"success": false, "message": "Unexpected error occurred."};
    }
  }

  // ==========================
  // AuthService: Reset Password via API (Final Fixed Version)
  // ==========================
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await DioClient().postRequest(
        Endpoints.RESET_PASSWORD,
        data: {
          "email": email.trim(),
          "newPassword": newPassword.trim(),
          "confirmPassword": confirmPassword.trim(),
        },
        responseType: ResponseType.plain,
      );

      if (response == null) {
        return {"success": false, "message": "No response from server."};
      }

      dynamic data;
      try {
        data =
            response.data is String ? jsonDecode(response.data) : response.data;
      } catch (_) {
        data = response.data;
      }

      // Case 1: JSON response
      if (data is Map<String, dynamic>) {
        final status =
            data["status"]?.toString().toLowerCase() == "true" ||
            data["success"] == true;
        final message =
            data["message"]?.toString() ?? "Password updated successfully.";
        return {"success": status, "message": message};
      }

      // Case 2: Plain text response
      if (data is String) {
        final msg = data.trim();
        return {
          "success": msg.toLowerCase().contains("success"),
          "message": msg,
        };
      }

      // Fallback
      return {"success": false, "message": "Unexpected server response."};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {
          "success": false,
          "message": "Connection timed out. Try again.",
        };
      } else if (e.error is SocketException) {
        return {"success": false, "message": "No internet connection."};
      } else if (e.response != null) {
        return {
          "success": false,
          "message":
              "Server error: ${e.response?.statusMessage ?? 'Unknown error'} (${e.response?.statusCode ?? ''})",
        };
      }
      return {
        "success": false,
        "message": "Something went wrong. Please retry.",
      };
    } catch (e) {
      print("resetPassword() error: $e");
      return {"success": false, "message": "Unexpected error occurred."};
    }
  }

  // ==========================
  // signOut (API only)
  // ==========================
  Future<Map<String, dynamic>> signOutUser() async {
    try {
      // LOGOUT FROM API
      try {
        final response = await DioClient().dio.post(
          Endpoints.LOGOUT,
          options: Options(
            headers: {"Authorization": "Bearer ${Preference.token}"},
          ),
        );

        print("🚪 Logout API → ${response.data}");
      } catch (e) {
        print("API logout error → $e");
      }

      // CLEAR STORAGE
      Preference.clearAll();

      return {"success": true, "message": "Logged out successfully"};
    } catch (e) {
      print("Logout error → $e");
      return {"success": false, "message": "Logout failed"};
    }
  }

  // ==========================
  // Send Login OTP (Phone Authentication)
  // ==========================
  Future<Map<String, dynamic>> sendLoginOtp({
    required String countryCode,
    required String phone,
  }) async {
    try {
      final response = await DioClient().postRequest(
        Endpoints.SEND_LOGIN_OTP,
        data: {
          "countryCode": countryCode.trim(),
          "phone": phone.trim(),
        },
      );

      if (response == null || response.data == null) {
        return {"success": false, "message": "No response from server."};
      }

      final data = response.data;

      if (data is Map<String, dynamic>) {
        final isSuccess = data['sucess']?.toString().toLowerCase() == 'true' ||
            data['success']?.toString().toLowerCase() == 'true';

        return {
          "success": isSuccess,
          "message": data['message'] ?? (isSuccess ? "OTP sent successfully" : "Failed to send OTP"),
          "phone": data['phone'] ?? "$countryCode$phone",
        };
      }

      if (data is String) {
        final msg = data.trim().toLowerCase();
        return {
          "success": msg.contains("success") || msg.contains("sent"),
          "message": data.trim(),
        };
      }

      return {"success": false, "message": "Unexpected server response."};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {"success": false, "message": "Connection timed out. Try again."};
      } else if (e.error is SocketException) {
        return {"success": false, "message": "No internet connection."};
      } else if (e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'] ?? "Failed to send OTP.";
          return {"success": false, "message": message.toString()};
        }
      }
      return {"success": false, "message": "Something went wrong. Please retry."};
    } catch (e) {
      print("sendLoginOtp() error: $e");
      return {"success": false, "message": "Unexpected error occurred."};
    }
  }

  // ==========================
  // Verify Login OTP (Phone Authentication)
  // ==========================
  Future<Map<String, dynamic>> verifyLoginOtp({
    required String phone,
    required String otp,
    String? deviceId,
    String? deviceModel,
    String? deviceBrand,
    String? deviceOS,
    String? deviceType,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        "phone": phone.trim(),
        "otp": otp.trim(),
      };

      // Add device info if provided
      if (deviceId != null && deviceId.isNotEmpty) {
        requestData["deviceId"] = deviceId;
      }
      if (deviceModel != null && deviceModel.isNotEmpty) {
        requestData["deviceModel"] = deviceModel;
      }
      if (deviceBrand != null && deviceBrand.isNotEmpty) {
        requestData["deviceBrand"] = deviceBrand;
      }
      if (deviceOS != null && deviceOS.isNotEmpty) {
        requestData["deviceOS"] = deviceOS;
      }
      if (deviceType != null && deviceType.isNotEmpty) {
        requestData["deviceType"] = deviceType;
      }

      final response = await DioClient().postRequest(
        Endpoints.VERIFY_LOGIN_OTP,
        data: requestData,
        rethrowError: true,
      );

      if (response == null || response.data == null) {
        return {"success": false, "message": "No response from server."};
      }

      final data = response.data;

      if (data is Map<String, dynamic>) {
        final successValue = data['success']?.toString().toLowerCase() ?? '';
        final hasValidData = data['data'] != null && data['data']['accessToken'] != null;
        final isSuccess = successValue == 'true' || successValue == 'tue' || hasValidData;

        if (isSuccess) {
          final userData = data['data'] ?? {};

          return {
            "success": true,
            "message": data['message'] ?? "Login successful",
            "data": {
              "accessToken": userData['accessToken'] ?? '',
              "userId": userData['userId'] ?? 0,
              "email": userData['email'] ?? '',
              "name": userData['name'] ?? userData['fullName'] ?? '',
              "profilePhoto": userData['profilePhoto'] ?? userData['profileImageUrl'] ?? '',
              "phone": userData['phone'] ?? phone,
              "role": userData['role'] ?? 'USER',
            },
          };
        }

        return {
          "success": false,
          "message": data['message'] ?? "Invalid OTP. Please try again.",
        };
      }

      return {"success": false, "message": "Unexpected server response."};
    } on DioException catch (e) {
      print("verifyLoginOtp() DioException: ${e.type} - ${e.message}");
      print("verifyLoginOtp() Response data: ${e.response?.data}");

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {"success": false, "message": "Connection timed out. Try again."};
      } else if (e.error is SocketException) {
        return {"success": false, "message": "No internet connection."};
      } else if (e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'] ??
                         responseData['error'] ??
                         "Invalid OTP. Please try again.";
          return {"success": false, "message": message.toString()};
        } else if (responseData is String) {
          return {"success": false, "message": responseData};
        }
      }
      return {"success": false, "message": "Something went wrong. Please retry."};
    } catch (e) {
      print("verifyLoginOtp() error: $e");
      return {"success": false, "message": "Unexpected error occurred."};
    }
  }

  // ==========================
  // Resend Login OTP
  // ==========================
  Future<Map<String, dynamic>> resendLoginOtp({required String phone}) async {
    try {
      final response = await DioClient().postRequest(
        Endpoints.RESEND_LOGIN_OTP,
        data: {"phone": phone.trim()},
      );

      if (response == null || response.data == null) {
        return {"success": false, "message": "No response from server."};
      }

      final data = response.data;

      if (data is Map<String, dynamic>) {
        final isSuccess = data['success']?.toString().toLowerCase() == 'true';

        return {
          "success": isSuccess,
          "message": data['message'] ?? (isSuccess ? "OTP resent successfully" : "Failed to resend OTP"),
        };
      }

      return {"success": false, "message": "Unexpected server response."};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {"success": false, "message": "Connection timed out. Try again."};
      } else if (e.error is SocketException) {
        return {"success": false, "message": "No internet connection."};
      } else if (e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'] ?? "Failed to resend OTP.";
          return {"success": false, "message": message.toString()};
        }
      }
      return {"success": false, "message": "Something went wrong. Please retry."};
    } catch (e) {
      print("resendLoginOtp() error: $e");
      return {"success": false, "message": "Unexpected error occurred."};
    }
  }

  // ==========================
  // DeleteAccount (API only)
  // ==========================
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      // DELETE FROM API
      try {
        final response = await DioClient().dio.delete(
          Endpoints.DELETE_ACCOUNT,
          data: {"email": Preference.email},
          options: Options(
            headers: {"Authorization": "Bearer ${Preference.token}"},
          ),
        );

        print("API account deleted → ${response.data}");
      } catch (e) {
        print("API delete error: $e");
      }

      // CLEAR ALL DATA
      Preference.clearAll();

      return {"success": true, "message": "Account deleted successfully"};
    } catch (e) {
      print("deleteAccount() error: $e");
      return {"success": false, "message": "Failed to delete account"};
    }
  }
}
