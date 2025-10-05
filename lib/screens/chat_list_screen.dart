import 'package:flutter/material.dart';
import 'package:yajid/models/chat_model.dart';
import 'package:yajid/services/messaging_service.dart';
import 'package:yajid/screens/chat_screen.dart';
import 'package:yajid/screens/user_search_screen.dart';
import 'package:yajid/theme/app_theme.dart';
import 'package:yajid/widgets/shared_bottom_nav.dart';
import 'package:yajid/l10n/app_localizations.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final MessagingService _messagingService = MessagingService();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedChatIds = {};
  String _selectedCategory = 'Friends';

  @override
  void initState() {
    super.initState();
    _initializeMessaging();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeMessaging() async {
    await _messagingService.initializeUser();
  }

  void _toggleSelection(String chatId) {
    setState(() {
      if (_selectedChatIds.contains(chatId)) {
        _selectedChatIds.remove(chatId);
      } else {
        _selectedChatIds.add(chatId);
      }
    });
  }

  void _archiveSelected() {
    if (_selectedChatIds.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text('${_selectedChatIds.length} chat(s) archived'),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {
      _selectedChatIds.clear();
    });
  }

  void _deleteSelected() {
    if (_selectedChatIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteChats),
        content: Text('Are you sure you want to delete ${_selectedChatIds.length} chat(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text('${_selectedChatIds.length} chat(s) deleted'),
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              setState(() {
                _selectedChatIds.clear();
              });
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      drawer: _buildNavigationDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              )
            : const Text(
                'Inbox',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: _selectedChatIds.isEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserSearchScreen(),
                      ),
                    );
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.archive, color: Colors.white),
                  onPressed: _archiveSelected,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: _deleteSelected,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _selectedChatIds.clear();
                    });
                  },
                ),
              ],
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: _messagingService.getUserChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your messaging journey by tapping the + button',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final currentUserId = _messagingService.currentUserId!;
              final otherUserName = chat.getOtherParticipantName(currentUserId);
              final unreadCount = chat.getUnreadCountForUser(currentUserId);

              final isSelected = _selectedChatIds.contains(chat.id);

              return ListTile(
                leading: _selectedChatIds.isEmpty
                    ? CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          _toggleSelection(chat.id);
                        },
                      ),
                title: Text(
                  otherUserName,
                  style: TextStyle(
                    fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: chat.lastMessage != null
                    ? Text(
                        chat.lastMessage!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: unreadCount > 0 ? Colors.black87 : Colors.grey.shade600,
                          fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                        ),
                      )
                    : Text(
                        'No messages yet',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                trailing: _selectedChatIds.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (chat.lastMessageTime != null)
                            Text(
                              _formatTime(chat.lastMessageTime!),
                              style: TextStyle(
                                fontSize: 12,
                                color: unreadCount > 0 ? Colors.blue : Colors.grey.shade500,
                              ),
                            ),
                          if (unreadCount > 0) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(minWidth: 20),
                              child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      )
                    : isSelected
                        ? const Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                onTap: () {
                  if (_selectedChatIds.isEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatId: chat.id,
                          otherUserName: otherUserName,
                          otherUserId: chat.getOtherParticipantId(currentUserId),
                        ),
                      ),
                    );
                  } else {
                    _toggleSelection(chat.id);
                  }
                },
                onLongPress: () {
                  _toggleSelection(chat.id);
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const SharedBottomNav(
        currentIndex: 0, // Use Home as default since this is accessed via messages icon
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d';
      } else {
        return '${time.day}/${time.month}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppTheme.buildLogo(),
                const SizedBox(height: 16),
                const Text(
                  'Inbox Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.people,
            title: 'Friends',
            isSelected: _selectedCategory == 'Friends',
            onTap: () {
              setState(() {
                _selectedCategory = 'Friends';
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.group,
            title: 'Groups',
            isSelected: _selectedCategory == 'Groups',
            onTap: () {
              setState(() {
                _selectedCategory = 'Groups';
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.forum,
            title: 'Threads',
            isSelected: _selectedCategory == 'Threads',
            onTap: () {
              setState(() {
                _selectedCategory = 'Threads';
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.local_offer,
            title: 'Promotions',
            isSelected: _selectedCategory == 'Promotions',
            onTap: () {
              setState(() {
                _selectedCategory = 'Promotions';
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.report,
            title: 'Spam',
            isSelected: _selectedCategory == 'Spam',
            onTap: () {
              setState(() {
                _selectedCategory = 'Spam';
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.delete,
            title: 'Trash',
            isSelected: _selectedCategory == 'Trash',
            onTap: () {
              setState(() {
                _selectedCategory = 'Trash';
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.blue.shade50,
      onTap: onTap,
    );
  }
}