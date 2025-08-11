import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'screens/email_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate() || !_agreeToTerms) return;

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.signUp(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } else {
      // Success - check if we have a stored signup email (indicating verification needed)
      debugPrint('=== SIGNUP SUCCESS NAVIGATION ===');
      debugPrint('LastSignupEmail: ${authService.lastSignupEmail}');
      
      if (authService.lastSignupEmail != null) {
        debugPrint('📧 Email verification required, navigating to EmailVerificationScreen');
        // Redirect to email verification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(
              email: authService.lastSignupEmail!,
            ),
          ),
        );
      } else {
        debugPrint('✅ Email already verified, navigating to HomeScreen');
        // Email already verified, go to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(_animationController);
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Form(
                key: _formKey,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    const SizedBox(height: 20),
                    
                    // Brand Section
                    Center(
                      child: Column(
                        children: [
                          // Logo
                          const Text(
                            'ster',
                            style: TextStyle(
                              fontSize: 84,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C2C2C),
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Tagline
                          const Text(
                            'FIND THE PERFECT CAR',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C2C2C),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Authentication Form Container
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Title
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // Name field
                            _buildInputField(
                              controller: _nameController,
                            label: 'Full Name',
                            keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            
                          const SizedBox(height: 10),
                            
                          // Email field
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
                            
                          // Password field
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
                            
                          const SizedBox(height: 10),
                            
                          // Confirm Password field
                          _buildInputField(
                              controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            
                          const SizedBox(height: 15),
                          
                          // Terms and Conditions
                          Row(
                                children: [
                              Checkbox(
                                value: _agreeToTerms,
                                onChanged: (value) {
                                      setState(() {
                                    _agreeToTerms = value ?? false;
                                      });
                                    },
                                activeColor: Colors.white,
                                checkColor: const Color(0xFF2C2C2C),
                              ),
                                  Expanded(
                                child: Text(
                                  'I agree to the Terms of Service and Privacy Policy',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // Signup Button
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF2C2C2C),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                                      child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C2C2C)),
                                      ),
                                    )
                                  : const Text(
                                      'Sign up',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF353935),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                              ),
                            ),
                            
                    const SizedBox(height: 15),
                            
                    // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                          style: TextStyle(
                            color: const Color(0xFF2C2C2C).withValues(alpha: 0.7),
                                    fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              color: Color(0xFF2C2C2C),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                    const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
        ),
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
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !(isPassword ? _isPasswordVisible : _isConfirmPasswordVisible),
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (isPassword ? _isPasswordVisible : _isConfirmPasswordVisible) 
                        ? Icons.visibility 
                        : Icons.visibility_off,
                    color: Colors.white70,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isPassword) {
                        _isPasswordVisible = !_isPasswordVisible;
                      } else {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      }
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        validator: validator,
      ),
    );
  }
}