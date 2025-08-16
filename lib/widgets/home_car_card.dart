import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/car.dart';
import '../car_details_screen.dart';
import 'heart_icon.dart';
import 'save_to_favorites_modal.dart';
import '../services/image_loading_service.dart';
import '../services/transition_service.dart';
import 'overflow_safe_row.dart';
import '../utils/price_formatter.dart';

class HomeCarCard extends StatelessWidget {
  final Car car;
  final double? width;
  final double? height;
  final bool showHeartIcon;
  final VoidCallback? onTap;
  final VoidCallback? onHeartTapped;

  const HomeCarCard({
    super.key,
    required this.car,
    this.width,
    this.height,
    this.showHeartIcon = true,
    this.onTap,
    this.onHeartTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = width ?? screenWidth * 0.375;
    final cardHeight = height ?? screenWidth * 0.8; // Match Home usage height for consistency

    return GestureDetector(
      onTap: onTap ?? () {
        TransitionService.navigateWithTransition(
          context,
          CarDetailsScreen(car: car),
          transitionType: TransitionType.slideFromBottom,
        );
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            // Allow bottom and side shadows to show more clearly
            BoxShadow(
              color: Color(0x33000000), // ~20% black
              blurRadius: 18,
              offset: Offset(0, 10),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Color(0x14000000), // ~8% black
              blurRadius: 6,
              offset: Offset(0, 3),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Hero(
                    tag: 'home_car_${car.id}',
                    child: ImageLoadingService.loadImage(
                      imagePath: car.image.contains('via.placeholder.com') ? '' : car.image,
                      width: double.infinity,
                      height: cardHeight * 0.45, // Increased to 45% for better image proportion
                      fit: BoxFit.cover,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      onLoadComplete: () {
                        // Image loaded successfully
                      },
                      onLoadError: () {
                        // Handle image load error
                      },
                    ),
                  ),
                ),
                // Heart icon
                if (showHeartIcon)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: HeartIcon(
                      carId: car.id,
                      carModel: car.name,
                      carImage: car.image,
                      carRating: car.rating,
                      carTrips: car.trips,
                      hostName: car.hostName,
                      isAllStarHost: car.hostRating >= 4.8,
                      carPrice: car.price,
                      carLocation: car.location,
                      onHeartTapped: onHeartTapped ?? () {
                        _showSaveToFavoritesModal(context);
                      },
                    ),
                  ),
              ],
            ),
            // Content section - Enhanced design with better spacing
            Padding(
              padding: const EdgeInsets.all(16.0), // Increased padding for better breathing room
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car name (large and bold)
                  OverflowSafeText(
                    car.name,
                    style: GoogleFonts.inter(
                      fontSize: 18, // Increased font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 6), // Increased spacing
                  // Rating with gold star
                  OverflowSafeRow(
                    wrapOnOverflow: false,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFFFD700), // Gold star
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: OverflowSafeText(
                          car.rating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // Increased spacing
                  // Use badge + Location
                  Row(
                    children: [
                      _useBadge(car.useType),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: OverflowSafeText(
                          car.location,
                          style: GoogleFonts.inter(
                            fontSize: 12, // Slightly increased
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12), // Added spacing before price section
                  // Price and View Details on same line
            Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price (left side)
                      Expanded(
                        child: OverflowSafeText(
                          PriceFormatter.formatWithSettings(context, car.price),
                          style: GoogleFonts.inter(
                            fontSize: 18, // Increased font size
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      // View Details with arrow (right side)
                      GestureDetector(
                        onTap: onTap ?? () {
                          TransitionService.navigateWithTransition(
                            context,
                            CarDetailsScreen(car: car),
                            transitionType: TransitionType.slideFromBottom,
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Added bottom spacing under price row
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _useBadge(CarUseType useType) {
    String label;
    Color color;
    switch (useType) {
      case CarUseType.business:
        label = 'Business';
        color = const Color(0xFF0EA5E9);
        break;
      case CarUseType.event:
        label = 'Events';
        color = const Color(0xFFF59E0B);
        break;
      case CarUseType.daily:
      default:
        label = 'Daily';
        color = const Color(0xFF22C55E);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  void _showSaveToFavoritesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaveToFavoritesModal(
        carId: car.id,
        carModel: car.name,
        carImage: car.image,
        carRating: car.rating,
        carTrips: car.trips,
        hostName: car.hostName,
        isAllStarHost: car.hostRating >= 4.8,
        carPrice: car.price,
        carLocation: car.location,
      ),
    );
  }
}