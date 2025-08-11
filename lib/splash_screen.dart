import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'screens/email_verification_screen.dart';
import 'services/context_aware_service.dart';
import 'services/context_tracking_service.dart';
import 'services/auth_service.dart';
import 'services/settings_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    // Start fade animation immediately
    _fadeController.forward();
    
    _initializeApp();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('🚀 Initializing STER app...');
      
      // Initialize context tracking services
      final contextAware = ContextAwareService();
      await contextAware.initialize();
      debugPrint('✅ Context tracking initialized');
      
      // Initialize context tracking service
      final contextTracking = ContextTrackingService();
      await contextTracking.initialize();
      debugPrint('✅ Context tracking service initialized');
      
      // Simulate other app initialization tasks
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        // Check if user is authenticated
        final authService = Provider.of<AuthService>(context, listen: false);
        final settingsService = Provider.of<SettingsService>(context, listen: false);
        
        // Wait for services to initialize
        await Future.delayed(const Duration(seconds: 1));
        
        // Get current Supabase user (even if local _currentUser is null)
        final supabaseUser = Supabase.instance.client.auth.currentUser;
        
        Widget nextScreen;
        if (supabaseUser != null) {
          // Check if user needs email verification
          if (supabaseUser.emailConfirmedAt == null) {
            debugPrint('📧 Supabase user exists but email not verified, redirecting to verification');
            nextScreen = EmailVerificationScreen(
              email: supabaseUser.email ?? '',
            );
          } else {
            debugPrint('👤 User is authenticated and verified, navigating to home');
            nextScreen = const HomeScreen();
          }
        } else {
          debugPrint('👤 No Supabase user found, navigating to login');
          nextScreen = const LoginScreen();
        }
        
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error during app initialization: $e');
      // Handle initialization errors
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Centered animated GIF splash
            Semantics(
              label: 'STER splash',
              child: Image.asset(
                'assets/ster_splash.gif',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.6,
              ),
            ),
            // Optional error overlay
            if (_hasError)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _hasError = false;
                              _errorMessage = '';
                              _isLoading = true;
                            });
                            _initializeApp();
                          },
                          child: const Text('Retry'),
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
}
