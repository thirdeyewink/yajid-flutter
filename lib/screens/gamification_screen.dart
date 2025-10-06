import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yajid/bloc/gamification/gamification_bloc.dart';
import 'package:yajid/bloc/gamification/gamification_event.dart';
import 'package:yajid/bloc/gamification/gamification_state.dart';
import 'package:yajid/widgets/gamification/points_display_widget.dart';
import 'package:yajid/widgets/gamification/points_history_widget.dart';
import 'package:yajid/models/gamification/badge_model.dart';
import 'package:yajid/models/gamification/level_model.dart';
import 'package:yajid/screens/badge_showcase_screen.dart';
import 'package:yajid/screens/leaderboard_screen.dart';

/// Gamification screen showing points, badges, level, and leaderboard
class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> with SingleTickerProviderStateMixin {
  late GamificationBloc _gamificationBloc;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _gamificationBloc = GamificationBloc();
    _tabController = TabController(length: 4, vsync: this);
    _loadGamificationData();
  }

  void _loadGamificationData() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _gamificationBloc.add(LoadGamificationData(userId));
    }
  }

  @override
  void dispose() {
    _gamificationBloc.close();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Your Progress',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: Icon(Icons.stars, color: Colors.white), text: 'Points'),
            Tab(icon: Icon(Icons.military_tech, color: Colors.white), text: 'Badges'),
            Tab(icon: Icon(Icons.trending_up, color: Colors.white), text: 'Level'),
            Tab(icon: Icon(Icons.leaderboard, color: Colors.white), text: 'Leaderboard'),
          ],
        ),
      ),
      body: BlocBuilder<GamificationBloc, GamificationState>(
        bloc: _gamificationBloc,
        builder: (context, state) {
          if (state is GamificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GamificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadGamificationData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is GamificationLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildPointsTab(state),
                _buildBadgesTab(state),
                _buildLevelTab(state),
                _buildLeaderboardTab(),
              ],
            );
          }

          return const Center(child: Text('Loading...'));
        },
      ),
    );
  }

  Widget _buildPointsTab(GamificationLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          _gamificationBloc.add(RefreshGamificationData(userId));
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Points display card
            PointsDisplayWidget(
              userPoints: state.userPoints,
              userLevel: state.userLevel,
              compact: false,
            ),

            const SizedBox(height: 24),

            // Daily points remaining
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.today, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Points Remaining',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.dailyPointsRemaining} / 500 points',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${state.dailyPointsRemaining}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Points history
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            PointsHistoryWidget(
              transactions: state.pointsHistory,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesTab(GamificationLoaded state) {
    final unlockedBadges = state.userBadges.where((b) => b.isUnlocked).toList();
    final lockedBadges = state.userBadges.where((b) => !b.isUnlocked).toList();

    return RefreshIndicator(
      onRefresh: () async {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          _gamificationBloc.add(LoadUserBadges(userId));
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBadgeStat('Unlocked', unlockedBadges.length, Colors.green),
                        Container(width: 1, height: 40, color: Colors.grey[300]),
                        _buildBadgeStat('Locked', lockedBadges.length, Colors.grey),
                        Container(width: 1, height: 40, color: Colors.grey[300]),
                        _buildBadgeStat('Total', state.userBadges.length, Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BadgeShowcaseScreen()),
                        );
                      },
                      icon: const Icon(Icons.workspace_premium),
                      label: const Text('View All Badges'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Unlocked badges
            if (unlockedBadges.isNotEmpty) ...[
              const Text(
                'Unlocked Badges',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: unlockedBadges.length,
                itemBuilder: (context, index) => _buildBadgeCard(unlockedBadges[index], true),
              ),
              const SizedBox(height: 24),
            ],

            // Locked badges
            if (lockedBadges.isNotEmpty) ...[
              const Text(
                'Locked Badges',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: lockedBadges.length,
                itemBuilder: (context, index) => _buildBadgeCard(lockedBadges[index], false),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(UserBadge badge, bool isUnlocked) {
    return Card(
      elevation: isUnlocked ? 4 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isUnlocked ? null : Colors.grey[200],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.military_tech,
              size: 40,
              color: isUnlocked ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              badge.badgeId,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.black : Colors.grey,
              ),
            ),
            if (!isUnlocked) ...[
              const SizedBox(height: 4),
              Text(
                '${badge.currentProgress} pts',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLevelTab(GamificationLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          _gamificationBloc.add(RefreshGamificationData(userId));
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current level card
            Card(
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(int.parse(state.userLevel.tier.colorHex.replaceFirst('#', '0xFF'))),
                      Color(int.parse(state.userLevel.tier.colorHex.replaceFirst('#', '0xFF'))).withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Current Level',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${state.userLevel.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.userLevel.tier.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tier benefits
            const Text(
              'Tier Benefits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: state.userLevel.tier.benefits.map((benefit) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(benefit),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Next level progress
            const Text(
              'Level Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Level ${state.userLevel.level}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Level ${state.userLevel.level + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: state.userLevel.progressToNextLevel,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(int.parse(state.userLevel.tier.colorHex.replaceFirst('#', '0xFF'))),
                        ),
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${state.userLevel.pointsNeededForNextLevel} points to go!',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return RefreshIndicator(
      onRefresh: () async {
        _gamificationBloc.add(const LoadLeaderboard());
      },
      child: BlocBuilder<GamificationBloc, GamificationState>(
        bloc: _gamificationBloc,
        builder: (context, state) {
          if (state is LeaderboardLoaded) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                      );
                    },
                    icon: const Icon(Icons.emoji_events),
                    label: const Text('View Full Leaderboard'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.leaderboard.length > 10 ? 10 : state.leaderboard.length,
                    itemBuilder: (context, index) {
                final entry = state.leaderboard[index];
                final isCurrentUser = entry.userId == FirebaseAuth.instance.currentUser?.uid;

                return Card(
                  elevation: isCurrentUser ? 4 : 1,
                  color: isCurrentUser ? Colors.orange[50] : null,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getRankColor(entry.rank),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.rank}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      entry.userName,
                      style: TextStyle(
                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      'Level ${entry.level} • ${entry.tier.displayName}',
                      style: TextStyle(
                        color: Color(int.parse(entry.tier.colorHex.replaceFirst('#', '0xFF'))),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.totalPoints}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        if (entry.rankChange != 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                entry.rankChange > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 12,
                                color: entry.rankChange > 0 ? Colors.green : Colors.red,
                              ),
                              Text(
                                '${entry.rankChange.abs()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: entry.rankChange > 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
                ),
              ],
            );
          }

          // Auto-load leaderboard on first visit
          if (state is GamificationLoaded) {
            _gamificationBloc.add(const LoadLeaderboard());
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(child: Text('Loading leaderboard...'));
        },
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber; // Gold
    if (rank == 2) return Colors.grey; // Silver
    if (rank == 3) return Colors.orange; // Bronze
    return Colors.blue;
  }
}
