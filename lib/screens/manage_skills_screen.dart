import 'package:flutter/material.dart';
import 'package:yajid/services/user_profile_service.dart';
import 'package:yajid/theme/app_theme.dart';

class ManageSkillsScreen extends StatefulWidget {
  const ManageSkillsScreen({super.key});

  @override
  State<ManageSkillsScreen> createState() => _ManageSkillsScreenState();
}

class _ManageSkillsScreenState extends State<ManageSkillsScreen> {
  final UserProfileService _profileService = UserProfileService();
  final Map<String, TextEditingController> _controllers = {};

  Map<String, List<String>> _skills = {
    'Musical Instruments': [],
    'Sports': [],
    'Professional': [],
    'Software': [],
    'Tools': [],
    'Game Role': [],
    'Languages': [],
    'Creative': [],
  };

  bool _isLoading = true;
  bool _isSaving = false;

  // Suggestions for each category
  static const Map<String, List<String>> _suggestions = {
    'Musical Instruments': [
      'Piano',
      'Guitar',
      'Violin',
      'Drums',
      'Bass',
      'Saxophone',
      'Flute',
      'Trumpet',
      'Cello',
      'Clarinet',
      'Ukulele',
      'Harmonica',
    ],
    'Sports': [
      'Soccer',
      'Basketball',
      'Tennis',
      'Swimming',
      'Running',
      'Cycling',
      'Volleyball',
      'Baseball',
      'Golf',
      'Boxing',
      'Martial Arts',
      'Yoga',
      'Climbing',
      'Skiing',
      'Surfing',
    ],
    'Professional': [
      'Project Management',
      'Marketing',
      'Sales',
      'Data Analysis',
      'Accounting',
      'Legal',
      'HR Management',
      'Business Strategy',
      'Public Speaking',
      'Leadership',
      'Negotiation',
      'Financial Planning',
    ],
    'Software': [
      'Python',
      'JavaScript',
      'Java',
      'C++',
      'React',
      'Flutter',
      'Node.js',
      'SQL',
      'MongoDB',
      'Docker',
      'AWS',
      'Git',
      'Photoshop',
      'Figma',
      'Excel',
      'AutoCAD',
    ],
    'Tools': [
      'Woodworking',
      'Electrical Work',
      'Plumbing',
      'Carpentry',
      'Welding',
      'Painting',
      'Car Repair',
      'Home Repair',
      'Gardening',
      'Sewing',
      'Cooking',
    ],
    'Game Role': [
      'Tank',
      'Healer',
      'DPS',
      'Support',
      'Assassin',
      'Mage',
      'Warrior',
      'Archer',
      'Scout',
      'Leader',
      'Strategist',
    ],
    'Languages': [
      'English',
      'Spanish',
      'French',
      'German',
      'Chinese',
      'Japanese',
      'Arabic',
      'Portuguese',
      'Italian',
      'Russian',
      'Korean',
      'Hindi',
    ],
    'Creative': [
      'Drawing',
      'Painting',
      'Photography',
      'Video Editing',
      'Writing',
      'Poetry',
      'Storytelling',
      'Animation',
      'Graphic Design',
      'UI/UX Design',
      'Music Composition',
      'Dance',
      'Acting',
      'Sculpting',
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSkills();
  }

  void _initializeControllers() {
    for (final category in _skills.keys) {
      _controllers[category] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSkills() async {
    setState(() => _isLoading = true);

    try {
      final profileData = await _profileService.getUserProfile();
      if (profileData != null && profileData['skills'] != null) {
        final skillsData = Map<String, dynamic>.from(profileData['skills']);

        setState(() {
          skillsData.forEach((category, skills) {
            if (_skills.containsKey(category)) {
              _skills[category] = List<String>.from(skills ?? []);
            }
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSkills() async {
    setState(() => _isSaving = true);

    try {
      final success = await _profileService.updateSkills(_skills);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(child: Text('Skills saved successfully')),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(child: Text('Failed to save skills')),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Normalizes text to prevent duplicates
  String _normalizeText(String text) {
    String normalized = text.trim().toLowerCase();
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    // Capitalize first letter of each word
    return normalized.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  void _addSkill(String category, String skill) {
    final normalized = _normalizeText(skill);

    if (normalized.isEmpty) return;

    // Check for duplicates (case-insensitive)
    final normalizedLower = normalized.toLowerCase();
    final isDuplicate = _skills[category]!.any(
      (s) => s.toLowerCase() == normalizedLower
    );

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text('This skill is already added')),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _skills[category]!.add(normalized);
      _controllers[category]!.clear();
    });
  }

  void _removeSkill(String category, String skill) {
    setState(() {
      _skills[category]!.remove(skill);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Manage Skills',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveSkills,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _skills.entries.map((entry) {
                  return _buildSkillCategory(entry.key, entry.value);
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildSkillCategory(String category, List<String> skills) {
    final suggestions = _suggestions[category] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category title
            Text(
              category,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Input field for adding custom skills
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controllers[category],
                    decoration: InputDecoration(
                      hintText: 'Add a $category skill...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      prefixIcon: const Icon(Icons.add_circle_outline),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _addSkill(category, value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: () {
                    final text = _controllers[category]!.text;
                    if (text.isNotEmpty) {
                      _addSkill(category, text);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Your skills chips
            if (skills.isNotEmpty) ...[
              const Text(
                'Your Skills:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((skill) {
                  return InputChip(
                    label: Text(skill),
                    onDeleted: () => _removeSkill(category, skill),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    deleteIconColor: Colors.blue,
                    side: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Suggestions
            if (suggestions.isNotEmpty) ...[
              const Text(
                'Quick Add:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions.map((suggestion) {
                  final isSelected = skills.any(
                    (s) => s.toLowerCase() == suggestion.toLowerCase()
                  );

                  return ActionChip(
                    label: Text(suggestion),
                    onPressed: isSelected ? null : () => _addSkill(category, suggestion),
                    backgroundColor: isSelected
                        ? Colors.grey.withValues(alpha: 0.3)
                        : Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.grey : Colors.black87,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.grey.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.5),
                    ),
                    avatar: isSelected
                        ? const Icon(Icons.check_circle, size: 16, color: Colors.grey)
                        : null,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
