import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  final Map<String, dynamic> profileData;

  const ProfileUpdateRequested({required this.profileData});

  @override
  List<Object?> get props => [profileData];
}

class ProfilePersonalInfoUpdateRequested extends ProfileEvent {
  final String? displayName;
  final String? email;
  final String? phoneNumber;
  final String? birthday;

  const ProfilePersonalInfoUpdateRequested({
    this.displayName,
    this.email,
    this.phoneNumber,
    this.birthday,
  });

  @override
  List<Object?> get props => [displayName, email, phoneNumber, birthday];
}

class ProfileSocialMediaUpdateRequested extends ProfileEvent {
  final Map<String, String> socialMedia;

  const ProfileSocialMediaUpdateRequested({required this.socialMedia});

  @override
  List<Object?> get props => [socialMedia];
}

class ProfileSkillsUpdateRequested extends ProfileEvent {
  final Map<String, List<String>> skills;

  const ProfileSkillsUpdateRequested({required this.skills});

  @override
  List<Object?> get props => [skills];
}

class ProfileSkillAddRequested extends ProfileEvent {
  final String category;
  final String skill;

  const ProfileSkillAddRequested({
    required this.category,
    required this.skill,
  });

  @override
  List<Object?> get props => [category, skill];
}

class ProfileSkillRemoveRequested extends ProfileEvent {
  final String category;
  final String skill;

  const ProfileSkillRemoveRequested({
    required this.category,
    required this.skill,
  });

  @override
  List<Object?> get props => [category, skill];
}