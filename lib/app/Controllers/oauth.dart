// ignore_for_file: avoid_print, unused_field

import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../api/end_points.dart';
import '../core/utils/storage/preference.dart';

class AuthService {
  // ---------- Firebase ----------
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '480572814025-n6561pfngtku0nbvv70v1k9uuphnluhd.apps.googleusercontent.com',
  );
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ---------- API / Dio ----------
  final Dio _dio = DioClient().dio;

  // ---------- Firebase User ----------
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
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
  // Firebase Google Sign-In (Local only)
  // ==========================
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Start Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled login

      // Get Google authentication details
      final googleAuth = await googleUser.authentication;

      // Create a Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // ✅ Get Firebase ID Token safely (non-null fallback)
        final String idToken = await user.getIdToken() ?? '';

        // ✅ Debug print (optional)
        print('🔥 Firebase ID Token: $idToken');

        // ✅ Save user info to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName,
          'email': user.email,
          'photoUrl': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // ✅ Save user info locally in Hive (Preference)
        Preference.token = idToken;
        Preference.userName = user.displayName ?? '';
        Preference.email = user.email ?? '';
        Preference.profileImage = user.photoURL ?? '';
        Preference.isLoggedIn = true;

        print('✅ User data saved to local storage');
      }

      return userCredential;
    } catch (e, s) {
      print('❌ Google sign-in error: $e');
      print('Stacktrace: $s');
      return null;
    }
  }

  // ==========================
  // Get Google User Info (without backend login)
  // ==========================
  Future<Map<String, dynamic>> getGoogleUserInfo() async {
    try {
      // Start Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {"success": false, "message": "Google sign-in canceled"};
      }

      // Get Google authentication details
      final googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return {"success": false, "message": "Failed to get Google ID token"};
      }

      print('🔥 Google User Info → ${googleUser.email}');

      return {
        "success": true,
        "email": googleUser.email,
        "name": googleUser.displayName ?? '',
        "photoUrl": googleUser.photoUrl ?? '',
        "idToken": idToken,
      };
    } catch (e, s) {
      print('❌ Google sign-in error: $e');
      print('Stacktrace: $s');
      return {"success": false, "message": "Google sign-in failed"};
    }
  }

  // ==========================
  // Google Sign-In with Backend API (using existing token)
  // ==========================
  Future<Map<String, dynamic>> signInWithGoogleAPIWithToken(String idToken) async {
    try {
      print('🔥 Google ID Token: $idToken');

      // Send ID token to backend API
      final response = await DioClient().dio.post(
        Endpoints.GOOGLE_LOGIN,
        data: {"token": idToken},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final headers = data['headers'] ?? {};
        final userData = data['data'] ?? {};

        final isSuccess =
            headers['status'] == 'success' || headers['statusCode'] == 200;

        if (isSuccess) {
          // ✅ Save user data to local storage
          Preference.token = userData['accessToken'] ?? '';
          Preference.userId = userData['userId'] ?? 0;
          Preference.email = userData['email'] ?? '';
          Preference.userName = userData['name'] ?? '';
          Preference.isLoggedIn = true;

          print('✅ Google login successful → User: ${userData['name']}');

          return {
            "success": true,
            "message": headers['message'] ?? "Google login successful",
            "data": userData,
          };
        }

        return {
          "success": false,
          "message": headers['message'] ?? "Google login failed",
        };
      }

      return {"success": false, "message": "Unexpected server response"};
    } on DioException catch (e) {
      print('❌ Google API login error: ${e.message}');
      if (e.error is SocketException) {
        return {"success": false, "message": "No internet connection"};
      }
      return {
        "success": false,
        "message": e.response?.data?['headers']?['message'] ?? "Network error",
      };
    } catch (e, s) {
      print('❌ Google sign-in API error: $e');
      print('Stacktrace: $s');
      return {"success": false, "message": "Google sign-in failed"};
    }
  }

  // ==========================
  // Google Sign-In with Backend API
  // ==========================
  Future<Map<String, dynamic>> signInWithGoogleAPI() async {
    try {
      // 1️⃣ Start Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {"success": false, "message": "Google sign-in canceled"};
      }

      // 2️⃣ Get Google authentication details
      final googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return {"success": false, "message": "Failed to get Google ID token"};
      }

      print('🔥 Google ID Token: $idToken');

      // 3️⃣ Send ID token to backend API
      final response = await DioClient().dio.post(
        Endpoints.GOOGLE_LOGIN,
        data: {"token": idToken},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final headers = data['headers'] ?? {};
        final userData = data['data'] ?? {};

        final isSuccess =
            headers['status'] == 'success' || headers['statusCode'] == 200;

        if (isSuccess) {
          // ✅ Save user data to local storage
          Preference.token = userData['accessToken'] ?? '';
          Preference.userId = userData['userId'] ?? 0;
          Preference.email = userData['email'] ?? '';
          Preference.userName = userData['name'] ?? '';
          Preference.isLoggedIn = true;

          print('✅ Google login successful → User: ${userData['name']}');

          return {
            "success": true,
            "message": headers['message'] ?? "Google login successful",
            "data": userData,
          };
        }

        return {
          "success": false,
          "message": headers['message'] ?? "Google login failed",
        };
      }

      return {"success": false, "message": "Unexpected server response"};
    } on DioException catch (e) {
      print('❌ Google API login error: ${e.message}');
      if (e.error is SocketException) {
        return {"success": false, "message": "No internet connection"};
      }
      return {
        "success": false,
        "message": e.response?.data?['headers']?['message'] ?? "Network error",
      };
    } catch (e, s) {
      print('❌ Google sign-in API error: $e');
      print('Stacktrace: $s');
      return {"success": false, "message": "Google sign-in failed"};
    }
  }

  // ==========================
  // API Signup
  // ==========================
  Future<Map<String, dynamic>> registerWithAPI({
    required String name,
    required String email,
    required String password,
    required String phone, // <-- added
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

      // ✅ Handle direct response format (without nested headers)
      // Expected format:
      // {
      //   "userId": 62,
      //   "email": "as7@yopmail.com",
      //   "status": "success",
      //   "accessToken": "...",
      //   "device": {...}
      // }

      final status = responseData["status"]?.toString().toLowerCase();
      bool success = status == "success";

      return {
        "status": success,
        "message": success
            ? "OTP verified successfully."
            : (responseData["message"] ?? "Invalid OTP. Please try again."),
        "data": success ? responseData : null, // ✅ Return the entire response as data
      };
    } on DioException catch (e) {
      // Log internally for debugging, do not expose to user
      debugPrint("DIO ERROR → ${e.message} | ${e.response?.statusCode}");

      // Extract error message from API response if available
      if (e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          // Try to get message from different possible locations
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
      // Catch any other error safely
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
        Endpoints.REQUEST_OTP, // "/userresource/resend-otp"
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
      // 🚀 Use DioClient but OVERRIDE headers for this one request
      final response = await DioClient().dio.post(
        "${Endpoints.CHECK_EMAIL_AVAILABILITY}/$email",
        options: Options(
          headers: {
            "Authorization": "", // 🚀 Force remove token for THIS request only
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final bool emailNotFound = data['status']?.toString() == 'false';

        return emailNotFound
            ? {
              "available": true,
              "message": "Email not found. You can register.",
            }
            : {
              "available": false,
              "message": "Email already exists. Please log in.",
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
        responseType: ResponseType.plain, // handle both text & JSON
      );

      if (response == null) {
        return {"result": false, "message": "No response from server."};
      }

      // Handle various possible response formats
      final data = response.data;

      if (data == null) {
        return {"result": false, "message": "Empty response from server."};
      }

      // ✅ Case 1: Plain text from backend
      if (data is String) {
        final msg = data.trim();
        if (msg.toLowerCase().contains("otp") ||
            msg.toLowerCase().contains("sent")) {
          return {"result": true, "message": msg};
        } else {
          return {"result": false, "message": msg};
        }
      }

      // ✅ Case 2: JSON object from backend
      if (data is Map<String, dynamic>) {
        return {
          "result": data["result"] ?? data["success"] ?? false,
          "message": data["message"]?.toString() ?? "No message from server.",
          "otp": data["otp"],
        };
      }

      // ❌ Case 3: Unexpected data type
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
        responseType: ResponseType.plain, // handle both text & JSON
      );

      if (response == null) {
        return {"success": false, "message": "No response from server."};
      }

      final data = response.data;

      // ✅ Case 1: Plain text response
      if (data is String) {
        final msg = data.trim();
        if (msg.toLowerCase().contains("verified")) {
          return {"success": true, "message": msg};
        } else {
          return {"success": false, "message": msg};
        }
      }

      // ✅ Case 2: JSON object response
      if (data is Map<String, dynamic>) {
        return {
          "success": data["success"] ?? data["result"] ?? false,
          "message": data["message"]?.toString() ?? "No message from server.",
        };
      }
      // ❌ Unexpected data type
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
        Endpoints.RESET_PASSWORD, // Make sure endpoint is correct
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
        responseType: ResponseType.plain, // ✅ Handles both text & JSON
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

      // ✅ Case 1: JSON response
      if (data is Map<String, dynamic>) {
        final status =
            data["status"]?.toString().toLowerCase() == "true" ||
            data["success"] == true;
        final message =
            data["message"]?.toString() ?? "Password updated successfully.";
        return {"success": status, "message": message};
      }

      // ✅ Case 2: Plain text response
      if (data is String) {
        final msg = data.trim();
        return {
          "success": msg.toLowerCase().contains("success"),
          "message": msg,
        };
      }

      // ❌ Fallback
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
  // signOut (Firebase + API)
  // ==========================
  Future<Map<String, dynamic>> signOutUser() async {
    try {
      // 1️⃣ LOGOUT FROM API (FORCE TOKEN)
      try {
        final response = await DioClient().dio.post(
          Endpoints.LOGOUT, // "/userresource/logout-post"
          options: Options(
            headers: {"Authorization": "Bearer ${Preference.token}"},
          ),
        );

        print("🚪 Logout API → ${response.data}");
      } catch (e) {
        print("API logout error → $e");
      }

      // 2️⃣ SIGN OUT FROM FIREBASE
      try {
        await _auth.signOut();
        await _googleSignIn.signOut();
      } catch (e) {
        print("Firebase signOut error → $e");
      }

      // 3️⃣ CLEAR STORAGE
      Preference.clearAll();

      return {"success": true, "message": "Logged out successfully"};
    } catch (e) {
      print("Logout error → $e");
      return {"success": false, "message": "Logout failed"};
    }
  }

  // ==========================
  // Firebase: Update Name / Photo
  // ==========================
  Future<void> updateDisplayName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        await _firestore.collection('users').doc(user.uid).update({
          'name': newName,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Update name error: $e");
    }
  }

  // ==========================
  // updatePhoto (Firebase)
  // ==========================

  Future<void> updatePhoto(String filePath) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final file = File(filePath);
      final ref = _storage.ref().child('user_photos/${user.uid}.jpg');
      await ref.putFile(file);
      final photoUrl = await ref.getDownloadURL();

      await user.updatePhotoURL(photoUrl);
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Update photo error: $e");
    }
  }

  // ==========================
  // DeleteAccount (Firebase + API)
  // ==========================
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final user = _auth.currentUser;

      // 1️⃣ DELETE FROM API (FORCING TOKEN)
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

      // 2️⃣ DELETE FROM FIREBASE
      try {
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).delete();
          await user.delete();
          print("Firebase account deleted");
        }
      } catch (e) {
        print("Firebase delete error: $e");
      }

      // 3️⃣ CLEAR ALL DATA
      Preference.clearAll();

      return {"success": true, "message": "Account deleted successfully"};
    } catch (e) {
      print("deleteAccount() error: $e");
      return {"success": false, "message": "Failed to delete account"};
    }
  }
}