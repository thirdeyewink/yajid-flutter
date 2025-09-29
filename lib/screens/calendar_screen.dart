import 'package:flutter/material.dart';
import 'package:yajid/home_screen.dart';
import 'package:yajid/profile_screen.dart';
import 'package:yajid/screens/discover_screen.dart';
import 'package:yajid/screens/add_content_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _currentIndex = 3; // Calendar tab is index 3
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  String _selectedView = 'Month';

  final List<String> _viewTypes = ['Month', 'Week', 'Agenda'];

  // Sample calendar events
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime(2025, 1, 15): [
      {
        'title': 'Movie Night: Dune Part Two',
        'type': 'entertainment',
        'time': '19:00',
        'category': 'Movies',
        'description': 'Watching with friends at AMC Theater',
      },
    ],
    DateTime(2025, 1, 18): [
      {
        'title': 'Book Club Meeting',
        'type': 'social',
        'time': '14:00',
        'category': 'Books',
        'description': 'Discussing "Fourth Wing" by Rebecca Yarros',
      },
      {
        'title': 'New Restaurant: Sakura Sushi',
        'type': 'dining',
        'time': '18:30',
        'category': 'Restaurants',
        'description': 'Trying the new sushi place downtown',
      },
    ],
    DateTime(2025, 1, 22): [
      {
        'title': 'Concert: Taylor Swift Eras Tour',
        'type': 'entertainment',
        'time': '20:00',
        'category': 'Music',
        'description': 'Live concert at MetLife Stadium',
      },
    ],
    DateTime(2025, 1, 25): [
      {
        'title': 'Gaming Session: Baldur\'s Gate 3',
        'type': 'gaming',
        'time': '16:00',
        'category': 'Games',
        'description': 'Co-op playthrough with online friends',
      },
    ],
  };

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation based on tab
    switch (index) {
      case 0:
        // Recommendations - navigate to home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        // Discover - navigate to discover screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DiscoverScreen()),
        );
        break;
      case 2:
        // Add - navigate to add content screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AddContentScreen()),
        );
        break;
      case 3:
        // Calendar - already on calendar screen
        break;
      case 4:
        // Profile - navigate to profile screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'entertainment':
        return Colors.purple;
      case 'social':
        return Colors.green;
      case 'dining':
        return Colors.orange;
      case 'gaming':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'entertainment':
        return Icons.movie;
      case 'social':
        return Icons.people;
      case 'dining':
        return Icons.restaurant;
      case 'gaming':
        return Icons.games;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.view_module),
            onSelected: (value) {
              setState(() {
                _selectedView = value;
              });
            },
            itemBuilder: (context) => _viewTypes
                .map((view) => PopupMenuItem(
                      value: view,
                      child: Row(
                        children: [
                          Icon(
                            view == 'Month'
                                ? Icons.calendar_month
                                : view == 'Week'
                                    ? Icons.view_week
                                    : Icons.list,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(view),
                        ],
                      ),
                    ))
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddEventDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          Expanded(
            child: _selectedView == 'Month'
                ? _buildMonthView()
                : _selectedView == 'Week'
                    ? _buildWeekView()
                    : _buildAgendaView(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        selectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black54
            : Colors.white70,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_awesome),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_outline),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
              });
            },
          ),
          Text(
            '${_getMonthName(_focusedDate.month)} ${_focusedDate.year}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView() {
    return Column(
      children: [
        _buildWeekDaysHeader(),
        Expanded(child: _buildCalendarGrid()),
        if (_getEventsForDay(_selectedDate).isNotEmpty) _buildSelectedDayEvents(),
      ],
    );
  }

  Widget _buildWeekView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.view_week, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Week view coming soon',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaView() {
    final allEvents = <Map<String, dynamic>>[];
    _events.forEach((date, events) {
      for (var event in events) {
        allEvents.add({
          ...event,
          'date': date,
        });
      }
    });

    allEvents.sort((a, b) => a['date'].compareTo(b['date']));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allEvents.length,
      itemBuilder: (context, index) {
        final event = allEvents[index];
        return _buildEventCard(event, showDate: true);
      },
    );
  }

  Widget _buildWeekDaysHeader() {
    const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: weekDays
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42, // 6 weeks * 7 days
      itemBuilder: (context, index) {
        final date = startDate.add(Duration(days: index));
        final isCurrentMonth = date.month == _focusedDate.month;
        final isSelected = date.day == _selectedDate.day &&
            date.month == _selectedDate.month &&
            date.year == _selectedDate.year;
        final isToday = date.day == DateTime.now().day &&
            date.month == DateTime.now().month &&
            date.year == DateTime.now().year;
        final events = _getEventsForDay(date);

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue
                  : isToday
                      ? Colors.blue.shade100
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isCurrentMonth
                            ? Colors.black
                            : Colors.grey,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (events.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDayEvents() {
    final events = _getEventsForDay(_selectedDate);
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Events for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return _buildEventCard(events[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, {bool showDate = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getEventIcon(event['type']),
          color: _getEventColor(event['type']),
        ),
        title: Text(
          event['title'],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDate)
              Text(
                '${event['date'].day}/${event['date'].month}/${event['date'].year} • ${event['time']}',
                style: const TextStyle(fontSize: 12),
              )
            else
              Text(event['time']),
            if (event['description'].isNotEmpty)
              Text(
                event['description'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        trailing: Chip(
          label: Text(
            event['category'],
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: _getEventColor(event['type']).withValues(alpha: 0.1),
          labelStyle: TextStyle(color: _getEventColor(event['type'])),
        ),
      ),
    );
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Event'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available, size: 48, color: Colors.green),
            SizedBox(height: 16),
            Text('Event creation feature coming soon!'),
            SizedBox(height: 8),
            Text(
              'You\'ll be able to add movies, concerts, restaurant visits, and more to your calendar.',
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

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}