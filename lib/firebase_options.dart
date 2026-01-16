import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Use best-effort web options (using android apiKey/projectId)
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        // Return android as fallback instead of throwing
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDgmDaBYk404zpfrRxxmDl3N5S5bYw1W6I",
    appId: "1:934918414242:web:7f8e7d6c5b4a3f2e1d0c9b", // Fallback Web ID
    messagingSenderId: "934918414242",
    projectId: "mindnest-fa744",
    authDomain: "mindnest-fa744.firebaseapp.com",
    storageBucket: "mindnest-fa744.firebasestorage.app",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDgmDaBYk404zpfrRxxmDl3N5S5bYw1W6I",
    appId: "1:934918414242:android:17c9fdd10833330ab39cfb",
    messagingSenderId: "934918414242",
    projectId: "mindnest-fa744",
    storageBucket: "mindnest-fa744.firebasestorage.app",
  );
}
