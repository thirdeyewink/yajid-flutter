import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';
import '../bloc/event/event_bloc.dart';
import '../bloc/event/event_event.dart';
import '../bloc/event/event_state.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: Colors.black,
        actions: [
          // Only show edit/delete for event owner
          if (widget.event.userId == FirebaseAuth.instance.currentUser?.uid)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditDialog();
                } else if (value == 'delete') {
                  _showDeleteDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit Event'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Event', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventDeleted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is EventUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Type Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getEventColor(widget.event.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getEventIcon(widget.event.type),
                      size: 16,
                      color: _getEventColor(widget.event.type),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.event.type,
                      style: TextStyle(
                        color: _getEventColor(widget.event.type),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Event Title
              Text(
                widget.event.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Event Details Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Date',
                        '${widget.event.date.day}/${widget.event.date.month}/${widget.event.date.year}',
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        Icons.access_time,
                        'Time',
                        widget.event.time,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        Icons.timelapse,
                        'Duration',
                        _formatDuration(widget.event.durationMinutes),
                      ),
                      if (widget.event.place.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildDetailRow(
                          Icons.location_on,
                          'Location',
                          widget.event.place,
                        ),
                      ],
                      if (widget.event.description.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildDetailRow(
                          Icons.description,
                          'Description',
                          widget.event.description,
                        ),
                      ],
                      if (widget.event.participants.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildDetailRow(
                          Icons.people,
                          'Participants',
                          widget.event.participants.join(', '),
                        ),
                      ],
                      if (widget.event.videoLink != null) ...[
                        const Divider(height: 24),
                        _buildDetailRow(
                          Icons.video_call,
                          'Video Link',
                          widget.event.videoLink!,
                          isLink: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Status Indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.event).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(widget.event),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(widget.event),
                      color: _getStatusColor(widget.event),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getStatusText(widget.event),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(widget.event),
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

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLink ? Colors.blue : null,
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else if (minutes == 60) {
      return '1 hour';
    } else if (minutes == 1440) {
      return 'All day';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hours';
      } else {
        return '$hours h $remainingMinutes min';
      }
    }
  }

  Color _getEventColor(String type) {
    switch (type.toLowerCase()) {
      case 'dinner':
      case 'dining':
        return Colors.orange;
      case 'drinks':
        return Colors.purple;
      case 'party':
        return Colors.pink;
      case 'date':
        return Colors.red;
      case 'playdate':
        return Colors.green;
      case 'concert':
      case 'festival':
        return Colors.purple;
      case 'play':
      case 'movie':
      case 'comedy show':
        return Colors.indigo;
      case 'sports game':
      case 'training':
        return Colors.blue;
      case 'meeting':
      case 'conference':
      case 'workshop':
        return Colors.teal;
      case 'birthday':
      case 'wedding':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(String type) {
    switch (type.toLowerCase()) {
      case 'dinner':
      case 'dining':
        return Icons.restaurant;
      case 'drinks':
        return Icons.local_bar;
      case 'party':
        return Icons.celebration;
      case 'date':
        return Icons.favorite;
      case 'playdate':
        return Icons.child_care;
      case 'concert':
      case 'festival':
        return Icons.music_note;
      case 'play':
      case 'movie':
        return Icons.movie;
      case 'comedy show':
        return Icons.theater_comedy;
      case 'sports game':
        return Icons.sports_soccer;
      case 'training':
        return Icons.fitness_center;
      case 'meeting':
        return Icons.business;
      case 'conference':
        return Icons.groups;
      case 'workshop':
        return Icons.construction;
      case 'birthday':
        return Icons.cake;
      case 'wedding':
        return Icons.favorite_border;
      default:
        return Icons.event;
    }
  }

  Color _getStatusColor(EventModel event) {
    if (event.isPast) {
      return Colors.grey;
    } else if (event.isActive) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  IconData _getStatusIcon(EventModel event) {
    if (event.isPast) {
      return Icons.check_circle;
    } else if (event.isActive) {
      return Icons.circle;
    } else {
      return Icons.schedule;
    }
  }

  String _getStatusText(EventModel event) {
    if (event.isPast) {
      return 'Completed';
    } else if (event.isActive) {
      return 'Active Now';
    } else {
      return 'Upcoming';
    }
  }

  void _showEditDialog() {
    final titleController = TextEditingController(text: widget.event.title);
    final descriptionController = TextEditingController(text: widget.event.description);
    final placeController = TextEditingController(text: widget.event.place);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: placeController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final updates = <String, dynamic>{
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'place': placeController.text,
                };
                context.read<EventBloc>().add(UpdateEvent(widget.event.id, updates));
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<EventBloc>().add(DeleteEvent(widget.event.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
