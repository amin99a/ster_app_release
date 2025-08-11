import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'more_screen.dart';
import 'search_screen.dart';
import 'car_details_screen.dart';
import 'models/car.dart';
import 'widgets/recently_viewed_section.dart';
import 'constants.dart';
import 'saved_screen.dart';
import 'services/heart_refresh_service.dart';
import 'widgets/animated_widgets.dart';
import 'widgets/save_to_favorites_modal.dart';
import 'widgets/home_car_card.dart';
import 'featured_car_square.dart';
import 'notification_screen.dart';
import 'services/auth_service.dart';
import 'services/car_service.dart';
import 'guards/email_verification_guard.dart';
import 'widgets/distance_selection_dialog.dart';
import 'screens/nearby_cars_map_screen.dart';
import 'widgets/search_filter_chip.dart';
import 'services/host_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _selectedDestination;
  String? selectedDestination; // Add destination selection
  bool _isLoadingTopHosts = false;
  List<TopHost> _topHosts = [];

  void _onItemTapped(int index) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    final isGuest = user?.isGuest == true;

    // Prevent guest users from accessing restricted tabs
    if (isGuest && (index == 2 || index == 3)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign up to access this feature'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
      // Clear selected destination when navigating away from search
      if (index != 1) {
        _selectedDestination = null;
      }
    });
  }

  void _navigateToSearch() {
    setState(() {
      _selectedIndex = 1; // Switch to Search tab
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
      SearchScreen(preSelectedWilaya: _selectedDestination),
      if (!isGuest) const SavedScreen(),
      if (!isGuest) const MoreScreen(),
    ];

    // Role-based navigation items
    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: 'Search',
      ),
      if (!isGuest) const BottomNavigationBarItem(
        icon: Icon(Icons.favorite),
        label: 'Saved',
      ),
      if (!isGuest) const BottomNavigationBarItem(
        icon: Icon(Icons.more_horiz),
        label: 'More',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
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
                color: const Color(0xFF353935),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Home tab
                  _buildNavItem(
                    icon: Icons.home,
                    label: 'Home',
                    index: 0,
                    isSelected: _selectedIndex == 0,
                  ),
                  
                  // Search tab
                  _buildNavItem(
                    icon: Icons.search,
                    label: 'Search',
                    index: 1,
                    isSelected: _selectedIndex == 1,
                  ),
                  
                  // Saved tab (only for authenticated users)
                  if (!isGuest) _buildNavItem(
                    icon: Icons.favorite,
                    label: 'Saved',
                    index: 2,
                    isSelected: _selectedIndex == 2,
                  ),
                  
                  // More tab (only for authenticated users)
                  if (!isGuest) _buildNavItem(
                    icon: Icons.more_horiz,
                    label: 'More',
                    index: 3,
                    isSelected: _selectedIndex == 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Optimized padding to fit icons better
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          children: [
            Container(
              width: 28, // Optimized size to fit better
              height: 28, // Optimized size to fit better
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(14), // Optimized for better fit
                boxShadow: isSelected ? [
                  // Primary shadow for selected state
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                  // Secondary shadow for depth
            BoxShadow(
                    color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
                    offset: const Offset(0, 4),
              spreadRadius: 0,
                  ),
                ] : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF353935) : Colors.white,
                size: 16, // Optimized size to fit better
              ),
            ),
            const SizedBox(height: 3), // Optimized spacing to fit better
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 9, // Optimized size to fit better
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
  String selectedCategory = 'All';
  String? selectedDestination; // Add destination selection
  List<Car> _cars = [];
  List<Car> _featuredCars = [];
  List<TopHost> _topHosts = [];
  bool _isLoading = true;
  bool _isLoadingFeatured = true;
  bool _isLoadingTopHosts = true;
  bool _showWelcomeBanner = true; // Show welcome banner for new users
  final TextEditingController _searchController = TextEditingController();

  List<String> categories = ['All', 'SUV', 'Luxury', 'Electric', 'Convertible', 'Business', 'Sport', 'Mini'];

  @override
  void initState() {
    super.initState();
    _loadCars();
    _loadFeaturedCars();
    _loadTopHosts();
    _checkIfNewUser();
  }

  Future<void> _checkIfNewUser() async {
    // Check if user just signed up (you can add logic here to determine if it's a new user)
    // For now, we'll show the banner for a few seconds
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      setState(() {
        _showWelcomeBanner = false;
      });
    }
  }

  Future<void> _loadCars() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final carService = Provider.of<CarService>(context, listen: false);
      final cars = await carService.getCars();
      setState(() {
        _cars = cars ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading cars: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to load cars. Please try again.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _loadCars(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadFeaturedCars() async {
    setState(() {
      _isLoadingFeatured = true;
    });
    
    try {
      final carService = Provider.of<CarService>(context, listen: false);
      final featuredCars = await carService.getFeaturedCars();
      setState(() {
        _featuredCars = featuredCars ?? [];
        _isLoadingFeatured = false;
      });
    } catch (e) {
      print('Error loading featured cars: $e');
      setState(() {
        _isLoadingFeatured = false;
      });
      
      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to load featured cars.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _loadTopHosts() async {
    setState(() {
      _isLoadingTopHosts = true;
    });
    
    try {
      final topHosts = await HostService.getTopHosts(limit: 4);
      setState(() {
        _topHosts = topHosts;
        _isLoadingTopHosts = false;
      });
    } catch (e) {
      print('Error loading top hosts: $e');
      setState(() {
        _isLoadingTopHosts = false;
      });
      
      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to load top hosts.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  List<Car> get filteredCars {
    List<Car> filtered = _cars;
    
    // Filter by category
    if (selectedCategory != 'All') {
      filtered = filtered.where((car) => car.category == selectedCategory).toList();
    }
    
    // Filter by destination (if selected)
    if (selectedDestination != null && selectedDestination != 'Near by') {
      filtered = filtered.where((car) {
        // This is a placeholder - you'll need to implement actual destination filtering
        // based on your Car model structure and API response
        return car.location?.toLowerCase().contains(selectedDestination!.toLowerCase()) ?? false;
      }).toList();
    }
    
    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    try {
    // Navigate to search screen with the search query
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          preSelectedWilaya: null,
        ),
      ),
    );
    } catch (e) {
      print('Error performing search: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to perform search. Please try again.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _onDestinationSelected(String destination) {
    try {
      if (destination == 'Near by') {
        _showDistanceSelectionDialog();
      } else {
        _showComingSoonMessage(destination);
      }
    } catch (e) {
      print('Error selecting destination: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select destination. Please try again.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _showComingSoonMessage(String destination) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$destination - Coming Soon!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF353935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        elevation: 8,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
    } catch (e) {
      print('Error showing coming soon message: $e');
    }
  }

  void _showDistanceSelectionDialog() {
    try {
      showDialog(
        context: context,
        builder: (context) => DistanceSelectionDialog(
          onDistanceSelected: (distance) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NearbyCarsMapScreen(
                  searchRadius: distance,
                ),
              ),
            );
          },
        ),
      );
    } catch (e) {
      print('Error showing distance selection dialog: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open distance selection. Please try again.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  Widget _buildDestinationOption(
    String name,
    IconData icon,
    Color color,
    {
      required bool isSelected,
      required VoidCallback onTap,
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
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildFlagWidget(name),
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

  Widget _buildFlagWidget(String countryName) {
    switch (countryName) {
      case 'Near by':
        return Image.asset(
          'assets/images/near_by.png',
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade100,
                    Colors.blue.shade200,
                  ],
                ),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.blue,
                size: 24,
              ),
            );
          },
        );
      
      case 'Algeria':
        return Image.asset(
          'assets/images/algeria.png',
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF006C54), // Algerian green
                    Colors.white,
                  ],
                  stops: [0.5, 0.5],
                ),
              ),
              child: Stack(
                children: [
                  // Red crescent
                  Positioned(
                    left: 8,
                    top: 12,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  // Red star
                  Positioned(
                    right: 8,
                    top: 12,
                    child: Icon(
                      Icons.star,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      
      case 'Tunisia':
        return Image.asset(
          'assets/images/tunisia.png',
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFE70013), // Tunisian red
              ),
              child: Stack(
                children: [
                  // White circle
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Red crescent in white circle
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  // Red star in white circle
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Icon(
                      Icons.star,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      
      case 'Morocco':
        return Image.asset(
          'assets/images/maroco.png',
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFC1272D), // Moroccan red
              ),
              child: Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF006C54), // Green star
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      
      case 'Egypt':
        return Image.asset(
          'assets/images/egypt.png',
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFCE1126), // Egyptian red
                    Colors.white,
                    Color(0xFF000000), // Black
                  ],
                  stops: [0.0, 0.33, 0.66],
                ),
              ),
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4AF37), // Gold eagle
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      
      case 'France':
        return Image.asset(
          'assets/images/france.png',
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF002395), // French blue
                    Colors.white,
                    Color(0xFFED2939), // French red
                  ],
                  stops: [0.0, 0.33, 0.66],
                ),
              ),
            );
          },
        );
      
      default:
        return Icon(
          Icons.flag,
          color: Colors.grey.shade600,
          size: 24,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = screenWidth * 0.88; // 88% of screen width

        return RefreshIndicator(
          onRefresh: () async {
            try {
              await HeartRefreshService().refreshAllHeartStates();
              await _loadCars();
              await _loadFeaturedCars();
            } catch (e) {
              print('Error refreshing data: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to refresh data. Please try again.'),
                  backgroundColor: Colors.red.shade600,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - 100, // Account for bottom nav
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Floating dark header section matching the image design
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF353935), // Onyx color from the image
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          // Primary shadow - closest to the surface
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                          // Secondary shadow - medium depth
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                          // Tertiary shadow - deepest layer
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 50,
                            offset: const Offset(0, 16),
                            spreadRadius: 0,
                          ),
                          // Ambient shadow - subtle overall depth
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 80,
                            offset: const Offset(0, 25),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            // STER logo text (large and bold) - increased by 75%
                            const Padding(
                              padding: EdgeInsets.only(left: 15),
                              child: Text(
                                'ster',
                                style: TextStyle(
                                  fontSize: 42, // Increased from 24 by 75%
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15), // 15px spacing before "find the perfect car"
                            // "Find the perfect car" text (smaller)
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
                            // Notification bell (only for non-guest users)
                            if (user?.isGuest != true)
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: GestureDetector(
                                  onTap: () {
                                    try {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const NotificationScreen(),
                                        ),
                                      );
                                    } catch (e) {
                                      print('Error navigating to notifications: $e');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to open notifications. Please try again.'),
                                          backgroundColor: Colors.red.shade600,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Browse by destination section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Browse by destination',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Destination options
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildDestinationOption(
                                'Near by',
                                Icons.location_on,
                                Colors.blue,
                                isSelected: selectedDestination == 'Near by',
                                onTap: () => _onDestinationSelected('Near by'),
                              ),
                              const SizedBox(width: 16),
                              _buildDestinationOption(
                                'Algeria',
                                Icons.flag,
                                const Color(0xFF006C54), // Algerian green
                                isSelected: selectedDestination == 'Algeria',
                                onTap: () => _onDestinationSelected('Algeria'),
                              ),
                              const SizedBox(width: 16),
                              _buildDestinationOption(
                                'Tunisia',
                                Icons.flag,
                                const Color(0xFFE70013), // Tunisian red
                                isSelected: selectedDestination == 'Tunisia',
                                onTap: () => _onDestinationSelected('Tunisia'),
                              ),
                              const SizedBox(width: 16),
                              _buildDestinationOption(
                                'Morocco',
                                Icons.flag,
                                const Color(0xFFC1272D), // Moroccan red
                                isSelected: selectedDestination == 'Morocco',
                                onTap: () => _onDestinationSelected('Morocco'),
                              ),
                              const SizedBox(width: 16),
                              _buildDestinationOption(
                                'Egypt',
                                Icons.flag,
                                const Color(0xFFCE1126), // Egyptian red
                                isSelected: selectedDestination == 'Egypt',
                                onTap: () => _onDestinationSelected('Egypt'),
                              ),
                              const SizedBox(width: 16),
                              _buildDestinationOption(
                                'France',
                                Icons.flag,
                                const Color(0xFF002395), // French blue
                                isSelected: selectedDestination == 'France',
                                onTap: () => _onDestinationSelected('France'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Host Cards Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Top Hosts',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                try {
                                  // Navigate to all hosts screen
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const SearchScreen(
                                        preSelectedWilaya: null,
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  print('Error navigating to hosts screen: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to open hosts screen. Please try again.'),
                                      backgroundColor: Colors.red.shade600,
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF353935),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF353935).withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF353935).withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF353935).withOpacity(0.1),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
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
                        const SizedBox(height: 14),
                        
                        // Host cards
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
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        ..._topHosts.map((host) => Padding(
                                          padding: const EdgeInsets.only(right: 20),
                                          child: _buildHostCard(
                                            host.name,
                                            host.hostType,
                                            host.coverImage ?? 'assets/images/featured.jpg',
                                            host.profileImage ?? 'assets/images/host.png',
                                            host.rating,
                                            host.trips,
                                            host.location,
                                            carsCount: host.carsCount,
                                          ),
                                        )).toList(),
                                      ],
                                    ),
                                  ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  SizedBox(height: screenHeight * 0.02),

                  // Recently Viewed Section
                  const RecentlyViewedSection(
                    userId: AppConstants.defaultUserId,
                  ),

                  // Add proper spacing between sections
                  const SizedBox(height: 20),

                  // Categories Section
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
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                try {
                                  // Navigate to search tab instead of pushing new route
                                  widget.onTabChanged?.call(1); // Switch to search tab (index 1)
                                } catch (e) {
                                  print('Error navigating to search tab: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to switch to search tab. Please try again.'),
                                      backgroundColor: Colors.red.shade600,
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF353935),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF353935).withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF353935).withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF353935).withOpacity(0.1),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
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
                        const SizedBox(height: 14),
                        
                        // Categories grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                          children: [
                            _buildCategoryCard(
                              'Sedan',
                              Icons.directions_car,
                              Colors.blue,
                              () => _navigateToCategory('Sedan'),
                            ),
                            _buildCategoryCard(
                              'SUV',
                              Icons.local_shipping,
                              Colors.green,
                              () => _navigateToCategory('SUV'),
                            ),
                            _buildCategoryCard(
                              'Sports',
                              Icons.sports_motorsports,
                              Colors.red,
                              () => _navigateToCategory('Sports'),
                            ),
                            _buildCategoryCard(
                              'Luxury',
                              Icons.diamond,
                              Colors.purple,
                              () => _navigateToCategory('Luxury'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSaveToFavoritesModal(BuildContext context, String carName, String carImage) {
    try {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaveToFavoritesModal(
        carId: 'home_${carName.hashCode}',
        carModel: carName,
        carImage: carImage,
        carRating: 4.97,
        carTrips: 81,
        hostName: 'Sarah Johnson',
        isAllStarHost: true,
        carPrice: '\$98/day',
        carLocation: 'London, UK',
      ),
    );
    } catch (e) {
      print('Error showing save to favorites modal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open favorites modal. Please try again.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _showAdvancedFilters(BuildContext context) {
    try {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAdvancedFiltersModal(context),
    );
    } catch (e) {
      print('Error showing advanced filters modal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open advanced filters. Please try again.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  Widget _buildAdvancedFiltersModal(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Advanced Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildFilterSection('Price Range', [
                  SearchFilterChip(
                    label: 'Under \$50', 
                    isSelected: false,
                    onTap: () {},
                  ),
                  SearchFilterChip(
                    label: '\$50-\$100', 
                    isSelected: true,
                    onTap: () {},
                  ),
                  SearchFilterChip(
                    label: '\$100-\$200', 
                    isSelected: false,
                    onTap: () {},
                  ),
                  SearchFilterChip(
                    label: 'Over \$200', 
                    isSelected: false,
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 20),
                _buildFilterSection('Car Type', [
                  SearchFilterChip(
                    label: 'Sedan', 
                    isSelected: false,
                    onTap: () {},
                  ),
                  SearchFilterChip(
                    label: 'SUV', 
                    isSelected: true,
                    onTap: () {},
                  ),
                  SearchFilterChip(
                    label: 'Sports', 
                    isSelected: false,
                    onTap: () {},
                  ),
                  SearchFilterChip(
                    label: 'Luxury', 
                    isSelected: false,
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 20),
                _buildFilterSection('Transmission', [
                  SearchFilterChip(
                    label: 'Automatic', 
                    isSelected: true,
                    onTap: () {},
                  ),
                  SearchFilterChip(
                    label: 'Manual', 
                    isSelected: false,
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 20),
                _buildFilterSection('Fuel Type', [
                  SearchFilterChip(
                    label: 'Gasoline', 
                    isSelected: true,
                    onTap: () {},
                  ),
                  SearchFilterChip(
                    label: 'Diesel', 
                    isSelected: false,
                    onTap: () {},
                  ),
                  SearchFilterChip(
                    label: 'Electric', 
                    isSelected: false,
                    onTap: () {},
                  ),
                  SearchFilterChip(
                    label: 'Hybrid', 
                    isSelected: false,
                    onTap: () {},
                  ),
                ]),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showMessageDialog(context, 'Filters applied successfully!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF353935),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        ),
      ],
    );
  }

  void _showMessageDialog(BuildContext context, String message) {
    try {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    } catch (e) {
      print('Error showing message dialog: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to show message. Please try again.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _startVoiceSearch() {
    try {
    // TODO: Implement voice search
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice search coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
    } catch (e) {
      print('Error starting voice search: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start voice search. Please try again.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _navigateToCarDetails(String name, String imagePath, String price) {
    try {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => CarDetailsScreen(
              car: Car(
                id: 'home_${name.hashCode}',
                name: name,
                image: imagePath,
                price: price,
                category: 'Luxury',
                rating: 4.97,
                trips: 81,
                location: 'London, UK',
                hostName: 'Sarah Johnson',
                hostImage: 'assets/images/host.jpg',
                hostRating: 4.9,
                responseTime: '1 hour',
                description: 'Premium luxury car with excellent features and comfort.',
                features: ['GPS Navigation', 'Bluetooth Audio', 'Leather Seats', 'Climate Control'],
                images: [imagePath],
                specs: {
                  'engine': '2.0L Turbo',
                  'transmission': 'Automatic',
                  'fuel': 'Petrol',
                  'seats': '5',
                },
              ),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    } catch (e) {
      print('Error navigating to car details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open car details. Please try again.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  Widget _buildHostCard(
    String hostName,
    String hostType,
    String coverImage,
    String logoImage,
    double rating,
    int trips,
    String location,
    {int carsCount = 5,} // Make cars count dynamic
  ) {
    return GestureDetector(
      onTap: () {
        try {
          _showHostProfileModal(context, hostName, hostType, coverImage, logoImage, rating, trips, location);
        } catch (e) {
          print('Error tapping host card: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open host profile. Please try again.'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width > 400 ? 275 : 250, // Responsive width
        height: 280, // Fixed height for consistent layout
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, 16),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Cover image section (40% of card height)
            Container(
              height: 112, // 40% of 280
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.grey.shade200,
              ),
              child: Stack(
                children: [
                  // Cover image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: coverImage.startsWith('http')
                        ? Image.network(
                            coverImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey.shade400,
                                  size: 40,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            coverImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey.shade400,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                  ),
                  // Centered round logo
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: logoImage.startsWith('http')
                              ? Image.network(
                                  logoImage,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 44,
                                      height: 44,
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey.shade400,
                                        size: 20,
                                      ),
                                    );
                                  },
                                )
                              : Image.asset(
                                  logoImage,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 44,
                                      height: 44,
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey.shade400,
                                        size: 20,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Information section (60% of card height)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Host name with verified badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hostName,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF353935),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Rating
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${trips} reviews)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Cars available
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: Colors.blue,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$carsCount cars available',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Location and View Cars button row
                    Row(
                      children: [
                        // Location
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.grey.shade600,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                location,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // View Cars button (aligned to the right)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              // Primary shadow - closest to the surface
                              BoxShadow(
                                color: const Color(0xFF353935).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                                spreadRadius: 0,
                              ),
                              // Secondary shadow - medium depth
                              BoxShadow(
                                color: const Color(0xFF353935).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                                spreadRadius: 0,
                              ),
                              // Tertiary shadow - deepest layer
                              BoxShadow(
                                color: const Color(0xFF353935).withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                                                      child: ElevatedButton(
                              onPressed: () {
                                try {
                                  _showHostProfileModal(context, hostName, hostType, coverImage, logoImage, rating, trips, location);
                                } catch (e) {
                                  print('Error pressing view cars button: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to open host profile. Please try again.'),
                                      backgroundColor: Colors.red.shade600,
                                    ),
                                  );
                                }
                              },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF353935),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0, // Remove default elevation since we're using custom shadows
                            ),
                            child: Text(
                              'View Cars',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
    );
  }

  Color _getHostTypeColor(String hostType) {
    switch (hostType.toLowerCase()) {
      case 'premium host':
        return const Color(0xFF353935);
      case 'super host':
        return const Color(0xFF353935);
      case 'verified host':
        return const Color(0xFF353935);
      default:
        return const Color(0xFF353935);
    }
  }

  void _showNotificationDialog(BuildContext context, String hostName) {
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
        title: Text('Notifications for ${hostName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications_active, color: Colors.blue),
              title: const Text('New Car Available'),
              subtitle: const Text('Get notified when this host adds new cars'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Toggle notification setting
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.local_offer, color: Colors.orange),
              title: const Text('Special Offers'),
              subtitle: const Text('Receive notifications about discounts'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // Toggle notification setting
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: Colors.green),
              title: const Text('Availability Updates'),
              subtitle: const Text('Know when cars become available'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Toggle notification setting
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notification settings updated for ${hostName}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    } catch (e) {
      print('Error showing notification dialog: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open notification dialog. Please try again.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showHostProfileModal(BuildContext context, String hostName, String hostType, String coverImage, String profileImage, double rating, int trips, String location) {
    try {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header with cover image
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                image: DecorationImage(
                  image: AssetImage(coverImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(profileImage),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hostName,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              hostType,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating and stats
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildStatCard('Trips', '${trips}', Icons.local_shipping_outlined, Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard('Cars', '5', Icons.directions_car_outlined, Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Location
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            location,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Navigate to host's cars
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF353935),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'View Cars',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showMessageDialog(context, hostName);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: BorderSide(color: Colors.blue.shade300),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Message',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
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
      ),
    );
    } catch (e) {
      print('Error showing host profile modal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open host profile. Please try again.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }


}
