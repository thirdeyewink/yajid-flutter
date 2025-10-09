import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider with ChangeNotifier {
  bool _isOnboardingCompleted = false;
  bool _isLoading = false;
  String? _currentUserId;
  bool _isLoadingInProgress = false;

  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isLoading => _isLoading;

  OnboardingProvider();

  Future<void> loadOnboardingStatus(String userId) async {
    // Prevent multiple simultaneous loads
    if (_isLoadingInProgress) {
      print('OnboardingProvider: Load already in progress, skipping');
      return;
    }

    // If already loaded for this user and not loading, skip
    if (_currentUserId == userId && !_isLoading) {
      print('OnboardingProvider: Already loaded for user $userId');
      return;
    }

    print('OnboardingProvider: Loading onboarding status for user $userId');
    _isLoadingInProgress = true;
    _isLoading = true;
    _currentUserId = userId;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboardingCompleted = prefs.getBool('onboarding_completed_$userId') ?? false;
      print('OnboardingProvider: Onboarding completed: $_isOnboardingCompleted');
    } catch (e) {
      print('OnboardingProvider: Error loading onboarding status: $e');
      _isOnboardingCompleted = false;
    }

    _isLoading = false;
    _isLoadingInProgress = false;
    notifyListeners();
    print('OnboardingProvider: Finished loading, isCompleted=$_isOnboardingCompleted');
  }

  Future<void> completeOnboarding() async {
    if (_currentUserId == null) {
      print('OnboardingProvider: Cannot complete onboarding, no user ID');
      return;
    }

    print('OnboardingProvider: Completing onboarding for user $_currentUserId');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed_$_currentUserId', true);
      _isOnboardingCompleted = true;
      notifyListeners();
      print('OnboardingProvider: Onboarding completed successfully');
    } catch (e) {
      print('OnboardingProvider: Error completing onboarding: $e');
    }
  }

  Future<void> resetOnboarding() async {
    if (_currentUserId == null) return;

    print('OnboardingProvider: Resetting onboarding for user $_currentUserId');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed_$_currentUserId', false);
      _isOnboardingCompleted = false;
      notifyListeners();
    } catch (e) {
      print('OnboardingProvider: Error resetting onboarding: $e');
    }
  }

  void clearUser() {
    print('OnboardingProvider: Clearing user data');
    _currentUserId = null;
    _isOnboardingCompleted = false;
    _isLoading = false;
    _isLoadingInProgress = false;
    notifyListeners();
  }
}