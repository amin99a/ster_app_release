import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _feedbackMessage;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _feedbackMessage = null;
    });

    final email = _emailController.text.trim();

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      setState(() {
        _feedbackMessage = 'Password reset link sent. Check your email.';
      });
    } on AuthException catch (e) {
      setState(() {
        _feedbackMessage = 'Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _feedbackMessage = 'An unexpected error occurred.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C2C2C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
                    
                    // Reset Password Form Container
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
                            'Reset Password',
                            style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                              color: Colors.white,
                                    ),
                                  ),
                          
                          const SizedBox(height: 8),
                                  
                                  // Description
                                  Text(
                            'Enter your email to receive a password reset link',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                          
                          const SizedBox(height: 15),
                          
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
                          
                          const SizedBox(height: 15),
                          
                          // Reset Button
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _resetPassword,
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
                                      'Send Reset Link',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF353935),
                                      ),
                                    ),
                                    ),
                                  ),
                          
                          // Feedback Message
                          if (_feedbackMessage != null) ...[
                            const SizedBox(height: 15),
                                  Container(
                              padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                color: _feedbackMessage!.contains('Error') 
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : Colors.green.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                  color: _feedbackMessage!.contains('Error') 
                                      ? Colors.red.withValues(alpha: 0.3)
                                      : Colors.green.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Text(
                                _feedbackMessage!,
                                style: TextStyle(
                                  color: _feedbackMessage!.contains('Error') 
                                      ? Colors.red
                                      : Colors.green,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                          
                    const SizedBox(height: 15),
                          
                    // Back to Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Remember your password? ',
                          style: TextStyle(
                            color: const Color(0xFF2C2C2C).withValues(alpha: 0.7),
                                    fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
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
        obscureText: isPassword,
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        validator: validator,
      ),
    );
  }
} 