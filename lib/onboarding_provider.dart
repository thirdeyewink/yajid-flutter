import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider with ChangeNotifier {
  bool _isOnboardingCompleted = false;
  bool _isLoading = true;

  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isLoading => _isLoading;

  OnboardingProvider() {
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    } catch (e) {
      _isOnboardingCompleted = false;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      _isOnboardingCompleted = true;
      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', false);
      _isOnboardingCompleted = false;
      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }
}