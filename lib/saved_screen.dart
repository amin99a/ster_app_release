import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'models/favorite_list.dart';
import 'models/view_history.dart';
import 'services/favorite_service.dart';
import 'services/view_history_service.dart';
import 'widgets/favorite_list_card.dart';
import 'search_screen.dart';
import 'constants.dart';
import 'favorite_list_details_screen.dart';
import 'services/heart_refresh_service.dart';
import 'screens/notifications_screen.dart';
import 'services/notification_service.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'login_screen.dart';
import 'widgets/floating_header.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<FavoriteList> _favoriteLists = [];
  List<ViewHistory> _recentHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Ensure notification service is initialized to drive unread badge
    try {
      final notificationService = context.read<NotificationService>();
      if (!notificationService.isInitialized) {
        notificationService.initialize();
      }
    } catch (_) {}
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load favorite lists and recent history in parallel
      final results = await Future.wait([
        FavoriteService.getUserFavoriteLists(AppConstants.defaultUserId),
        ViewHistoryService.getRecentViewHistory(AppConstants.defaultUserId),
      ]);

      setState(() {
        _favoriteLists = results[0] as List<FavoriteList>;
        _recentHistory = results[1] as List<ViewHistory>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading saved screen data: $e');
    }
  }

  void _navigateToSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  Widget _buildGuestContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Add top padding for guest users
          SizedBox(height: MediaQuery.of(context).padding.top + 14),
          
          // Login Card for Guest Users
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF353935), Color(0xFF353935)], // Updated to Onyx
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.login,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sign In to Access Your Favorites',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Features list
                  Column(
                    children: [
                      _buildFeatureItem(Icons.favorite, 'Save Favorite Cars'),
                      const SizedBox(height: 8),
                      _buildFeatureItem(Icons.history, 'View Recent Searches'),
                      const SizedBox(height: 8),
                      _buildFeatureItem(Icons.bookmark, 'Create Collections'),
                      const SizedBox(height: 8),
                      _buildFeatureItem(Icons.share, 'Share Your Lists'),
                      const SizedBox(height: 8),
                      _buildFeatureItem(Icons.sync, 'Sync Across Devices'),
                      const SizedBox(height: 8),
                      _buildFeatureItem(Icons.notifications, 'Get Price Alerts'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF353935), // Updated to Onyx
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Sign In Now',
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
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        
        return Scaffold(
          backgroundColor: Colors.white,
          body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(user),
        );
      },
    );
  }

  Widget _buildContent(user) {
    // For guest users, show sign-in card
    if (user?.isGuest == true) {
      return _buildGuestContent();
    }
    
    if (_favoriteLists.isEmpty) {
      return _buildEmptyState(user);
    } else {
      return _buildFavoritesContent();
    }
  }

  Widget _buildEmptyState(user) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadData();
        await HeartRefreshService().refreshAllHeartStates();
      },
      child: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Floating 3D Header
          FloatingHeader(
            child: Row(
              children: [
                // Favorites title on the left
                Text(
                  'Saved',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                  // Notification icon on the right (only for non-guest users)
                  if (user?.isGuest != true)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
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
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Title under header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Personal Collection',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Get started section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Get started with favorites',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the heart icon to save your favorite vehicles to a list.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Search bar
                GestureDetector(
                  onTap: _navigateToSearch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.search,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Find new favorites',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Recently viewed section (if any)
          if (_recentHistory.isNotEmpty) ...[
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recently viewed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recentHistory.length,
                      itemBuilder: (context, index) {
                        final historyItem = _recentHistory[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: SizedBox(
                            width: 200,
                            child: _buildRecentlyViewedCard(historyItem),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
      ),
    );
  }

  Widget _buildFavoritesContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadData();
        await HeartRefreshService().refreshAllHeartStates();
      },
      child: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // Floating 3D Header
           FloatingHeader(
             child: Row(
               children: [
                 // Favorites title on the left
                 Text(
                   'Saved',
                   style: GoogleFonts.inter(
                     fontSize: 20,
                     fontWeight: FontWeight.w700,
                     color: Colors.white,
                   ),
                 ),
                 const Spacer(),
                 // Notification icon on the right with unread badge
                 GestureDetector(
                   onTap: () {
                     Navigator.of(context).push(
                       MaterialPageRoute(
                         builder: (context) => const NotificationsScreen(),
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
               ],
             ),
           ),

           const SizedBox(height: 30),

           // Title under header
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 20),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(
                   'Your Personal Collection',
                   style: GoogleFonts.inter(
                     fontSize: 16,
                     fontWeight: FontWeight.bold,
                     color: Colors.black,
                   ),
                 ),
               ],
             ),
           ),

          // Favorite lists grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _favoriteLists.length,
              itemBuilder: (context, index) {
                final list = _favoriteLists[index];
                return FavoriteListCard(
                  favoriteList: list,
                  onTap: () {
                    // Navigate to list details
                    _navigateToListDetails(list);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
      ),
    );
  }

  Widget _buildRecentlyViewedCard(ViewHistory historyItem) {
    return GestureDetector(
      onTap: () {
        // Navigate to car details
        _navigateToCarDetails(historyItem);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: (historyItem.carImage.startsWith('http') || historyItem.carImage.startsWith('https'))
                        ? Image.network(
                            historyItem.carImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.car_rental,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            historyItem.carImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.car_rental,
                                  size: 50,
                                  color: Colors.grey,
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
                  child: GestureDetector(
                    onTap: () {
                      // Show save to favorites modal
                      _showSaveToFavoritesModal(historyItem);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.heart,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Car details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car name
                  Text(
                    historyItem.carModel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Rating and host info
                  Row(
                    children: [
                      Text(
                        historyItem.carRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xFF593CFB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${historyItem.carTrips} trip${historyItem.carTrips != 1 ? 's' : ''})',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // All-Star Host badge
                  if (historyItem.isAllStarHost)
                    const Row(
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          size: 16,
                          color: Color(0xFF593CFB),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'All-Star Host',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF593CFB),
                          ),
                        ),
                      ],
                    ),

                  const Spacer(),

                  // View details button
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'View details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToListDetails(FavoriteList list) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FavoriteListDetailsScreen(favoriteList: list),
      ),
    );
  }

  void _navigateToCarDetails(ViewHistory historyItem) {
    // TODO: Navigate to car details screen
    print('Navigate to car: ${historyItem.carModel}');
  }

  void _showSaveToFavoritesModal(ViewHistory historyItem) {
    // TODO: Show save to favorites modal
    print('Show save to favorites modal for: ${historyItem.carModel}');
  }
} 