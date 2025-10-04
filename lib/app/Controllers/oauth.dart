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
    String profilePhoto = "",
  }) async {
    try {
      final response = await DioClient().postRequest(
        Endpoints.register,
        data: {
          "name": name,
          "email": email,
          "password": password,
          "profilePhoto": profilePhoto,
        },
      );
      return response.data;
    } on DioException catch (e) {
      print("API signup error: ${e.response?.data ?? e.message}");
      return {
        "result": false,
        "message": e.response?.data['message'] ?? e.message,
      };
    } catch (e) {
      print("API signup unknown error: $e");
      return {"result": false, "message": e.toString()};
    }
  }

  // ==========================
  // API Login
  // ==========================
  Future<Map<String, dynamic>> loginWithAPI({
    required String email,
    required String password,
  }) async {
    try {
      final response = await DioClient().postRequest(
        Endpoints.login,
        data: {"email": email, "password": password},
      );
      return response.data;
    } on DioException catch (e) {
      print("API login error: ${e.response?.data ?? e.message}");
      return {
        "result": false,
        "message": e.response?.data['message'] ?? e.message,
      };
    } catch (e) {
      print("API login unknown error: $e");
      return {"result": false, "message": e.toString()};
    }
  }

  // ==========================
  // AuthService: Reset Password via API
  // ==========================
  Future<Map<String, dynamic>> resetPasswordWithAPI({
    required String email,
  }) async {
    try {
      final response = await DioClient().postRequest(
        Endpoints.forgetPassword, // Your API endpoint
        data: {"email": email.trim()},
      );
      return response.data;
    } on DioException catch (e) {
      print("API reset password error: ${e.response?.data ?? e.message}");
      return {
        "result": false,
        "message": e.response?.data['message'] ?? e.message,
      };
    } catch (e) {
      print("Unknown error in reset password: $e");
      return {"result": false, "message": e.toString()};
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
