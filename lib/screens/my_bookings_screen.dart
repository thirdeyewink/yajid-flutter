import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/booking_model.dart';
import '../bloc/booking/booking_bloc.dart';
import '../bloc/booking/booking_event.dart';
import '../bloc/booking/booking_state.dart';

class MyBookingsScreen extends StatefulWidget {
  final String userId;

  const MyBookingsScreen({super.key, required this.userId});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadBookings();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBookings() {
    switch (_tabController.index) {
      case 0: // All
        context.read<BookingBloc>().add(LoadUserBookings(widget.userId));
        break;
      case 1: // Upcoming
        context.read<BookingBloc>().add(LoadUpcomingBookings(widget.userId));
        break;
      case 2: // Past
        context.read<BookingBloc>().add(LoadPastBookings(widget.userId));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList(),
          _buildBookingsList(),
          _buildBookingsList(),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is BookingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading bookings',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadBookings,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is BookingsLoaded) {
          if (state.bookings.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadBookings();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                return _buildBookingCard(state.bookings[index]);
              },
            ),
          );
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    String message;
    switch (_tabController.index) {
      case 1:
        message = 'No upcoming bookings';
        break;
      case 2:
        message = 'No past bookings';
        break;
      default:
        message = 'No bookings yet';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start booking venues to see them here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final now = DateTime.now();
    final isUpcoming = booking.startTime.isAfter(now);
    final isPast = booking.endTime.isBefore(now);
    final isActive = !isUpcoming && !isPast;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Venue Name and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.venueName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),
              const SizedBox(height: 12),

              // Date and Time
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${booking.startTime.day}/${booking.startTime.month}/${booking.startTime.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Number of People and Duration
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${booking.numberOfPeople} ${booking.numberOfPeople == 1 ? 'person' : 'people'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.timelapse, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${booking.durationInHours.toStringAsFixed(1)} hours',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),

              // Active indicator
              if (isActive) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.green[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Active Now',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(height: 24),

              // Price and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${booking.totalPrice.toStringAsFixed(2)} ${booking.currency}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  if (booking.canBeCancelled && isUpcoming)
                    OutlinedButton(
                      onPressed: () => _showCancelDialog(booking),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Cancel'),
                    )
                  else
                    TextButton(
                      onPressed: () => _showBookingDetails(booking),
                      child: const Text('View Details'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case BookingStatus.pending:
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        label = 'Pending';
        break;
      case BookingStatus.confirmed:
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        label = 'Confirmed';
        break;
      case BookingStatus.cancelled:
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        label = 'Cancelled';
        break;
      case BookingStatus.completed:
        backgroundColor = Colors.blue[50]!;
        textColor = Colors.blue[700]!;
        label = 'Completed';
        break;
      case BookingStatus.noShow:
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        label = 'No Show';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showBookingDetails(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Booking Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 24),

                // Details
                _buildDetailRow('Venue', booking.venueName),
                _buildDetailRow('Booking ID', booking.id),
                _buildDetailRow(
                  'Date',
                  '${booking.startTime.day}/${booking.startTime.month}/${booking.startTime.year}',
                ),
                _buildDetailRow(
                  'Time',
                  '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
                ),
                _buildDetailRow(
                  'Duration',
                  '${booking.durationInHours.toStringAsFixed(1)} hours',
                ),
                _buildDetailRow(
                  'Guests',
                  '${booking.numberOfPeople} ${booking.numberOfPeople == 1 ? 'person' : 'people'}',
                ),
                _buildDetailRow(
                  'Status',
                  _getStatusText(booking.status),
                ),
                if (booking.specialRequests != null)
                  _buildDetailRow('Special Requests', booking.specialRequests!),
                if (booking.cancellationReason != null) ...[
                  _buildDetailRow('Cancellation Reason', booking.cancellationReason!),
                  _buildDetailRow(
                    'Cancelled At',
                    '${booking.cancelledAt?.day}/${booking.cancelledAt?.month}/${booking.cancelledAt?.year}',
                  ),
                ],

                const Divider(height: 32),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Price',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${booking.totalPrice.toStringAsFixed(2)} ${booking.currency}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                if (booking.canBeCancelled && booking.startTime.isAfter(DateTime.now())) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showCancelDialog(booking);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel Booking'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BookingModel booking) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to cancel this booking?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                hintText: 'Optional',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookingBloc>().add(
                    CancelBooking(
                      booking.id,
                      reasonController.text.trim().isEmpty
                          ? 'No reason provided'
                          : reasonController.text.trim(),
                    ),
                  );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking cancelled successfully'),
                  backgroundColor: Colors.green,
                ),
              );

              // Reload bookings
              _loadBookings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending Confirmation';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.noShow:
        return 'No Show';
    }
  }
}
