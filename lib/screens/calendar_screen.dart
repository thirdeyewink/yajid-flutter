import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yajid/theme/app_theme.dart';
import 'package:yajid/l10n/app_localizations.dart';
import 'package:yajid/services/astronomical_service.dart';
import 'package:yajid/bloc/event/event_bloc.dart';
import 'package:yajid/bloc/event/event_event.dart';
import 'package:yajid/models/event_model.dart';
import 'package:geolocator/geolocator.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  String _selectedView = 'Agenda';
  int? _selectedHour;
  Position? _userLocation;
  List<Holiday> _holidays = [];
  SolsticesEquinoxes? _solsticesEquinoxes;

  final List<String> _viewTypes = ['Month', 'Week', 'Agenda'];

  String _getLocalizedViewName(String view) {
    switch (view) {
      case 'Month':
        return AppLocalizations.of(context)!.month;
      case 'Week':
        return AppLocalizations.of(context)!.week;
      case 'Agenda':
        return AppLocalizations.of(context)!.agenda;
      default:
        return view;
    }
  }

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_holidays.isEmpty) {
      _loadAstronomicalData();
    }
  }

  Future<void> _loadAstronomicalData() async {
    final location = await AstronomicalService.getCurrentLocation();
    if (!mounted) return;
    final locale = Localizations.localeOf(context).languageCode;

    setState(() {
      _userLocation = location;
      _holidays = AstronomicalService.getHolidays(_focusedDate.year, locale);
      _solsticesEquinoxes = AstronomicalService.getSolsticesEquinoxes(_focusedDate.year);

      // Add solstices and equinoxes as calendar events
      if (_solsticesEquinoxes != null) {
        final se = _solsticesEquinoxes!;

        // Spring Equinox
        final springDate = DateTime(se.springEquinox.year, se.springEquinox.month, se.springEquinox.day);
        if (_events[springDate] == null) {
          _events[springDate] = [];
        }
        _events[springDate]!.add({
          'title': '${AppLocalizations.of(context)!.springEquinox} 🌸',
          'type': 'astronomical',
          'time': '00:00',
          'category': 'Astronomy',
          'description': 'First day of spring. Day and night are approximately equal in length.',
        });

        // Summer Solstice
        final summerDate = DateTime(se.summerSolstice.year, se.summerSolstice.month, se.summerSolstice.day);
        if (_events[summerDate] == null) {
          _events[summerDate] = [];
        }
        _events[summerDate]!.add({
          'title': '${AppLocalizations.of(context)!.summerSolstice} ☀️',
          'type': 'astronomical',
          'time': '00:00',
          'category': 'Astronomy',
          'description': 'Longest day of the year in the Northern Hemisphere.',
        });

        // Autumn Equinox
        final autumnDate = DateTime(se.autumnEquinox.year, se.autumnEquinox.month, se.autumnEquinox.day);
        if (_events[autumnDate] == null) {
          _events[autumnDate] = [];
        }
        _events[autumnDate]!.add({
          'title': '${AppLocalizations.of(context)!.autumnEquinox} 🍂',
          'type': 'astronomical',
          'time': '00:00',
          'category': 'Astronomy',
          'description': 'First day of autumn. Day and night are approximately equal in length.',
        });

        // Winter Solstice
        final winterDate = DateTime(se.winterSolstice.year, se.winterSolstice.month, se.winterSolstice.day);
        if (_events[winterDate] == null) {
          _events[winterDate] = [];
        }
        _events[winterDate]!.add({
          'title': '${AppLocalizations.of(context)!.winterSolstice} ❄️',
          'type': 'astronomical',
          'time': '00:00',
          'category': 'Astronomy',
          'description': 'Shortest day of the year in the Northern Hemisphere.',
        });
      }
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  bool _isHoliday(DateTime date) {
    return _holidays.any((h) =>
      h.date.year == date.year &&
      h.date.month == date.month &&
      h.date.day == date.day
    );
  }

  Holiday? _getHoliday(DateTime date) {
    try {
      return _holidays.firstWhere((h) =>
        h.date.year == date.year &&
        h.date.month == date.month &&
        h.date.day == date.day
      );
    } catch (_) {
      return null;
    }
  }

  bool _isSolsticeOrEquinox(DateTime date) {
    if (_solsticesEquinoxes == null) return false;

    final se = _solsticesEquinoxes!;
    return (se.springEquinox.year == date.year &&
            se.springEquinox.month == date.month &&
            se.springEquinox.day == date.day) ||
           (se.summerSolstice.year == date.year &&
            se.summerSolstice.month == date.month &&
            se.summerSolstice.day == date.day) ||
           (se.autumnEquinox.year == date.year &&
            se.autumnEquinox.month == date.month &&
            se.autumnEquinox.day == date.day) ||
           (se.winterSolstice.year == date.year &&
            se.winterSolstice.month == date.month &&
            se.winterSolstice.day == date.day);
  }

  String _getSolsticeOrEquinoxName(DateTime date, BuildContext context) {
    if (_solsticesEquinoxes == null) return '';

    final se = _solsticesEquinoxes!;
    if (se.springEquinox.year == date.year &&
        se.springEquinox.month == date.month &&
        se.springEquinox.day == date.day) {
      return '${AppLocalizations.of(context)!.springEquinox} 🌸';
    } else if (se.summerSolstice.year == date.year &&
               se.summerSolstice.month == date.month &&
               se.summerSolstice.day == date.day) {
      return '${AppLocalizations.of(context)!.summerSolstice} ☀️';
    } else if (se.autumnEquinox.year == date.year &&
               se.autumnEquinox.month == date.month &&
               se.autumnEquinox.day == date.day) {
      return '${AppLocalizations.of(context)!.autumnEquinox} 🍂';
    } else if (se.winterSolstice.year == date.year &&
               se.winterSolstice.month == date.month &&
               se.winterSolstice.day == date.day) {
      return '${AppLocalizations.of(context)!.winterSolstice} ❄️';
    }
    return '';
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
      case 'astronomical':
        return Colors.deepOrange;
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
      case 'astronomical':
        return Icons.wb_sunny;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
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
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.view_module, color: Colors.white),
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
                                  Text(_getLocalizedViewName(view)),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      _showAddEventDialog();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
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
              final previousYear = _focusedDate.year;
              setState(() {
                if (_selectedView == 'Week') {
                  // Go back one week
                  _focusedDate = _focusedDate.subtract(const Duration(days: 7));
                } else {
                  // Go back one month
                  _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
                }
                // Reload astronomical data if year changed
                if (_focusedDate.year != previousYear) {
                  _loadAstronomicalData();
                }
              });
            },
          ),
          Text(
            _selectedView == 'Week'
                ? '${_getMonthName(_focusedDate.month)} ${_focusedDate.day}, ${_focusedDate.year}'
                : '${_getMonthName(_focusedDate.month)} ${_focusedDate.year}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final previousYear = _focusedDate.year;
              setState(() {
                if (_selectedView == 'Week') {
                  // Go forward one week
                  _focusedDate = _focusedDate.add(const Duration(days: 7));
                } else {
                  // Go forward one month
                  _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
                }
                // Reload astronomical data if year changed
                if (_focusedDate.year != previousYear) {
                  _loadAstronomicalData();
                }
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
    final startOfWeek = _getStartOfWeek(_focusedDate);
    final hours = List.generate(18, (index) => index + 6);

    return Column(
      children: [
        _buildWeekHeader(startOfWeek),
        Expanded(
          child: ListView.builder(
            itemCount: hours.length,
            itemBuilder: (context, index) {
              return _buildHourRow(hours[index], startOfWeek);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekHeader(DateTime startOfWeek) {
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade400, width: 2)),
      ),
      child: Row(
        children: [
          // Time column header
          Container(
            width: 60,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade400, width: 2)),
            ),
            child: Center(
              child: Text(
                'Time',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
          // Days of week
          ...List.generate(7, (index) {
            final date = startOfWeek.add(Duration(days: index));
            final isToday = date.day == DateTime.now().day &&
                date.month == DateTime.now().month &&
                date.year == DateTime.now().year;
            final isSelected = date.day == _selectedDate.day &&
                date.month == _selectedDate.month &&
                date.year == _selectedDate.year;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          weekDays[date.weekday % 7],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isToday ? Colors.blue : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 1),
                        // Moon phase emoji (only new moon and full moon)
                        Builder(
                          builder: (context) {
                            final moonPhase = AstronomicalService.getMoonPhase(date);
                            final showMoon = moonPhase.phase == 'New Moon' || moonPhase.phase == 'Full Moon';
                            return showMoon
                                ? Text(
                                    moonPhase.emoji,
                                    style: const TextStyle(fontSize: 9),
                                  )
                                : const SizedBox(height: 9);
                          },
                        ),
                        const SizedBox(height: 1),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isToday ? Colors.blue : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isToday ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHourRow(int hour, DateTime startOfWeek) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          // Time label
          Container(
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                right: BorderSide(color: Colors.grey.shade400, width: 2),
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Center(
              child: Text(
                _formatHour(hour),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
          // Day cells
          ...List.generate(7, (dayIndex) {
            final date = startOfWeek.add(Duration(days: dayIndex));
            final events = _getEventsForDay(date);
            final isSelected = date.day == _selectedDate.day &&
                date.month == _selectedDate.month &&
                date.year == _selectedDate.year;

            // Find events for this hour
            final hourEvents = events.where((event) {
              final eventHour = int.parse(event['time'].split(':')[0]);
              return eventHour == hour;
            }).toList();

            final isSelectedSlot = isSelected && _selectedHour == hour;

            // Check for sunrise/sunset times
            SunTimes? sunTimes;
            if (_userLocation != null) {
              sunTimes = AstronomicalService.calculateSunTimes(
                date,
                _userLocation!.latitude,
                _userLocation!.longitude,
              );
            }

            final bool isSunriseHour = sunTimes?.sunrise?.hour == hour;
            final bool isSunsetHour = sunTimes?.sunset?.hour == hour;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _selectedHour = hour;
                  });
                  _showCreateEventDialog(date, hour);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelectedSlot
                        ? Colors.blue.shade100
                        : isSelected
                            ? Colors.blue.shade50
                            : Colors.white,
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300),
                      bottom: BorderSide(color: Colors.grey.shade200),
                      top: isSelectedSlot
                          ? BorderSide(color: Colors.blue, width: 2)
                          : BorderSide.none,
                      right: isSelectedSlot
                          ? BorderSide(color: Colors.blue, width: 2)
                          : BorderSide.none,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Sunrise/Sunset indicators
                      if (isSunriseHour && sunTimes?.sunrise != null)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Text(
                            '🌅 ${sunTimes!.sunrise!.hour}:${sunTimes.sunrise!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      if (isSunsetHour && sunTimes?.sunset != null)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Text(
                            '🌇 ${sunTimes!.sunset!.hour}:${sunTimes.sunset!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      // Events
                      if (hourEvents.isEmpty)
                        const SizedBox.expand()
                      else
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Column(
                            children: hourEvents.map((event) {
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 1),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getEventColor(event['type']),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        event['time'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          event['title'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
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
                const SizedBox(height: 2),
                // Moon phase emoji (only new moon and full moon)
                Builder(
                  builder: (context) {
                    final moonPhase = AstronomicalService.getMoonPhase(date);
                    final showMoon = moonPhase.phase == 'New Moon' || moonPhase.phase == 'Full Moon';
                    return showMoon
                        ? Text(
                            moonPhase.emoji,
                            style: const TextStyle(fontSize: 12),
                          )
                        : const SizedBox(height: 12);
                  },
                ),
                if (events.isNotEmpty || _isHoliday(date) || _isSolsticeOrEquinox(date))
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _isHoliday(date) || _isSolsticeOrEquinox(date)
                          ? (isSelected ? Colors.white : Colors.orange)
                          : (isSelected ? Colors.white : Colors.blue),
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
    final holiday = _getHoliday(_selectedDate);
    final solsticeEquinox = _getSolsticeOrEquinoxName(_selectedDate, context);
    final moonPhase = AstronomicalService.getMoonPhase(_selectedDate);

    SunTimes? sunTimes;
    if (_userLocation != null) {
      sunTimes = AstronomicalService.calculateSunTimes(
        _selectedDate,
        _userLocation!.latitude,
        _userLocation!.longitude,
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Events for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                moonPhase.emoji,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Astronomical info
          if (holiday != null || solsticeEquinox.isNotEmpty || sunTimes != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (holiday != null)
                    Text(
                      '🎉 ${holiday.name}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  if (solsticeEquinox.isNotEmpty)
                    Text(
                      solsticeEquinox,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  if (sunTimes?.sunrise != null && sunTimes?.sunset != null)
                    Text(
                      '🌅 ${sunTimes!.sunrise!.hour}:${sunTimes.sunrise!.minute.toString().padLeft(2, '0')} | 🌇 ${sunTimes.sunset!.hour}:${sunTimes.sunset!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  Text(
                    'Moon: ${moonPhase.phase} (${(moonPhase.illumination * 100).toInt()}%)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Text(
                      'No events scheduled',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
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

  void _showCreateEventDialog(DateTime date, int hour) {
    // Navigate to the add event dialog with pre-filled date and time
    _showAddEventDialog(prefilledDate: date, prefilledHour: hour);
  }

  void _showAddEventDialog({DateTime? prefilledDate, int? prefilledHour}) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final placeController = TextEditingController();
    final videoLinkController = TextEditingController();
    final participantsController = TextEditingController();

    DateTime selectedDate = prefilledDate ?? DateTime.now();
    TimeOfDay selectedTime = prefilledHour != null
        ? TimeOfDay(hour: prefilledHour, minute: 0)
        : TimeOfDay.now();
    String selectedEventType = 'Dinner';
    int selectedDurationMinutes = 60;

    final eventTypes = [
      'Dinner',
      'Drinks',
      'Party',
      'Date',
      'Playdate',
      'Concert',
      'Festival',
      'Play',
      'Movie',
      'Comedy Show',
      'Sports Game',
      'Training',
      'Meeting',
      'Conference',
      'Workshop',
      'Birthday',
      'Wedding',
      'Other',
    ];

    final durations = [
      {'label': '30 min', 'value': 30},
      {'label': '1 hour', 'value': 60},
      {'label': '1.5 hours', 'value': 90},
      {'label': '2 hours', 'value': 120},
      {'label': '3 hours', 'value': 180},
      {'label': '4 hours', 'value': 240},
      {'label': 'All day', 'value': 1440},
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.addEvent),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Title *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Event Type Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedEventType,
                    decoration: const InputDecoration(
                      labelText: 'Event Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: eventTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedEventType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Place/Location
                  TextField(
                    controller: placeController,
                    decoration: const InputDecoration(
                      labelText: 'Place/Location',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                      hintText: 'Restaurant name, address, etc.',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Date Selector
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(AppLocalizations.of(context)!.eventDate),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  const Divider(),

                  // Time Selector
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      selectedTime.format(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(AppLocalizations.of(context)!.startTime),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                  ),
                  const Divider(),

                  // Duration Dropdown
                  DropdownButtonFormField<int>(
                    initialValue: selectedDurationMinutes,
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    items: durations.map((duration) {
                      return DropdownMenuItem(
                        value: duration['value'] as int,
                        child: Text(duration['label'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDurationMinutes = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Participants
                  TextField(
                    controller: participantsController,
                    decoration: const InputDecoration(
                      labelText: 'Participants',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                      hintText: 'Enter names separated by commas',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Video Call Link
                  TextField(
                    controller: videoLinkController,
                    decoration: const InputDecoration(
                      labelText: 'Video Call Link',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.video_call),
                      hintText: 'Zoom, Meet, Teams link',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please sign in to create events'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final eventDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                  );

                  // Parse participants
                  final participantsList = participantsController.text.isEmpty
                      ? <String>[]
                      : participantsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                  final event = EventModel(
                    id: '',
                    userId: user.uid,
                    title: titleController.text,
                    type: selectedEventType,
                    description: descriptionController.text,
                    place: placeController.text,
                    date: eventDate,
                    time: selectedTime.format(context),
                    durationMinutes: selectedDurationMinutes,
                    participants: participantsList,
                    videoLink: videoLinkController.text.isEmpty ? null : videoLinkController.text,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    isPublic: false,
                    invitedUserIds: [],
                    category: 'event',
                  );

                  Navigator.pop(context);

                  // Create event via EventBloc
                  context.read<EventBloc>().add(CreateEvent(event));

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Event added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.addEvent),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    final months = [
      AppLocalizations.of(context)!.january,
      AppLocalizations.of(context)!.february,
      AppLocalizations.of(context)!.march,
      AppLocalizations.of(context)!.april,
      AppLocalizations.of(context)!.may,
      AppLocalizations.of(context)!.june,
      AppLocalizations.of(context)!.july,
      AppLocalizations.of(context)!.august,
      AppLocalizations.of(context)!.september,
      AppLocalizations.of(context)!.october,
      AppLocalizations.of(context)!.november,
      AppLocalizations.of(context)!.december,
    ];
    return months[month - 1];
  }

  DateTime _getStartOfWeek(DateTime date) {
    final daysFromSunday = date.weekday % 7;
    return date.subtract(Duration(days: daysFromSunday));
  }
}