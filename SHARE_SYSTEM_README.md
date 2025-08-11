# Share System Implementation

## Overview

This document describes the comprehensive share system implemented for the Ster car rental app. The system includes sharing functionality for host profiles, car listings, booking confirmations, favorite lists, and deep linking support.

## Features

### ✅ Implemented Features

1. **Share Host Profiles**
   - Share host information with deep links
   - Include host name, location, and profile image
   - Generate shareable URLs

2. **Share Car Listings**
   - Share car details with pricing information
   - Include car brand, model, and host information
   - Generate deep links for car pages

3. **Share Booking Confirmations**
   - Share booking details with dates and pricing
   - Include car and host information
   - Generate booking-specific URLs

4. **Share Favorite Lists**
   - Share collections of favorite cars
   - Include list name and car descriptions
   - Generate list-specific deep links

5. **Deep Linking Support**
   - Handle incoming URLs from shared links
   - Navigate to specific screens based on URL patterns
   - Support for app launch from external links

6. **Reusable Share Components**
   - `ShareButton` widget for consistent UI
   - `ShareService` for centralized sharing logic
   - `DeepLinkService` for URL handling

## Architecture

### Services

#### ShareService (`lib/services/share_service.dart`)
- Centralized sharing functionality
- Handles all share operations
- Generates share text and URLs
- Manages platform-specific sharing

#### DeepLinkService (`lib/services/deep_link_service.dart`)
- Handles incoming deep links
- Manages URL parsing and navigation
- Provides global navigation key
- Initializes deep link listeners

### Widgets

#### ShareButton (`lib/widgets/share_button.dart`)
- Reusable share button component
- Supports multiple share types
- Customizable styling
- Consistent user experience

### Configuration

#### DeepLinkConfig (`lib/config/deep_link_config.dart`)
- URL scheme definitions
- Link pattern templates
- App store URLs
- Social media templates

## Setup Instructions

### 1. Dependencies

Add the following dependencies to `pubspec.yaml`:

```yaml
dependencies:
  share_plus: ^7.2.1
  uni_links: ^0.5.1
  url_launcher: ^6.2.4
  package_info_plus: ^8.0.0
```

### 2. Platform Configuration

#### Android (`android/app/src/main/AndroidManifest.xml`)

Add intent filters for deep linking:

```xml
<activity>
    <!-- ... existing activity configuration ... -->
    
    <!-- Deep link handling -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https" android:host="ster-app.com" />
    </intent-filter>
    
    <!-- Custom scheme handling -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="ster" />
    </intent-filter>
</activity>
```

#### iOS (`ios/Runner/Info.plist`)

Add URL scheme configuration:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.ster.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>ster</string>
        </array>
    </dict>
</array>
```

### 3. App Initialization

Update `lib/main.dart` to initialize the deep link service:

```dart
// Add to providers
Provider(create: (_) => DeepLinkService()),

// Initialize in MaterialApp
final deepLinkService = Provider.of<DeepLinkService>(context, listen: false);
WidgetsBinding.instance.addPostFrameCallback((_) {
  deepLinkService.initialize();
});

return MaterialApp(
  navigatorKey: deepLinkService.getNavigatorKey(),
  // ... rest of MaterialApp configuration
);
```

## Usage Examples

### 1. Share Host Profile

```dart
// Using ShareService directly
await ShareService.shareHostProfile(
  hostId: 'host_123',
  hostName: 'John Doe',
  hostLocation: 'New York, NY',
  hostImage: 'https://example.com/profile.jpg',
);

// Using ShareButton widget
ShareButton(
  type: ShareType.hostProfile,
  data: {
    'hostId': 'host_123',
    'hostName': 'John Doe',
    'hostLocation': 'New York, NY',
    'hostImage': 'https://example.com/profile.jpg',
  },
)
```

### 2. Share Car Listing

```dart
// Using ShareService directly
await ShareService.shareCarListing(
  carId: 'car_456',
  carName: 'BMW X5',
  carBrand: 'BMW',
  carModel: 'X5',
  price: 'UK£150',
  hostName: 'John Doe',
  carImage: 'https://example.com/car.jpg',
);

// Using ShareButton widget
ShareButton(
  type: ShareType.carListing,
  data: {
    'carId': 'car_456',
    'carName': 'BMW X5',
    'carBrand': 'BMW',
    'carModel': 'X5',
    'price': 'UK£150',
    'hostName': 'John Doe',
    'carImage': 'https://example.com/car.jpg',
  },
)
```

### 3. Share Booking Confirmation

```dart
await ShareService.shareBookingConfirmation(
  bookingId: 'booking_789',
  carName: 'BMW X5',
  hostName: 'John Doe',
  startDate: '2024-01-15',
  endDate: '2024-01-18',
  totalPrice: 'UK£450',
);
```

### 4. Share Favorite List

```dart
await ShareService.shareFavoriteList(
  listName: 'My Dream Cars',
  cars: [
    {'name': 'BMW X5', 'brand': 'BMW'},
    {'name': 'Mercedes GLE', 'brand': 'Mercedes'},
  ],
  listDescription: 'A collection of luxury SUVs',
);
```

## Deep Link URL Patterns

### Supported URL Formats

1. **Host Profile**: `https://ster-app.com/host/{hostId}`
2. **Car Listing**: `https://ster-app.com/car/{carId}`
3. **Booking Details**: `https://ster-app.com/booking/{bookingId}`
4. **Favorite List**: `https://ster-app.com/favorites/{listName}`
5. **Search**: `https://ster-app.com/search?{parameters}`

### Example URLs

- `https://ster-app.com/host/john_doe_123`
- `https://ster-app.com/car/bmw_x5_456`
- `https://ster-app.com/booking/booking_789`
- `https://ster-app.com/favorites/dream_cars`
- `https://ster-app.com/search?location=NYC&brand=BMW`

## Customization

### 1. Update App Domain

Change the domain in `lib/config/deep_link_config.dart`:

```dart
static const String appDomain = 'your-domain.com';
static const String appUrl = 'https://your-domain.com';
```

### 2. Update App Store URLs

Replace placeholder URLs with actual app store links:

```dart
static const Map<String, String> appStoreUrls = {
  'ios': 'https://apps.apple.com/app/your-app/id123456789',
  'android': 'https://play.google.com/store/apps/details?id=com.your.app',
  'web': 'https://your-domain.com',
};
```

### 3. Customize Share Templates

Modify share text templates in `DeepLinkConfig`:

```dart
static const Map<String, String> shareTemplates = {
  'host': 'Your custom host share template...',
  'car': 'Your custom car share template...',
  // ... other templates
};
```

## Testing

### 1. Test Deep Links

Use the following commands to test deep linking:

```bash
# Android
adb shell am start -W -a android.intent.action.VIEW -d "https://ster-app.com/host/test_host" com.ster.app

# iOS Simulator
xcrun simctl openurl booted "ster://host/test_host"
```

### 2. Test Share Functionality

1. Navigate to a host profile, car listing, or booking
2. Tap the share button
3. Verify the share dialog appears with correct content
4. Test sharing to different apps

## Troubleshooting

### Common Issues

1. **Deep links not working**
   - Verify platform configuration
   - Check URL scheme registration
   - Ensure app is properly installed

2. **Share dialog not appearing**
   - Check share_plus package installation
   - Verify platform permissions
   - Test on physical device

3. **Navigation not working**
   - Verify navigator key setup
   - Check deep link service initialization
   - Ensure proper route configuration

### Debug Information

Enable debug logging by checking console output for:
- Deep link initialization messages
- URL parsing information
- Navigation attempts
- Share operation results

## Future Enhancements

### Planned Features

1. **Social Media Integration**
   - Direct sharing to specific platforms
   - Custom share cards for social media
   - Analytics tracking for shared content

2. **Advanced Deep Linking**
   - Universal links support
   - App indexing for search engines
   - Dynamic link generation

3. **Share Analytics**
   - Track share interactions
   - Measure share effectiveness
   - User engagement metrics

4. **Custom Share UI**
   - In-app share preview
   - Custom share animations
   - Branded share templates

## Support

For issues or questions regarding the share system implementation, please refer to:
- Share system documentation
- Platform-specific setup guides
- Troubleshooting section above
