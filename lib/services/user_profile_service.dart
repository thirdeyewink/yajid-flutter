import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yajid/services/logging_service.dart';

class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUserId == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      logger.error('Error getting user profile', e);
    }
    return null;
  }

  Future<bool> saveUserProfile(Map<String, dynamic> profileData) async {
    if (currentUserId == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set(profileData, SetOptions(merge: true));
      return true;
    } catch (e) {
      logger.error('Error saving user profile', e);
      return false;
    }
  }

  Future<bool> updatePersonalInfo({
    String? displayName,
    String? displayNameAr,
    String? displayNameEs,
    String? displayNameFr,
    String? displayNamePt,
    String? email,
    String? phoneNumber,
    String? birthday,
    String? profileImageUrl,
  }) async {
    if (currentUserId == null) return false;

    try {
      Map<String, dynamic> updateData = {};
      if (displayName != null) updateData['displayName'] = displayName;
      if (displayNameAr != null) updateData['displayName_ar'] = displayNameAr;
      if (displayNameEs != null) updateData['displayName_es'] = displayNameEs;
      if (displayNameFr != null) updateData['displayName_fr'] = displayNameFr;
      if (displayNamePt != null) updateData['displayName_pt'] = displayNamePt;
      if (email != null) updateData['email'] = email;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (birthday != null) updateData['birthday'] = birthday;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set(updateData, SetOptions(merge: true));
      return true;
    } catch (e) {
      logger.error('Error updating personal info', e);
      return false;
    }
  }

  Future<bool> updateSocialMedia(Map<String, String> socialMedia) async {
    if (currentUserId == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set({
            'socialMedia': socialMedia,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      return true;
    } catch (e) {
      logger.error('Error updating social media', e);
      return false;
    }
  }

  Future<bool> updateSkills(Map<String, List<String>> skills) async {
    if (currentUserId == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set({
            'skills': skills,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      return true;
    } catch (e) {
      logger.error('Error updating skills', e);
      return false;
    }
  }

  Future<bool> updatePreferences(List<String> selectedCategories) async {
    if (currentUserId == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set({
            'selectedCategories': selectedCategories,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      return true;
    } catch (e) {
      logger.error('Error updating preferences', e);
      return false;
    }
  }

  Future<bool> addBookmark(Map<String, dynamic> bookmark) async {
    if (currentUserId == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set({
            'bookmarks': FieldValue.arrayUnion([bookmark]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      return true;
    } catch (e) {
      logger.error('Error adding bookmark', e);
      return false;
    }
  }

  Future<bool> removeBookmark(Map<String, dynamic> bookmark) async {
    if (currentUserId == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set({
            'bookmarks': FieldValue.arrayRemove([bookmark]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      return true;
    } catch (e) {
      logger.error('Error removing bookmark', e);
      return false;
    }
  }

  Future<bool> addRating(Map<String, dynamic> rating) async {
    if (currentUserId == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set({
            'ratedItems': FieldValue.arrayUnion([rating]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      return true;
    } catch (e) {
      logger.error('Error adding rating', e);
      return false;
    }
  }

  Stream<Map<String, dynamic>?> getUserProfileStream() {
    if (currentUserId == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  Future<bool> createUserProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String gender,
    String? birthday,
  }) async {
    if (currentUserId == null) return false;

    try {
      final user = _auth.currentUser!;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set({
        'displayName': '$firstName $lastName',
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'birthday': birthday ?? '',
        'profileImageUrl': user.photoURL,
        'socialMedia': {
          'instagram': '',
          'x': '',
          'linkedin': '',
          'spotify': '',
          'youtube': '',
          'tiktok': '',
          'whatsapp': '',
        },
        'selectedCategories': <String>[],
        'skills': {
          'Musical Instruments': <String>[],
          'Sports': <String>[],
          'Professional': <String>[],
          'Software': <String>[],
          'Tools': <String>[],
          'Game Role': <String>[],
        },
        'bookmarks': <Map<String, dynamic>>[],
        'ratedItems': <Map<String, dynamic>>[],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      logger.error('Error creating user profile', e);
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    if (currentUserId == null) return false;

    try {
      profileData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set(profileData, SetOptions(merge: true));
      return true;
    } catch (e) {
      logger.error('Error updating profile', e);
      return false;
    }
  }

  Future<bool> initializeUserProfile() async {
    if (currentUserId == null) return false;

    try {
      final user = _auth.currentUser!;
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      if (!doc.exists) {
        // Create initial profile
        await _firestore
            .collection('users')
            .doc(currentUserId)
            .set({
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'phoneNumber': user.phoneNumber ?? '',
          'birthday': '',
          'profileImageUrl': user.photoURL,
          'socialMedia': {
            'instagram': '',
            'x': '',
            'linkedin': '',
            'spotify': '',
            'youtube': '',
            'tiktok': '',
            'whatsapp': '',
          },
          'selectedCategories': <String>[],
          'skills': {
            'Musical Instruments': <String>[],
            'Sports': <String>[],
            'Professional': <String>[],
            'Software': <String>[],
            'Tools': <String>[],
            'Game Role': <String>[],
          },
          'bookmarks': <Map<String, dynamic>>[],
          'ratedItems': <Map<String, dynamic>>[],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      logger.error('Error initializing user profile', e);
      return false;
    }
  }
}