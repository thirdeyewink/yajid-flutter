import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _notificationTypes = ['All', 'Social', 'Recommendations', 'System'];

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _notificationTypes.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredNotifications() {
    final selectedType = _notificationTypes[_tabController.index].toLowerCase();
    if (selectedType == 'all') {
      return _notifications;
    }
    return _notifications.where((notification) {
      return notification['type'] == selectedType ||
             (selectedType == 'recommendations' && notification['type'] == 'recommendation');
    }).toList();
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final notification = _notifications.firstWhere((n) => n['id'] == notificationId);
      notification['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Center(child: Text('All notifications marked as read')),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notificationId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Center(child: Text('Notification deleted')),
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

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n['isRead']).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                _showNotificationSettings();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Notification Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: _notificationTypes.map((type) => Tab(text: type)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _notificationTypes.map((type) => _buildNotificationsList()).toList(),
      ),
    );
  }

  Widget _buildNotificationsList() {
    final filteredNotifications = _getFilteredNotifications();

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
              'No notifications',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
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
              color: notification['color'].withOpacity(0.1),
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
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _showFriendRequestDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Friend Request'),
        content: Text(notification['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Center(child: Text('Friend request accepted!')),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showRecommendationDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Recommendation'),
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
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Comment'),
        content: Text(notification['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('View Comment'),
          ),
        ],
      ),
    );
  }

  void _showDigestDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weekly Digest'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.email, size: 48, color: Colors.orange),
            SizedBox(height: 16),
            Text('Your personalized weekly recommendations are ready!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('View Digest'),
          ),
        ],
      ),
    );
  }

  void _showTrendingDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trending Near You'),
        content: Text(notification['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Learn More'),
          ),
        ],
      ),
    );
  }

  void _showActivityDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Friend Activity'),
        content: Text(notification['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('View Profile'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text('Notification settings coming soon!'),
            SizedBox(height: 8),
            Text(
              'You\'ll be able to customize which notifications you receive.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}