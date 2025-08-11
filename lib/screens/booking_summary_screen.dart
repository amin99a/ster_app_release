import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking.dart';
import '../models/car.dart';
import '../services/share_service.dart';
import '../widgets/floating_header.dart';
import '../utils/price_formatter.dart';

class BookingSummaryScreen extends StatelessWidget {
  final Booking booking;
  final Car? car;

  const BookingSummaryScreen({
    super.key,
    required this.booking,
    this.car,
  });

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
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Booking Summary',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _shareBooking(context),
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Banner
                    _buildStatusBanner(),
                    
                    const SizedBox(height: 24),
                    
                    // Car Information
                    if (car != null) ...[
                      _buildCarInfoCard(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Booking Details
                    _buildBookingDetailsCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Payment Information
                    _buildPaymentInfoCard(context),
                    
                    const SizedBox(height: 24),
                    
                    // Timeline
                    _buildTimelineCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Contact Information
                    _buildContactCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    _buildActionButtons(context),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color statusColor;
    IconData statusIcon;
    String statusMessage;

    switch (booking.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusMessage = 'Booking request is pending host approval';
        break;
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusMessage = 'Booking confirmed - ready for pickup';
        break;
      case 'active':
        statusColor = Colors.blue;
        statusIcon = Icons.directions_car;
        statusMessage = 'Trip is currently active';
        break;
      case 'completed':
        statusColor = Colors.grey;
        statusIcon = Icons.check_circle_outline;
        statusMessage = 'Trip completed successfully';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusMessage = 'Booking has been cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusMessage = 'Unknown status';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.statusDisplay,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusMessage,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarInfoCard() {
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
          Row(
            children: [
              const Icon(Icons.directions_car, color: Color(0xFF353935), size: 24),
              const SizedBox(width: 8),
              Text(
                'Vehicle Details',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Car Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (car!.image.startsWith('http') || car!.image.startsWith('https'))
                    ? Image.network(
                        car!.image,
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.grey,
                              size: 32,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        car!.image,
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.grey,
                              size: 32,
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car!.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      car!.category,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${car!.rating} (${car!.trips} trips)',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard() {
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
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF353935), size: 24),
              const SizedBox(width: 8),
              Text(
                'Booking Details',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Booking ID', booking.id),
          _buildDetailRow('Start Date', _formatDate(booking.startDate)),
          _buildDetailRow('End Date', _formatDate(booking.endDate)),
          _buildDetailRow('Duration', '${booking.durationInDays} day${booking.durationInDays > 1 ? 's' : ''}'),
          _buildDetailRow('Created', _formatDateTime(booking.createdAt)),
          if (booking.notes != null && booking.notes!.isNotEmpty)
            _buildDetailRow('Notes', booking.notes!),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(BuildContext context) {
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
          Row(
            children: [
              const Icon(Icons.payment, color: Color(0xFF353935), size: 24),
              const SizedBox(width: 8),
              Text(
                'Payment Information',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Total Amount', PriceFormatter.formatWithSettings(context, booking.totalPrice.toStringAsFixed(0))),
          _buildDetailRow('Payment Status', _getPaymentStatus()),
          if (booking.durationInDays >= 3)
            _buildDetailRow('Discount Applied', _getDiscountText()),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Paid',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                PriceFormatter.formatWithSettings(context, booking.totalPrice.toStringAsFixed(0)),
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

  Widget _buildTimelineCard() {
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
          Row(
            children: [
              const Icon(Icons.timeline, color: Color(0xFF353935), size: 24),
              const SizedBox(width: 8),
              Text(
                'Trip Timeline',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            'Booking Created',
            _formatDateTime(booking.createdAt),
            true,
            Icons.create,
          ),
          if (booking.status != 'pending')
            _buildTimelineItem(
              'Booking Confirmed',
              _formatDateTime(booking.updatedAt),
              true,
              Icons.check_circle,
            ),
          _buildTimelineItem(
            'Trip Start',
            _formatDate(booking.startDate),
            booking.isOngoing || booking.isPast,
            Icons.play_circle,
          ),
          _buildTimelineItem(
            'Trip End',
            _formatDate(booking.endDate),
            booking.isPast,
            Icons.stop_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, bool isCompleted, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? const Color(0xFF353935).withValues(alpha: 0.1)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isCompleted ? const Color(0xFF353935) : Colors.grey[400],
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.black : Colors.grey[500],
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Icon(
              Icons.check,
              color: Colors.green[600],
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
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
          Row(
            children: [
              const Icon(Icons.contact_support, color: Color(0xFF353935), size: 24),
              const SizedBox(width: 8),
              Text(
                'Contact Information',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (car != null) ...[
            _buildContactItem(
              'Host',
              car!.hostName,
              Icons.person,
              onTap: () => _contactHost(),
            ),
            const SizedBox(height: 12),
          ],
          _buildContactItem(
            'Customer Support',
            '+213 XXX XXX XXX',
            Icons.support_agent,
            onTap: () => _contactSupport(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF353935).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF353935),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    List<Widget> buttons = [];

    if (booking.status == 'pending') {
      buttons.add(
        Expanded(
          child: OutlinedButton(
            onPressed: () => _cancelBooking(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[600],
              side: BorderSide(color: Colors.red[600]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Cancel Booking',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    if (booking.status == 'confirmed') {
      if (buttons.isNotEmpty) {
        buttons.add(const SizedBox(width: 12));
      }
      buttons.add(
        Expanded(
          child: ElevatedButton(
            onPressed: () => _startTrip(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF353935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Start Trip',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    if (booking.status == 'active') {
      buttons.add(
        Expanded(
          child: ElevatedButton(
            onPressed: () => _endTrip(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'End Trip',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    if (booking.status == 'completed') {
      buttons.add(
        Expanded(
          child: ElevatedButton(
            onPressed: () => _rateExperience(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF353935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Rate Experience',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(children: buttons);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getPaymentStatus() {
    switch (booking.status) {
      case 'pending':
        return 'Pending approval';
      case 'confirmed':
      case 'active':
      case 'completed':
        return 'Paid';
      case 'cancelled':
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }

  String _getDiscountText() {
    if (booking.durationInDays >= 30) return '20% discount applied';
    if (booking.durationInDays >= 14) return '15% discount applied';
    if (booking.durationInDays >= 7) return '10% discount applied';
    if (booking.durationInDays >= 3) return '5% discount applied';
    return '';
  }

  void _shareBooking(BuildContext context) async {
    try {
      await ShareService.shareBookingConfirmation(
        bookingId: booking.id,
        carName: car?.name ?? 'Car',
        hostName: car?.hostName ?? 'Host',
        startDate: booking.startDate.toString().split(' ')[0],
        endDate: booking.endDate.toString().split(' ')[0],
        totalPrice: PriceFormatter.formatWithSettings(context, booking.totalPrice.toString()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing booking: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _cancelBooking(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Booking',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep Booking',
              style: GoogleFonts.inter(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement cancellation logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Cancel Booking',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _startTrip(BuildContext context) {
    // Implement trip start logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip started successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _endTrip(BuildContext context) {
    // Implement trip end logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip ended successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _rateExperience(BuildContext context) {
    // Navigate to rating screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rating screen coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _contactHost() {
    // Implement host contact functionality
  }

  void _contactSupport() {
    // Implement support contact functionality
  }
}