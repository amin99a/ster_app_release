import 'package:flutter/material.dart';

class ApiConstants {
  // Replace with your actual API base URL
  static const String baseUrl = 'https://your-api-domain.com/api';
  
  // API endpoints
  static const String authEndpoint = '/auth';
  static const String carsEndpoint = '/cars';
  static const String rentalsEndpoint = '/rentals';
  static const String usersEndpoint = '/users';
  static const String paymentsEndpoint = '/payments';
  static const String notificationsEndpoint = '/notifications';
  static const String viewHistoryEndpoint = '/view-history';
  static const String favoritesEndpoint = '/favorites';
  static const String disputesEndpoint = '/disputes';
  static const String messagesEndpoint = '/messages';
  static const String reviewsEndpoint = '/reviews';
  static const String insuranceEndpoint = '/insurance';
  static const String documentsEndpoint = '/documents';
  static const String locationsEndpoint = '/locations';
  static const String availabilityEndpoint = '/availability';
  
  // API timeout
  static const Duration timeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // HTTP Status Codes
  static const int success = 200;
  static const int created = 201;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int internalServerError = 500;
  static const int serviceUnavailable = 503;
  
  // Error Messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String unauthorizedError = 'Unauthorized access';
  static const String notFoundError = 'Resource not found';
  static const String validationError = 'Validation error';
  static const String timeoutError = 'Request timeout';
  static const String unknownError = 'Unknown error occurred';
}

class AppConstants {
  // App colors
  static const int primaryColor = 0xFF353935; // Updated to Onyx
  static const int secondaryColor = 0xFFF4F4F4;
  
  // App dimensions
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';
  static const String viewHistoryKey = 'view_history';
  static const String favoritesKey = 'favorites';
  static const String offlineDataKey = 'offline_data';
  static const String lastSyncKey = 'last_sync';
  
  // Cache keys
  static const String carsCacheKey = 'cars_cache';
  static const String favoritesCacheKey = 'favorites_cache';
  static const String userCacheKey = 'user_cache';
  
  // Cache expiration (in minutes)
  static const int cacheExpirationMinutes = 30;
  static const int userCacheExpirationMinutes = 60;
  
  // Default values
  static const String defaultUserId = 'current_user_id';
  static const String defaultUserName = 'Guest User';
  
  // Offline sync settings
  static const int maxOfflineItems = 1000;
  static const Duration syncRetryDelay = Duration(minutes: 5);
  static const int maxSyncRetries = 3;
}

// Colors
const Color primaryColor = Color(0xFF353935); // Updated to Onyx
const Color secondaryColor = Color(0xFF2C2C2E);
const Color accentColor = Color(0xFF007AFF);
const Color lightGrey = Color(0xFFF2F2F7);
const Color darkGrey = Color(0xFF8E8E93);

// Padding
const double defaultPadding = 16.0;

// Text Styles
const TextStyle headingStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: primaryColor,
);

const TextStyle subHeadingStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: primaryColor,
);

const TextStyle lightTextStyle = TextStyle(
  fontSize: 14,
  color: darkGrey,
);

// Example usage:
// style: headingStyle.copyWith(fontSize: 28),

// Responsive sizing constants
class AppSizes {
  // Screen dimensions
  static double get screenWidth => MediaQuery.of(GlobalKey<NavigatorState>().currentContext!).size.width;
  static double get screenHeight => MediaQuery.of(GlobalKey<NavigatorState>().currentContext!).size.height;
  
  // Header dimensions
  static const double headerHeight = 80.0;
  static const double logoHeight = 48.0;
  static const double logoWidth = 120.0;
  static const double headerPadding = 16.0;
  
  // Search bar dimensions
  static const double searchBarHeight = 44.0;
  static const double searchBarBorderRadius = 22.0;
  static const double searchBarWidthPercentage = 0.9;
  
  // Card dimensions
  static const double cardBorderRadius = 16.0;
  static const double cardPadding = 16.0;
  static const double cardSpacing = 12.0;
  
  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  
  // Text sizes
  static const double textSizeSmall = 12.0;
  static const double textSizeMedium = 14.0;
  static const double textSizeLarge = 16.0;
  static const double textSizeXLarge = 18.0;
  
  // Button dimensions
  static const double buttonHeight = 48.0;
  static const double buttonBorderRadius = 24.0;
  
  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Responsive helpers
  static double get responsiveWidth => screenWidth * 0.9;
  static double get cardWidth => screenWidth * 0.88;
  static double get cardHeight => cardWidth * 0.8;
}

// Color constants
class AppColors {
  static const Color primary = Color(0xFF353935); // Updated to Onyx
  static const Color secondary = Color(0xFF2D1457);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D1457);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color accent = Color(0xFFFF6B35);
}

// Text styles
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: AppSizes.textSizeXLarge,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: AppSizes.textSizeMedium,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: AppSizes.textSizeSmall,
    color: AppColors.textSecondary,
  );
}
