import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'host_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'login_screen.dart';
import 'screens/user_profile_edit_screen.dart';
import 'screens/booking_history_screen.dart';
import 'payment_methods_screen.dart';
import 'notification_screen.dart';
import 'legal_privacy_screen.dart';
import 'terms_of_service_screen.dart';
import 'become_host_screen.dart';
import 'widgets/floating_header.dart';
import 'screens/app_settings_screen.dart';
import 'screens/admin_car_approval_screen.dart';
import 'screens/admin_host_approval_screen.dart';
import 'screens/multilingual_demo_screen.dart';
import 'screens/currency_converter_screen.dart';
import 'models/user.dart' as app_user;
import 'my_cars_screen.dart';
import 'my_bookings_screen.dart';
import 'screens/notifications_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        final isGuest = user?.isGuest == true;
        final isHost = user?.isHost == true;
        final isAdmin = user?.isAdmin == true;
        final isCustomer = user?.isRegularUser == true;
        
        // Debug information
        debugPrint('=== MORE SCREEN DEBUG ===');
        debugPrint('User: $user');
        debugPrint('User role: ${user?.role}');
        debugPrint('Is guest: $isGuest');
        debugPrint('Is host: $isHost');
        debugPrint('Is admin: $isAdmin');
        debugPrint('Is customer: $isCustomer');
        
    return Scaffold(
          backgroundColor: Colors.white,
          body: ListView(
              padding: EdgeInsets.zero,
              children: [
              // Guest users see sign-in prompt
              if (isGuest) _buildGuestSignInPrompt(),
              
              // Authenticated users see role-based menu
              if (!isGuest) ...[
                // User profile header
                _buildUserProfileHeader(user),
                
                // Main menu items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                          children: [
                      // My Profile - Always first for all authenticated users
                      _buildMenuItem('My Profile', Icons.person_outline, () => _showProfileScreen(context)),
                      
                      // Customer-specific menu items
                      if (isCustomer) ...[
                        _buildMenuItem('My Bookings', Icons.calendar_today, () => _showMyBookingsScreen(context)),
                        _buildMenuItem('Payment Methods', Icons.payment, () => _showPaymentMethodsScreen(context)),
                      ],
                      
                      // Host-specific menu items
                      if (isHost) ...[
                        _buildMenuItem('Host Dashboard', Icons.dashboard, () => _showHostDashboardScreen(context)),
                        _buildMenuItem('My Cars', Icons.directions_car, () => _showMyCarsScreen(context)),
                        _buildMenuItem('Booking Requests', Icons.notifications, () => _showBookingRequestsScreen(context)),
                      ],
                      
                      // Admin-specific menu items
                      if (isAdmin) ...[
                        _buildMenuItem('Admin Dashboard', Icons.admin_panel_settings, () => _showAdminDashboardScreen(context)),
                        _buildMenuItem('Car Approvals', Icons.approval, () => _showCarApprovalsScreen(context)),
                        _buildMenuItem('Host Requests', Icons.business_center, () => _showHostRequestsScreen(context)),
                        _buildMenuItem('User Management', Icons.people, () => _showUserManagementScreen(context)),
                        _buildMenuItem('Currency Converter', Icons.currency_exchange_outlined, () => _showCurrencyConverterScreen(context)),
                        _buildMenuItem('Multilingual Demo', Icons.language_outlined, () => _showMultilingualDemoScreen(context)),
                        _buildMenuItem('Debug: Create Test User', Icons.bug_report, () => _createTestUser(context)),
                      ],
                      
                      // Common menu items for all authenticated users
                      _buildMenuItem('Notifications', Icons.notifications_outlined, () => _showNotificationsScreen(context)),
                      
                      // Show "Become a Host" for all users who are not already hosts
                      if (!isHost && !isAdmin) ...[
                        _buildMenuItem('Become a Host', Icons.business, () => _showBecomeHostScreen(context)),
                      ],
                    ],
                  ),
                ),

                // Help & Support section (for all authenticated users)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                      _buildMenuItem('Help & Support', Icons.help_outline, () => _showHelpSupportScreen(context)),
                      _buildMenuItem('Legal & Privacy', Icons.privacy_tip_outlined, () => _showLegalPrivacyScreen(context)),
                      _buildMenuItem('Terms of Service', Icons.description_outlined, () => _showTermsOfServiceScreen(context)),
                    ],
                  ),
                ),
              ],
            ],
      ),
    );
      },
    );
  }

  Widget _buildGuestSignInPrompt() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
          colors: [Color(0xFF353935), Color(0xFF4A4A4A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.login,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sign In to Access More Features',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        // Features list
                        Column(
                          children: [
                            _buildFeatureItem(Icons.car_rental, 'Book Cars'),
                            const SizedBox(height: 8),
                            _buildFeatureItem(Icons.person_outline, 'Manage Profile'),
                            const SizedBox(height: 8),
                            _buildFeatureItem(Icons.calendar_today, 'Track Bookings'),
                            const SizedBox(height: 8),
                            _buildFeatureItem(Icons.payment, 'Payment Methods'),
                            const SizedBox(height: 8),
                            _buildFeatureItem(Icons.notifications, 'Get Notifications'),
                            const SizedBox(height: 8),
                            _buildFeatureItem(Icons.business, 'Become a Host'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF353935),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Sign In Now',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildUserProfileHeader(app_user.User? user) {
    // Debug information
    debugPrint('=== BUILDING USER PROFILE HEADER ===');
    debugPrint('User: $user');
    debugPrint('User name: ${user?.name}');
    debugPrint('User email: ${user?.email}');
    debugPrint('User role: ${user?.role}');
    debugPrint('Is guest: ${user?.isGuest}');
    debugPrint('Is host: ${user?.isHost}');
    debugPrint('Is admin: ${user?.isAdmin}');
    debugPrint('Is regular user: ${user?.isRegularUser}');
    
    return FloatingHeader(
      height: 100,
                  child: Column(
                    children: [
          const SizedBox(height: 20),
          
          // Profile section inside header - horizontal with centered content
          Row(
            children: [
              // Avatar/Icon
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(Icons.person, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 16),
              // Name and email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name?.isNotEmpty == true ? user!.name : (user?.email ?? 'User'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                            ),
                          ],
                        ),
              ),
              // Logout button
              IconButton(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 24,
                ),
                tooltip: 'Logout',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
      child: _moreTile(icon, title, onTap: onTap),
    );
  }

  Future<void> _switchUserRole(BuildContext context, String role) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    switch (role) {
      case 'logout':
        await authService.logout();
        break;
      default:
        // For now, just show a message that demo accounts are removed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo accounts have been removed. Please use real authentication.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully logged out'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildHostStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF353935), // Updated to Onyx
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _moreTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF353935)), // Updated to Onyx
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF353935), // Updated to Onyx
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF353935)), // Updated to Onyx
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Regular User Navigation Methods
  void _showProfileScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserProfileEditScreen(),
      ),
    );
  }

  void _showMyBookingsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingHistoryScreen(),
      ),
    );
  }

  void _showPaymentMethodsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentMethodsScreen(),
      ),
    );
  }

  void _showNotificationsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }

  void _showHelpSupportScreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text('Get help with your account or report issues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLegalPrivacyScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LegalPrivacyScreen(),
      ),
    );
  }

  void _showTermsOfServiceScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsOfServiceScreen(),
      ),
    );
  }

  void _showBecomeHostScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BecomeHostScreen(),
      ),
    );
  }

  void _showCurrencyConverterScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CurrencyConverterScreen(),
      ),
    );
  }

  void _showMultilingualDemoScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MultilingualDemoScreen(),
      ),
    );
  }

  void _createTestUser(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.createManualTestUser();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test user created. Check debug console for details.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Host-specific navigation methods
  void _showHostDashboardScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HostDashboardScreen(),
      ),
    );
  }

  void _showMyCarsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyCarsScreen(),
      ),
    );
  }

  void _showBookingRequestsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyBookingsScreen(),
      ),
    );
  }

  // Admin-specific navigation methods
  void _showAdminDashboardScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminCarApprovalScreen(),
      ),
    );
  }

  void _showCarApprovalsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminCarApprovalScreen(),
      ),
    );
  }

  void _showHostRequestsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminHostApprovalScreen(),
      ),
    );
  }

  void _showUserManagementScreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Management'),
        content: const Text('Manage platform users and permissions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNewNotificationsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(), // Use the new notifications screen
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF353935).withValues(alpha: 0.05), // Updated to Onyx
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Icon container
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF353935).withValues(alpha: 0.1), // Updated to Onyx
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF353935).withValues(alpha: 0.2), // Updated to Onyx
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        size: 36,
                        color: Color(0xFF353935), // Updated to Onyx
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Logout',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF353935), // Updated to Onyx
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Are you sure you want to logout?',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF6C757D),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE9ECEF),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.of(context).pop(),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6C757D),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Logout button
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF353935), // Updated to Onyx
                              Color(0xFF353935), // Updated to Onyx
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF353935).withValues(alpha: 0.3), // Updated to Onyx
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.of(context).pop();
                              // Logout logic
                              final authService = Provider.of<AuthService>(context, listen: false);
                              authService.logout();
                              // Navigate to login screen
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.0, 1.0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 300),
                                ),
                              );
                            },
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.logout_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Logout',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
} 