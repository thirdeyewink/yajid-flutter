import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yajid/services/user_profile_service.dart';
import 'package:yajid/services/logging_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserProfileService _userProfileService;
  final FirebaseAuth _firebaseAuth;
  final LoggingService _logger;

  ProfileBloc({
    UserProfileService? userProfileService,
    FirebaseAuth? firebaseAuth,
    LoggingService? logger,
  })  : _userProfileService = userProfileService ?? UserProfileService(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _logger = logger ?? LoggingService(),
        super(const ProfileInitial()) {

    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfilePersonalInfoUpdateRequested>(_onProfilePersonalInfoUpdateRequested);
    on<ProfileSocialMediaUpdateRequested>(_onProfileSocialMediaUpdateRequested);
    on<ProfileSkillsUpdateRequested>(_onProfileSkillsUpdateRequested);
    on<ProfileSkillAddRequested>(_onProfileSkillAddRequested);
    on<ProfileSkillRemoveRequested>(_onProfileSkillRemoveRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = _firebaseAuth.currentUser;

      // Initialize profile if it doesn't exist
      await _userProfileService.initializeUserProfile();

      // Load profile data
      final profileData = await _userProfileService.getUserProfile();

      if (profileData != null) {
        emit(ProfileLoaded(
          profileData: profileData,
          displayName: profileData['displayName'] ?? user?.displayName ?? '',
          email: profileData['email'] ?? user?.email ?? '',
          phoneNumber: profileData['phoneNumber'] ?? user?.phoneNumber ?? '',
          birthday: profileData['birthday'] ?? 'Not set',
          profileImageUrl: profileData['profileImageUrl'] ?? user?.photoURL,
          socialMedia: Map<String, String>.from(profileData['socialMedia'] ?? {}),
          selectedCategories: List<String>.from(profileData['selectedCategories'] ?? []),
          skills: _parseSkills(profileData['skills']),
          bookmarks: List<Map<String, dynamic>>.from(profileData['bookmarks'] ?? []),
          ratedItems: List<Map<String, dynamic>>.from(profileData['ratedItems'] ?? []),
        ));
      } else {
        emit(const ProfileError(message: 'Failed to load profile'));
      }
    } catch (e) {
      _logger.error('Failed to load profile', e);
      emit(const ProfileError(message: 'Failed to load profile'));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileUpdating());
    try {
      // Update profile in Firestore
      await _userProfileService.updateProfile(event.profileData);

      // Reload the profile
      add(const ProfileLoadRequested());

      emit(const ProfileUpdateSuccess(message: 'Profile updated successfully'));
    } catch (e) {
      _logger.error('Failed to update profile', e);
      emit(const ProfileError(message: 'Failed to update profile'));
    }
  }

  Future<void> _onProfilePersonalInfoUpdateRequested(
    ProfilePersonalInfoUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileUpdating());
    try {
      final success = await _userProfileService.updatePersonalInfo(
        displayName: event.displayName,
        email: event.email,
        phoneNumber: event.phoneNumber,
        birthday: event.birthday,
      );

      if (success) {
        // Reload the profile to get updated data
        add(const ProfileLoadRequested());
        emit(const ProfileUpdateSuccess(message: 'Personal information updated successfully'));
      } else {
        emit(const ProfileError(message: 'Failed to update personal information'));
      }
    } catch (e) {
      _logger.error('Failed to update personal info', e);
      emit(const ProfileError(message: 'Failed to update personal information'));
    }
  }

  Future<void> _onProfileSocialMediaUpdateRequested(
    ProfileSocialMediaUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    emit(const ProfileUpdating());
    try {
      final success = await _userProfileService.updateSocialMedia(event.socialMedia);

      if (success && currentState is ProfileLoaded) {
        // Emit updated profile state directly without intermediate success state
        emit(currentState.copyWith(socialMedia: event.socialMedia));
      } else if (!success) {
        emit(const ProfileError(message: 'Failed to update social media'));
      }
    } catch (e) {
      _logger.error('Failed to update social media', e);
      emit(const ProfileError(message: 'Failed to update social media'));
    }
  }

  Future<void> _onProfileSkillsUpdateRequested(
    ProfileSkillsUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    emit(const ProfileUpdating());
    try {
      final success = await _userProfileService.updateSkills(event.skills);

      if (success && currentState is ProfileLoaded) {
        // Emit updated profile state directly without intermediate success state
        emit(currentState.copyWith(skills: event.skills));
      } else if (!success) {
        emit(const ProfileError(message: 'Failed to update skills'));
      }
    } catch (e) {
      _logger.error('Failed to update skills', e);
      emit(const ProfileError(message: 'Failed to update skills'));
    }
  }

  Future<void> _onProfileSkillAddRequested(
    ProfileSkillAddRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final updatedSkills = Map<String, List<String>>.from(currentState.skills);

      if (updatedSkills.containsKey(event.category)) {
        updatedSkills[event.category] = List.from(updatedSkills[event.category]!)..add(event.skill);
      } else {
        updatedSkills[event.category] = [event.skill];
      }

      add(ProfileSkillsUpdateRequested(skills: updatedSkills));
    }
  }

  Future<void> _onProfileSkillRemoveRequested(
    ProfileSkillRemoveRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final updatedSkills = Map<String, List<String>>.from(currentState.skills);

      if (updatedSkills.containsKey(event.category)) {
        updatedSkills[event.category] = List.from(updatedSkills[event.category]!)..remove(event.skill);
      }

      add(ProfileSkillsUpdateRequested(skills: updatedSkills));
    }
  }

  Map<String, List<String>> _parseSkills(dynamic skillsData) {
    if (skillsData == null) return {};

    final Map<String, List<String>> skills = {};
    final Map<String, dynamic> skillsMap = Map<String, dynamic>.from(skillsData);

    skillsMap.forEach((category, skillsList) {
      if (skillsList is List) {
        skills[category] = List<String>.from(skillsList);
      }
    });

    return skills;
  }
}