import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profileData;
  final String displayName;
  final String email;
  final String phoneNumber;
  final String birthday;
  final String? profileImageUrl;
  final Map<String, String> socialMedia;
  final List<String> selectedCategories;
  final Map<String, List<String>> skills;
  final List<Map<String, dynamic>> bookmarks;
  final List<Map<String, dynamic>> ratedItems;

  const ProfileLoaded({
    required this.profileData,
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    required this.birthday,
    this.profileImageUrl,
    required this.socialMedia,
    required this.selectedCategories,
    required this.skills,
    required this.bookmarks,
    required this.ratedItems,
  });

  ProfileLoaded copyWith({
    Map<String, dynamic>? profileData,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? birthday,
    String? profileImageUrl,
    Map<String, String>? socialMedia,
    List<String>? selectedCategories,
    Map<String, List<String>>? skills,
    List<Map<String, dynamic>>? bookmarks,
    List<Map<String, dynamic>>? ratedItems,
  }) {
    return ProfileLoaded(
      profileData: profileData ?? this.profileData,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthday: birthday ?? this.birthday,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      socialMedia: socialMedia ?? this.socialMedia,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      skills: skills ?? this.skills,
      bookmarks: bookmarks ?? this.bookmarks,
      ratedItems: ratedItems ?? this.ratedItems,
    );
  }

  @override
  List<Object?> get props => [
    profileData,
    displayName,
    email,
    phoneNumber,
    birthday,
    profileImageUrl,
    socialMedia,
    selectedCategories,
    skills,
    bookmarks,
    ratedItems,
  ];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;

  const ProfileUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}