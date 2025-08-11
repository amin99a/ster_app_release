# iOS Build Checklist (Flutter + Supabase)

1) Xcode Project
- Open `ios/Runner.xcworkspace` in Xcode
- Set a valid Team and Bundle Identifier (`Runner` target → Signing & Capabilities)
- Confirm Deployment Target: iOS 14.0+

2) URL Schemes / OAuth
- Info.plist has URL scheme `io.supabase.flutter`
- Supabase Auth → Additional Redirect URLs includes `io.supabase.flutter://login-callback/`

3) Privacy Usage Strings
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription
- NSPhotoLibraryAddUsageDescription
- NSMicrophoneUsageDescription (if used)
- NSLocationWhenInUseUsageDescription (maps/location)

4) Capabilities
- Sign in with Apple: Enabled (Runner.entitlements) if using Apple auth
- Push Notifications/Background modes: add only if used

5) CocoaPods
```
flutter clean
flutter pub get
cd ios && pod repo update && pod install && cd ..
```

6) Build
```
flutter build ios --no-codesign
```

7) CI (macOS)
- Cache pub, run pods, build IPA/no-codesign
- Configure App Store Connect API keys if uploading to TestFlight
