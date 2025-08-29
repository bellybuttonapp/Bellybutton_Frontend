// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- Register ---
  Future<UserCredential?> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user!.updateDisplayName(name);
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Registration error: ${e.message}');
      return null;
    }
  }

  // --- Sign in ---
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Sign-in error: ${e.message}');
      rethrow;
    }
  }

  // --- Reset password ---
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Reset password error: ${e.message}');
    }
  }

  // --- Google Sign-In ---
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

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

  // --- Update display name ---
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
      print("Error updating username: $e");
    }
  }

  // --- Update profile photo ---
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
      print("Failed to update profile photo: $e");
    }
  }

  // --- Delete account ---
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
      }
    } catch (e) {
      print("Delete account error: $e");
    }
  }

  // --- Sign out ---
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
