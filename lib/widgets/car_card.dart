import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/car.dart';
import '../car_details_screen.dart';
import '../constants.dart';
import 'heart_icon.dart';
import 'save_to_favorites_modal.dart';
import 'overflow_safe_row.dart';
import '../utils/price_formatter.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final double? width;
  final double? height;
  final bool showHeartIcon;
  final bool showViewDetails;
  final VoidCallback? onTap;
  final VoidCallback? onHeartTapped;

  const CarCard({
    super.key,
    required this.car,
    this.width,
    this.height,
    this.showHeartIcon = true,
    this.showViewDetails = true,
    this.onTap,
    this.onHeartTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = width ?? AppSizes.cardWidth;
    final cardHeight = height ?? AppSizes.cardHeight;

    return GestureDetector(
      onTap: onTap ?? () {
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
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000), // ~20% black for clearer bottom/side
              blurRadius: 18,
              offset: Offset(0, 10),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Color(0x14000000), // soft ambient
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
                     tag: 'car_${car.id}',
                     child: (car.image.startsWith('http') || car.image.startsWith('https'))
                         ? Image.network(
                             car.image,
                             width: double.infinity,
                             height: cardHeight * 0.65,
                             fit: BoxFit.cover,
                             errorBuilder: (context, error, stackTrace) {
                               return Container(
                                 width: double.infinity,
                                 height: cardHeight * 0.65,
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
                             car.image,
                             width: double.infinity,
                             height: cardHeight * 0.65,
                             fit: BoxFit.cover,
                             errorBuilder: (context, error, stackTrace) {
                               return Container(
                                 width: double.infinity,
                                 height: cardHeight * 0.65,
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
             Expanded(
               child: Padding(
                 padding: const EdgeInsets.all(18.0), // Increased padding
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // Car name (larger, bolder)
                     OverflowSafeText(
                       car.name,
                       style: GoogleFonts.inter(
                         fontSize: 20, // Increased font size
                         fontWeight: FontWeight.bold,
                         color: Colors.black,
                       ),
                       maxLines: 1,
                     ),
                     const SizedBox(height: 8), // Increased spacing
                     // Rating with star icon
                     OverflowSafeRow(
                       wrapOnOverflow: false,
                       children: [
                         const Icon(
                           Icons.star,
                           size: 16,
                           color: Color(0xFFFFD700), // Gold star
                         ),
                         const SizedBox(width: 4),
                         Flexible(
                           child: OverflowSafeText(
                             car.rating.toStringAsFixed(1),
                             style: GoogleFonts.inter(
                               fontSize: 14,
                               fontWeight: FontWeight.w600,
                               color: Colors.black,
                             ),
                             maxLines: 1,
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 10), // Increased spacing
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
                                fontSize: 13, // Slightly increased
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                     const SizedBox(height: 12), // Added spacing before price
                     // Price (larger, bolder)
                     OverflowSafeText(
                       PriceFormatter.formatWithSettings(context, car.price),
                       style: GoogleFonts.inter(
                         fontSize: 18, // Increased font size
                         fontWeight: FontWeight.bold,
                         color: Colors.black,
                       ),
                       maxLines: 1,
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

// Factory method to create Car objects from form data
class CarFactory {
  static Car createFromFormData({
    required String id,
    required String name,
    required String image,
    required String price,
    required String category,
    required String location,
    required String hostName,
    String hostImage = 'assets/images/host.jpg',
    double hostRating = 4.9,
    String responseTime = '1 hour',
    String description = '',
    List<String> features = const [],
    List<String> images = const [],
    Map<String, String> specs = const {},
    double rating = 4.97,
    int trips = 0,
  }) {
    return Car(
      id: id,
      name: name,
      image: image,
      price: price,
      category: category,
      rating: rating,
      trips: trips,
      location: location,
      hostName: hostName,
      hostImage: hostImage,
      hostRating: hostRating,
      responseTime: responseTime,
      description: description,
      features: features,
      images: images,
      specs: specs,
    );
  }
} 