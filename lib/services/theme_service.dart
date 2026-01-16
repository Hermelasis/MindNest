import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ValueNotifier<bool> themeNotifier = ValueNotifier(false);
  static const String _kIsDarkMode = 'is_dark_mode';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    themeNotifier.value = prefs.getBool(_kIsDarkMode) ?? false;
  }

  static Future<void> toggleTheme(bool isDark) async {
    themeNotifier.value = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsDarkMode, isDark);
  }

  static bool get isDarkMode => themeNotifier.value;
}
