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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedChatIds = {};
  String _selectedCategory = 'Inbox';

  @override
  void initState() {
    super.initState();
    _initializeMessaging();
  }

  String _getLocalizedCategoryName(String category) {
    switch (category) {
      case 'Inbox':
        return AppLocalizations.of(context)!.inbox;
      case 'Groups':
        return AppLocalizations.of(context)!.groups;
      case 'Events':
        return AppLocalizations.of(context)!.events;
      case 'Promotions':
        return AppLocalizations.of(context)!.promotions;
      case 'Draft':
        return AppLocalizations.of(context)!.draft;
      case 'Spam':
        return AppLocalizations.of(context)!.spam;
      case 'Trash':
        return AppLocalizations.of(context)!.trash;
      default:
        return category;
    }
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

  void _showCreateOptions() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: Container(
              width: 280,
              height: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40, right: 8),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 8, right: 16),
                    leading: const Icon(Icons.message, color: Colors.blue),
                    title: Text(AppLocalizations.of(context)!.writeNewMessage),
                    subtitle: Text(AppLocalizations.of(context)!.startConversation),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserSearchScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 8, right: 16),
                    leading: const Icon(Icons.forum, color: Colors.orange),
                    title: Text(AppLocalizations.of(context)!.startNewThread),
                    subtitle: Text(AppLocalizations.of(context)!.startTopicDiscussion),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(child: Text('Thread creation coming soon!')),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 8, right: 16),
                    leading: const Icon(Icons.group_add, color: Colors.green),
                    title: Text(AppLocalizations.of(context)!.startGroupChat),
                    subtitle: Text(AppLocalizations.of(context)!.chatWithMultiplePeople),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(child: Text('Group creation coming soon!')),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.screenBackground,
      endDrawer: _buildNavigationDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _getLocalizedCategoryName(_selectedCategory),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        leadingWidth: 120,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchConversations,
              hintStyle: const TextStyle(color: Colors.white70),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70, size: 20),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        actions: _selectedChatIds.isEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _showCreateOptions,
                ),
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    _scaffoldKey.currentState?.openEndDrawer();
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
                    AppLocalizations.of(context)!.noConversationsYet,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.startMessagingJourney,
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
                        AppLocalizations.of(context)!.noMessagesYet,
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
          Padding(
            padding: const EdgeInsets.only(top: 40, right: 8),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.inbox,
            title: _getLocalizedCategoryName('Inbox'),
            isSelected: _selectedCategory == 'Inbox',
            onTap: () {
              setState(() {
                _selectedCategory = 'Inbox';
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.group,
            title: _getLocalizedCategoryName('Groups'),
            isSelected: _selectedCategory == 'Groups',
            onTap: () {
              setState(() {
                _selectedCategory = 'Groups';
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.event,
            title: _getLocalizedCategoryName('Events'),
            isSelected: _selectedCategory == 'Events',
            onTap: () {
              setState(() {
                _selectedCategory = 'Events';
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.local_offer,
            title: _getLocalizedCategoryName('Promotions'),
            isSelected: _selectedCategory == 'Promotions',
            onTap: () {
              setState(() {
                _selectedCategory = 'Promotions';
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.drafts,
            title: _getLocalizedCategoryName('Draft'),
            isSelected: _selectedCategory == 'Draft',
            onTap: () {
              setState(() {
                _selectedCategory = 'Draft';
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.report,
            title: _getLocalizedCategoryName('Spam'),
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
            title: _getLocalizedCategoryName('Trash'),
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
      contentPadding: const EdgeInsets.only(left: 8, right: 16),
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