import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static const _kUserName = 'user_name';
  static const _kEmail = 'user_email';
  static const _kPassword = 'user_password';
  static const _kSignedIn = 'signed_in';
  static const _kCompletedOnboarding = 'completed_onboarding';

  static Future<void> saveUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserName, username);
    await prefs.setString(_kEmail, email);
    await prefs.setString(_kPassword, password);
    await prefs.setBool(_kSignedIn, true);
    // new users should complete onboarding flow
    await prefs.setBool(_kCompletedOnboarding, false);
  }

  static Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString(_kUserName),
      'email': prefs.getString(_kEmail),
      'password': prefs.getString(_kPassword),
    };
  }

  static Future<bool> validateCredentials(
    String usernameOrEmail,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString(_kUserName);
    final storedEmail = prefs.getString(_kEmail);
    final storedPassword = prefs.getString(_kPassword);
    if (storedPassword == null) return false;
    if ((usernameOrEmail == storedUser || usernameOrEmail == storedEmail) &&
        password == storedPassword) {
      await prefs.setBool(_kSignedIn, true);
      return true;
    }
    return false;
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSignedIn, false);
  }

  static Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSignedIn) ?? false;
  }

  static Future<void> updateUser({
    String? username,
    String? email,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (username != null) await prefs.setString(_kUserName, username);
    if (email != null) await prefs.setString(_kEmail, email);
    if (password != null) await prefs.setString(_kPassword, password);
  }

  static Future<void> setCompletedOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCompletedOnboarding, value);
  }

  static Future<bool> isCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kCompletedOnboarding) ?? false;
  }
}
