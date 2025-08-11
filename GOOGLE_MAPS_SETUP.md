# Google Maps Setup Guide

## Prerequisites

1. **Google Cloud Console Account**: You need a Google Cloud account
2. **Billing Enabled**: Google Maps API requires billing to be enabled

## Step-by-Step Setup

### 1. Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable billing for your project

### 2. Enable Required APIs

1. Go to "APIs & Services" > "Library"
2. Search for and enable these APIs:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Places API** (for location search)
   - **Geocoding API** (for address conversion)

### 3. Create API Key

1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "API Key"
3. Copy the generated API key

### 4. Restrict API Key (Recommended)

1. Click on your API key to edit it
2. Under "Application restrictions", select "Android apps"
3. Add your app's package name: `com.example.ster_app`
4. Add your SHA-1 certificate fingerprint
5. Under "API restrictions", select "Restrict key"
6. Select the APIs you enabled in step 2

### 5. Update Android Manifest

Replace `YOUR_GOOGLE_MAPS_API_KEY` in `android/app/src/main/AndroidManifest.xml` with your actual API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE" />
```

### 6. Get SHA-1 Certificate Fingerprint

For debug builds:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

For release builds:
```bash
keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
```

### 7. iOS Setup (Optional)

If you plan to support iOS, you'll also need to:

1. Enable Maps SDK for iOS in Google Cloud Console
2. Add the API key to your iOS configuration
3. Update `ios/Runner/AppDelegate.swift` with the API key

## Testing

After setup, the "Near by" feature should work:

1. Tap the "Near by" option in the destination section
2. Select a distance radius
3. The app will request location permissions
4. You'll see a map with nearby cars marked

## Troubleshooting

### Common Issues:

1. **"Maps API key not found"**: Make sure you've added the API key to AndroidManifest.xml
2. **"Location permission denied"**: The app will show a fallback screen
3. **"No cars found"**: This is expected in demo mode - cars are simulated around your location

### Debug Tips:

- Check Google Cloud Console for API usage and errors
- Verify your API key restrictions allow your app
- Ensure billing is enabled for your Google Cloud project

## Cost Considerations

- Google Maps API has a generous free tier
- Basic usage (maps, geocoding) is usually free for small apps
- Monitor usage in Google Cloud Console to avoid unexpected charges

## Security Notes

- Never commit your API key to public repositories
- Use environment variables or secure storage for production
- Restrict your API key to only your app's package name
- Set up API restrictions to limit usage to only the APIs you need 