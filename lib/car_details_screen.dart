import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/car.dart';
import 'services/view_history_service.dart';
import 'services/review_service.dart';
import 'services/chat_service.dart';
import 'services/share_service.dart';
import 'models/chat_message.dart';
import 'widgets/heart_icon.dart';
import 'widgets/save_to_favorites_modal.dart';
import 'widgets/floating_header.dart';
import 'screens/car_booking_screen.dart';
import 'screens/chat_detail_screen.dart';
import 'utils/price_formatter.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'constants.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car car;

  const CarDetailsScreen({
    super.key,
    required this.car,
  });

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  int _currentImageIndex = 0;
  
  bool _isBooking = false;
  DateTime? _startDate;
  DateTime? _endDate;
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;
  
  // Chat service
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    print('DEBUG: CarDetailsScreen initState - car.name: "${widget.car.name}", car.image: "${widget.car.image}", car.hostName: "${widget.car.hostName}"');
    print('DEBUG: Car brand: "${widget.car.brand}", model: "${widget.car.model}"');
    print('DEBUG: Car images array: ${widget.car.images}');
    _recordCarView();
    _loadReviews();
  }

  void _recordCarView() {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userId = auth.currentUser?.id ?? AppConstants.defaultUserId;
    print('DEBUG: Recording car view - car.name: "${widget.car.name}", car.image: "${widget.car.image}", car.hostName: "${widget.car.hostName}"');
    print('DEBUG: Recording car view - car.price: "${widget.car.price}", car.location: "${widget.car.location}"');
    ViewHistoryService.addCarView(
        userId: userId,
        carId: widget.car.id,
        carModel: widget.car.name,
        carImage: widget.car.image,
        carRating: widget.car.rating,
        carTrips: widget.car.trips,
        hostName: widget.car.hostName,
      isAllStarHost: widget.car.hostRating >= 4.5,
      price: widget.car.price,
      location: widget.car.location,
      hostImage: widget.car.hostImage,
      hostRating: widget.car.hostRating,
      responseTime: widget.car.responseTime,
      features: widget.car.features,
      specs: widget.car.specs,
      images: widget.car.images,
      hostId: widget.car.hostId,
    );
  }

  Future<void> _loadReviews() async {
    try {
      final reviewService = ReviewService();
      final reviews = await reviewService.getHostReviews(widget.car.hostName);
      if (mounted) {
      setState(() {
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  String _calculateDailyRate() {
    print('DEBUG: _calculateDailyRate - widget.car.price: "${widget.car.price}"');
    final formatted = PriceFormatter.formatWithSettings(context, widget.car.price);
    print('DEBUG: _calculateDailyRate - formatted: "$formatted"');
    return formatted;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _contactHost() async {
    try {
      // Show loading indicator
      showDialog(
      context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get current user ID (you might want to get this from your auth service)
      const currentUserId = 'current_user_id'; // Replace with actual user ID
      const currentUserName = 'You'; // Replace with actual user name

      // Get host ID or use host name as fallback
      final hostId = widget.car.hostId ?? 'host_${widget.car.hostName.replaceAll(' ', '_').toLowerCase()}';
      
      // Create a ChatRoom for the host conversation
      final chatRoom = ChatRoom(
        id: 'host_chat_$hostId',
        name: widget.car.hostName,
        avatar: widget.car.hostImage,
        participantIds: [currentUserId, hostId],
        participants: [
          ChatParticipant(
            id: currentUserId,
            name: currentUserName,
            isOnline: true,
            role: ChatParticipantRole.member,
          ),
          ChatParticipant(
            id: hostId,
            name: widget.car.hostName,
            avatar: widget.car.hostImage,
            isOnline: false,
            role: ChatParticipantRole.owner,
          ),
        ],
        carId: widget.car.id,
        type: ChatRoomType.booking,
        unreadCount: 0,
        lastActivity: DateTime.now(),
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Navigate to chat detail screen
        Navigator.push(
          context,
      MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
            chatRoom: chatRoom,
        ),
      ),
    );
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Stack(
          children: [
            // Main Content (starts from top of screen)
            Column(
              children: [
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Gallery
                        _buildCarImageSection(),
                        
                        // Host Details Section (directly after image)
                        _buildHostDetailsSection(),

                        // Date & Pickup Section
                        _buildDateSelectionSection(),

                        // Car Details Section
                        _buildCarDetailsSection(),

                        // Requirements & Conditions Section (last)
                        _buildRequirementsSection(),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Booking Button
                _buildConfirmButton(),
              ],
            ),
            
            // Floating Header (overlay on top)
            Positioned(
              top: 0,
              left: 10,
              right: 10,
              child: _buildAppBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return FloatingHeader(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        bottom: 0,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
                color: Colors.white,
              size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
              child: Text(
               '${widget.car.brand ?? ''} ${widget.car.model ?? ''}'.trim(),
               style: GoogleFonts.inter(
                  fontSize: 18,
                            fontWeight: FontWeight.w600,
                  color: Colors.white,
               ),
               overflow: TextOverflow.ellipsis,
             ),
           ),
          GestureDetector(
            onTap: () async {
              await ShareService.shareCarListing(
                carId: widget.car.id,
                carName: widget.car.name,
                carBrand: widget.car.brand ?? 'Unknown',
                carModel: widget.car.model ?? 'Unknown',
                price: _calculateDailyRate(),
                hostName: widget.car.hostName,
                carImage: widget.car.image,
              );
            },
            child: const Icon(
              Icons.share,
                  color: Colors.white,
              size: 20,
                ),
              ),
              const SizedBox(width: 12),
          HeartIcon(
        carId: widget.car.id,
        carModel: widget.car.name,
        carImage: widget.car.image,
        carRating: widget.car.rating,
        carTrips: widget.car.trips,
        hostName: widget.car.hostName,
            isAllStarHost: widget.car.hostRating >= 4.5,
        carPrice: widget.car.price,
        carLocation: widget.car.location,
                  showShadow: false,
            color: Colors.white,
            cleanMode: true,
            size: 20,
          ),
        ],
      ),
    );
  }



    Widget _buildCarImageSection() {
    // Sanitize images: ensure first image is main car.image, remove empties, dedupe
    final List<String> images = [
      if (widget.car.image.isNotEmpty) widget.car.image,
      ...widget.car.images.where((s) => s.isNotEmpty),
    ].toSet().toList();
    if (images.isEmpty) {
      images.add(widget.car.image);
    }
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.35; // 35% of screen height
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Container(
      height: imageHeight + statusBarHeight,
      width: double.infinity,
              decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
                boxShadow: [
                  BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: 1,
          ),
                    BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 48,
            offset: const Offset(0, 18),
            spreadRadius: 3,
          ),
                    BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 70,
            offset: const Offset(0, 26),
            spreadRadius: 6,
                    ),
                  ],
                ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: GestureDetector(
          onTap: () => _openFullScreenGallery(
            widget.car.images.isNotEmpty ? widget.car.images : [widget.car.image],
            _currentImageIndex,
          ),
          child: Stack(
                children: [
            PageView.builder(
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
              itemCount: images.length,
                      itemBuilder: (context, index) {
                return Container(
                            width: double.infinity,
                  height: imageHeight + statusBarHeight,
                  child: images[index].startsWith('http') || images[index].startsWith('https')
                      ? Image.network(
                          images[index],
                                fit: BoxFit.cover,
                          width: double.infinity,
                          height: imageHeight + statusBarHeight,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: imageHeight + statusBarHeight,
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.directions_car,
                                color: Colors.grey.shade400,
                                size: 50,
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: imageHeight + statusBarHeight,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: imageHeight + statusBarHeight,
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.directions_car,
                                color: Colors.grey.shade400,
                                size: 50,
                              ),
                            );
                          },
                          ),
                        );
                      },
                  ),
                  
            if (images.length > 1)
                  Positioned(
                bottom: 16,
                    left: 0,
                    right: 0,
                child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                    images.length,
                    (index) => Container(
                      width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                        shape: BoxShape.circle,
                                color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  void _openFullScreenGallery(List<String> images, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => _FullScreenGallery(
          images: images,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildCarTitleSection() {
    // Removed price, location, rating/reviews from the title section
    return const SizedBox.shrink();
  }

  Widget _buildHostDetailsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hosted by',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: widget.car.hostImage.startsWith('http') || widget.car.hostImage.startsWith('https')
                    ? NetworkImage(widget.car.hostImage) as ImageProvider
                    : (widget.car.hostImage.isNotEmpty
                        ? AssetImage(widget.car.hostImage)
                        : null),
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle error
                },
                child: widget.car.hostImage.isEmpty
                    ? Icon(Icons.person, color: Colors.grey.shade400)
                    : null,
              ),
          const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.car.hostName,
                      style: GoogleFonts.inter(
                    fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                  const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.car.hostRating}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                    fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        if (widget.car.hostRating >= 4.5) ...[
                          const SizedBox(width: 8),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'All-Star Host',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber.shade800,
                              ),
                          ),
                        ),
                      ],
                        ],
                      ),
                  const SizedBox(height: 4),
                  Text(
                      'Response time: ${widget.car.responseTime}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          ),
              // Contact Button
              ElevatedButton.icon(
                onPressed: _contactHost,
                icon: const Icon(Icons.message, size: 16),
                label: Text(
                  'Contact',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
                  style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF353935),
                    foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarDetailsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
        boxShadow: const [
              BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
                blurRadius: 16,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 32,
            offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Car Details',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              _useBadge(widget.car.useType),
            ],
          ),
          const SizedBox(height: 16),
          
          if (widget.car.features.isNotEmpty) ...[
          Text(
              'Features',
              style: GoogleFonts.inter(
                            fontSize: 16,
                      fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.car.features.take(6).map((feature) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                          child: Text(
                            feature,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              )).toList(),
        ),
        const SizedBox(height: 16),
          ],
          
          if (widget.car.specs.isNotEmpty) ...[
        Text(
              'Specifications',
              style: GoogleFonts.inter(
                    fontSize: 16,
            fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.car.specs.entries.take(6).map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
      children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key,
                      style: GoogleFonts.inter(
                fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.value,
                      style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                        color: Colors.black87,
                          ),
                        ),
                        ),
                      ],
                    ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _useBadge(CarUseType useType) {
    String label;
    Color color;
    IconData icon;
    switch (useType) {
      case CarUseType.business:
        label = 'Business';
        color = const Color(0xFF0EA5E9);
        icon = Icons.business_center;
        break;
      case CarUseType.event:
        label = 'Events';
        color = const Color(0xFFF59E0B);
        icon = Icons.celebration;
        break;
      case CarUseType.daily:
      default:
        label = 'Daily use';
        color = const Color(0xFF22C55E);
        icon = Icons.calendar_today;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectionSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
            'Date, Pickup & Drop-off',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
          const SizedBox(height: 12),
          // Pickup location field
          GestureDetector(
            onTap: () => _showLocationSelector(
              title: 'Pickup location',
              options: widget.car.pickupLocations.isNotEmpty
                  ? widget.car.pickupLocations
                  : [widget.car.location],
              onSelected: (value) {
                // You can store selected pickup in state if needed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pickup: $value')),
                );
              },
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
      child: Row(
        children: [
                  Icon(Icons.location_on, color: Colors.grey.shade700, size: 18),
                  const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                          'Pickup location',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                Text(
                          widget.car.location,
                          style: GoogleFonts.inter(
                    fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                  ),
                          overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
        children: [
          Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                      });
                    }
                  },
            child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                          'Start Date',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                  const SizedBox(height: 4),
                  Text(
                          _startDate != null ? _formatDate(_startDate) : 'Select date',
                          style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                            color: _startDate != null ? Colors.black : Colors.grey.shade400,
                    ),
                  ),
              ],
            ),
          ),
                ),
              ),
          const SizedBox(width: 12),
          Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (_startDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select start date first')),
                      );
                      return;
                    }
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate!.add(const Duration(days: 1)),
                      firstDate: _startDate!.add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                    }
      },
      child: Container(
                    padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  Text(
                          'End Date',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                      ),
                      ),
                      const SizedBox(height: 4),
                  Text(
                          _endDate != null ? _formatDate(_endDate) : 'Select date',
                          style: GoogleFonts.inter(
                          fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _endDate != null ? Colors.black : Colors.grey.shade400,
                        ),
                  ),
                ],
              ),
                ),
              ),
            ),
                ],
              ),
              const SizedBox(height: 12),
        // Drop-off location field (under dates)
        GestureDetector(
          onTap: () => _showLocationSelector(
            title: 'Drop-off location',
            options: widget.car.dropoffLocations.isNotEmpty
                ? widget.car.dropoffLocations
                : [widget.car.location],
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Drop-off: $value')),
              );
            },
          ),
            child: Container(
            padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.place, color: Colors.grey.shade700, size: 18),
          const SizedBox(width: 8),
                Expanded(
                  child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
                        'Drop-off location',
                        style: GoogleFonts.inter(
            fontSize: 12,
                          color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
            Text(
                        widget.car.location,
                        style: GoogleFonts.inter(
                fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationSelector({
    required String title,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
        maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (context, controller) {
            return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
                  const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                      color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
              ),
              Expanded(
                          child: Center(
                            child: Text(
                  title,
                              style: GoogleFonts.inter(
                    fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
              ],
            ),
          ),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final item = options[index];
                        return ListTile(
                          title: Text(item),
      onTap: () {
                            Navigator.pop(context);
                            onSelected(item);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
        color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                'Reviews',
                style: GoogleFonts.inter(
                  fontSize: 18,
                          fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
                      Text(
                '(${_reviews.length})',
                style: GoogleFonts.inter(
                          fontSize: 16,
                  color: Colors.grey.shade600,
                        ),
                      ),
                    ],
            ),
            const SizedBox(height: 16),
          
          if (_isLoadingReviews)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_reviews.isEmpty)
            Center(
                            child: Text(
                'No reviews yet',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            )
          else
            ..._reviews.take(3).map((review) => _buildReviewCard(review)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
                child: Icon(
                  Icons.person,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${review.rating}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.createdAt),
                          style: GoogleFonts.inter(
                                  fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
              Text(
            review.comment,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final isDateSelected = _startDate != null && _endDate != null;
    final days = _startDate != null && _endDate != null
        ? _endDate!.difference(_startDate!).inDays
        : 0;
    final totalPrice = days * 120;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonWidth = constraints.maxWidth * 0.3;
          final priceText = isDateSelected
              ? 'UK£$totalPrice'
              : _calculateDailyRate();
          final priceLabel = isDateSelected ? 'Total for $days days' : 'Per day';

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
              // Price tag (left)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
                    color: const Color(0xFF353935),
                    borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
        children: [
              Text(
                        priceLabel,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                        Text(
                        priceText,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                                color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
              // Confirm button (right, 30% width)
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: isDateSelected
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarBookingScreen(
                                car: widget.car,
                              ),
      ),
    );
  }
                      : null,
              style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF353935),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
                  child: _isBooking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isDateSelected ? 'Confirm' : 'Select Dates',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequirementsSection() {
    // Extract known groups if present
    final driver = widget.car.requirements['driver_requirements'];
    final policies = widget.car.requirements['policies'];
    final finance = widget.car.requirements['financial_terms'];

    return Container(
      margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Row(
                children: [
              const Icon(Icons.rule, color: Color(0xFF353935), size: 20),
              const SizedBox(width: 8),
              Text(
                'Requirements & Conditions',
                style: GoogleFonts.inter(
                  fontSize: 18,
                          fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (driver != null) ...[
            _buildReqGroup('Driver Requirements', driver),
            const SizedBox(height: 12),
          ],
          if (policies != null) ...[
            _buildReqGroup('Policies', policies),
            const SizedBox(height: 12),
          ],
          if (finance != null) ...[
            _buildReqGroup('Financial & Usage Terms', finance),
          ],
          if (driver == null && policies == null && finance == null)
            (widget.car.requirements.isNotEmpty
                ? _buildReqGroup('Details', widget.car.requirements)
                : Text(
                    'No specific requirements provided by the host.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  )),
        ],
      ),
    );
  }

  Widget _buildReqGroup(String title, dynamic data) {
    final items = <Widget>[];
    if (data is Map) {
      data.forEach((key, value) {
        items.add(_buildReqItem(key.toString(), value));
      });
    } else if (data is List) {
      for (final v in data) {
        items.add(_buildReqItem('•', v));
      }
    } else if (data != null) {
      items.add(_buildReqItem('', data));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
          title,
          style: GoogleFonts.inter(
              fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF353935),
          ),
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildReqItem(String key, dynamic value) {
    String label = key;
    String text = value?.toString() ?? '';
    if (value is Map || value is List) {
      text = value.toString();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty && label != '•')
            SizedBox(
              width: 140,
              child: Text(
            label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            )
          else if (label == '•')
            const Text('• ', style: TextStyle(fontSize: 14, color: Colors.black87)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenGallery({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex.clamp(0, widget.images.length - 1);
    _controller = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.98),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final src = widget.images[index];
              final isNetwork = src.startsWith('http') || src.startsWith('https');
              return InteractiveViewer(
                child: isNetwork
                    ? Image.network(
                        src,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: imageHeight,
                      )
                    : Image.asset(
                        src,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: imageHeight,
                      ),
              );
            },
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
      child: Container(
                padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
          // Dots
          if (widget.images.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
        child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (i) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                      color: _current == i ? Colors.white : Colors.white.withOpacity(0.4),
                shape: BoxShape.circle,
                    ),
                  ),
                ),
                        ),
                      ),
                    ],
      ),
    );
  }
}
