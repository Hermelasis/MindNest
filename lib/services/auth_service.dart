import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'local_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '934918414242-l62qiarjskhpm57r2gg47mp5e0315i9n.apps.googleusercontent.com' : null,
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth changes
  Stream<User?> get user => _auth.authStateChanges();

  // Sign Up
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Anti-Gravity: Initialize Firestore in BACKGROUND to prevent UI blocks
      // We don't 'await' this so the user can proceed immediately
      _backgroundInitializeFirestore(userCredential.user);
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "An error occurred during sign up";
    } catch (e) {
      throw e.toString();
    }
  }

  // Login
  Future<UserCredential?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Anti-Gravity: Wake up Firestore in background
      _firestore.enableNetwork().catchError((_) {});
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "An error occurred during login";
    } catch (e) {
      throw e.toString();
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print("AuthService: Starting Google Sign-In...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print("AuthService: Google Sign-In cancelled by user or failed (null account).");
        return null;
      }
      print("AuthService: Google account retrieved: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print("AuthService: Google Authentication tokens retrieved.");

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("AuthService: Signing in to Firebase with Google credentials...");
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      print("AuthService: Firebase Sign-In successful for UID: ${userCredential.user?.uid}");
      
      // Anti-Gravity: Background Firestore initialization
      // This allows the UI to navigate IMMEDIATELY without waiting for Firestore
      print("AuthService: Kicking off background Firestore initialization...");
      _backgroundInitializeFirestore(userCredential.user);
      
      return userCredential;
    } catch (e, stacktrace) {
      print("AuthService: Error during Google Sign-In: $e");
      print("AuthService: Stacktrace: $stacktrace");
      throw e.toString();
    }
  }

  /// Anti-Gravity: Background helper to initialize user data without blocking UI
  Future<void> _backgroundInitializeFirestore(User? user) async {
    if (user == null) return;
    
    // We run the resilient initialization in the background
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Brief wait for auth propagation
      await _firestore.enableNetwork();
      final doc = await _runResiliently(() => _initializeUserInFirestore(user));
      
      // Update local cache with latest Firestore data
      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        await LocalAuthService.updateUser(
          username: data['displayName'] ?? data['username'],
          email: data['email'],
        );
      }
      
      print("AuthService: Background Firestore initialization COMPLETED for ${user.uid}");
    } catch (e) {
      print("AuthService: Background Firestore initialization failed (user still signed in): $e");
      // Note: We don't rethrow here because this is a background task
    }
  }

  /// Anti-Gravity: Helper to run Firestore operations with automatic network recovery
  Future<T> _runResiliently<T>(Future<T> Function() action) async {
    int attempts = 0;
    const maxAttempts = 2; // Reduced attempts for background sync
    
    while (attempts < maxAttempts) {
      try {
        attempts++;
        return await action().timeout(const Duration(seconds: 10));
      } catch (e) {
        String error = e.toString().toLowerCase();
        bool isOffline = error.contains('unavailable') || 
                         error.contains('offline') || 
                         error.contains('timeout');

        if (isOffline && attempts < maxAttempts) {
          print("AuthService: Firestore background retry (Attempt $attempts)...");
          await _firestore.enableNetwork();
          await Future.delayed(Duration(milliseconds: 1000 * attempts));
          continue;
        }
        rethrow;
      }
    }
    throw "Firestore operation failed after maximum retries.";
  }

  // Initialize user document in Firestore if it doesn't exist
  Future<DocumentSnapshot?> _initializeUserInFirestore(User? user) async {
    if (user == null) return null;
    
    final userDoc = _firestore.collection('users').doc(user.uid);
    
    // Attempt local-first fetch to be fast, fallback to server if not found
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
      return await userDoc.get(); // Refresh to get the created doc
    } else {
      await userDoc.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      return docSnapshot;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
    await LocalAuthService.signOut();
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "An error occurred during password reset";
    } catch (e) {
      throw e.toString();
    }
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
