# 🔐 Social Login Setup Guide

This guide will help you set up Google, Apple, and Facebook login for your STER car rental app.

## 📋 Prerequisites

- Flutter SDK 3.2.3 or higher
- Android Studio / Xcode
- Google Cloud Console account
- Apple Developer account
- Facebook Developer account
- Supabase project

## 🚀 Quick Start

### 1. Install Dependencies

Run the following command to install all required packages:

```bash
flutter pub get
```

### 2. Configure Social Login Providers

#### Google Sign-In Setup

1. **Google Cloud Console Setup:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing one
   - Enable Google+ API and Google Sign-In API
   - Go to Credentials → Create Credentials → OAuth 2.0 Client ID
   - Add your app's package name and SHA-1 fingerprint

2. **Android Configuration:**
   - Add your `google-services.json` to `android/app/`
   - Update `android/app/build.gradle.kts`:
   ```kotlin
   plugins {
       id("com.google.gms.google-services")
   }
   ```

3. **iOS Configuration:**
   - Add your `GoogleService-Info.plist` to `ios/Runner/`
   - Update `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLName</key>
           <string>REVERSED_CLIENT_ID</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```

#### Apple Sign-In Setup

1. **Apple Developer Console:**
   - Go to [Apple Developer](https://developer.apple.com/)
   - Create App ID with Sign In with Apple capability
   - Create Service ID for your app
   - Generate private key for Sign In with Apple

2. **iOS Configuration:**
   - Update `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLName</key>
           <string>YOUR_BUNDLE_ID</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>YOUR_BUNDLE_ID</string>
           </array>
       </dict>
   </array>
   ```

#### Facebook Login Setup

1. **Facebook Developer Console:**
   - Go to [Facebook Developers](https://developers.facebook.com/)
   - Create a new app
   - Add Facebook Login product
   - Configure OAuth redirect URIs

2. **Android Configuration:**
   - Add your `facebook_app_id` to `android/app/src/main/res/values/strings.xml`:
   ```xml
   <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
   <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
   ```

3. **iOS Configuration:**
   - Update `ios/Runner/Info.plist`:
   ```xml
   <key>FacebookAppID</key>
   <string>YOUR_FACEBOOK_APP_ID</string>
   <key>FacebookClientToken</key>
   <string>YOUR_FACEBOOK_CLIENT_TOKEN</string>
   <key>FacebookDisplayName</key>
   <string>STER</string>
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLName</key>
           <string>facebook</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>fbYOUR_FACEBOOK_APP_ID</string>
           </array>
       </dict>
   </array>
   ```

### 3. Update Configuration

1. **Update `lib/config/social_auth_config.dart`:**
   ```dart
   class SocialAuthConfig {
     // Replace with your actual credentials
     static const String googleClientId = 'YOUR_ACTUAL_GOOGLE_CLIENT_ID';
     static const String facebookAppId = 'YOUR_ACTUAL_FACEBOOK_APP_ID';
     static const String appleServiceId = 'YOUR_ACTUAL_APPLE_SERVICE_ID';
     // ... other configurations
   }
   ```

2. **Configure Supabase OAuth:**
   - Go to your Supabase project dashboard
   - Navigate to Authentication → Providers
   - Enable and configure Google, Apple, and Facebook providers
   - Add your OAuth redirect URLs

### 4. Platform-Specific Setup

#### Android Setup

1. **Update `android/app/build.gradle.kts`:**
   ```kotlin
   android {
       defaultConfig {
           applicationId "com.example.ster_app"
           minSdkVersion 21
           targetSdkVersion 33
       }
   }
   ```

2. **Add permissions to `android/app/src/main/AndroidManifest.xml`:**
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   ```

#### iOS Setup

1. **Update `ios/Runner/Info.plist`:**
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <!-- Add your URL schemes here -->
   </array>
   ```

2. **Update minimum iOS version in `ios/Podfile`:**
   ```ruby
   platform :ios, '12.0'
   ```

### 5. Testing

1. **Test Google Sign-In:**
   ```dart
   final result = await socialAuthService.signInWithGoogle();
   print('Google Sign-In Result: $result');
   ```

2. **Test Apple Sign-In:**
   ```dart
   final result = await socialAuthService.signInWithApple();
   print('Apple Sign-In Result: $result');
   ```

3. **Test Facebook Sign-In:**
   ```dart
   final result = await socialAuthService.signInWithFacebook();
   print('Facebook Sign-In Result: $result');
   ```

## 🔧 Troubleshooting

### Common Issues

1. **Google Sign-In not working:**
   - Verify SHA-1 fingerprint is correct
   - Check if Google Services JSON is properly placed
   - Ensure Google+ API is enabled

2. **Apple Sign-In not working:**
   - Verify App ID has Sign In with Apple capability
   - Check if Service ID is properly configured
   - Ensure private key is valid

3. **Facebook Login not working:**
   - Verify App ID and Client Token are correct
   - Check if OAuth redirect URIs are configured
   - Ensure app is not in development mode

### Debug Tips

1. **Enable debug logging:**
   ```dart
   // Add to your main.dart
   if (kDebugMode) {
     print('Debug mode enabled');
   }
   ```

2. **Check network connectivity:**
   ```dart
   // Test OAuth URL launch
   final success = await launchUrl(Uri.parse('https://example.com'));
   print('URL launch success: $success');
   ```

3. **Verify Supabase configuration:**
   ```dart
   // Test Supabase connection
   final response = await Supabase.instance.client.auth.getSession();
   print('Supabase session: ${response.session}');
   ```

## 📱 Features

### ✅ Implemented Features

- **Modern UI Design:** Clean, gradient-based design with smooth animations
- **Social Login Integration:** Google, Apple, and Facebook authentication
- **Form Validation:** Email and password validation with error messages
- **Loading States:** Proper loading indicators during authentication
- **Error Handling:** Comprehensive error handling with user-friendly messages
- **Responsive Design:** Works on all screen sizes
- **Accessibility:** Screen reader support and keyboard navigation

### 🔄 Removed Features

- **Demo Accounts:** Removed all demo account functionality
- **Guest Mode:** Removed guest user navigation
- **Mock Authentication:** Replaced with real OAuth authentication

### 🎨 UI Improvements

- **Gradient Background:** Modern gradient from purple to dark
- **Rounded Cards:** Soft, modern card design
- **Smooth Animations:** Staggered animations for better UX
- **Social Buttons:** Platform-specific styling for social login buttons
- **Enhanced Typography:** Google Fonts with proper hierarchy
- **Shadow Effects:** Subtle shadows for depth

## 🚀 Next Steps

1. **Configure your actual OAuth credentials**
2. **Test on real devices**
3. **Set up proper error handling**
4. **Add analytics tracking**
5. **Implement user profile management**
6. **Add account linking features**

## 📞 Support

If you encounter any issues:

1. Check the troubleshooting section above
2. Verify all configuration files are correct
3. Test on different devices and platforms
4. Review the official documentation for each provider

## 📄 License

This implementation follows the respective terms of service for:
- [Google Sign-In](https://developers.google.com/identity/sign-in/android)
- [Apple Sign-In](https://developer.apple.com/sign-in-with-apple/)
- [Facebook Login](https://developers.facebook.com/docs/facebook-login/) 