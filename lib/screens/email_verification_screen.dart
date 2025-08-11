import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../services/auth_service.dart';
import '../home_screen.dart';
import '../login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  
  const EmailVerificationScreen({
    super.key, 
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _verificationTimer;
  bool _isCheckingVerification = false;
  bool _isResendingEmail = false;
  bool _canResend = true;
  int _resendCooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    // Check immediately first
    _checkEmailVerification();
    
    // Then check every 5 seconds
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkEmailVerification(),
    );
  }

  Future<void> _checkEmailVerification() async {
    if (_isCheckingVerification) return;
    
    setState(() {
      _isCheckingVerification = true;
    });

    try {
      // Check if there's a current user in Supabase (even without session)
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      
      if (supabaseUser != null && supabaseUser.emailConfirmedAt != null) {
        debugPrint('✅ Email verification confirmed via Supabase user!');
        _verificationTimer?.cancel();
        
        // Use AuthService to properly load the user session
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.refreshUserSession();
        
        // Navigate to home screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        // Try the AuthService method as fallback (will handle session creation)
        try {
          final authService = Provider.of<AuthService>(context, listen: false);
          final isVerified = await authService.checkEmailVerificationStatus();
          
          if (isVerified) {
            debugPrint('✅ Email verification confirmed via AuthService!');
            _verificationTimer?.cancel();
            
            // Navigate to home screen
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          }
        } catch (authError) {
          // This is expected for unverified users - session doesn't exist yet
          debugPrint('ℹ️ No session yet (email not verified): $authError');
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking email verification: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingVerification = false;
        });
      }
    }
  }

  Future<void> _resendConfirmationEmail() async {
    if (!_canResend || _isResendingEmail) return;

    setState(() {
      _isResendingEmail = true;
    });

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Confirmation email sent to ${widget.email}'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Start cooldown
      _startResendCooldown();
      
    } catch (e) {
      debugPrint('❌ Error resending confirmation email: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend email. Please try again.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResendingEmail = false;
        });
      }
    }
  }

  void _startResendCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldownSeconds = 60; // 60 second cooldown
    });

    _cooldownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          _resendCooldownSeconds--;
        });

        if (_resendCooldownSeconds <= 0) {
          setState(() {
            _canResend = true;
          });
          timer.cancel();
        }
      },
    );
  }

  void _goBackToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header with back button
              Row(
                children: [
                  IconButton(
                    onPressed: _goBackToLogin,
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back to Login',
                  ),
                  Expanded(
                    child: Text(
                      'Verify Your Email',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Main content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Email icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_unread_outlined,
                        size: 50,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Title
                    Text(
                      'Check your email',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: 'We sent a verification link to\n',
                          ),
                          TextSpan(
                            text: widget.email,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const TextSpan(
                            text: '\n\nClick the link in the email to verify your account.',
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Verification status
                    if (_isCheckingVerification)
                      Column(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Checking verification status...',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              
              // Action buttons
              Column(
                children: [
                  // Resend email button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _canResend && !_isResendingEmail 
                          ? _resendConfirmationEmail 
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isResendingEmail
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _canResend 
                                  ? 'Resend confirmation email'
                                  : 'Resend in ${_resendCooldownSeconds}s',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Back to login button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: _goBackToLogin,
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        'Back to Login',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}