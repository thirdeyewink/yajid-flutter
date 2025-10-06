import 'package:flutter/material.dart';
import 'package:yajid/services/user_profile_service.dart';
import 'package:yajid/theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _nameArController = TextEditingController();
  final TextEditingController _nameEsController = TextEditingController();
  final TextEditingController _nameFrController = TextEditingController();
  final TextEditingController _namePtController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileData = await _profileService.getUserProfile();
      if (profileData != null) {
        if (mounted) {
          setState(() {
            _nameEnController.text = profileData['displayName'] ?? '';
            _nameArController.text = profileData['displayName_ar'] ?? '';
            _nameEsController.text = profileData['displayName_es'] ?? '';
            _nameFrController.text = profileData['displayName_fr'] ?? '';
            _namePtController.text = profileData['displayName_pt'] ?? '';
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await _profileService.updatePersonalInfo(
        displayName: _nameEnController.text.trim().isNotEmpty ? _nameEnController.text.trim() : null,
        displayNameAr: _nameArController.text.trim().isNotEmpty ? _nameArController.text.trim() : null,
        displayNameEs: _nameEsController.text.trim().isNotEmpty ? _nameEsController.text.trim() : null,
        displayNameFr: _nameFrController.text.trim().isNotEmpty ? _nameFrController.text.trim() : null,
        displayNamePt: _namePtController.text.trim().isNotEmpty ? _namePtController.text.trim() : null,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate profile was updated
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _nameEsController.dispose();
    _nameFrController.dispose();
    _namePtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Multi-Language Display Names',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set your name in different languages. The app will display your name based on the selected language.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // English Name
                    _buildNameField(
                      controller: _nameEnController,
                      label: 'English Name (Default)',
                      hint: 'Enter your name in English',
                      icon: Icons.language,
                      flagEmoji: '🇬🇧',
                    ),
                    const SizedBox(height: 16),

                    // Arabic Name
                    _buildNameField(
                      controller: _nameArController,
                      label: 'Arabic Name',
                      hint: 'أدخل اسمك بالعربية',
                      icon: Icons.language,
                      flagEmoji: '🇸🇦',
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 16),

                    // Spanish Name
                    _buildNameField(
                      controller: _nameEsController,
                      label: 'Spanish Name',
                      hint: 'Ingresa tu nombre en español',
                      icon: Icons.language,
                      flagEmoji: '🇪🇸',
                    ),
                    const SizedBox(height: 16),

                    // French Name
                    _buildNameField(
                      controller: _nameFrController,
                      label: 'French Name',
                      hint: 'Entrez votre nom en français',
                      icon: Icons.language,
                      flagEmoji: '🇫🇷',
                    ),
                    const SizedBox(height: 16),

                    // Portuguese Name
                    _buildNameField(
                      controller: _namePtController,
                      label: 'Portuguese Name',
                      hint: 'Digite seu nome em português',
                      icon: Icons.language,
                      flagEmoji: '🇵🇹',
                    ),
                    const SizedBox(height: 32),

                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Leave a field empty if you don\'t want to set a name for that language. The app will use the default English name.',
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
            ),
    );
  }

  Widget _buildNameField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String flagEmoji,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              flagEmoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textDirection: textDirection,
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: textDirection,
            prefixIcon: Icon(icon, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
