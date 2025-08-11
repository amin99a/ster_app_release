import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'more_screen.dart';
import 'search_screen.dart';
import 'saved_screen.dart';
import 'services/auth_service.dart';
import 'guards/email_verification_guard.dart';
import 'services/view_history_service.dart';
import 'services/notification_service.dart';
import 'services/host_service.dart';
import 'models/view_history.dart';
import 'models/car.dart';
import 'models/top_host.dart';
import 'car_details_screen.dart';
import 'featured_car_square.dart';
import 'widgets/home_car_card.dart';
import 'services/car_service.dart';
import 'screens/host_profile_screen.dart';
// import 'screens/chat_list_screen.dart';
import 'screens/notifications_screen.dart';
import 'constants.dart';
import 'widgets/heart_icon.dart';
import 'utils/price_formatter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToSearch() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return EmailVerificationGuard(
      child: _buildHomeContent(context),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final isGuest = user?.isGuest == true;

    // Role-based screen configuration
    final List<Widget> screens = [
      HomeContent(
        onSearchTap: _navigateToSearch,
        onTabChanged: _onItemTapped,
      ),
      SearchScreen(preSelectedWilaya: null),
      if (!isGuest) const SavedScreen(),
      if (!isGuest) const MoreScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main content
          screens[_selectedIndex],
          
          // Floating navigation bar
          Positioned(
            bottom: 35,
            left: 25,
            right: 25,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home, 'Home', 0),
                  _buildNavItem(Icons.search, 'Search', 1),
                  if (!isGuest) _buildNavItem(Icons.favorite, 'Saved', 2),
                  if (!isGuest) _buildNavItem(Icons.more_horiz, 'More', 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _selectedIndex == index ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: _selectedIndex == index ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ] : null,
              ),
              child: Icon(
                icon,
                color: _selectedIndex == index ? Theme.of(context).colorScheme.primary : Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: _selectedIndex == index ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
        ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final VoidCallback onSearchTap;
  final Function(int index)? onTabChanged; // Added callback for tab changes

  const HomeContent({
    super.key, 
    required this.onSearchTap,
    this.onTabChanged, // Added parameter
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _selectedDestination = 'Near by';
  List<ViewHistory> _recentlyViewed = [];
  bool _isLoadingRecentlyViewed = true;
  List<TopHost> _topHosts = [];
  bool _isLoadingTopHosts = true;
  String selectedCategory = 'All';
  List<Car> _cars = [];
  bool _isLoading = true;
  List<String> categories = ['All', 'SUV', 'Luxury', 'Electric', 'Convertible', 'Business', 'Sport', 'Mini'];

  @override
  void initState() {
    super.initState();
    // Initialize notifications to drive unread badge
    try {
      final notificationService = context.read<NotificationService>();
      if (!notificationService.isInitialized) {
        notificationService.initialize();
      }
    } catch (_) {}
    _loadRecentlyViewed();
    _loadTopHosts();
    _loadCars();
  }

  Future<void> _loadRecentlyViewed() async {
      setState(() {
      _isLoadingRecentlyViewed = true;
    });
    
    try {
      final user = context.read<AuthService>().currentUser;
      final userId = user?.id ?? AppConstants.defaultUserId;
      final recentlyViewed = await ViewHistoryService.getRecentViewHistory(
        userId,
        limit: 3,
      );
      if (mounted) {
      setState(() {
            _recentlyViewed = recentlyViewed;
            _isLoadingRecentlyViewed = false;
      });
        }
    } catch (e) {
      print('Error loading recently viewed: $e');
      if (mounted) {
      setState(() {
          _isLoadingRecentlyViewed = false;
        });
      }
    }
  }



  void _onDestinationSelected(String destination) {
      setState(() {
      _selectedDestination = destination;
    });
    // Navigate to search screen with selected destination
    widget.onTabChanged?.call(1);
  }

  Future<void> _loadTopHosts() async {
    setState(() {
      _isLoadingTopHosts = true;
    });
    
    try {
      final topHosts = await HostService.getTopHosts(limit: 4);
      if (mounted) {
      setState(() {
        _topHosts = topHosts;
        _isLoadingTopHosts = false;
      });
      }
    } catch (e) {
      print('Error loading top hosts: $e');
      if (mounted) {
      setState(() {
        _isLoadingTopHosts = false;
      });
      }
    }
  }

  Future<void> _loadCars() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final carService = CarService();
      await carService.initialize();
      final cars = await carService.getCars();
      if (mounted) {
        setState(() {
          _cars = cars ?? []; // Handle nullable list
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading cars: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Car> get filteredCars {
    if (selectedCategory == 'All') {
      return _cars;
    }
    return _cars.where((car) => car.category == selectedCategory).toList();
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
              child: Column(
            children: [
                // Header section
                Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.20),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 15),
                          child: Text(
                            'ster',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            'find the perfect car',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        if (user?.isGuest != true)
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => NotificationsScreen(),
                                  ),
                                );
                              },
                              child: StreamBuilder<int>(
                                stream: context.read<NotificationService>().unreadCountStream,
                                initialData: context.read<NotificationService>().unreadCount,
                                builder: (context, snapshot) {
                                  final unread = snapshot.data ?? 0;
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      const Icon(
                                Icons.notifications_outlined,
                                            color: Colors.white,
                                size: 24,
                                      ),
                                      if (unread > 0)
                                        Positioned(
                                          right: -2,
                                          top: -2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0x33000000),
                                                  blurRadius: 6,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                unread > 99 ? '99+' : '$unread',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                
                // Simple content
                        Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await _loadRecentlyViewed();
                      await _loadTopHosts();
                      await _loadCars();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      clipBehavior: Clip.none,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 200, // Account for header and nav bar
                        ),
                        child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                  children: [
                            const SizedBox(height: 15),
                            
                            // Browse by destination section
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                      'Browse by destination',
                      style: GoogleFonts.inter(
                                  fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                            ),
                    
                            const SizedBox(height: 12),
                            
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final rowWidth = screenWidth * 0.85;
                        final itemCount = 6;
                        const gap = 8.0;
                        final itemWidth = (rowWidth - gap * (itemCount - 1)) / itemCount;
                        return Center(
                          child: SizedBox(
                            width: rowWidth,
                      child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                                SizedBox(
                                  width: itemWidth,
                                  child: _buildDestinationOption(
                            'Near by',
                            Icons.location_on,
                                    const Color(0xFF353935),
                                    isSelected: _selectedDestination == 'Near by',
                            onTap: () => _onDestinationSelected('Near by'),
                                    imagePath: 'assets/images/near_by.png',
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: _buildDestinationOption(
                            'Algeria',
                            Icons.flag,
                                    const Color(0xFF353935),
                                    isSelected: _selectedDestination == 'Algeria',
                            onTap: () => _onDestinationSelected('Algeria'),
                                    imagePath: 'assets/images/algeria.png',
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: _buildDestinationOption(
                            'Tunisia',
                            Icons.flag,
                                    const Color(0xFF353935),
                                    isSelected: _selectedDestination == 'Tunisia',
                            onTap: () => _onDestinationSelected('Tunisia'),
                                    imagePath: 'assets/images/tunisia.png',
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: _buildDestinationOption(
                            'Morocco',
                            Icons.flag,
                                    const Color(0xFF353935),
                                    isSelected: _selectedDestination == 'Morocco',
                            onTap: () => _onDestinationSelected('Morocco'),
                                    imagePath: 'assets/images/maroco.png',
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: _buildDestinationOption(
                            'Egypt',
                            Icons.flag,
                                    const Color(0xFF353935),
                                    isSelected: _selectedDestination == 'Egypt',
                            onTap: () => _onDestinationSelected('Egypt'),
                                    imagePath: 'assets/images/egypt.png',
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: _buildDestinationOption(
                            'France',
                            Icons.flag,
                                    const Color(0xFF353935),
                                    isSelected: _selectedDestination == 'France',
                            onTap: () => _onDestinationSelected('France'),
                                    imagePath: 'assets/images/france.png',
                      ),
                    ),
                  ],
                ),
                          ),
                        );
                      },
              ),
              
                            const SizedBox(height: 15),

                            // Top Hosts section - NEW COMPACT APPROACH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Top Hosts',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                                    widget.onTabChanged?.call(1);
                          },
                          child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                              'View all',
                              style: GoogleFonts.inter(
                                            fontSize: 7,
                                fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                ),
                                        const SizedBox(width: 2),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                          size: 6,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                    
                            const SizedBox(height: 12),
                            
                            // Compact host cards - NEW APPROACH
                    _isLoadingTopHosts
                        ? const Row(
                            children: [
                              SizedBox(width: 20),
                              CircularProgressIndicator(),
                              SizedBox(width: 20),
                            ],
                          )
                        : _topHosts.isEmpty
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(20),
                                  child: Text(
                                    'No top hosts available',
                                            style: TextStyle(
                                      fontSize: 14,
                                              color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                                    : SizedBox(
                                        height: 290, // Increased height for new host card design
                                        child: ListView.builder(
                                clipBehavior: Clip.none,
                                scrollDirection: Axis.horizontal,
                                          itemCount: _topHosts.length,
                                          itemBuilder: (context, index) {
                                            final host = _topHosts[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 15),
                                              child: _buildCompactHostCard(host),
                                            );
                                          },
                ),
              ),
              
              const SizedBox(height: 20),

                           // Discover our cars section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discover our cars',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                                         widget.onTabChanged?.call(1);
                      },
                      child: Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                                           color: Theme.of(context).colorScheme.primary,
                                           borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.20),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                        'View all',
                        style: GoogleFonts.inter(
                                                 fontSize: 7,
                          fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                                             const SizedBox(width: 2),
                            const Icon(
                              Icons.arrow_forward_ios,
                                               size: 6,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Explore Cars Section
          _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : filteredCars.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No cars available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              : SizedBox(
                                   height: MediaQuery.of(context).size.width * 0.8, // Increased height for better content fit
                  child: ListView.separated(
                    clipBehavior: Clip.none,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 0), // Removed left padding
                    itemCount: filteredCars.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final car = filteredCars[index];
                      return HomeCarCard(
                        car: car,
                                         width: MediaQuery.of(context).size.width * 0.75, // Doubled from 0.375
                                         height: MediaQuery.of(context).size.width * 0.8, // Increased height for better content fit
                      );
                    },
                  ),
                ),
          
                           const SizedBox(height: 15),
                           
                                                       // Recently Viewed section
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Recently Viewed',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
                           
                           const SizedBox(height: 12),
                           
                           _isLoadingRecentlyViewed
                               ? const Row(
        children: [
                                     SizedBox(width: 20),
                                     CircularProgressIndicator(),
                                     SizedBox(width: 20),
                                   ],
                                 )
                               : _recentlyViewed.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                                           'No recently viewed cars',
                  style: TextStyle(
                                             fontSize: 14,
                                             color: Colors.grey,
                                           ),
                    ),
                  ),
                )
                                   : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                                       child: Row(
              children: [
                                           ..._recentlyViewed.map((history) => Padding(
                                             padding: const EdgeInsets.only(right: 15),
                                             child: _buildRecentlyViewedCard(
                                               history,
                                             ),
                                           )).toList(),
        ],
              ),
            ),
                           

                           
                const SizedBox(height: 20),
                           
                           // Featured Car Square section - LAST SECTION
                           const FeaturedCarSquare(),
                           
                           const SizedBox(height: 120), // Extra space for floating nav bar + featured car square
              ],
            ),
          ),
                ),
              ),
            ),
          ),
        ],
      ),
          ),
        );
      },
    );
  }
}

  Widget _buildCompactHostCard(TopHost host) {
    return Builder(
      builder: (context) => GestureDetector(
      onTap: () {
          // Navigate to host profile screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HostProfileScreen(
                hostId: host.id,
                hostName: host.name,
                hostImage: host.profileImage,
                hostCoverImage: host.coverImage,
              ),
            ),
          );
      },
      child: Container(
        width: 280,
        height: 290,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 3,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full width cover image with logo positioned at middle end
            Stack(
              children: [
                // Cover image
            Container(
                  height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.grey.shade200,
              ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: (host.coverImage ?? '').startsWith('http') || (host.coverImage ?? '').startsWith('https')
                        ? Image.network(
                            host.coverImage ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            host.coverImage ?? 'assets/images/featured.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                          ),
                  ),
                ),
                // Logo positioned at middle end of cover image
                  Positioned(
                  bottom: -25,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipOval(
                        child: (host.profileImage ?? '').startsWith('http') || (host.profileImage ?? '').startsWith('https')
                              ? Image.network(
                                host.profileImage ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                    color: Colors.grey.shade300,
                                      child: Icon(
                                        Icons.person,
                                      size: 25,
                                      color: Colors.grey.shade600,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.person,
                                    size: 25,
                                    color: Colors.grey.shade600,
                                      ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Centered host name
                    Text(
                      host.name,
                            style: GoogleFonts.inter(
                        fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                                         const SizedBox(height: 16),
                     // Reviews, Cars, Trips labels
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                           'Reviews',
                          style: GoogleFonts.inter(
                             fontSize: 10,
                             color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                           'CARS',
                          style: GoogleFonts.inter(
                             fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                           'TRIP',
                          style: GoogleFonts.inter(
                             fontSize: 10,
                             color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                     // Reviews, Cars, Trips values
                    Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                         // Reviews
                         Row(
                            children: [
                              Text(
                               host.rating.toStringAsFixed(1),
                                style: GoogleFonts.inter(
                                 fontSize: 14,
                                 fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                             const SizedBox(width: 4),
                             ...List.generate(5, (index) {
                               return Icon(
                                 index < host.rating.floor() ? Icons.star : Icons.star_border,
                                 size: 12,
                                 color: index < host.rating.floor() ? Colors.amber : Colors.grey.shade300,
                               );
                             }),
                           ],
                         ),
                         // Cars
                         Text(
                           '${host.carsCount}',
                           style: GoogleFonts.inter(
                             fontSize: 16,
                             fontWeight: FontWeight.bold,
                             color: Colors.black,
                           ),
                         ),
                         // Trips
                         Text(
                           '${host.trips}',
                           style: GoogleFonts.inter(
                             fontSize: 16,
                             fontWeight: FontWeight.bold,
                             color: Colors.black,
                           ),
                              ),
                            ],
                          ),
                     const SizedBox(height: 16),
                     // Location & View Profile action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            host.location,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // View Profile action
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Profile',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF353935),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward,
                              size: 12,
                              color: Color(0xFF353935),
                          ),
                      ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

Widget _buildRecentlyViewedCard(ViewHistory history) {
  return Builder(
    builder: (context) => GestureDetector(
              onTap: () {
          print('DEBUG: TAPPING on recently viewed car card');
          // Create a Car object from ViewHistory data
          print('DEBUG: Creating Car from ViewHistory - carModel: "${history.carModel}", carImage: "${history.carImage}", hostName: "${history.hostName}"');
        
        // Check if data is empty and provide better fallbacks
        if (history.carModel.isEmpty && history.carImage.isEmpty) {
          print('DEBUG: ViewHistory data is empty - using fallback data');
        }
        
        // Extract brand and model from carModel
        final carModelParts = history.carModel.split(' ');
        final brand = carModelParts.isNotEmpty ? carModelParts.first : '';
        final model = carModelParts.length > 1 ? carModelParts.skip(1).take(2).join(' ') : '';
        
        // Get metadata if available
        final metadata = history.metadata;
        print('DEBUG: ViewHistory metadata: $metadata');
        
        final price = metadata?['price']?.toString() ?? '120';
        final location = metadata?['location']?.toString() ?? 'Algiers';
        final hostImage = metadata?['hostImage']?.toString() ?? 'assets/images/host.png';
        final hostRating = (metadata?['hostRating'] ?? history.carRating).toDouble();
        final responseTime = metadata?['responseTime']?.toString() ?? '1 hour';
        
        // Handle features array
        List<String> features = ['GPS', 'Bluetooth', 'Air Conditioning']; // Default
        if (metadata?['features'] != null) {
          if (metadata!['features'] is List) {
            features = (metadata['features'] as List).map((e) => e.toString()).toList();
          }
        }
        
        // Handle specs map
        Map<String, String> specs = {
          'Transmission': 'Automatic',
          'Fuel Type': 'Petrol',
          'Seats': '5',
        }; // Default
        if (metadata?['specs'] != null) {
          if (metadata!['specs'] is Map) {
            specs = (metadata['specs'] as Map).map((k, v) => MapEntry(k.toString(), v.toString()));
          }
        }
        
        // Handle images array - ensure we have at least the main image
        List<String> images = [];
        if (metadata?['images'] != null && metadata!['images'] is List) {
          images = (metadata['images'] as List).map((e) => e.toString()).toList();
        }
        // Always include the main car image
        if (history.carImage.isNotEmpty && !images.contains(history.carImage)) {
          images.insert(0, history.carImage);
        }
        if (images.isEmpty) {
          images = ['assets/images/car_placeholder.png'];
        }
        
        final hostId = metadata?['hostId']?.toString();
        
        final car = Car(
          id: history.carId,
          name: history.carModel.isNotEmpty ? history.carModel : 'Car ${history.carId}',
          brand: brand,
          model: model,
          image: history.carImage.isNotEmpty ? history.carImage : 'assets/images/car_placeholder.png',
          price: price,
          category: 'Sedan', // Default category
          rating: history.carRating,
          trips: history.carTrips,
          location: location,
          hostName: history.hostName.isNotEmpty ? history.hostName : 'Host',
          hostImage: hostImage,
          hostRating: hostRating,
          responseTime: responseTime,
          description: 'A great car for your journey',
          features: features,
          images: images,
          specs: specs,
          pickupLocations: ['Algiers Airport', 'City Center'],
          dropoffLocations: ['Algiers Airport', 'City Center'],
          requirements: {
            'Driver License': 'Valid driver license required',
            'Credit Card': 'Credit card required for booking',
            'Age': 'Minimum 21 years old',
            'Insurance': 'Basic insurance included',
          },
        );
        
        print('DEBUG: Created Car object - name: "${car.name}", image: "${car.image}", hostName: "${car.hostName}"');
        print('DEBUG: Car brand: "${car.brand}", model: "${car.model}"');
        print('DEBUG: Car images array: ${car.images}');
        
        // Navigate to car details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailsScreen(car: car),
          ),
        );
      },
    child: Container(
      width: 200,
      height: 295, // Added 15px to height (280 + 15 = 295)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 3,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car image with heart icon
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Hero(
                  tag: 'recently_viewed_${history.carId}',
                  child: history.carImage.startsWith('http') || history.carImage.startsWith('https')
                      ? Image.network(
                          history.carImage,
                          width: double.infinity,
                          height: 133, // 45% of 295 (295 * 0.45 = 133)
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 133,
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.directions_car,
                                color: Colors.grey.shade400,
                                size: 30,
                ),
              );
            },
                        )
                      : Image.asset(
                          history.carImage,
                          width: double.infinity,
                          height: 133,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 133,
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.directions_car,
                                color: Colors.grey.shade400,
                                size: 30,
                              ),
                            );
                },
              ),
            ),
              ),
                             // Heart icon
               Positioned(
                 top: 8,
                 right: 8,
                 child: Builder(
                   builder: (context) => HeartIcon(
                     carId: history.carId,
                     carModel: history.carModel,
                     carImage: history.carImage,
                     carRating: history.carRating,
                     carTrips: history.carTrips,
                     hostName: history.hostName,
                     isAllStarHost: history.carRating >= 4.8,
                     carPrice: 'UK£120/day',
                     carLocation: 'Algiers',
                   ),
            ),
          ),
        ],
      ),
          // Content section - Enhanced design with better spacing
            Padding(
            padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                // Car name (large and bold)
                        Text(
                  history.carModel,
                          style: GoogleFonts.inter(
              fontSize: 18,
                            fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Rating with gold star
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: Color(0xFFFFD700), // Gold star
                    ),
                    const SizedBox(width: 4),
          Text(
                      history.carRating.toStringAsFixed(1),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                        color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                const SizedBox(height: 8),
                // Location with icon
                Row(
                    children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Algiers', // Default location
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                // Price and View Details on same line
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                                         // Price (left side)
                  Expanded(
                       child: Builder(
                         builder: (context) => Text(
                           PriceFormatter.formatWithSettings(context, '120'),
                          style: GoogleFonts.inter(
                             fontSize: 18,
                            fontWeight: FontWeight.bold,
                             color: Colors.black,
                           ),
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                         ),
                       ),
                     ),
                    // View Details with arrow (right side)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                          'View',
                    style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            color: const Color(0xFF353935),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: Color(0xFF353935),
                        ),
                      ],
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
              ],
            ),
                  ),
                ],
                        ),
                      ),
                    ),
);
}

Widget _buildDestinationOption(
  String name,
  IconData icon,
  Color color,
  {
    required bool isSelected,
    required VoidCallback onTap,
    String? imagePath,
  }
) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
                children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
              ),
          child: imagePath != null
              ? Image.asset(
                  imagePath,
                  width: 24,
                  height: 24,
                )
              : Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? color : Colors.black87,
                    ),
                  ),
                ],
    ),
  );
  }


