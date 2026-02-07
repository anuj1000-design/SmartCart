import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // GoogleSignIn instance for native sign-in
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user role from Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc['role'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Set user role in Firestore
  Future<void> setUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).set({
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Sign in with Email & Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login time
      await _firestore.collection('users').doc(result.user!.uid).set({
        'lastLoginTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign up with Email & Password
  Future<UserCredential?> signUpWithEmail(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update display name
      await result.user?.updateDisplayName(name);
      
      // Create complete user profile in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'displayName': name,
        'role': role,
        'phone': '',
        'avatarEmoji': '👤',
        'isSuspended': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginTime': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ User profile created: $name ($email)');
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google (native where possible, fallback to provider)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint('🔐 Starting Google Sign-In...');
      // Try native sign-in first (uses Play Services on Android)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      debugPrint('👤 Google user: ${googleUser?.email ?? "null"}');
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        debugPrint('🔑 Got authentication tokens');

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        debugPrint('✅ Firebase sign-in successful');

        // Create or update user profile in Firestore
        await _createOrUpdateUserProfile(userCredential.user!);
        return userCredential;
      }

      debugPrint('🔄 Falling back to provider-based flow');
      // If user cancelled native flow or it isn't available, fall back to provider-based flow
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      googleProvider.setCustomParameters({'prompt': 'select_account'});

      final UserCredential userCredential = await _auth.signInWithProvider(
        googleProvider,
      );

      // Create or update user profile in Firestore
      await _createOrUpdateUserProfile(userCredential.user!);
      return userCredential;
    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      final msg = e.toString();
      // Detect common Play Services / OAuth misconfig issues and give actionable guidance
      if (msg.contains('DEVELOPER_ERROR') ||
          msg.contains('Unknown calling package') ||
          msg.contains('developer_error')) {
        debugPrint('🚨 DEVELOPER_ERROR detected - check SHA fingerprints and google-services.json');
        throw 'Google Sign-In failed: DEVELOPER_ERROR detected. Likely causes: SHA-1/SHA-256 fingerprints for your app are not configured in Firebase, or package name / OAuth client mismatch. Add both SHA fingerprints to the Firebase Android app, re-download `google-services.json`, replace it in `android/app/`, rebuild and try again.';
      }
      throw 'Google Sign-In failed: $e';
    }
  }

  // Helper function to create or update user profile in Firestore
  Future<void> _createOrUpdateUserProfile(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      final String displayName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
      final String email = user.email ?? 'no-email@smartcart.com';
      
      if (!userDoc.exists) {
        // First time user - create complete profile
        await _firestore.collection('users').doc(user.uid).set({
          'name': displayName,
          'displayName': displayName,
          'email': email,
          'phone': user.phoneNumber ?? '',
          'avatarEmoji': '👤',
          'role': 'customer',
          'isSuspended': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastLoginTime': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ New user profile created: $displayName ($email)');
      } else {
        // Existing user - update last login and ensure name/email are set
        final Map<String, dynamic> updates = {
          'lastLoginTime': FieldValue.serverTimestamp(),
        };
        
        // Update name/email if they're missing in Firestore
        final data = userDoc.data();
        if (data?['name'] == null || data?['name'] == 'Unknown' || data?['name'] == '') {
          updates['name'] = displayName;
          updates['displayName'] = displayName;
        }
        if (data?['email'] == null || data?['email'] == '') {
          updates['email'] = email;
        }
        
        await _firestore.collection('users').doc(user.uid).update(updates);
        debugPrint('✅ User profile updated: ${data?['name'] ?? displayName}');
      }
    } catch (e) {
      debugPrint('❌ Error creating/updating user profile: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    // Sign out from Google native plugin (if used) and Firebase
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
