import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yajid/l10n/app_localizations.dart';
import 'package:yajid/services/user_profile_service.dart';
import 'package:yajid/theme/app_theme.dart';
import 'package:yajid/screens/gamification_screen.dart';
import 'package:yajid/services/logging_service.dart';
import 'package:yajid/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final UserProfileService _profileService = UserProfileService();
  late TabController _tabController;
  bool _isLoading = true;

  // Editable user data
  String _displayName = '';
  String _email = '';
  String _phoneNumber = '';
  String _birthday = '';
  String? _profileImageUrl;

  // Sample data - in a real app, this would come from a database
  final Map<String, String> _socialMedia = {
    'instagram': '',
    'x': '',
    'linkedin': '',
    'spotify': '',
    'youtube': '',
    'tiktok': '',
    'whatsapp': '',
  };

  final List<String> _selectedCategories = [
    'movies',
    'music',
    'restaurants',
    'books',
  ];

  List<Map<String, dynamic>> _bookmarks = [];
  List<Map<String, dynamic>> _ratedItems = [];

  // Skills data
  final Map<String, List<String>> _skills = {
    'Musical Instruments': [],
    'Sports': [],
    'Professional': [],
    'Software': [],
    'Tools': [],
    'Game Role': [],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initializeUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeUserData() async {
    setState(() {
      _isLoading = true;
    });

    // Initialize profile if it doesn't exist
    await _profileService.initializeUserProfile();

    // Load profile data
    final profileData = await _profileService.getUserProfile();

    if (profileData != null && mounted) {
      setState(() {
        _displayName = profileData['displayName'] ?? user?.displayName ?? '';
        _email = profileData['email'] ?? user?.email ?? '';
        _phoneNumber = profileData['phoneNumber'] ?? user?.phoneNumber ?? '';
        _birthday = profileData['birthday'] ?? 'Not set';
        _profileImageUrl = profileData['profileImageUrl'] ?? user?.photoURL;

        // Load social media
        if (profileData['socialMedia'] != null) {
          final socialMediaData = Map<String, String>.from(profileData['socialMedia']);
          _socialMedia.addAll(socialMediaData);
        }

        // Load categories
        if (profileData['selectedCategories'] != null) {
          _selectedCategories.clear();
          _selectedCategories.addAll(List<String>.from(profileData['selectedCategories']));
        }

        // Load skills
        if (profileData['skills'] != null) {
          final skillsData = Map<String, dynamic>.from(profileData['skills']);
          skillsData.forEach((category, skills) {
            if (_skills.containsKey(category)) {
              _skills[category] = List<String>.from(skills ?? []);
            }
          });
        }
      });
    }

    // Load bookmarks and rated items from Firestore subcollections
    await _loadBookmarksAndRatings();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadBookmarksAndRatings() async {
    if (user == null) return;

    try {
      // Load bookmarks
      final bookmarksSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('bookmarks')
          .orderBy('bookmarkedAt', descending: true)
          .get();

      // Load rated items
      final ratedSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('rated')
          .orderBy('ratedAt', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _bookmarks = bookmarksSnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'title': data['title'] ?? '',
              'category': data['category'] ?? '',
              'rating': data['communityRating'] ?? 0.0,
              'image': data['imageUrl'] ?? 'https://via.placeholder.com/150',
              'description': data['description'] ?? '',
            };
          }).toList();

          _ratedItems = ratedSnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'title': data['title'] ?? '',
              'category': data['category'] ?? '',
              'rating': data['communityRating'] ?? 0.0,
              'myRating': (data['userRating'] ?? 0.0).toInt(),
              'image': data['imageUrl'] ?? 'https://via.placeholder.com/150',
              'description': data['description'] ?? '',
            };
          }).toList();
        });
      }
    } catch (e) {
      logger.error('Error loading bookmarks and ratings', e);
    }
  }

  String _getLocalizedCategoryName(String category) {
    switch (category) {
      case 'movies':
        return AppLocalizations.of(context)!.movies;
      case 'music':
        return AppLocalizations.of(context)!.music;
      case 'restaurants':
        return 'Restaurants';
      case 'books':
        return AppLocalizations.of(context)!.books;
      case 'tvShows':
        return AppLocalizations.of(context)!.tvShows;
      case 'games':
        return 'Games';
      case 'fashion':
        return 'Fashion';
      case 'travel':
        return 'Travel';
      default:
        return category.substring(0, 1).toUpperCase() + category.substring(1);
    }
  }

  void _editProfilePicture() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Center(child: Text('Profile picture edit coming soon')),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEditDialog(String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await onSave(controller.text);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final birthdayString = '${picked.day}/${picked.month}/${picked.year}';

      // Save to Firestore
      final success = await _profileService.updatePersonalInfo(birthday: birthdayString);

      if (success && mounted) {
        setState(() {
          _birthday = birthdayString;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text('Birthday updated successfully')),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text('Failed to update birthday')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _editSocialMedia(String platform, String key, String currentValue) {
    _showEditDialog(platform, currentValue, (value) async {
      // Update local state
      setState(() {
        _socialMedia[key] = value;
      });

      // Save to Firestore
      final success = await _profileService.updateSocialMedia(_socialMedia);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('$platform updated successfully')),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed to update $platform')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _addSkill(String category) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $category Skill'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Skill name',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                // Update local state
                setState(() {
                  _skills[category]?.add(controller.text.trim());
                });

                // Save to Firestore
                final success = await _profileService.updateSkills(_skills);

                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(child: Text('Skill added successfully')),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(child: Text('Failed to add skill')),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeSkill(String category, String skill) async {
    // Update local state
    setState(() {
      _skills[category]?.remove(skill);
    });

    // Save to Firestore
    final success = await _profileService.updateSkills(_skills);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text('Skill removed successfully')),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text('Failed to remove skill')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildFriendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildFriendsSection(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildPersonalInformation(),
          const SizedBox(height: 16),
          _buildSocialMediaSection(),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildRecommendationPreferences(),
    );
  }

  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildSkillsSection(),
    );
  }

  Widget _buildRatingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildRatedSection(),
    );
  }

  Widget _buildBookmarksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildBookmarksSection(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          elevation: 1,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppTheme.buildLogo(
                    size: 55.0,
                    onTap: () {
                      // Navigate to home (index 0)
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                  ),
                  const Spacer(),
                  // Settings icon
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading profile...'),
                ],
              ),
            )
          : Column(
              children: [
                // Profile Header (without email)
                _buildProfileHeader(),

                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: const [
                    Tab(text: 'Friends'),
                    Tab(text: 'Info'),
                    Tab(text: 'Preferences'),
                    Tab(text: 'Skills'),
                    Tab(text: 'Rated'),
                    Tab(text: 'Bookmarks'),
                  ],
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFriendsTab(),
                      _buildInfoTab(),
                      _buildPreferencesTab(),
                      _buildSkillsTab(),
                      _buildRatingsTab(),
                      _buildBookmarksTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null
                      ? Text(
                          _displayName.isNotEmpty
                              ? _displayName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      onPressed: _editProfilePicture,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _displayName.isNotEmpty ? _displayName : 'User Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Gamification button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GamificationScreen()),
                );
              },
              icon: const Icon(Icons.stars),
              label: const Text('View Your Progress'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEditableInfoTile(
              Icons.person,
              'Name',
              _displayName.isNotEmpty ? _displayName : 'Not set',
              () => _showEditDialog('Name', _displayName, (value) async {
                // Update local state
                setState(() {
                  _displayName = value;
                });

                // Save to Firestore
                final success = await _profileService.updatePersonalInfo(displayName: value);

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(child: Text('Name updated successfully')),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(child: Text('Failed to update name')),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }),
            ),
            _buildEditableInfoTile(
              Icons.email,
              'Email',
              _email.isNotEmpty ? _email : 'Not set',
              () => _showEditDialog('Email', _email, (value) async {
                // Update local state
                setState(() {
                  _email = value;
                });

                // Save to Firestore
                final success = await _profileService.updatePersonalInfo(email: value);

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(child: Text('Email updated successfully')),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(child: Text('Failed to update email')),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }),
            ),
            _buildEditableInfoTile(
              Icons.phone,
              'Phone',
              _phoneNumber.isNotEmpty ? _phoneNumber : 'Not set',
              () => _showEditDialog('Phone', _phoneNumber, (value) async {
                // Update local state
                setState(() {
                  _phoneNumber = value;
                });

                // Save to Firestore
                final success = await _profileService.updatePersonalInfo(phoneNumber: value);

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(child: Text('Phone updated successfully')),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(child: Text('Failed to update phone')),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }),
            ),
            _buildEditableInfoTile(
              Icons.cake,
              'Birthday',
              _birthday,
              _showDatePicker,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableInfoTile(IconData icon, String label, String value, VoidCallback onEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Social Media',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSocialMediaTile(Icons.camera_alt, 'Instagram', _socialMedia['instagram'] ?? ''),
            _buildSocialMediaTile(Icons.alternate_email, 'X (Twitter)', _socialMedia['x'] ?? ''),
            _buildSocialMediaTile(Icons.business, 'LinkedIn', _socialMedia['linkedin'] ?? ''),
            _buildSocialMediaTile(Icons.music_note, 'Spotify', _socialMedia['spotify'] ?? ''),
            _buildSocialMediaTile(Icons.play_circle, 'YouTube', _socialMedia['youtube'] ?? ''),
            _buildSocialMediaTile(Icons.video_camera_front, 'TikTok', _socialMedia['tiktok'] ?? ''),
            _buildSocialMediaTile(Icons.chat, 'WhatsApp', _socialMedia['whatsapp'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaTile(IconData icon, String platform, String handle) {
    final platformKey = platform.toLowerCase().replaceAll(' ', '').replaceAll('(twitter)', '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  handle.isEmpty ? 'Not set' : '@$handle',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(handle.isEmpty ? Icons.add : Icons.edit, size: 20),
            onPressed: () => _editSocialMedia(platform, platformKey, handle),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationPreferences() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommendation Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _selectedCategories.map((category) {
                return Chip(
                  label: Text(_getLocalizedCategoryName(category)),
                  backgroundColor: Colors.blue.shade100,
                  labelStyle: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                // Show coming soon message for edit preferences feature
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Center(child: Text('Edit preferences feature coming soon')),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Preferences'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bookmarks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_bookmarks.isEmpty)
              const Center(
                child: Text(
                  'No bookmarks yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...(_bookmarks.map((bookmark) => _buildBookmarkItem(bookmark))),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkItem(Map<String, dynamic> bookmark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.grey.shade200,
              child: const Icon(Icons.bookmark, color: Colors.blue),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookmark['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  bookmark['category'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      bookmark['rating'].toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.blue),
            onPressed: () {
              // Bookmark removal feature - to be implemented
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRatedSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rated',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_ratedItems.isEmpty)
              const Center(
                child: Text(
                  'No ratings yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...(_ratedItems.map((item) => _buildRatedItem(item))),
          ],
        ),
      ),
    );
  }

  Widget _buildRatedItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.grey.shade200,
              child: const Icon(Icons.star, color: Colors.amber),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item['category'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Row(
                  children: [
                    const Text('My Rating: ', style: TextStyle(fontSize: 12)),
                    ...List.generate(5, (index) {
                      return Icon(
                        index < item['myRating'] ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Skills',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._skills.entries.map((entry) => _buildSkillCategory(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillCategory(String category, List<String> skills) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20, color: Colors.blue),
                onPressed: () => _addSkill(category),
              ),
            ],
          ),
          if (skills.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                'No skills added yet',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: skills.map((skill) => Chip(
                  label: Text(skill),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeSkill(category, skill),
                )).toList(),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFriendsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Friends',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_add, color: Colors.blue),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Center(child: Text('Add friends feature coming soon')),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No friends yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Connect with friends to see their recommendations',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(child: Text('Find friends feature coming soon')),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.search),
                label: const Text('Find Friends'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}