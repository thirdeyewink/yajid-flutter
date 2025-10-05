import 'package:flutter/material.dart';
import 'package:yajid/theme/app_theme.dart';

class AddContentScreen extends StatefulWidget {
  const AddContentScreen({super.key});

  @override
  State<AddContentScreen> createState() => _AddContentScreenState();
}

class _AddContentScreenState extends State<AddContentScreen> {

  void _showAddMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'business',
          child: Row(
            children: [
              Icon(Icons.business, size: 20),
              SizedBox(width: 12),
              Text('Add Your Business'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'event',
          child: Row(
            children: [
              Icon(Icons.event, size: 20),
              SizedBox(width: 12),
              Text('Create Event'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'trip',
          child: Row(
            children: [
              Icon(Icons.flight, size: 20),
              SizedBox(width: 12),
              Text('New Trip'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'group',
          child: Row(
            children: [
              Icon(Icons.group, size: 20),
              SizedBox(width: 12),
              Text('Create Group'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'thread',
          child: Row(
            children: [
              Icon(Icons.forum, size: 20),
              SizedBox(width: 12),
              Text('Create Thread'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'recipe',
          child: Row(
            children: [
              Icon(Icons.restaurant_menu, size: 20),
              SizedBox(width: 12),
              Text('Add Recipe'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('$value feature coming soon')),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          elevation: 1,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppTheme.buildLogo(size: 55.0),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => _showAddMenu(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: const Center(
        child: SizedBox.shrink(),
      ),
    );
  }
}