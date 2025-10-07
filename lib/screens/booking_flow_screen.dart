import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/venue_model.dart';
import '../models/booking_model.dart';
import '../bloc/booking/booking_bloc.dart';
import '../bloc/booking/booking_event.dart';
import '../bloc/booking/booking_state.dart';
import 'booking_confirmation_screen.dart';

class BookingFlowScreen extends StatefulWidget {
  final VenueModel venue;

  const BookingFlowScreen({super.key, required this.venue});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  int _numberOfPeople = 1;
  final TextEditingController _specialRequestsController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
  }

  double _calculateTotalPrice() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    final durationHours = (endMinutes - startMinutes) / 60.0;

    if (durationHours <= 0) return 0;

    return widget.venue.pricePerHour * durationHours;
  }

  DateTime _getStartDateTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
  }

  DateTime _getEndDateTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );
  }

  bool _isValidBooking() {
    final now = DateTime.now();
    final startDateTime = _getStartDateTime();
    final endDateTime = _getEndDateTime();

    // Check if booking is in the future
    if (startDateTime.isBefore(now)) {
      return false;
    }

    // Check if end time is after start time
    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      return false;
    }

    // Check capacity
    if (_numberOfPeople > widget.venue.capacity) {
      return false;
    }

    return true;
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        // Automatically adjust end time if needed
        final startMinutes = _startTime.hour * 60 + _startTime.minute;
        final endMinutes = _endTime.hour * 60 + _endTime.minute;
        if (endMinutes <= startMinutes) {
          // Set end time to 3 hours after start time
          final newEndMinutes = startMinutes + 180;
          _endTime = TimeOfDay(
            hour: (newEndMinutes ~/ 60) % 24,
            minute: newEndMinutes % 60,
          );
        }
      });
    }
  }

  void _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _confirmBooking() async {
    if (!_isValidBooking()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check your booking details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to book'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final booking = BookingModel(
      id: '',
      userId: user.uid,
      venueId: widget.venue.id,
      venueName: widget.venue.name,
      startTime: _getStartDateTime(),
      endTime: _getEndDateTime(),
      numberOfPeople: _numberOfPeople,
      totalPrice: _calculateTotalPrice(),
      currency: 'MAD',
      status: BookingStatus.pending,
      specialRequests: _specialRequestsController.text.trim().isEmpty
          ? null
          : _specialRequestsController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<BookingBloc>().add(CreateBooking(booking));
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotalPrice();
    final isValid = _isValidBooking();

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingCreated) {
          setState(() {
            _isProcessing = false;
          });

          // Navigate to confirmation screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BookingConfirmationScreen(
                bookingId: state.bookingId,
                venue: widget.venue,
              ),
            ),
          );
        } else if (state is BookingError) {
          setState(() {
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book Venue'),
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Venue Summary Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Venue Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: widget.venue.photoUrls.isNotEmpty
                            ? Image.network(
                                widget.venue.photoUrls.first,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.business, size: 40),
                              ),
                      ),
                      const SizedBox(width: 16),
                      // Venue Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.venue.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.venue.category,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.venue.rating.toStringAsFixed(1)} (${widget.venue.reviewCount})',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Date Selection
              const Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 16),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Time Selection
              const Text(
                'Select Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Start Time
                  Expanded(
                    child: InkWell(
                      onTap: _selectStartTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _startTime.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // End Time
                  Expanded(
                    child: InkWell(
                      onTap: _selectEndTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _endTime.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Number of People
              const Text(
                'Number of People',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _numberOfPeople > 1
                          ? () => setState(() => _numberOfPeople--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.blue,
                    ),
                    Text(
                      '$_numberOfPeople',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _numberOfPeople < widget.venue.capacity
                          ? () => setState(() => _numberOfPeople++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              Text(
                'Max capacity: ${widget.venue.capacity}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Special Requests
              const Text(
                'Special Requests (Optional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _specialRequestsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any special requirements or requests?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Price Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Price per hour:',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          '${widget.venue.pricePerHour.toStringAsFixed(2)} MAD',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Duration:',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          '${_calculateTotalPrice() > 0 ? (_calculateTotalPrice() / widget.venue.pricePerHour).toStringAsFixed(1) : 0} hours',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${totalPrice.toStringAsFixed(2)} MAD',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isValid && !_isProcessing ? _confirmBooking : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirm Booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (!isValid) ...[
                const SizedBox(height: 8),
                Text(
                  _getValidationMessage(),
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getValidationMessage() {
    final now = DateTime.now();
    final startDateTime = _getStartDateTime();
    final endDateTime = _getEndDateTime();

    if (startDateTime.isBefore(now)) {
      return 'Start time must be in the future';
    }

    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      return 'End time must be after start time';
    }

    if (_numberOfPeople > widget.venue.capacity) {
      return 'Number of people exceeds venue capacity';
    }

    return '';
  }
}
