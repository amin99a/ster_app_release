import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:package_info_plus/package_info_plus.dart';

class ShareService {
  static const String _baseUrl = 'https://ster-app.com'; // Replace with your actual domain
  static const String _appName = 'Ster';
  
  // Share host profile
  static Future<void> shareHostProfile({
    required String hostId,
    required String hostName,
    String? hostLocation,
    String? hostImage,
  }) async {
    try {
      final url = '$_baseUrl/host/$hostId';
      final text = _buildHostShareText(hostName, hostLocation);
      
      if (kIsWeb) {
        // Web platform - use clipboard fallback
        _copyToClipboard('$text\n\nCheck out this host: $url');
      } else {
        // Mobile platforms - try native share
        await share_plus.Share.share(
          '$text\n\nCheck out this host: $url',
          subject: 'Check out $hostName on $_appName',
        );
      }
    } catch (e) {
      debugPrint('Error sharing host profile: $e');
      // Fallback: copy to clipboard
      final url = '$_baseUrl/host/$hostId';
      final text = _buildHostShareText(hostName, hostLocation);
      _copyToClipboard('$text\n\nCheck out this host: $url');
    }
  }

  // Share car listing
  static Future<void> shareCarListing({
    required String carId,
    required String carName,
    required String carBrand,
    required String carModel,
    required String price,
    required String hostName,
    String? carImage,
  }) async {
    try {
      final url = '$_baseUrl/car/$carId';
      final text = _buildCarShareText(carName, carBrand, carModel, price, hostName);
      
      if (kIsWeb) {
        // Web platform - use clipboard fallback
        _copyToClipboard('$text\n\nView this car: $url');
      } else {
        // Mobile platforms - try native share
        await share_plus.Share.share(
          '$text\n\nView this car: $url',
          subject: 'Check out this $carBrand $carModel on $_appName',
        );
      }
    } catch (e) {
      debugPrint('Error sharing car listing: $e');
      // Fallback: copy to clipboard
      final url = '$_baseUrl/car/$carId';
      final text = _buildCarShareText(carName, carBrand, carModel, price, hostName);
      _copyToClipboard('$text\n\nView this car: $url');
    }
  }

  // Share booking confirmation
  static Future<void> shareBookingConfirmation({
    required String bookingId,
    required String carName,
    required String hostName,
    required String startDate,
    required String endDate,
    required String totalPrice,
  }) async {
    try {
      final url = '$_baseUrl/booking/$bookingId';
      final text = _buildBookingShareText(
        carName, 
        hostName, 
        startDate, 
        endDate, 
        totalPrice
      );
      
      await share_plus.Share.share(
        '$text\n\nView booking details: $url',
        subject: 'My booking on $_appName',
      );
    } catch (e) {
      debugPrint('Error sharing booking: $e');
      // Fallback: show a dialog with the share text
      final url = '$_baseUrl/booking/$bookingId';
      final text = _buildBookingShareText(
        carName, 
        hostName, 
        startDate, 
        endDate, 
        totalPrice
      );
      _showShareDialog('$text\n\nView booking details: $url', 'My booking on $_appName');
    }
  }

  // Share favorite list
  static Future<void> shareFavoriteList({
    required String listName,
    required List<Map<String, dynamic>> cars,
    String? listDescription,
  }) async {
    try {
      final url = '$_baseUrl/favorites/$listName';
      final text = _buildFavoriteListShareText(listName, cars, listDescription);
      
      await share_plus.Share.share(
        '$text\n\nView my favorites: $url',
        subject: 'My $listName on $_appName',
      );
    } catch (e) {
      debugPrint('Error sharing favorite list: $e');
      // Fallback: show a dialog with the share text
      final url = '$_baseUrl/favorites/$listName';
      final text = _buildFavoriteListShareText(listName, cars, listDescription);
      _showShareDialog('$text\n\nView my favorites: $url', 'My $listName on $_appName');
    }
  }

  // Share app
  static Future<void> shareApp() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appUrl = _getAppStoreUrl();
      
      final text = '''
🚗 Discover amazing cars on $_appName!

Rent cars from trusted hosts in your area. 
Download now: $appUrl

#CarRental #SterApp
''';
      
      await share_plus.Share.share(text, subject: 'Check out $_appName');
    } catch (e) {
      debugPrint('Error sharing app: $e');
      // Fallback: show a dialog with the share text
      final appUrl = _getAppStoreUrl();
      final text = '''
🚗 Discover amazing cars on $_appName!

Rent cars from trusted hosts in your area. 
Download now: $appUrl

#CarRental #SterApp
''';
      _showShareDialog(text, 'Check out $_appName');
    }
  }

  // Handle incoming deep links
  static Future<void> handleDeepLink(String url) async {
    try {
      final uri = Uri.parse(url);
      
      if (uri.host == 'ster-app.com' || uri.host == 'www.ster-app.com') {
        final path = uri.pathSegments;
        
        if (path.isNotEmpty) {
          switch (path[0]) {
            case 'host':
              if (path.length > 1) {
                await _navigateToHostProfile(path[1]);
              }
              break;
            case 'car':
              if (path.length > 1) {
                await _navigateToCarDetails(path[1]);
              }
              break;
            case 'booking':
              if (path.length > 1) {
                await _navigateToBookingDetails(path[1]);
              }
              break;
            case 'favorites':
              if (path.length > 1) {
                await _navigateToFavoriteList(path[1]);
              }
              break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  // Build share text for host profile
  static String _buildHostShareText(String hostName, String? location) {
    return '''
🏠 Meet $hostName on $_appName!

${location != null ? '📍 Located in $location' : ''}
🚗 Professional car rental host
⭐ Trusted by our community

Check out their cars and book your next ride!
''';
  }

  // Build share text for car listing
  static String _buildCarShareText(
    String carName, 
    String brand, 
    String model, 
    String price, 
    String hostName
  ) {
    return '''
🚗 $brand $model available on $_appName!

💰 $price per day
👤 Hosted by $hostName
⭐ Professional rental experience

Perfect for your next trip!
''';
  }

  // Build share text for booking confirmation
  static String _buildBookingShareText(
    String carName,
    String hostName,
    String startDate,
    String endDate,
    String totalPrice,
  ) {
    return '''
✅ Booking confirmed on $_appName!

🚗 $carName
👤 Host: $hostName
📅 $startDate to $endDate
💰 Total: $totalPrice

Excited for my trip! 🎉
''';
  }

  // Build share text for favorite list
  static String _buildFavoriteListShareText(
    String listName,
    List<Map<String, dynamic>> cars,
    String? description,
  ) {
    final carCount = cars.length;
    final carNames = cars.take(3).map((car) => car['name'] ?? 'Car').join(', ');
    
    return '''
❤️ My $listName on $_appName!

${description ?? 'A collection of my favorite cars'}
🚗 $carCount cars including: $carNames${cars.length > 3 ? ' and more...' : ''}

Check out my picks!
''';
  }

  // Get app store URL based on platform
  static String _getAppStoreUrl() {
    if (Platform.isIOS) {
      return 'https://apps.apple.com/app/ster-car-rental/id123456789'; // Replace with actual App Store ID
    } else if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=com.ster.app'; // Replace with actual package name
    }
    return _baseUrl;
  }

  // Navigation methods for deep links
  static Future<void> _navigateToHostProfile(String hostId) async {
    // This will be implemented when we have navigation service
    debugPrint('Navigate to host profile: $hostId');
  }

  static Future<void> _navigateToCarDetails(String carId) async {
    // This will be implemented when we have navigation service
    debugPrint('Navigate to car details: $carId');
  }

  static Future<void> _navigateToBookingDetails(String bookingId) async {
    // This will be implemented when we have navigation service
    debugPrint('Navigate to booking details: $bookingId');
  }

  static Future<void> _navigateToFavoriteList(String listName) async {
    // This will be implemented when we have navigation service
    debugPrint('Navigate to favorite list: $listName');
  }

  // Check if URL can be launched
  static Future<bool> canLaunchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await url_launcher.canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  // Launch URL
  static Future<void> launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await url_launcher.launchUrl(uri, mode: url_launcher.LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  // Fallback dialog for sharing when native share is not available
  static void _showShareDialog(String text, String subject) {
    // This is a simple fallback - in a real app, you might want to show a custom dialog
    debugPrint('Share text: $text');
    debugPrint('Share subject: $subject');
    // You could show a SnackBar or Dialog here with the share text
  }

  // Copy text to clipboard as fallback
  static void _copyToClipboard(String text) {
    try {
      // For now, just log the text - in a real app, you'd use Clipboard.setData
      debugPrint('Copied to clipboard: $text');
      debugPrint('Share text copied to clipboard. You can paste it manually.');
    } catch (e) {
      debugPrint('Error copying to clipboard: $e');
    }
  }
}
