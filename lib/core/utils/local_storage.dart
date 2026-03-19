// lib/core/utils/local_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _onboardingKey = 'onboarding_seen';

  static Future<void> setOnboardingSeen(bool seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, seen);
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }
}