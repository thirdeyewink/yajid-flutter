import 'package:flutter/material.dart';
import 'package:yajid/theme/app_theme.dart';
import 'package:yajid/widgets/shared_bottom_nav.dart';
import 'package:yajid/l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Filter state
  Set<String> _selectedFilters = {'social', 'recommendation', 'system'};

  // Sample notifications data
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'social',
      'title': 'New Friend Request',
      'message': 'Sarah Johnson wants to connect with you',
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
      'isRead': false,
      'icon': Icons.person_add,
      'color': Colors.blue,
      'actionType': 'friend_request',
    },
    {
      'id': '2',
      'type': 'recommendation',
      'title': 'New Movie Recommendation',
      'message': 'Based on your preferences, we think you\'ll love "Oppenheimer"',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
      'icon': Icons.movie,
      'color': Colors.purple,
      'actionType': 'view_recommendation',
    },
    {
      'id': '3',
      'type': 'social',
      'title': 'Comment on Your Review',
      'message': 'Mike Thompson commented on your review of "Dune"',
      'time': DateTime.now().subtract(const Duration(hours: 4)),
      'isRead': true,
      'icon': Icons.comment,
      'color': Colors.green,
      'actionType': 'view_comment',
    },
    {
      'id': '4',
      'type': 'system',
      'title': 'Weekly Digest Ready',
      'message': 'Your personalized weekly recommendations are ready to view',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'icon': Icons.email,
      'color': Colors.orange,
      'actionType': 'view_digest',
    },
    {
      'id': '5',
      'type': 'recommendation',
      'title': 'Trending in Your Area',
      'message': 'New sushi restaurant "Sakura" is trending near you',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
      'icon': Icons.trending_up,
      'color': Colors.red,
      'actionType': 'view_trending',
    },
    {
      'id': '6',
      'type': 'social',
      'title': 'Friend Activity',
      'message': 'Emma rated 5 new movies this week',
      'time': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
      'icon': Icons.star,
      'color': Colors.amber,
      'actionType': 'view_activity',
    },
  ];


  void _markAsRead(String notificationId) {
    setState(() {
      final notification = _notifications.firstWhere((n) => n['id'] == notificationId);
      notification['isRead'] = true;
    });
  }


  void _deleteNotification(String notificationId) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notificationId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(AppLocalizations.of(context)!.notificationDeleted)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleNotificationAction(Map<String, dynamic> notification) {
    _markAsRead(notification['id']);

    switch (notification['actionType']) {
      case 'friend_request':
        _showFriendRequestDialog(notification);
        break;
      case 'view_recommendation':
        _showRecommendationDialog(notification);
        break;
      case 'view_comment':
        _showCommentDialog(notification);
        break;
      case 'view_digest':
        _showDigestDialog(notification);
        break;
      case 'view_trending':
        _showTrendingDialog(notification);
        break;
      case 'view_activity':
        _showActivityDialog(notification);
        break;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.filterNotifications),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: Text(AppLocalizations.of(context)!.social),
                  subtitle: Text(AppLocalizations.of(context)!.socialDescription),
                  value: _selectedFilters.contains('social'),
                  onChanged: (bool? value) {
                    setDialogState(() {
                      if (value == true) {
                        _selectedFilters.add('social');
                      } else {
                        _selectedFilters.remove('social');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(AppLocalizations.of(context)!.newRecommendations),
                  subtitle: Text(AppLocalizations.of(context)!.newRecommendationsDescription),
                  value: _selectedFilters.contains('recommendation'),
                  onChanged: (bool? value) {
                    setDialogState(() {
                      if (value == true) {
                        _selectedFilters.add('recommendation');
                      } else {
                        _selectedFilters.remove('recommendation');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(AppLocalizations.of(context)!.system),
                  subtitle: Text(AppLocalizations.of(context)!.systemDescription),
                  value: _selectedFilters.contains('system'),
                  onChanged: (bool? value) {
                    setDialogState(() {
                      if (value == true) {
                        _selectedFilters.add('system');
                      } else {
                        _selectedFilters.remove('system');
                      }
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilters = {'social', 'recommendation', 'system'};
              });
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.reset),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.apply),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      appBar: AppTheme.buildAppBar(
        title: Text(
          AppLocalizations.of(context)!.notifications,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: _buildNotificationsList(),
      bottomNavigationBar: const SharedBottomNav(
        currentIndex: 0, // Home index
      ),
    );
  }

  Widget _buildNotificationsList() {
    // Filter notifications based on selected filters
    final filteredNotifications = _notifications
        .where((notification) => _selectedFilters.contains(notification['type']))
        .toList();

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noNotifications,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.allCaughtUp,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: notification['isRead'] ? 1 : 3,
      child: Dismissible(
        key: Key(notification['id']),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          _deleteNotification(notification['id']);
        },
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (notification['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              notification['icon'],
              color: notification['color'],
              size: 24,
            ),
          ),
          title: Text(
            notification['title'],
            style: TextStyle(
              fontWeight: notification['isRead'] ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification['message'],
                style: TextStyle(
                  color: notification['isRead'] ? Colors.grey.shade600 : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(notification['time']),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          trailing: notification['isRead']
              ? null
              : Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
          onTap: () => _handleNotificationAction(notification),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context)!.justNow;
    } else if (difference.inMinutes < 60) {
      return AppLocalizations.of(context)!.minutesAgo(difference.inMinutes.toString());
    } else if (difference.inHours < 24) {
      return AppLocalizations.of(context)!.hoursAgo(difference.inHours.toString());
    } else if (difference.inDays < 7) {
      return AppLocalizations.of(context)!.daysAgo(difference.inDays.toString());
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _showFriendRequestDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.friendRequest),
        content: Text(notification['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.decline),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(child: Text(AppLocalizations.of(context)!.friendRequestAccepted)),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.accept),
          ),
        ],
      ),
    );
  }

  void _showRecommendationDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.newRecommendation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.movie, size: 48, color: Colors.purple),
            const SizedBox(height: 16),
            Text(notification['message']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.later),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.viewDetails),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.newComment),
        content: Text(notification['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.viewComment),
          ),
        ],
      ),
    );
  }

  void _showDigestDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.weeklyDigest),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.email, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.weeklyRecommendationsReady),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.later),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.viewDigest),
          ),
        ],
      ),
    );
  }

  void _showTrendingDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.trendingNearYou),
        content: Text(notification['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.learnMore),
          ),
        ],
      ),
    );
  }

  void _showActivityDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.friendActivity),
        content: Text(notification['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.viewProfile),
          ),
        ],
      ),
    );
  }
}