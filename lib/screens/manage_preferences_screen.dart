import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yajid/theme/app_theme.dart';

class ManagePreferencesScreen extends StatefulWidget {
  const ManagePreferencesScreen({super.key});

  @override
  State<ManagePreferencesScreen> createState() => _ManagePreferencesScreenState();
}

class _ManagePreferencesScreenState extends State<ManagePreferencesScreen> {
  final TextEditingController _textController = TextEditingController();
  List<String> _selectedPreferences = [];
  bool _isLoading = true;
  bool _isSaving = false;

  // Predefined suggestions for preferences
  static const List<String> _suggestions = [
    'Movies',
    'Music',
    'Books',
    'TV Shows',
    'Podcasts',
    'Sports',
    'Videogames',
    'Brands',
    'Recipes',
    'Events',
    'Activities',
    'Businesses',
    'Restaurants',
    'Coffee Shops',
    'Bars',
    'Nightlife',
    'Art & Culture',
    'Museums',
    'Theatre',
    'Concerts',
    'Festivals',
    'Outdoor Activities',
    'Travel',
    'Photography',
    'Fashion',
    'Technology',
    'Gaming',
    'Fitness',
    'Yoga',
    'Wellness',
    'Food & Dining',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final lookingFor = prefs.getStringList('looking_for') ?? [];

      if (mounted) {
        setState(() {
          _selectedPreferences = lookingFor;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('looking_for', _selectedPreferences);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text('Preferences saved successfully')),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed to save preferences: $e')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Normalizes text to prevent duplicates
  /// - Converts to lowercase
  /// - Trims whitespace
  /// - Removes extra spaces
  /// - Capitalizes first letter of each word
  String _normalizeText(String text) {
    // Trim and convert to lowercase for comparison
    String normalized = text.trim().toLowerCase();

    // Remove extra spaces
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    // Capitalize first letter of each word
    return normalized.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  void _addPreference(String preference) {
    final normalized = _normalizeText(preference);

    if (normalized.isEmpty) return;

    // Check for duplicates (case-insensitive)
    final normalizedLower = normalized.toLowerCase();
    final isDuplicate = _selectedPreferences.any(
      (p) => p.toLowerCase() == normalizedLower
    );

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text('This preference is already added')),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _selectedPreferences.add(normalized);
      _textController.clear();
    });
  }

  void _removePreference(String preference) {
    setState(() {
      _selectedPreferences.remove(preference);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Manage Preferences',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _savePreferences,
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
                children: [
                  // Input field for adding custom preferences
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              decoration: const InputDecoration(
                                hintText: 'Type to add a preference...',
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.add_circle_outline),
                              ),
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  _addPreference(value);
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.blue),
                            onPressed: () {
                              if (_textController.text.isNotEmpty) {
                                _addPreference(_textController.text);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Selected preferences section
                  if (_selectedPreferences.isNotEmpty) ...[
                    const Text(
                      'Your Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedPreferences.map((preference) {
                        return InputChip(
                          label: Text(preference),
                          onDeleted: () => _removePreference(preference),
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
                    const SizedBox(height: 24),
                  ],

                  // Suggestions section
                  const Text(
                    'Quick Add Suggestions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to quickly add popular preferences',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestions.map((suggestion) {
                      final isSelected = _selectedPreferences.any(
                        (p) => p.toLowerCase() == suggestion.toLowerCase()
                      );

                      return ActionChip(
                        label: Text(suggestion),
                        onPressed: isSelected ? null : () => _addPreference(suggestion),
                        backgroundColor: isSelected
                            ? Colors.grey.withValues(alpha: 0.3)
                            : Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.grey : Colors.black87,
                          fontWeight: isSelected ? FontWeight.normal : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.grey.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.5),
                        ),
                        avatar: isSelected
                            ? const Icon(Icons.check_circle, size: 18, color: Colors.grey)
                            : null,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'These preferences help us personalize your recommendations. You can add custom preferences or use our suggestions.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
