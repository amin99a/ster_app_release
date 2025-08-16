import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car.dart';
import '../services/booking_service.dart';
import '../services/notification_service.dart';
import '../widgets/floating_header.dart';
import '../widgets/animated_widgets.dart';
import '../utils/animations.dart';
import '../models/booking.dart' as booking_model;
import 'booking_summary_screen.dart';
import '../services/context_aware_service.dart';

class EnhancedBookingConfirmationScreen extends StatefulWidget {
  final Car car;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final int rentalDays;

  const EnhancedBookingConfirmationScreen({
    super.key,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.rentalDays,
  });

  @override
  State<EnhancedBookingConfirmationScreen> createState() => _EnhancedBookingConfirmationScreenState();
}

class _EnhancedBookingConfirmationScreenState extends State<EnhancedBookingConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isProcessing = false;
  bool _isConfirmed = false;
  booking_model.Booking? _createdBooking;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _processBooking();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.6)),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
    ));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.4, 1.0)),
    );

    _animationController.forward();
  }

  Future<void> _processBooking() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // Track start_booking
      try {
        ContextAwareService().trackEvent(
          eventName: 'start_booking',
          service: 'BookingService',
          operation: 'create_booking',
          metadata: {
            'car_id': widget.car.id,
            'user_id': Supabase.instance.client.auth.currentUser?.id,
            'start_date': widget.startDate.toIso8601String(),
            'end_date': widget.endDate.toIso8601String(),
          },
        );
      } catch (_) {}

      final bookingService = Provider.of<BookingService>(context, listen: false);
      final notificationService = Provider.of<NotificationService>(context, listen: false);

      // Create booking
      final booking = await bookingService.createBooking(
        carId: widget.car.id,
        carName: '${widget.car.brand} ${widget.car.model}',
        userId: Supabase.instance.client.auth.currentUser?.id ?? '',
        userName: Supabase.instance.client.auth.currentUser?.userMetadata?['full_name'] ?? 'User',
        startDate: widget.startDate,
        endDate: widget.endDate,
        totalPrice: widget.totalPrice,
        depositAmount: widget.totalPrice * 0.3, // 30% deposit
        remainingAmount: widget.totalPrice * 0.7, // 70% remaining
      );

      if (booking != null) {
        // Convert Booking from service to Booking model
        final bookingModel = booking_model.Booking(
          id: booking.id,
          carId: booking.carId,
          userId: booking.userId,
          hostId: booking.hostId,
          startDate: booking.startDate,
          endDate: booking.endDate,
          totalPrice: booking.totalPrice,
          status: booking.status,
          notes: booking.notes,
          createdAt: booking.createdAt,
          updatedAt: booking.createdAt, // Use createdAt as updatedAt for now
          car: widget.car,
        );

        // Send confirmation notification
        await notificationService.sendNotification(
          userId: Supabase.instance.client.auth.currentUser?.id ?? '',
          title: 'Booking Confirmed!',
          message: 'Your booking for ${widget.car.brand} ${widget.car.model} has been confirmed.',
          type: 'booking_confirmation',
        );

        // Track complete_booking
        try {
          ContextAwareService().trackEvent(
            eventName: 'complete_booking',
            service: 'BookingService',
            operation: 'create_booking',
            metadata: {
              'booking_id': booking.id,
              'car_id': widget.car.id,
              'user_id': booking.userId,
            },
          );
        } catch (_) {}

        setState(() {
          _createdBooking = bookingModel;
          _isConfirmed = true;
          _isProcessing = false;
        });
      } else {
        throw Exception('Failed to create booking');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to process booking: $e';
        _isProcessing = false;
      });
    }
  }

  void _navigateToBookingSummary() {
    if (_createdBooking != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSummaryScreen(
            booking: _createdBooking!,
            car: widget.car,
          ),
        ),
      );
    }
  }

  void _goBackToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
                  child: Column(
                    children: [
            // Header
            FloatingHeader(
      child: Row(
        children: [
                  IconButton(
            onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
          Expanded(
                    child: Text(
                  'Booking Confirmation',
                  style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  ),
                ),
              ],
            ),
          ),
            
            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return _buildErrorState();
    }

    if (_isProcessing) {
      return _buildProcessingState();
    }

    if (_isConfirmed) {
      return _buildConfirmationState();
    }

    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return Center(
            child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
              children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
                Text(
            'Processing your booking...',
                  style: GoogleFonts.inter(
                    fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF353935),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
              Text(
            'Confirming your booking...',
                style: GoogleFonts.inter(
              fontSize: 18,
                  fontWeight: FontWeight.w600,
              color: const Color(0xFF353935),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we process your payment and send confirmation.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Success Animation
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120,
              height: 120,
      decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
          ),
        ],
      ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Confirmation Message
                        Text(
            'Booking Confirmed!',
                          style: GoogleFonts.inter(
              fontSize: 28,
                            fontWeight: FontWeight.bold,
              color: const Color(0xFF353935),
                          ),
            textAlign: TextAlign.center,
                        ),
          
          const SizedBox(height: 16),
          
                        Text(
            'Your car rental has been successfully booked. You will receive a confirmation email with all the details shortly.',
                          style: GoogleFonts.inter(
                            fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Booking Details Card
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
                    'Booking Details',
            style: GoogleFonts.inter(
                      fontSize: 20,
              fontWeight: FontWeight.bold,
                      color: const Color(0xFF353935),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildDetailRow('Car', '${widget.car.brand} ${widget.car.model}'),
                  _buildDetailRow('Booking ID', _createdBooking?.id ?? 'N/A'),
                  _buildDetailRow('Start Date', _formatDate(widget.startDate)),
                  _buildDetailRow('End Date', _formatDate(widget.endDate)),
                  _buildDetailRow('Duration', '${widget.rentalDays} days'),
                  _buildDetailRow('Total Price', '\$${widget.totalPrice.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: AnimatedButton(
                  onPressed: _goBackToHome,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
                    child: Text(
                      'Back to Home',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF353935),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedButton(
                  onPressed: _navigateToBookingSummary,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF353935),
                borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'View Details',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
          ),
        ],
      ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF353935),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
              child: Padding(
        padding: const EdgeInsets.all(24),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
              Text(
              'Booking Failed',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                color: const Color(0xFF353935),
                ),
              ),
            const SizedBox(height: 8),
              Text(
              _error ?? 'An error occurred while processing your booking.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _processBooking,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}