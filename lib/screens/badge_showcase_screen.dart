import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yajid/models/gamification/badge_model.dart' as gam;
import 'package:yajid/services/gamification_service.dart';
import 'package:yajid/theme/app_theme.dart';

class BadgeShowcaseScreen extends StatefulWidget {
  const BadgeShowcaseScreen({super.key});

  @override
  State<BadgeShowcaseScreen> createState() => _BadgeShowcaseScreenState();
}

class _BadgeShowcaseScreenState extends State<BadgeShowcaseScreen> {
  final GamificationService _gamificationService = GamificationService();
  List<gam.UserBadge> _userBadges = [];
  bool _isLoading = true;
  String? _errorMessage;
  gam.BadgeCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Please sign in to view badges';
          _isLoading = false;
        });
        return;
      }

      final userBadges = await _gamificationService.getUserBadges(user.uid);

      if (mounted) {
        setState(() {
          _userBadges = userBadges;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load badges: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<gam.Badge> _getFilteredBadges() {
    final allBadges = gam.PredefinedBadges.all;
    if (_selectedCategory == null) {
      return allBadges;
    }
    return allBadges.where((badge) => badge.category == _selectedCategory).toList();
  }

  gam.UserBadge? _getUserBadgeForBadge(gam.Badge badge) {
    try {
      return _userBadges.firstWhere((ub) => ub.badgeId == badge.id);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Badge Collection',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('All', null),
                  ...gam.BadgeCategory.values.map((category) {
                    return _buildCategoryChip(category.displayName, category);
                  }),
                ],
              ),
            ),
          ),

          // Badge stats summary
          _buildBadgeStats(),

          // Badges grid
          Expanded(
            child: _buildBadgeContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, gam.BadgeCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.blue.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildBadgeStats() {
    final unlockedCount = _userBadges.where((ub) => ub.isUnlocked).length;
    final totalCount = gam.PredefinedBadges.all.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.emoji_events,
            label: 'Unlocked',
            value: '$unlockedCount',
            color: Colors.amber,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildStatItem(
            icon: Icons.lock_outline,
            label: 'Locked',
            value: '${totalCount - unlockedCount}',
            color: Colors.grey,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildStatItem(
            icon: Icons.percent,
            label: 'Progress',
            value: totalCount > 0 ? '${((unlockedCount / totalCount) * 100).toInt()}%' : '0%',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadBadges,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredBadges = _getFilteredBadges();

    if (filteredBadges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No badges in this category',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredBadges.length,
      itemBuilder: (context, index) {
        final badge = filteredBadges[index];
        final userBadge = _getUserBadgeForBadge(badge);
        return _buildBadgeCard(badge, userBadge);
      },
    );
  }

  Widget _buildBadgeCard(gam.Badge badge, gam.UserBadge? userBadge) {
    final isUnlocked = userBadge?.isUnlocked ?? false;
    final tierColor = _getTierColor(badge.tier);

    return GestureDetector(
      onTap: () => _showBadgeDetails(badge, userBadge),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? tierColor : Colors.grey.shade300,
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Lock overlay for locked badges
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

            // Badge content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isUnlocked ? Icons.workspace_premium : Icons.lock,
                      size: 40,
                      color: isUnlocked ? tierColor : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Badge name
                  Text(
                    badge.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.black : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Tier badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge.tier.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: tierColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Points reward
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: isUnlocked ? Colors.amber : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${badge.pointsReward} pts',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isUnlocked ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  // Progress bar for locked badges
                  if (!isUnlocked && userBadge != null) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: userBadge.progressPercentage,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${userBadge.currentProgress}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(gam.BadgeTier tier) {
    switch (tier) {
      case gam.BadgeTier.bronze:
        return const Color(0xFFCD7F32);
      case gam.BadgeTier.silver:
        return const Color(0xFF9CA3AF);
      case gam.BadgeTier.gold:
        return const Color(0xFFFFC107);
      case gam.BadgeTier.platinum:
        return const Color(0xFFE5E4E2);
      case gam.BadgeTier.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  void _showBadgeDetails(gam.Badge badge, gam.UserBadge? userBadge) {
    final isUnlocked = userBadge?.isUnlocked ?? false;
    final tierColor = _getTierColor(badge.tier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with tier color
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: tierColor, width: 3),
                      ),
                      child: Icon(
                        isUnlocked ? Icons.workspace_premium : Icons.lock,
                        size: 50,
                        color: isUnlocked ? tierColor : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      badge.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: tierColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge.tier.displayName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badge.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Badge info
                    _buildDetailRow(
                      icon: Icons.category,
                      label: 'Category',
                      value: badge.category.displayName,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.star,
                      label: 'Reward',
                      value: '${badge.pointsReward} points',
                    ),

                    if (userBadge != null && isUnlocked) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        icon: Icons.check_circle,
                        label: 'Unlocked',
                        value: _formatDate(userBadge.unlockedAt!),
                      ),
                    ],

                    if (userBadge != null && !isUnlocked) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: userBadge.progressPercentage,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${userBadge.currentProgress}% complete',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
