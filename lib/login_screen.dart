import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/user.dart';
import 'host_dashboard_screen.dart';
import 'screens/admin_car_approval_screen.dart';
import 'screens/email_verification_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;



  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } else {
      // Check if email verification is needed first
      if (authService.needsEmailVerification) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final user = authService.currentUser;
      final role = user?.role;
      
      // Validate user role before navigation
      if (role == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid user role. Please contact support.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Role-based navigation with proper validation
      switch (role) {
        case UserRole.admin:
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const AdminCarApprovalScreen())
          );
          break;
        case UserRole.host:
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const HostDashboardScreen())
          );
          break;
        case UserRole.user:
          // Customer users go to home screen with full access
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const HomeScreen())
          );
          break;
        case UserRole.guest:
          // Guest users go to home screen with limited access
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const HomeScreen())
          );
          break;
        default:
          // Fallback to home screen for unknown roles
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const HomeScreen())
          );
          break;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(_animationController);
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0), // Reduced from 12
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20), // Reduced from 32
                    
                    // Brand Section
                    Center(
                      child: Column(
                        children: [
                          // Logo
                          const Text(
                            'ster',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2F3132),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 3), // Reduced from 5
                          // Tagline
                          const Text(
                            'FIND THE PERFECT CAR',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xCC2F3132),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20), // Reduced from 32
                    
                    // Authentication Form Container
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                            color: const Color(0xFF2F3132),
                            borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                            blurRadius: 20,
                                offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                              // Segmented tabs (Sign in / Sign Up)
                              _buildSegmentedTabs(context),
                              const SizedBox(height: 20),
                          
                          // Input Fields
                          _buildInputField(
                            controller: _emailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 10),
                          
                          _buildInputField(
                            controller: _passwordController,
                            label: 'Password',
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          
                              const SizedBox(height: 20),
                          
                          // Forgot Password Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // Reduced from 4
                              ),
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12, // Reduced from 13
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          
                              const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                                height: 60,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF2F3132),
                                    elevation: 6,
                                    shadowColor: Colors.black54,
                                shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F3132)),
                                      ),
                                    )
                                  : const Text(
                                          'Log in',
                                      style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF2F3132),
                                      ),
                                    ),
                              ),
                            ),
                              const SizedBox(height: 16),
                    const Text(
                      'Or continue with',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                                  color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: const Color(0xFFE9EAEB)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 10,
                                        offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                                  child: TextButton(
                                    onPressed: () {
                                      final auth = Provider.of<AuthService>(context, listen: false);
                                      auth.signInWithGoogle();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF2F3132),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                        Text('G', style: TextStyle(color: Color(0xFF4285F4), fontSize: 20, fontWeight: FontWeight.w700)),
                                  SizedBox(width: 10),
                                  Text(
                                          'Continue with Google',
                                    style: TextStyle(
                                            color: Color(0xE62F3132),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                                    ),
                                  ),
                                ],
                          ),
                        ),
                      ),
                    ),

                    ],
                  ),
                ),
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildSegmentedTabs(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {/* already on Sign in */},
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2F3132),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFEAEAEA), width: 2),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Sign in',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0x992F3132),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
            decoration: BoxDecoration(
        color: const Color(0x143A3C3C), // ~8% white on dark
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x40616466), width: 1),
            ),
            child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
              decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white70,
                    size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required String icon,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
                borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF2C2C2C),
            width: 1,
          ),
              boxShadow: [
                BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
          elevation: 0,
              child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            splashColor: const Color(0xFF2C2C2C).withValues(alpha: 0.1),
            highlightColor: const Color(0xFF2C2C2C).withValues(alpha: 0.05),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                  _buildSocialIcon(icon),
                  const SizedBox(width: 10),
                          Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF353935),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildSocialIcon(String icon) {
    switch (icon) {
      case 'G':
        return const Text(
          'G',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4285F4),
          ),
        );
      case '🍎':
        return Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xFF000000),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.apple,
              color: Colors.white,
              size: 12,
            ),
          ),
        );
      case 'f':
        return Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xFF1877F2),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'f',
              style: TextStyle(
                      color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      default:
        return Text(
          icon,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }
}