import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'services/car_service.dart';
import 'services/host_service.dart';
import 'services/booking_service.dart';
import 'services/notification_service.dart';
import 'services/search_service.dart';
import 'services/image_upload_service.dart';
import 'services/error_logging_service.dart';
import 'services/social_auth_service.dart';
import 'services/performance_service.dart';
import 'services/settings_service.dart';
import 'services/rental_service.dart';
import 'services/payment_service.dart';
import 'services/recommendation_service.dart';
import 'services/availability_service.dart';
import 'services/review_service.dart';
import 'services/activity_service.dart';
import 'services/context_aware_service.dart';
import 'services/context_tracking_service.dart';
import 'services/currency_service.dart';
import 'services/messaging_service.dart';
import 'services/chat_service.dart';
import 'services/deep_link_service.dart';
import 'widgets/error_boundary.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupLogging();

  // Shorebird is automatically initialized when the app starts
  // No manual initialization needed

  // Filter framework and platform-dispatched errors for known transient auth noise
  FlutterError.onError = (FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    if (message.contains('AuthRetryableFetchException')) {
      return; // suppress noisy transient Supabase refresh logs
    }
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    final message = error.toString();
    if (message.contains('AuthRetryableFetchException')) {
      return true; // handled
    }
    return false; // allow default handling
  };

  // Run app in a zone that filters print() noise
  runZonedGuarded(() async {
    // Enable edge-to-edge and make status bar transparent so content can appear behind it
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Android icon color
      statusBarBrightness: Brightness.dark,      // iOS text color
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    try {
      await Supabase.initialize(
        url: 'https://etufhqdrucqwqkrzctsq.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV0dWZocWRydWNxd3FrcnpjdHNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjUzNjksImV4cCI6MjA2OTUwMTM2OX0.SNOX3fh8FRROx_0kYMkc37y6is_kTV_LEfqjmpFs0Kk',
      );
      debugPrint('✅ Supabase initialized successfully');
    } catch (e) {
      // Suppress transient init noise; connection will be retried by SDK
    }

    runApp(const MyApp());
  }, (error, stack) {
    final msg = error.toString();
    if (msg.contains('AuthRetryableFetchException')) {
      return; // swallow transient
    }
  }, zoneSpecification: ZoneSpecification(
    print: (self, parent, zone, line) {
      final message = line ?? '';
      if (_shouldBlockLog(message)) return;
      parent.print(zone, line);
    },
  ));
}

bool _shouldBlockLog(String msg) {
  const blockedFragments = <String>[
    'supabase.auth:',
    'supabase.supabase_flutter:',
    'PostgrestException(',
    'Tracked database operation:',
    'Tracked event chain:',
    'Tracked business rule:',
    'ContextTrackingService',
    'ContextAwareService',
    'Cache expired, clearing',
    'Caching heart state',
    'Heart state for',
    'Building heart icon',
    'API error: Network connection error',
  ];
  return blockedFragments.any((f) => msg.contains(f));
}

void _setupLogging() {
  // Drop overly noisy logs during startup while keeping important ones
  debugPrint = (String? message, {int? wrapWidth}) {
    final msg = message ?? '';
    final isBlocked = _shouldBlockLog(msg);
    if (!isBlocked) {
      debugPrintSynchronously(msg, wrapWidth: wrapWidth);
    }
  };
}

// Helper function to create MaterialColor from a single color
MaterialColor _createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (double strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core Services
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SettingsService()..initialize()),
        ChangeNotifierProvider(create: (_) => ErrorLoggingService()),
        ChangeNotifierProvider(create: (_) => PerformanceService()),

        // Context Tracking Services
        ChangeNotifierProvider(create: (_) => ContextTrackingService()),

        // Business Logic Services
        ChangeNotifierProvider(create: (_) => CarService()),
        ChangeNotifierProvider(create: (_) => HostService()),
        ChangeNotifierProvider(create: (_) => BookingService()),
        ChangeNotifierProvider(create: (_) => RentalService()),
        ChangeNotifierProvider(create: (_) => PaymentService()),
        ChangeNotifierProvider(create: (_) => AvailabilityService()),
        ChangeNotifierProvider(create: (_) => RecommendationService()),
        ChangeNotifierProvider(create: (_) => ReviewService()),
        ChangeNotifierProvider(create: (_) => ActivityService()),

        // UI & Interaction Services
        ChangeNotifierProvider(create: (_) => SearchService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => ImageUploadService()),
        ChangeNotifierProvider(create: (_) => SocialAuthService()),

        // Messaging Services
        ChangeNotifierProvider(create: (_) => MessagingService()..initialize()),
        ChangeNotifierProvider(create: (_) => ChatService()..initialize()),

        // New Services
        ChangeNotifierProvider(create: (_) => CurrencyService()..initialize()),

        // Share & Deep Link Services
        Provider(create: (_) => DeepLinkService()),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          final deepLinkService = Provider.of<DeepLinkService>(context, listen: false);

          // Initialize deep link service
          WidgetsBinding.instance.addPostFrameCallback((_) {
            deepLinkService.initialize();
          });

          return MaterialApp(
            navigatorKey: deepLinkService.getNavigatorKey(),
            title: 'STER - Car Rental',
              theme: ThemeData(
              primaryColor: const Color(0xFF353935),
              primarySwatch: _createMaterialColor(const Color(0xFF353935)),
                colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF353935),
                primary: const Color(0xFF353935),
                secondary: Colors.white,
                  surface: Colors.white,
                onPrimary: Colors.white,
                onSecondary: const Color(0xFF353935),
                onSurface: const Color(0xFF353935),
              ),
                textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFF353935),
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: const Color(0xFF353935).withValues(alpha: 0.3),
                centerTitle: true,
              ),
                cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 12,
                  shadowColor: const Color(0xFF353935).withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF353935),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: const Color(0xFF353935).withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: const Color(0xFF353935),
                foregroundColor: Colors.white,
                elevation: 16,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFF353935).withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFF353935).withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF353935), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                labelStyle: TextStyle(color: const Color(0xFF353935).withValues(alpha: 0.7)),
                hintStyle: TextStyle(color: const Color(0xFF353935).withValues(alpha: 0.5)),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
                selectedItemColor: const Color(0xFF353935),
                unselectedItemColor: const Color(0xFF353935).withValues(alpha: 0.6),
                elevation: 20,
                type: BottomNavigationBarType.fixed,
              ),
              scaffoldBackgroundColor: Colors.white,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: 'Poppins',
            ),
            locale: Locale(settingsService.currentLanguage.code),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('fr', ''),
              Locale('ar', ''),
            ],
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return ErrorBoundary(
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
