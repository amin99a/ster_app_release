import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../services/booking_service.dart';
import '../services/payment_service.dart';
import '../services/auth_service.dart';
import '../widgets/animated_widgets.dart';
import '../utils/animations.dart';
import '../utils/price_formatter.dart';

class PaymentScreen extends StatefulWidget {
  final Car car;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final int rentalDays;
  final String? insuranceType;
  final double? insuranceCost;

  const PaymentScreen({
    super.key,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.rentalDays,
    this.insuranceType,
    this.insuranceCost,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  bool _isProcessing = false;
  bool _payFullAmount = false;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.creditCard;
  String? _selectedCardId;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _pickupLocationController = TextEditingController();
  final TextEditingController _dropoffLocationController = TextEditingController();

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppAnimations.smoothCurve,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.smoothCurve,
    ));
    
    _slideController.forward();
    _fadeController.forward();
  }

  void _initializeData() {
    _pickupLocationController.text = widget.car.location;
    _dropoffLocationController.text = widget.car.location;
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _notesController.dispose();
    _pickupLocationController.dispose();
    _dropoffLocationController.dispose();
    super.dispose();
  }

  double get _depositAmount => widget.totalPrice * 0.20;
  double get _remainingAmount => widget.totalPrice - _depositAmount;
  double get _paymentAmount => _payFullAmount ? widget.totalPrice : _depositAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Payment',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF353935),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car Summary Card
                _buildCarSummaryCard(),
                const SizedBox(height: 24),

                // Payment Options
                _buildPaymentOptions(),
                const SizedBox(height: 24),

                // Payment Method Selection
                _buildPaymentMethodSelection(),
                const SizedBox(height: 24),

                // Location Details
                _buildLocationDetails(),
                const SizedBox(height: 24),

                // Additional Notes
                _buildAdditionalNotes(),
                const SizedBox(height: 32),

                // Payment Summary
                _buildPaymentSummary(),
                const SizedBox(height: 32),

                // Pay Button
                _buildPayButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Car Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.car.image,
              width: 80,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_car, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 16),

          // Car Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.car.name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.rentalDays} day${widget.rentalDays > 1 ? 's' : ''} • ${widget.startDate.day}/${widget.startDate.month} - ${widget.endDate.day}/${widget.endDate.month}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.car.location,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Option',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Option 1: Pay 20% Deposit
          _buildPaymentOption(
            title: 'Pay 20% Deposit',
            subtitle: 'Pay ${PriceFormatter.formatWithSettings(context, _depositAmount.toStringAsFixed(0))} now, rest on pickup',
            amount: _depositAmount,
            isSelected: !_payFullAmount,
            onTap: () => setState(() => _payFullAmount = false),
          ),
          const SizedBox(height: 12),

          // Option 2: Pay Full Amount
          _buildPaymentOption(
            title: 'Pay Full Amount',
            subtitle: 'Pay ${PriceFormatter.formatWithSettings(context, widget.totalPrice.toStringAsFixed(0))} now',
            amount: widget.totalPrice,
            isSelected: _payFullAmount,
            onTap: () => setState(() => _payFullAmount = true),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required double amount,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF353935).withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF353935) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF353935) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF353935) : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              PriceFormatter.formatWithSettings(context, amount.toStringAsFixed(0)),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF353935),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Payment method options
          _buildPaymentMethodOption(
            method: PaymentMethod.creditCard,
            title: 'Credit Card',
            icon: Icons.credit_card,
            isSelected: _selectedPaymentMethod == PaymentMethod.creditCard,
          ),
          const SizedBox(height: 12),

          _buildPaymentMethodOption(
            method: PaymentMethod.debitCard,
            title: 'Debit Card',
            icon: Icons.credit_card,
            isSelected: _selectedPaymentMethod == PaymentMethod.debitCard,
          ),
          const SizedBox(height: 12),

          _buildPaymentMethodOption(
            method: PaymentMethod.digitalWallet,
            title: 'Digital Wallet',
            icon: Icons.account_balance_wallet,
            isSelected: _selectedPaymentMethod == PaymentMethod.digitalWallet,
          ),
          const SizedBox(height: 12),

          _buildPaymentMethodOption(
            method: PaymentMethod.cash,
            title: 'Cash on Pickup',
            icon: Icons.money,
            isSelected: _selectedPaymentMethod == PaymentMethod.cash,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required PaymentMethod method,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF353935).withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF353935) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF353935) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF353935),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pickup & Drop-off',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Pickup Location
          TextFormField(
            controller: _pickupLocationController,
            decoration: InputDecoration(
              labelText: 'Pickup Location',
              prefixIcon: const Icon(Icons.location_on, color: Color(0xFF353935)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dropoff Location
          TextFormField(
            controller: _dropoffLocationController,
            decoration: InputDecoration(
              labelText: 'Drop-off Location',
              prefixIcon: const Icon(Icons.location_on, color: Color(0xFF353935)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalNotes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Notes',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any special requests or notes...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Price breakdown
          _buildSummaryRow('Rental Price', widget.totalPrice - (widget.insuranceCost ?? 0)),
          if (widget.insuranceCost != null)
            _buildSummaryRow('Insurance', widget.insuranceCost!),
          const Divider(),
          _buildSummaryRow(
            'Total Amount',
            _paymentAmount,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Text(
            PriceFormatter.formatWithSettings(context, amount.toStringAsFixed(0)),
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF353935),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return AnimatedButton(
      onPressed: _isProcessing ? null : _processPayment,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF353935),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              const Icon(Icons.payment, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              _isProcessing ? 'Processing...' : 'Pay ${PriceFormatter.formatWithSettings(context, _paymentAmount.toStringAsFixed(0))}',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Create booking
      final bookingService = Provider.of<BookingService>(context, listen: false);
      final booking = await bookingService.createBooking(
        carId: widget.car.id,
        carName: widget.car.name,
        userId: currentUser.id,
        userName: currentUser.name ?? 'User',
        startDate: widget.startDate,
        endDate: widget.endDate,
        totalPrice: widget.totalPrice,
        depositAmount: _depositAmount,
        remainingAmount: _remainingAmount,
        hostId: widget.car.hostId,
        hostName: widget.car.hostName,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        pickupLocation: _pickupLocationController.text,
        dropoffLocation: _dropoffLocationController.text,
        paymentMethod: _selectedPaymentMethod.name,
        insuranceType: widget.insuranceType,
        insuranceCost: widget.insuranceCost,
      );

      if (booking == null) {
        throw Exception('Failed to create booking');
      }

      // Process payment
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      Payment? payment;

      if (_payFullAmount) {
        payment = await paymentService.processFullPayment(
          bookingId: booking.id,
          totalAmount: widget.totalPrice,
          method: _selectedPaymentMethod,
          userId: currentUser.id,
          hostId: widget.car.hostId,
        );
      } else {
        payment = await paymentService.processDepositPayment(
          bookingId: booking.id,
          depositAmount: _depositAmount,
          method: _selectedPaymentMethod,
          userId: currentUser.id,
          hostId: widget.car.hostId,
        );
      }

      if (payment == null) {
        throw Exception('Payment processing failed');
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _payFullAmount 
                  ? 'Payment successful! Your booking is confirmed.'
                  : 'Deposit payment successful! Pay the remaining amount on pickup.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to booking confirmation
        Navigator.pushReplacementNamed(context, '/booking-confirmation');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
} 