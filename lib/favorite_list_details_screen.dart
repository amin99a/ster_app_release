import 'package:flutter/material.dart';
import 'models/favorite_list.dart';
import 'models/favorite_item.dart';
import 'models/car.dart';
import 'services/favorite_service.dart';
import 'car_details_screen.dart';
import 'constants.dart';
import 'services/heart_state_service.dart';
import 'services/heart_refresh_service.dart';
import 'widgets/floating_header.dart';

class FavoriteListDetailsScreen extends StatefulWidget {
  final FavoriteList favoriteList;

  const FavoriteListDetailsScreen({
    super.key,
    required this.favoriteList,
  });

  @override
  State<FavoriteListDetailsScreen> createState() => _FavoriteListDetailsScreenState();
}

class _FavoriteListDetailsScreenState extends State<FavoriteListDetailsScreen> {
  List<FavoriteItem> _favoriteItems = [];
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteItems();
  }

  Future<void> _loadFavoriteItems() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final items = await FavoriteService.getListItems(widget.favoriteList.id);
      
      setState(() {
        _favoriteItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favorite items: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeCarFromList(FavoriteItem item) async {
    try {
      await FavoriteService.removeFromFavorites(item.id, widget.favoriteList.id, AppConstants.defaultUserId);
      
      // Update heart state to reflect that car is no longer saved
      await HeartStateService.updateHeartState(item.carId, false);
      
      // Trigger heart refresh across the app
      HeartRefreshService().refreshHeartState(item.carId);
      
      // Refresh the list
      await _loadFavoriteItems();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.carModel} removed from ${widget.favoriteList.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Implement undo functionality
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error removing car from list: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove car from list'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _deleteEntireList() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: Text(
          'Are you sure you want to delete "${widget.favoriteList.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      setState(() {
        _isDeleting = true;
      });

      // Delete all items in the list first
      for (final item in _favoriteItems) {
        await FavoriteService.removeFromFavorites(item.id, widget.favoriteList.id, AppConstants.defaultUserId);
      }

      // Delete the list itself
      await FavoriteService.deleteFavoriteList(widget.favoriteList.id, AppConstants.defaultUserId);

      if (mounted) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.favoriteList.name} deleted successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate back to saved screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error deleting list: $e');
      setState(() {
        _isDeleting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete list'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToCarDetails(FavoriteItem item) {
    // Create a Car object from FavoriteItem for navigation
    final car = Car(
      id: item.carId,
      name: item.carModel,
      image: item.carImage,
      price: item.carPrice ?? 'Price not available',
      category: 'Luxury', // Default category
      rating: item.carRating,
      trips: item.carTrips,
      location: item.carLocation ?? 'Location not available',
      hostName: item.hostName,
      hostImage: 'assets/images/host.jpg', // Default host image
      hostRating: item.isAllStarHost ? 4.9 : 4.5,
      responseTime: '1 hour',
      description: 'Car from your favorites list.',
      features: ['GPS Navigation', 'Bluetooth Audio', 'Leather Seats'],
      images: [item.carImage],
      specs: {
        'engine': '2.0L Turbo',
        'transmission': 'Automatic',
        'fuel': 'Petrol',
        'seats': '5',
      },
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CarDetailsScreen(car: car),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isDeleting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Deleting list...'),
                ],
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _favoriteItems.isEmpty
                  ? _buildEmptyState()
                  : _buildCarList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No cars in this list',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding cars to ${widget.favoriteList.name}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarList() {
    return Column(
      children: [
        // Floating 3D Header
        FloatingHeader(
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.favoriteList.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              if (_favoriteItems.isNotEmpty)
                GestureDetector(
                  onTap: () => _deleteEntireList(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Car list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _favoriteItems.length,
            itemBuilder: (context, index) {
              final item = _favoriteItems[index];
              return _buildCarCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarCard(FavoriteItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with remove button
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: GestureDetector(
                  onTap: () => _navigateToCarDetails(item),
                  child: Hero(
                    tag: 'favorite_car_${item.carId}',
                    child: (item.carImage.startsWith('http') || item.carImage.startsWith('https'))
                        ? Image.network(
                            item.carImage,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          )
                        : Image.asset(
                            item.carImage,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          ),
                  ),
                ),
              ),
              // Remove button
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => _removeCarFromList(item),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                        spreadRadius: 0,
                      ),
                    ],
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Content section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car name
                Text(
                  item.carModel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Rating and trips
                Row(
                  children: [
                    Text(
                      item.carRating.toString(),
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
                      color: Color(0xFF353935), // Updated to Onyx
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${item.carTrips} trips)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Host info
                Row(
                  children: [
                    Text(
                      item.hostName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    if (item.isAllStarHost) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF353935).withOpacity(0.1), // Updated to Onyx
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'All-Star Host',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF353935), // Updated to Onyx
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                
                // Price and location
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.carPrice ?? 'Price not available',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      item.carLocation ?? 'Location not available',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 