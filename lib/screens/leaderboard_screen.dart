import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yajid/models/gamification/level_model.dart';
import 'package:yajid/services/gamification_service.dart';
import 'package:yajid/theme/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final GamificationService _gamificationService = GamificationService();
  List<LeaderboardEntry> _leaderboardEntries = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'global';
  LeaderboardEntry? _currentUserEntry;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Please sign in to view leaderboard';
          _isLoading = false;
        });
        return;
      }

      // Get leaderboard based on selected filter
      List<LeaderboardEntry> entries;
      switch (_selectedFilter) {
        case 'weekly':
          entries = await _gamificationService.getWeeklyLeaderboard(limit: 100);
          break;
        case 'monthly':
          entries = await _gamificationService.getMonthlyLeaderboard(limit: 100);
          break;
        case 'friends':
          entries = await _gamificationService.getFriendsLeaderboard(userId: user.uid, limit: 100);
          break;
        default: // 'global'
          entries = await _gamificationService.getLeaderboard(limit: 100);
      }

      // Find current user's entry
      LeaderboardEntry? currentEntry;
      try {
        currentEntry = entries.firstWhere((entry) => entry.userId == user.uid);
      } catch (e) {
        // Current user not in top 100
      }

      if (mounted) {
        setState(() {
          _leaderboardEntries = entries;
          _currentUserEntry = currentEntry;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load leaderboard: $e';
          _isLoading = false;
        });
      }
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
          'Leaderboard',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(),

          // Content
          Expanded(
            child: _buildLeaderboardContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterTab('global', 'Global', Icons.public),
          const SizedBox(width: 8),
          _buildFilterTab('friends', 'Friends', Icons.people),
          const SizedBox(width: 8),
          _buildFilterTab('weekly', 'Weekly', Icons.calendar_today),
          const SizedBox(width: 8),
          _buildFilterTab('monthly', 'Monthly', Icons.calendar_month),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (_selectedFilter != value) {
            setState(() {
              _selectedFilter = value;
            });
            _loadLeaderboard();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardContent() {
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
              onPressed: _loadLeaderboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_leaderboardEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No leaderboard data yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to earn points!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Top 3 podium
        if (_leaderboardEntries.length >= 3)
          SliverToBoxAdapter(
            child: _buildPodium(),
          ),

        // Current user position (if not in top 3)
        if (_currentUserEntry != null && _currentUserEntry!.rank > 3)
          SliverToBoxAdapter(
            child: _buildCurrentUserCard(),
          ),

        // Divider
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(color: Colors.grey.shade300),
          ),
        ),

        // Rest of leaderboard
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Skip top 3 as they're in podium
                final adjustedIndex = index + 3;
                if (adjustedIndex >= _leaderboardEntries.length) return null;

                final entry = _leaderboardEntries[adjustedIndex];
                final isCurrentUser = entry.userId == FirebaseAuth.instance.currentUser?.uid;
                return _buildLeaderboardTile(entry, isCurrentUser);
              },
              childCount: _leaderboardEntries.length > 3
                  ? _leaderboardEntries.length - 3
                  : 0,
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
      ],
    );
  }

  Widget _buildPodium() {
    final top3 = _leaderboardEntries.take(3).toList();
    if (top3.length < 3) return const SizedBox.shrink();

    // Arrange as: 2nd, 1st, 3rd
    final first = top3[0];
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade100,
            Colors.yellow.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🏆 Top Champions 🏆',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place
              if (second != null) _buildPodiumPlace(second, 2, 130),
              // 1st place
              _buildPodiumPlace(first, 1, 160),
              // 3rd place
              if (third != null) _buildPodiumPlace(third, 3, 110),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(LeaderboardEntry entry, int place, double height) {
    Color medalColor;

    switch (place) {
      case 1:
        medalColor = const Color(0xFFFFD700); // Gold
        break;
      case 2:
        medalColor = const Color(0xFFC0C0C0); // Silver
        break;
      case 3:
        medalColor = const Color(0xFFCD7F32); // Bronze
        break;
      default:
        medalColor = Colors.grey;
    }

    return SizedBox(
      width: 90,
      child: Column(
        children: [
          // Medal badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: medalColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: medalColor.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                place.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: _getTierColor(entry.tier),
            child: Text(
              entry.userName.isNotEmpty ? entry.userName[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Name
          Text(
            entry.userName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          // Points
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 12, color: Colors.amber.shade700),
                const SizedBox(width: 2),
                Text(
                  entry.totalPoints.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Podium base
          Container(
            height: height - 100,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: medalColor.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserCard() {
    if (_currentUserEntry == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: const Center(
              child: Text(
                'Your Position',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildRankBadge(_currentUserEntry!.rank, Colors.blue),
                const SizedBox(width: 12),
                _buildAvatar(_currentUserEntry!),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUserEntry!.userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Level ${_currentUserEntry!.level} • ${_currentUserEntry!.tier.displayName}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPointsBadge(_currentUserEntry!.totalPoints),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(LeaderboardEntry entry, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? Colors.blue : Colors.grey.shade200,
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          _buildRankBadge(
            entry.rank,
            isCurrentUser ? Colors.blue : Colors.grey.shade700,
          ),
          const SizedBox(width: 12),
          _buildAvatar(entry),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                Text(
                  'Level ${entry.level} • ${entry.tier.displayName}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (entry.isRankImproved)
            Icon(
              Icons.arrow_upward,
              size: 16,
              color: Colors.green,
            ),
          const SizedBox(width: 8),
          _buildPointsBadge(entry.totalPoints),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(LeaderboardEntry entry) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: _getTierColor(entry.tier),
      child: Text(
        entry.userName.isNotEmpty ? entry.userName[0].toUpperCase() : 'U',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPointsBadge(int points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: Colors.amber.shade700),
          const SizedBox(width: 4),
          Text(
            points.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(ExpertiseTier tier) {
    switch (tier) {
      case ExpertiseTier.novice:
        return const Color(0xFF9CA3AF);
      case ExpertiseTier.explorer:
        return const Color(0xFFCD7F32);
      case ExpertiseTier.adventurer:
        return const Color(0xFF9CA3AF);
      case ExpertiseTier.expert:
        return const Color(0xFFFFC107);
      case ExpertiseTier.master:
        return const Color(0xFFE5E4E2);
      case ExpertiseTier.legend:
        return const Color(0xFF8B5CF6);
    }
  }
}
