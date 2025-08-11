import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/availability_service.dart';
import '../utils/price_formatter.dart';

class BookingCalendar extends StatefulWidget {
  final String carId;
  final double dailyRate;
  final Function(DateTime? startDate, DateTime? endDate, double totalPrice)? onDatesSelected;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final List<DateTime>? blockedDates;
  final int? minRentalDays;
  final int? maxRentalDays;

  const BookingCalendar({
    super.key,
    required this.carId,
    required this.dailyRate,
    this.onDatesSelected,
    this.initialStartDate,
    this.initialEndDate,
    this.blockedDates,
    this.minRentalDays = 1,
    this.maxRentalDays = 30,
  });

  @override
  State<BookingCalendar> createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {
  late final ValueNotifier<List<DateTime>> _selectedDates;
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  
  List<DateTime> _blockedDates = [];
  bool _isLoading = true;
  double _totalPrice = 0.0;
  int _rentalDays = 0;

  @override
  void initState() {
    super.initState();
    _selectedDates = ValueNotifier([]);
    _rangeStart = widget.initialStartDate;
    _rangeEnd = widget.initialEndDate;
    _blockedDates = widget.blockedDates ?? [];
    _loadBlockedDates();
    _calculateInitialPrice();
  }

  @override
  void dispose() {
    _selectedDates.dispose();
    super.dispose();
  }

  void _calculateInitialPrice() {
    if (_rangeStart != null && _rangeEnd != null) {
      _calculatePricing(_rangeStart!, _rangeEnd!);
    }
  }

  Future<void> _loadBlockedDates() async {
    setState(() => _isLoading = true);
    
    try {
      final availabilityService = AvailabilityService();
      final bookings = availabilityService.getCarBookings(widget.carId);
      
      final blocked = <DateTime>[];
      for (final booking in bookings) {
        if (booking.status == 'confirmed' || booking.status == 'active') {
          DateTime currentDate = booking.startDate;
          while (currentDate.isBefore(booking.endDate) || 
                 _isSameDay(currentDate, booking.endDate)) {
            blocked.add(DateTime(currentDate.year, currentDate.month, currentDate.day));
            currentDate = currentDate.add(const Duration(days: 1));
          }
        }
      }
      
      setState(() {
        _blockedDates.addAll(blocked);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading blocked dates: $e');
      setState(() => _isLoading = false);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isDayBlocked(DateTime day) {
    return _blockedDates.any((blocked) => _isSameDay(blocked, day));
  }

  bool _isDayAvailable(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDay = DateTime(day.year, day.month, day.day);
    
    // Block past dates
    if (checkDay.isBefore(today)) return false;
    
    // Block specifically blocked dates
    if (_isDayBlocked(day)) return false;
    
    return true;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!_isDayAvailable(selectedDay)) return;

    setState(() {
      _focusedDay = focusedDay;
      
      if (_rangeStart == null || _rangeEnd != null) {
        // Start new range
        _rangeStart = selectedDay;
        _rangeEnd = null;
        _selectedDates.value = [selectedDay];
      } else {
        // Complete the range
        if (selectedDay.isBefore(_rangeStart!)) {
          _rangeEnd = _rangeStart;
          _rangeStart = selectedDay;
        } else {
          _rangeEnd = selectedDay;
        }
        
        // Validate range doesn't include blocked dates
        if (_isRangeValid(_rangeStart!, _rangeEnd!)) {
          _selectedDates.value = _getDaysInRange(_rangeStart!, _rangeEnd!);
          _calculatePricing(_rangeStart!, _rangeEnd!);
        } else {
          // Reset if range includes blocked dates
          _rangeStart = selectedDay;
          _rangeEnd = null;
          _selectedDates.value = [selectedDay];
          _showErrorMessage('Selected range includes unavailable dates');
        }
      }
    });
  }

  bool _isRangeValid(DateTime start, DateTime end) {
    DateTime current = start;
    while (current.isBefore(end) || _isSameDay(current, end)) {
      if (_isDayBlocked(current)) return false;
      current = current.add(const Duration(days: 1));
    }
    return true;
  }

  List<DateTime> _getDaysInRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    DateTime current = start;
    
    while (current.isBefore(end) || _isSameDay(current, end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return days;
  }

  void _calculatePricing(DateTime start, DateTime end) {
    _rentalDays = end.difference(start).inDays + 1;
    
    // Validate rental duration
    if (widget.minRentalDays != null && _rentalDays < widget.minRentalDays!) {
      _showErrorMessage('Minimum rental period is ${widget.minRentalDays} days');
      return;
    }
    
    if (widget.maxRentalDays != null && _rentalDays > widget.maxRentalDays!) {
      _showErrorMessage('Maximum rental period is ${widget.maxRentalDays} days');
      return;
    }
    
    _totalPrice = widget.dailyRate * _rentalDays;
    
    // Apply discounts for longer rentals
    if (_rentalDays >= 30) {
      _totalPrice *= 0.8; // 20% discount for monthly rentals
    } else if (_rentalDays >= 14) {
      _totalPrice *= 0.85; // 15% discount for bi-weekly rentals
    } else if (_rentalDays >= 7) {
      _totalPrice *= 0.9; // 10% discount for weekly rentals
    } else if (_rentalDays >= 3) {
      _totalPrice *= 0.95; // 5% discount for 3+ days
    }
    
    // Notify parent widget
    widget.onDatesSelected?.call(start, end, _totalPrice);
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF353935), size: 24),
              const SizedBox(width: 8),
              Text(
                'Select Rental Dates',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Calendar
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF353935)),
                ),
              ),
            )
          else
            TableCalendar<DateTime>(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              rangeSelectionMode: _rangeSelectionMode,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: GoogleFonts.inter(color: Colors.red[400]),
                holidayTextStyle: GoogleFonts.inter(color: Colors.red[400]),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF353935),
                  shape: BoxShape.circle,
                ),
                rangeStartDecoration: const BoxDecoration(
                  color: Color(0xFF353935),
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: const BoxDecoration(
                  color: Color(0xFF353935),
                  shape: BoxShape.circle,
                ),
                rangeHighlightColor: const Color(0xFF353935).withValues(alpha: 0.2),
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF353935).withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                disabledDecoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: GoogleFonts.inter(),
                selectedTextStyle: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                rangeStartTextStyle: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                rangeEndTextStyle: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                todayTextStyle: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF353935),
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF353935),
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
                weekendStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.red[400],
                ),
              ),
              onDaySelected: _onDaySelected,
              enabledDayPredicate: _isDayAvailable,
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
            ),
          
          // Legend
          if (!_isLoading) ...[
            const SizedBox(height: 16),
            _buildLegend(),
          ],
          
          // Pricing Summary
          if (_rangeStart != null && _rangeEnd != null) ...[
            const SizedBox(height: 16),
            _buildPricingSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legend',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildLegendItem(
              color: const Color(0xFF353935),
              label: 'Selected',
            ),
            const SizedBox(width: 16),
            _buildLegendItem(
              color: Colors.grey[300]!,
              label: 'Unavailable',
            ),
            const SizedBox(width: 16),
            _buildLegendItem(
              color: const Color(0xFF353935).withValues(alpha: 0.5),
              label: 'Today',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF353935).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF353935).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rental Summary',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rental Period:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '$_rentalDays day${_rentalDays > 1 ? 's' : ''}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Rate:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                PriceFormatter.formatWithSettings(context, widget.dailyRate.toStringAsFixed(0)),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          if (_rentalDays >= 3) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.green[600],
                  ),
                ),
                Text(
                  _getDiscountText(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price:',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                PriceFormatter.formatWithSettings(context, _totalPrice.toStringAsFixed(0)),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF353935),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDiscountText() {
    if (_rentalDays >= 30) return '20% off';
    if (_rentalDays >= 14) return '15% off';
    if (_rentalDays >= 7) return '10% off';
    if (_rentalDays >= 3) return '5% off';
    return '';
  }
}