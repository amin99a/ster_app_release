class DeepLinkConfig {
  // App URL schemes
  static const String appScheme = 'ster';
  static const String appDomain = 'ster-app.com';
  static const String appUrl = 'https://ster-app.com';
  
  // Deep link patterns
  static const Map<String, String> linkPatterns = {
    'host': '/host/{hostId}',
    'car': '/car/{carId}',
    'booking': '/booking/{bookingId}',
    'favorites': '/favorites/{listName}',
    'search': '/search?{parameters}',
  };
  
  // Generate deep link URLs
  static String generateHostLink(String hostId) {
    return '$appUrl/host/$hostId';
  }
  
  static String generateCarLink(String carId) {
    return '$appUrl/car/$carId';
  }
  
  static String generateBookingLink(String bookingId) {
    return '$appUrl/booking/$bookingId';
  }
  
  static String generateFavoritesLink(String listName) {
    return '$appUrl/favorites/$listName';
  }
  
  static String generateSearchLink(Map<String, String> parameters) {
    final queryString = parameters.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$appUrl/search?$queryString';
  }
  
  // App store URLs (replace with actual URLs when published)
  static const Map<String, String> appStoreUrls = {
    'ios': 'https://apps.apple.com/app/ster-car-rental/id123456789',
    'android': 'https://play.google.com/store/apps/details?id=com.ster.app',
    'web': 'https://ster-app.com',
  };
  
  // Social media sharing templates
  static const Map<String, String> socialTemplates = {
    'twitter': 'Check out this amazing car on Ster! {url} #CarRental #SterApp',
    'facebook': 'I found this great car on Ster - {url}',
    'whatsapp': 'Check out this car: {url}',
    'telegram': '🚗 Amazing car on Ster: {url}',
  };
  
  // Share text templates
  static const Map<String, String> shareTemplates = {
    'host': '''
🏠 Meet {hostName} on Ster!

📍 Located in {location}
🚗 Professional car rental host
⭐ Trusted by our community

Check out their cars and book your next ride!
''',
    'car': '''
🚗 {brand} {model} available on Ster!

💰 {price} per day
👤 Hosted by {hostName}
⭐ Professional rental experience

Perfect for your next trip!
''',
    'booking': '''
✅ Booking confirmed on Ster!

🚗 {carName}
👤 Host: {hostName}
📅 {startDate} to {endDate}
💰 Total: {totalPrice}

Excited for my trip! 🎉
''',
    'favorites': '''
❤️ My {listName} on Ster!

{description}
🚗 {carCount} cars including: {carNames}

Check out my picks!
''',
  };
}
