import 'package:flutter/material.dart';
import 'car_details_screen.dart';
import 'models/car.dart';
import 'screens/enhanced_booking_confirmation_screen.dart';
import 'search_screen.dart';

class FeaturedCarSquare extends StatelessWidget {
  final VoidCallback? onExploreTap;
  
  const FeaturedCarSquare({super.key, this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 20,
              offset: Offset(0, 12),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                  // Title section
              const Text(
                    'STER',
                style: TextStyle(
                      fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
                  const SizedBox(height: 8),
              const Text(
                'Browse an incredible selection of cars, from the everyday to the extraordinary.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                      height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
                  const SizedBox(height: 20),
                  
                  // Main image section with rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: screenWidth * 0.5, // Increased height for better visibility
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        'assets/images/featured.jpg', // Using the new featured image
                width: double.infinity,
                        height: screenWidth * 0.5,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  // Add space for the overlapping button
                  const SizedBox(height: 60),
                ],
              ),
            ),
            
            // Overlapping "BOOK NOW" button
            Positioned(
              bottom: 30,
              right: 25,
              child: GestureDetector(
                onTap: () => _handleInstantBooking(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: const Offset(0, -1),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'BOOK NOW',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }

  void _handleInstantBooking(BuildContext context) {
    // Navigate to search screen instead of booking confirmation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      ),
    );
  }
}
