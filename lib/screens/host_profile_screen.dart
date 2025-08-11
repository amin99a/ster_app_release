import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/top_host.dart';
import 'package:provider/provider.dart';
import '../services/host_service.dart';
import '../services/car_service.dart';
import '../services/review_service.dart';
import '../services/messaging_service.dart';
import '../services/chat_service.dart';
import '../services/share_service.dart';
import '../models/car.dart';
import '../models/chat_message.dart';
import '../widgets/heart_icon.dart';
import '../widgets/save_to_favorites_modal.dart';
import '../utils/price_formatter.dart';
import '../utils/animations.dart';
import '../widgets/floating_header.dart';
import '../car_details_screen.dart';
import 'chat_detail_screen.dart';

class HostProfileScreen extends StatefulWidget {
  final String hostId;
  final String hostName;
  final String? hostImage;
  final String? hostCoverImage;

  const HostProfileScreen({
    super.key,
    required this.hostId,
    required this.hostName,
    this.hostImage,
    this.hostCoverImage,
  });

  @override
  State<HostProfileScreen> createState() => _HostProfileScreenState();
}

class _HostProfileScreenState extends State<HostProfileScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isLoadingCars = true;
  bool _isLoadingReviews = true;
  
  TopHost? _hostData;
  List<Car> _hostCars = [];
  List<Review> _hostReviews = [];
  
  // Messaging service
  final MessagingService _messagingService = MessagingService();
  
  // Chat service
  final ChatService _chatService = ChatService();
  
  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadHostData();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadHostData() async {
    setState(() => _isLoading = true);

    try {
      // Load host data
      final hosts = await HostService.getTopHosts(limit: 100);
      final host = hosts.firstWhere(
        (h) => h.id == widget.hostId,
        orElse: () => TopHost(
          id: widget.hostId,
          name: widget.hostName,
          profileImage: widget.hostImage,
          hostType: 'Verified Host',
          rating: 4.5,
          trips: 0,
          location: 'Unknown',
          carsCount: 0,
          coverImage: widget.hostCoverImage,
        ),
      );

      // Load host cars
      final carService = CarService();
      await carService.initialize();
      final allCars = await carService.getCars();
      final hostCars = (allCars ?? []).where((car) => car.hostId == widget.hostId).toList();

      // Load host reviews
      final reviewService = ReviewService();
      final hostReviews = await reviewService.getHostReviews(widget.hostName);

      setState(() {
        _hostData = host;
        _hostCars = hostCars;
        _hostReviews = hostReviews;
        _isLoading = false;
        _isLoadingCars = false;
        _isLoadingReviews = false;
      });
    } catch (e) {
      print('Error loading host data: $e');
      setState(() => _isLoading = false);
    }
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

      // Create a ChatRoom for the host conversation
      final chatRoom = ChatRoom(
        id: 'host_chat_${widget.hostId}',
        name: _hostData?.name ?? widget.hostName,
        avatar: _hostData?.profileImage,
        participantIds: [currentUserId, widget.hostId],
        participants: [
          ChatParticipant(
            id: currentUserId,
            name: currentUserName,
            isOnline: true,
            role: ChatParticipantRole.member,
          ),
          ChatParticipant(
            id: widget.hostId,
            name: _hostData?.name ?? widget.hostName,
            avatar: _hostData?.profileImage,
            isOnline: false,
            role: ChatParticipantRole.owner,
          ),
        ],
        carId: _hostCars.isNotEmpty ? _hostCars.first.id : null,
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
      backgroundColor: Colors.grey.shade50,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Custom Floating 3D Header
                SliverToBoxAdapter(
                  child: FloatingHeader(
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Color(0xFF353935),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Host name
                        Expanded(
                          child: Text(
                            _hostData?.name ?? widget.hostName,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Share button
                        GestureDetector(
                          onTap: () async {
                            await ShareService.shareHostProfile(
                              hostId: widget.hostId,
                              hostName: _hostData?.name ?? widget.hostName,
                              hostLocation: _hostData?.location,
                              hostImage: _hostData?.profileImage,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.share,
                              color: Color(0xFF353935),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Host Information Section
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            
                            // Host Profile Section with Name, Location, Contact
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Host Name, Location, Contact Row
                                  Row(
                                    children: [
                                      // Host Name and Location
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _hostData?.name ?? widget.hostName,
                                              style: GoogleFonts.inter(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  color: Colors.grey.shade600,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _hostData?.location ?? 'Location not specified',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 16,
                                                      color: Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                                                             // Contact Button
                                       ElevatedButton.icon(
                                         onPressed: () async {
                                           await _contactHost();
                                         },
                                        icon: const Icon(Icons.message, size: 18),
                                        label: Text(
                                          'Contact',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF353935),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          elevation: 4,
                                          shadowColor: const Color(0xFF353935).withOpacity(0.3),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Host Statistics
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatItem(
                                          'Rating',
                                          '${_hostData?.rating.toStringAsFixed(1) ?? '4.5'}',
                                          Icons.star,
                                          Colors.amber,
                                        ),
                                        _buildStatItem(
                                          'Cars',
                                          '${_hostData?.carsCount ?? _hostCars.length}',
                                          Icons.directions_car,
                                          const Color(0xFF353935),
                                        ),
                                        _buildStatItem(
                                          'Trips',
                                          '${_hostData?.trips ?? 0}',
                                          Icons.local_taxi,
                                          Colors.blue,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Host Cars Section
                            Text(
                              'Cars by ${_hostData?.name ?? widget.hostName}',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            
                            // Cars Grid
                            _isLoadingCars
                                ? const Center(child: CircularProgressIndicator())
                                : _hostCars.isEmpty
                                    ? _buildEmptyState('No cars available', Icons.directions_car)
                                    : GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.75,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                        ),
                                        itemCount: _hostCars.length,
                                        itemBuilder: (context, index) {
                                          return _buildCarCard(_hostCars[index]);
                                        },
                                      ),
                            
                            const SizedBox(height: 30),
                            
                            // Reviews Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Reviews',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '${_hostReviews.length} reviews',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Reviews List
                            _isLoadingReviews
                                ? const Center(child: CircularProgressIndicator())
                                : _hostReviews.isEmpty
                                    ? _buildEmptyState('No reviews yet', Icons.rate_review)
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: _hostReviews.length,
                                        itemBuilder: (context, index) {
                                          return _buildReviewCard(_hostReviews[index]);
                                        },
                                      ),
                            
                            const SizedBox(height: 100), // Bottom spacing
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCarCard(Car car) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailsScreen(car: car),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: car.image.startsWith('http') || car.image.startsWith('https')
                    ? Image.network(
                        car.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.directions_car,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        car.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.directions_car,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
              ),
            ),
            // Car Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          car.rating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      PriceFormatter.formatWithSettings(context, car.price),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF353935),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName.isNotEmpty ? review.userName : 'Anonymous',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            size: 16,
                            color: index < review.rating ? Colors.amber : Colors.grey.shade300,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          review.rating.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            icon,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
