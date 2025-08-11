import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/animations.dart';

class EnhancedBookingCalendar extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final double dailyRate;
  final Function(DateTime?, DateTime?, double) onDatesSelected;
  final List<DateTime> unavailableDates;
  final Map<DateTime, double> specialPricing;

  const EnhancedBookingCalendar({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.dailyRate,
    required this.onDatesSelected,
    this.unavailableDates = const [],
    this.specialPricing = const {},
  });

  @override
  State<EnhancedBookingCalendar> createState() => _EnhancedBookingCalendarState();
}

class _EnhancedBookingCalendarState extends State<EnhancedBookingCalendar>
    with TickerProviderStateMixin {
  late DateTime _currentMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSelectingEndDate = false;
  
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    
    _slideController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppAnimations.smoothCurve,
    ));
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _selectDate(DateTime date) {
    setState(() {
      if (_startDate == null || _isSelectingEndDate) {
        if (_startDate == null) {
          _startDate = date;
          _isSelectingEndDate = true;
        } else {
          if (date.isBefore(_startDate!)) {
            _startDate = date;
            _endDate = null;
            _isSelectingEndDate = true;
          } else {
            _endDate = date;
            _isSelectingEndDate = false;
          }
        }
      } else {
        _startDate = date;
        _endDate = null;
        _isSelectingEndDate = true;
      }
    });
    
    _calculateTotalPrice();
  }

  void _calculateTotalPrice() {
    if (_startDate != null && _endDate != null) {
      final days = _endDate!.difference(_startDate!).inDays;
      double totalPrice = 0;
      
      for (int i = 0; i < days; i++) {
        final currentDate = _startDate!.add(Duration(days: i));
        final dailyPrice = widget.specialPricing[currentDate] ?? widget.dailyRate;
        totalPrice += dailyPrice;
      }
      
      widget.onDatesSelected(_startDate, _endDate, totalPrice);
    } else {
      widget.onDatesSelected(_startDate, _endDate, 0);
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _animateMonth();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _animateMonth();
  }

  void _animateMonth() {
    _slideController.reset();
    _slideController.forward();
  }

  bool _isDateUnavailable(DateTime date) {
    return widget.unavailableDates.any((unavailable) =>
        unavailable.year == date.year &&
        unavailable.month == date.month &&
        unavailable.day == date.day);
  }

  bool _isDateInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
           date.isBefore(_endDate!.add(const Duration(days: 1)));
  }

  bool _isDateRangeStart(DateTime date) {
    if (_startDate == null) return false;
    return date.year == _startDate!.year &&
           date.month == _startDate!.month &&
           date.day == _startDate!.day;
  }

  bool _isDateRangeEnd(DateTime date) {
    if (_endDate == null) return false;
    return date.year == _endDate!.year &&
           date.month == _endDate!.month &&
           date.day == _endDate!.day;
  }

  Color _getDateBackgroundColor(DateTime date) {
    if (_isDateUnavailable(date)) {
      return Colors.grey.shade100;
    } else if (_isDateRangeStart(date) || _isDateRangeEnd(date)) {
      return const Color(0xFF593CFB);
    } else if (_isDateInRange(date)) {
      return const Color(0xFF593CFB).withOpacity(0.1);
    } else if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return Colors.grey.shade50;
    }
    return Colors.transparent;
  }

  Color _getDateTextColor(DateTime date) {
    if (_isDateUnavailable(date)) {
      return Colors.grey.shade400;
    } else if (_isDateRangeStart(date) || _isDateRangeEnd(date)) {
      return Colors.white;
    } else if (_isDateInRange(date)) {
      return const Color(0xFF593CFB);
    } else if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return Colors.grey.shade400;
    }
    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calendar Header
          _buildCalendarHeader(),
          
          // Days of Week
          _buildDaysOfWeekHeader(),
          
          // Calendar Grid
          SlideTransition(
            position: _slideAnimation,
            child: _buildCalendarGrid(),
          ),
          
          // Price Legend
          _buildPriceLegend(),
          
          // Selected Dates Summary
          if (_startDate != null || _endDate != null)
            _buildSelectedDatesSummary(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF593CFB), Color(0xFF7C5CFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedButton(
            onPressed: _previousMonth,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          Column(
            children: [
              Text(
                _getMonthYearString(_currentMonth),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (_startDate != null && _endDate != null)
                Text(
                  '${_endDate!.difference(_startDate!).inDays} nights',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
          
          AnimatedButton(
            onPressed: _nextMonth,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeekHeader() {
    const daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: daysOfWeek.map((day) {
          return Expanded(
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    
    final calendarDays = <Widget>[];
    
    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstDayWeekday; i++) {
      calendarDays.add(const SizedBox());
    }
    
    // Add all days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      calendarDays.add(_buildCalendarDay(date));
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        childAspectRatio: 1,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: calendarDays,
      ),
    );
  }

  Widget _buildCalendarDay(DateTime date) {
    final isUnavailable = _isDateUnavailable(date);
    final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    final canSelect = !isUnavailable && !isPast;
    final specialPrice = widget.specialPricing[date];
    
    return AnimatedButton(
      onPressed: canSelect ? () => _selectDate(date) : null,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        decoration: BoxDecoration(
          color: _getDateBackgroundColor(date),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isDateRangeStart(date) || _isDateRangeEnd(date)
                ? const Color(0xFF593CFB)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getDateTextColor(date),
              ),
            ),
            
            if (specialPrice != null && !isUnavailable && !isPast)
              Text(
                'UK£${specialPrice.toInt()}',
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: _getDateTextColor(date),
                ),
              )
            else if (!isUnavailable && !isPast)
              Text(
                'UK£${widget.dailyRate.toInt()}',
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: _getDateTextColor(date),
                ),
              ),
            
            if (isUnavailable)
              Icon(
                Icons.close,
                size: 12,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceLegend() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: _buildLegendItem('Available', const Color(0xFF593CFB), Colors.white)),
              Expanded(child: _buildLegendItem('Selected', const Color(0xFF593CFB), Colors.white)),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(child: _buildLegendItem('Unavailable', Colors.grey.shade200, Colors.grey.shade400)),
              Expanded(child: _buildLegendItem('Past Date', Colors.grey.shade50, Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color backgroundColor, Color textColor) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedDatesSummary() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF593CFB), Color(0xFF7C5CFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check-in',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    _startDate != null ? _formatDate(_startDate!) : 'Select date',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              
              Icon(
                Icons.arrow_forward,
                color: Colors.white70,
                size: 20,
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Check-out',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    _endDate != null ? _formatDate(_endDate!) : 'Select date',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (_startDate != null && _endDate != null) ...[
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_endDate!.difference(_startDate!).inDays} nights',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'UK£${_calculateDisplayTotal().toStringAsFixed(0)} total',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _calculateDisplayTotal() {
    if (_startDate == null || _endDate == null) return 0;
    
    final days = _endDate!.difference(_startDate!).inDays;
    double totalPrice = 0;
    
    for (int i = 0; i < days; i++) {
      final currentDate = _startDate!.add(Duration(days: i));
      final dailyPrice = widget.specialPricing[currentDate] ?? widget.dailyRate;
      totalPrice += dailyPrice;
    }
    
    return totalPrice;
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}