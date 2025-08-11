class SocialAuthConfig {
  // Google Sign-In Configuration
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID';
  static const String googleClientSecret = 'YOUR_GOOGLE_CLIENT_SECRET';
  
  // Facebook Login Configuration
  static const String facebookAppId = 'YOUR_FACEBOOK_APP_ID';
  static const String facebookClientToken = 'YOUR_FACEBOOK_CLIENT_TOKEN';
  
  // Apple Sign-In Configuration
  static const String appleServiceId = 'YOUR_APPLE_SERVICE_ID';
  static const String appleTeamId = 'YOUR_APPLE_TEAM_ID';
  static const String appleKeyId = 'YOUR_APPLE_KEY_ID';
  
  // Supabase OAuth Configuration
  static const String supabaseUrl = 'https://etufhqdrucqwqkrzctsq.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV0dWZocWRydWNxd3FrcnpjdHNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjUzNjksImV4cCI6MjA2OTUwMTM2OX0.SNOX3fh8FRROx_0kYMkc37y6is_kTV_LEfqjmpFs0Kk';
  
  // OAuth Redirect URLs
  static const String redirectUrl = 'io.supabase.flutter://login-callback/';
  static const String resetPasswordUrl = 'io.supabase.flutter://reset-password-callback/';
  
  // Platform-specific configurations
  static const Map<String, dynamic> androidConfig = {
    'googleClientId': 'YOUR_ANDROID_GOOGLE_CLIENT_ID',
    'facebookAppId': 'YOUR_ANDROID_FACEBOOK_APP_ID',
  };
  
  static const Map<String, dynamic> iosConfig = {
    'googleClientId': 'YOUR_IOS_GOOGLE_CLIENT_ID',
    'facebookAppId': 'YOUR_IOS_FACEBOOK_APP_ID',
    'appleServiceId': 'YOUR_IOS_APPLE_SERVICE_ID',
  };
  
  static const Map<String, dynamic> webConfig = {
    'googleClientId': 'YOUR_WEB_GOOGLE_CLIENT_ID',
    'facebookAppId': 'YOUR_WEB_FACEBOOK_APP_ID',
  };
  
  // Get platform-specific configuration
  static Map<String, dynamic> getPlatformConfig(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return androidConfig;
      case 'ios':
        return iosConfig;
      case 'web':
        return webConfig;
      default:
        return {};
    }
  }
  
  // Check if social login is enabled
  static bool isGoogleEnabled = true;
  static bool isAppleEnabled = true;
  static bool isFacebookEnabled = true;
  
  // Get enabled providers
  static List<String> getEnabledProviders() {
    final providers = <String>[];
    if (isGoogleEnabled) providers.add('google');
    if (isAppleEnabled) providers.add('apple');
    if (isFacebookEnabled) providers.add('facebook');
    return providers;
  }
} 