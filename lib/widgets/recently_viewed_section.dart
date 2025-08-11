import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/car.dart';
import '../models/view_history.dart';
import '../car_details_screen.dart';
import '../services/view_history_service.dart';
import 'save_to_favorites_modal.dart';
import 'home_car_card.dart';
import '../search_screen.dart'; // Added import for SearchScreen

class RecentlyViewedSection extends StatefulWidget {
  final String userId;

  const RecentlyViewedSection({
    super.key,
    required this.userId,
  });

  @override
  State<RecentlyViewedSection> createState() => _RecentlyViewedSectionState();
}

class _RecentlyViewedSectionState extends State<RecentlyViewedSection> {
  List<ViewHistory> _recentHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentHistory();
  }

  Future<void> _loadRecentHistory() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      final history = await ViewHistoryService.getRecentViewHistory(widget.userId);
      
      if (!mounted) return;
      setState(() {
        _recentHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSaveToFavoritesModal(ViewHistory historyItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaveToFavoritesModal(
        carId: historyItem.carId,
        carModel: historyItem.carModel,
        carImage: historyItem.carImage,
        carRating: historyItem.carRating,
        carTrips: historyItem.carTrips,
        hostName: historyItem.hostName,
        isAllStarHost: historyItem.isAllStarHost,
        carPrice: '\$0/day', // Default price for recently viewed
        carLocation: 'Location', // Default location for recently viewed
      ),
    );
  }

  void _navigateToCarDetails(ViewHistory historyItem) {
    // Create a Car object from ViewHistory for navigation
    final car = Car(
      id: historyItem.carId,
      name: historyItem.carModel,
      image: historyItem.carImage,
      price: '\$0/day', // You might want to store price in ViewHistory
      category: 'Car',
      rating: historyItem.carRating,
      trips: historyItem.carTrips,
      location: 'Location', // You might want to store location in ViewHistory
      hostName: historyItem.hostName,
      hostImage: 'assets/images/host.jpg',
      hostRating: historyItem.isAllStarHost ? 4.9 : 4.5,
      responseTime: '1 hour',
      description: 'Car details from recently viewed.',
      features: ['GPS Navigation', 'Bluetooth Audio', 'Leather Seats'],
      images: [historyItem.carImage],
      specs: {
        'engine': '2.0L',
        'transmission': 'Automatic',
        'fuel': 'Petrol',
        'seats': '5',
      },
    );

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CarDetailsScreen(car: car),
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
  }

  @override
  Widget build(BuildContext context) {
    // Only show the entire section if there are cars or if loading
    if (_isLoading || _recentHistory.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title with "View all" button - matching "Discover our cars" styling
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recently viewed',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          // Recently viewed cars list
          else
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.5, // Reduced height to match card height
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _recentHistory.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final historyItem = _recentHistory[index];
                  return _buildRecentlyViewedCard(historyItem);
                },
              ),
            ),
        ],
      );
    } else {
      // Return empty container when no recent history
      return const SizedBox.shrink();
    }
  }

  Widget _buildRecentlyViewedCard(ViewHistory historyItem) {
    // Create Car object from ViewHistory
    final car = Car(
      id: historyItem.carId,
      name: historyItem.carModel,
      image: historyItem.carImage,
      price: '\$0/day', // Default price for recently viewed
      category: 'Car',
      rating: historyItem.carRating,
      trips: historyItem.carTrips,
      location: 'Location', // Default location for recently viewed
      hostName: historyItem.hostName,
      hostImage: 'assets/images/host.jpg',
      hostRating: historyItem.isAllStarHost ? 4.9 : 4.5,
      responseTime: '1 hour',
      description: 'Car details from recently viewed.',
      features: ['GPS Navigation', 'Bluetooth Audio', 'Leather Seats'],
      images: [historyItem.carImage],
      specs: {
        'engine': '2.0L',
        'transmission': 'Automatic',
        'fuel': 'Petrol',
        'seats': '5',
      },
    );

    return HomeCarCard(
      car: car,
      onTap: () => _navigateToCarDetails(historyItem),
      onHeartTapped: () => _showSaveToFavoritesModal(historyItem),
    );
  }
}