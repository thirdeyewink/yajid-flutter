import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:yajid/bloc/profile/profile_bloc.dart';
import 'package:yajid/bloc/profile/profile_event.dart';
import 'package:yajid/bloc/profile/profile_state.dart';
import 'package:yajid/services/user_profile_service.dart';
import 'package:yajid/services/logging_service.dart';

// Mock classes
class MockUserProfileService extends Mock implements UserProfileService {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockLoggingService extends Mock implements LoggingService {}

void main() {
  group('ProfileBloc', () {
    late ProfileBloc profileBloc;
    late MockUserProfileService mockUserProfileService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockLoggingService mockLoggingService;

    setUp(() {
      mockUserProfileService = MockUserProfileService();
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockLoggingService = MockLoggingService();

      // Set up common mocks
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.displayName).thenReturn('Test User');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUser.phoneNumber).thenReturn('+1234567890');
      when(() => mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
      when(() => mockLoggingService.info(any())).thenReturn(null);
      when(() => mockLoggingService.error(any(), any())).thenReturn(null);

      profileBloc = ProfileBloc(
        userProfileService: mockUserProfileService,
        firebaseAuth: mockFirebaseAuth,
        logger: mockLoggingService,
      );
    });

    tearDown(() {
      profileBloc.close();
    });

    test('initial state is ProfileInitial', () {
      expect(profileBloc.state, equals(const ProfileInitial()));
    });

    group('ProfileLoadRequested', () {
      final mockProfileData = {
        'displayName': 'Test User',
        'email': 'test@example.com',
        'phoneNumber': '+1234567890',
        'birthday': '1990-01-01',
        'profileImageUrl': 'https://example.com/photo.jpg',
        'socialMedia': {
          'instagram': '@testuser',
          'x': '@testuser',
        },
        'selectedCategories': ['technology', 'sports'],
        'skills': {
          'Professional': ['Flutter', 'Dart'],
          'Software': ['Android Studio', 'VS Code'],
        },
        'bookmarks': [],
        'ratedItems': [],
      };

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileLoaded] when profile loading succeeds',
        build: () {
          when(() => mockUserProfileService.initializeUserProfile())
              .thenAnswer((_) async => true);
          when(() => mockUserProfileService.getUserProfile())
              .thenAnswer((_) async => mockProfileData);
          return profileBloc;
        },
        act: (bloc) => bloc.add(const ProfileLoadRequested()),
        expect: () => [
          const ProfileLoading(),
          ProfileLoaded(
            profileData: mockProfileData,
            displayName: 'Test User',
            email: 'test@example.com',
            phoneNumber: '+1234567890',
            birthday: '1990-01-01',
            profileImageUrl: 'https://example.com/photo.jpg',
            socialMedia: {
              'instagram': '@testuser',
              'x': '@testuser',
            },
            selectedCategories: ['technology', 'sports'],
            skills: {
              'Professional': ['Flutter', 'Dart'],
              'Software': ['Android Studio', 'VS Code'],
            },
            bookmarks: [],
            ratedItems: [],
          ),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileError] when profile loading fails',
        build: () {
          when(() => mockUserProfileService.initializeUserProfile())
              .thenAnswer((_) async => true);
          when(() => mockUserProfileService.getUserProfile())
              .thenAnswer((_) async => null);
          return profileBloc;
        },
        act: (bloc) => bloc.add(const ProfileLoadRequested()),
        expect: () => [
          const ProfileLoading(),
          const ProfileError(message: 'Failed to load profile'),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileError] when initialization fails',
        build: () {
          when(() => mockUserProfileService.initializeUserProfile())
              .thenThrow(Exception('Initialization failed'));
          return profileBloc;
        },
        act: (bloc) => bloc.add(const ProfileLoadRequested()),
        expect: () => [
          const ProfileLoading(),
          const ProfileError(message: 'Failed to load profile'),
        ],
      );
    });

    group('ProfileUpdateRequested', () {
      final updateData = {
        'displayName': 'Updated User',
        'phoneNumber': '+9876543210',
      };

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileUpdateSuccess] when update succeeds',
        build: () {
          when(() => mockUserProfileService.updateProfile(updateData))
              .thenAnswer((_) async => true);
          // Mock the profile reload that happens after update
          when(() => mockUserProfileService.initializeUserProfile())
              .thenAnswer((_) async => true);
          when(() => mockUserProfileService.getUserProfile())
              .thenAnswer((_) async => {
                'displayName': 'Updated User',
                'email': 'test@example.com',
                'phoneNumber': '+9876543210',
                'birthday': '1990-01-01',
                'profileImageUrl': null,
                'socialMedia': <String, String>{},
                'selectedCategories': <String>[],
                'skills': <String, List<String>>{},
                'bookmarks': <Map<String, dynamic>>[],
                'ratedItems': <Map<String, dynamic>>[],
              });
          return profileBloc;
        },
        act: (bloc) => bloc.add(ProfileUpdateRequested(profileData: updateData)),
        expect: () => [
          const ProfileUpdating(),
          const ProfileUpdateSuccess(message: 'Profile updated successfully'),
          const ProfileLoading(),
          isA<ProfileLoaded>(),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileError] when update fails',
        build: () {
          when(() => mockUserProfileService.updateProfile(updateData))
              .thenThrow(Exception('Update failed'));
          return profileBloc;
        },
        act: (bloc) => bloc.add(ProfileUpdateRequested(profileData: updateData)),
        expect: () => [
          const ProfileUpdating(),
          const ProfileError(message: 'Failed to update profile'),
        ],
      );
    });

    group('ProfilePersonalInfoUpdateRequested', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileUpdateSuccess] when personal info update succeeds',
        build: () {
          when(() => mockUserProfileService.updatePersonalInfo(
            displayName: 'Updated Name',
            email: 'updated@example.com',
            phoneNumber: '+9876543210',
            birthday: '1991-02-02',
          )).thenAnswer((_) async => true);
          // Mock the profile loading that happens after personal info update
          when(() => mockUserProfileService.initializeUserProfile())
              .thenAnswer((_) async => true);
          when(() => mockUserProfileService.getUserProfile())
              .thenAnswer((_) async => {
                'displayName': 'Updated Name',
                'email': 'updated@example.com',
                'phoneNumber': '+9876543210',
                'birthday': '1991-02-02',
                'profileImageUrl': null,
                'socialMedia': <String, String>{},
                'selectedCategories': <String>[],
                'skills': <String, List<String>>{},
                'bookmarks': <Map<String, dynamic>>[],
                'ratedItems': <Map<String, dynamic>>[],
              });
          return profileBloc;
        },
        act: (bloc) => bloc.add(const ProfilePersonalInfoUpdateRequested(
          displayName: 'Updated Name',
          email: 'updated@example.com',
          phoneNumber: '+9876543210',
          birthday: '1991-02-02',
        )),
        expect: () => [
          const ProfileUpdating(),
          const ProfileUpdateSuccess(message: 'Personal information updated successfully'),
          const ProfileLoading(),
          isA<ProfileLoaded>(),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileError] when personal info update fails',
        build: () {
          when(() => mockUserProfileService.updatePersonalInfo(
            displayName: 'Updated Name',
          )).thenAnswer((_) async => false);
          return profileBloc;
        },
        act: (bloc) => bloc.add(const ProfilePersonalInfoUpdateRequested(
          displayName: 'Updated Name',
        )),
        expect: () => [
          const ProfileUpdating(),
          const ProfileError(message: 'Failed to update personal information'),
        ],
      );
    });

    group('ProfileSocialMediaUpdateRequested', () {
      final socialMediaData = {
        'instagram': '@newtestuser',
        'x': '@newtestuser',
        'linkedin': 'linkedin.com/in/testuser',
      };

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileLoaded] when social media update succeeds',
        build: () {
          when(() => mockUserProfileService.updateSocialMedia(socialMediaData))
              .thenAnswer((_) async => true);
          return profileBloc;
        },
        seed: () => ProfileLoaded(
          profileData: const {},
          displayName: 'Test User',
          email: 'test@example.com',
          phoneNumber: '+1234567890',
          birthday: '1990-01-01',
          profileImageUrl: null,
          socialMedia: const {},
          selectedCategories: const [],
          skills: const {},
          bookmarks: const [],
          ratedItems: const [],
        ),
        act: (bloc) => bloc.add(ProfileSocialMediaUpdateRequested(socialMedia: socialMediaData)),
        expect: () => [
          const ProfileUpdating(),
          isA<ProfileLoaded>()
              .having((s) => s.socialMedia, 'socialMedia', socialMediaData),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileError] when social media update fails',
        build: () {
          when(() => mockUserProfileService.updateSocialMedia(socialMediaData))
              .thenThrow(Exception('Update failed'));
          return profileBloc;
        },
        act: (bloc) => bloc.add(ProfileSocialMediaUpdateRequested(socialMedia: socialMediaData)),
        expect: () => [
          const ProfileUpdating(),
          const ProfileError(message: 'Failed to update social media'),
        ],
      );
    });

    group('ProfileSkillsUpdateRequested', () {
      final skillsData = {
        'Professional': ['Flutter', 'React Native'],
        'Software': ['Android Studio', 'Xcode'],
      };

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileLoaded] when skills update succeeds',
        build: () {
          when(() => mockUserProfileService.updateSkills(skillsData))
              .thenAnswer((_) async => true);
          return profileBloc;
        },
        seed: () => ProfileLoaded(
          profileData: const {},
          displayName: 'Test User',
          email: 'test@example.com',
          phoneNumber: '+1234567890',
          birthday: '1990-01-01',
          profileImageUrl: null,
          socialMedia: const {},
          selectedCategories: const [],
          skills: const {},
          bookmarks: const [],
          ratedItems: const [],
        ),
        act: (bloc) => bloc.add(ProfileSkillsUpdateRequested(skills: skillsData)),
        expect: () => [
          const ProfileUpdating(),
          isA<ProfileLoaded>()
              .having((s) => s.skills, 'skills', skillsData),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileError] when skills update fails',
        build: () {
          when(() => mockUserProfileService.updateSkills(skillsData))
              .thenAnswer((_) async => false);
          return profileBloc;
        },
        act: (bloc) => bloc.add(ProfileSkillsUpdateRequested(skills: skillsData)),
        expect: () => [
          const ProfileUpdating(),
          const ProfileError(message: 'Failed to update skills'),
        ],
      );
    });

    group('ProfileSkillAddRequested', () {
      final initialProfileData = {
        'skills': {
          'Professional': ['Flutter'],
          'Software': ['Android Studio'],
        },
      };

      blocTest<ProfileBloc, ProfileState>(
        'adds skill to existing category when profile is loaded',
        build: () {
          when(() => mockUserProfileService.updateSkills(any()))
              .thenAnswer((_) async => true);
          return profileBloc;
        },
        seed: () => ProfileLoaded(
          profileData: initialProfileData,
          displayName: 'Test User',
          email: 'test@example.com',
          phoneNumber: '+1234567890',
          birthday: '1990-01-01',
          profileImageUrl: null,
          socialMedia: const {},
          selectedCategories: const [],
          skills: const {
            'Professional': ['Flutter'],
            'Software': ['Android Studio'],
          },
          bookmarks: const [],
          ratedItems: const [],
        ),
        act: (bloc) => bloc.add(const ProfileSkillAddRequested(
          category: 'Professional',
          skill: 'React Native',
        )),
        expect: () => [
          const ProfileUpdating(),
          isA<ProfileLoaded>()
              .having((s) => s.skills['Professional'], 'Professional skills',
                  containsAll(['Flutter', 'React Native'])),
        ],
        verify: (_) {
          verify(() => mockUserProfileService.updateSkills({
            'Professional': ['Flutter', 'React Native'],
            'Software': ['Android Studio'],
          })).called(1);
        },
      );

      blocTest<ProfileBloc, ProfileState>(
        'creates new category when adding skill to non-existing category',
        build: () {
          when(() => mockUserProfileService.updateSkills(any()))
              .thenAnswer((_) async => true);
          return profileBloc;
        },
        seed: () => ProfileLoaded(
          profileData: initialProfileData,
          displayName: 'Test User',
          email: 'test@example.com',
          phoneNumber: '+1234567890',
          birthday: '1990-01-01',
          profileImageUrl: null,
          socialMedia: const {},
          selectedCategories: const [],
          skills: const {
            'Professional': ['Flutter'],
            'Software': ['Android Studio'],
          },
          bookmarks: const [],
          ratedItems: const [],
        ),
        act: (bloc) => bloc.add(const ProfileSkillAddRequested(
          category: 'Sports',
          skill: 'Swimming',
        )),
        expect: () => [
          const ProfileUpdating(),
          isA<ProfileLoaded>()
              .having((s) => s.skills.containsKey('Sports'), 'has Sports category', true)
              .having((s) => s.skills['Sports'], 'Sports skills', ['Swimming']),
        ],
        verify: (_) {
          verify(() => mockUserProfileService.updateSkills({
            'Professional': ['Flutter'],
            'Software': ['Android Studio'],
            'Sports': ['Swimming'],
          })).called(1);
        },
      );
    });

    group('ProfileSkillRemoveRequested', () {
      blocTest<ProfileBloc, ProfileState>(
        'removes skill from category when profile is loaded',
        build: () {
          when(() => mockUserProfileService.updateSkills(any()))
              .thenAnswer((_) async => true);
          return profileBloc;
        },
        seed: () => ProfileLoaded(
          profileData: const {},
          displayName: 'Test User',
          email: 'test@example.com',
          phoneNumber: '+1234567890',
          birthday: '1990-01-01',
          profileImageUrl: null,
          socialMedia: const {},
          selectedCategories: const [],
          skills: const {
            'Professional': ['Flutter', 'React Native'],
            'Software': ['Android Studio'],
          },
          bookmarks: const [],
          ratedItems: const [],
        ),
        act: (bloc) => bloc.add(const ProfileSkillRemoveRequested(
          category: 'Professional',
          skill: 'React Native',
        )),
        expect: () => [
          const ProfileUpdating(),
          isA<ProfileLoaded>()
              .having((s) => s.skills['Professional'], 'Professional skills', ['Flutter'])
              .having((s) => s.skills['Professional']?.contains('React Native'),
                  'should not contain React Native', false),
        ],
        verify: (_) {
          verify(() => mockUserProfileService.updateSkills({
            'Professional': ['Flutter'],
            'Software': ['Android Studio'],
          })).called(1);
        },
      );
    });
  });
}