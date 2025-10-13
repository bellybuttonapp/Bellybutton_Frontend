// ignore_for_file: avoid_print, unused_field

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart';
import '../api/DioClient.dart';
import '../api/end_points.dart';
import '../utils/preference.dart';

class AuthService {
  // ---------- Firebase ----------
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
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
      return {"result": false};
    } catch (e) {
      print("Unexpected error: $e");
      return {"result": false};
    }
  }

  // ==========================
  // Firebase Google Sign-In
  // ==========================
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': userCredential.user!.displayName,
        'email': userCredential.user!.email,
        'photoUrl': userCredential.user!.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return userCredential;
    } catch (e) {
      print('Google sign-in error: $e');
      return null;
    }
  }

  // ==========================
  // API Signup
  // ==========================
  Future<Map<String, dynamic>> registerWithAPI({
    required String name,
    required String email,
    required String password,
    String? profilePhoto,
  }) async {
    return await _handleApiCall(
      DioClient().postRequest(
        Endpoints.register,
        data: {
          "name": name,
          "email": email,
          "password": password,
          "profilePhoto": profilePhoto,
        },
      ),
    );
  }

  // ==========================
  // Check Email Availability
  // ==========================
  Future<Map<String, dynamic>> checkEmailAvailability(String email) async {
    try {
      final response = await _dio.post(
        "${Endpoints.checkEmailAvailability}/$email",
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
  }) async {
    return await _handleApiCall(
      DioClient().postRequest(
        Endpoints.login,
        data: {"email": email, "password": password},
      ),
    );
  }

  // ==========================
  // AuthService: Forgot Password via API (Production Ready)
  // ==========================
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await DioClient().postRequest(
        Endpoints.forgetPassword,
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
        Endpoints.verifyOtp,
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
        Endpoints.resetPassword, // Make sure endpoint is correct
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
  // Firebase / Google Sign Out
  // ==========================
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      Preference.isLoggedIn = false;
      Preference.email = '';
      print("Signed out successfully");
    } catch (e) {
      print("Sign out error: $e");
      rethrow;
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
  // Delete Account (Firebase + API)
  // ==========================
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;

      // 1️⃣ Call API delete endpoint if user is logged in via API
      try {
        if (Preference.email.isNotEmpty) {
          await DioClient().postRequest(
            Endpoints
                .deleteAccount, // Make sure you have this endpoint in your API
            data: {"email": Preference.email},
          );
          print("API account deleted successfully");
        }
      } catch (apiError) {
        print("API account deletion error: $apiError");
      }

      // 2️⃣ Delete Firebase account if user exists
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        print("Firebase account deleted successfully");
      }

      // 3️⃣ Clear preferences
      Preference.clearAll();
    } catch (e) {
      print("Account deletion error: $e");
      rethrow;
    }
  }
}
