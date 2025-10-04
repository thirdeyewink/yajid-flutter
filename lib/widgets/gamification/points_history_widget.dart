import 'package:flutter/material.dart';
import 'package:yajid/models/gamification/points_model.dart';
import 'package:intl/intl.dart';

class PointsHistoryWidget extends StatelessWidget {
  final List<PointsTransaction> transactions;

  const PointsHistoryWidget({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'No activity yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start earning points to see your history',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length > 20 ? 20 : transactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionTile(transaction);
      },
    );
  }

  Widget _buildTransactionTile(PointsTransaction transaction) {
    final isEarned = transaction.type == PointsTransactionType.earned ||
        transaction.type == PointsTransactionType.bonus;
    final pointsColor = isEarned ? Colors.green : Colors.red;
    final pointsSign = isEarned ? '+' : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: pointsColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForCategory(transaction.category),
            size: 20,
            color: pointsColor,
          ),
        ),
        title: Text(
          transaction.description ?? _getCategoryDisplayName(transaction.category),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _formatDate(transaction.timestamp),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: pointsColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$pointsSign${transaction.points}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: pointsColor,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    try {
      final pointsCategory = PointsCategory.values.firstWhere(
        (e) => e.name == category,
        orElse: () => PointsCategory.other,
      );
      return _getIconDataFromName(pointsCategory.iconName);
    } catch (e) {
      return Icons.more_horiz;
    }
  }

  IconData _getIconDataFromName(String iconName) {
    switch (iconName) {
      case 'location_on':
        return Icons.location_on;
      case 'rate_review':
        return Icons.rate_review;
      case 'photo_camera':
        return Icons.photo_camera;
      case 'share':
        return Icons.share;
      case 'person_add':
        return Icons.person_add;
      case 'stars':
        return Icons.stars;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'event':
        return Icons.event;
      case 'account_circle':
        return Icons.account_circle;
      case 'group':
        return Icons.group;
      case 'thumb_up':
        return Icons.thumb_up;
      case 'military_tech':
        return Icons.military_tech;
      case 'trending_up':
        return Icons.trending_up;
      default:
        return Icons.more_horiz;
    }
  }

  String _getCategoryDisplayName(String category) {
    try {
      final pointsCategory = PointsCategory.values.firstWhere(
        (e) => e.name == category,
        orElse: () => PointsCategory.other,
      );
      return pointsCategory.displayName;
    } catch (e) {
      return 'Activity';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
