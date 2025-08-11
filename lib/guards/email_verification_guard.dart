import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../screens/email_verification_screen.dart';
import '../login_screen.dart';

/// A guard widget that ensures users have verified their email before accessing protected content
class EmailVerificationGuard extends StatelessWidget {
  final Widget child;
  final bool requireAuthentication;

  const EmailVerificationGuard({
    super.key,
    required this.child,
    this.requireAuthentication = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // Get current Supabase user (even if local _currentUser is null)
        final supabaseUser = Supabase.instance.client.auth.currentUser;
        
        // Check if authentication is required
        if (requireAuthentication && supabaseUser == null) {
          debugPrint('🔒 No Supabase user found, redirecting to login');
          return const LoginScreen();
        }

        // Check if user exists but email not verified
        if (supabaseUser != null && supabaseUser.emailConfirmedAt == null) {
          debugPrint('📧 Supabase user exists but email not verified, redirecting to verification');
          return EmailVerificationScreen(
            email: supabaseUser.email ?? '',
          );
        }

        // User is authenticated and verified, show protected content
        return child;
      },
    );
  }
}