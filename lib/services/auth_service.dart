import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_user;

import 'heart_state_service.dart';
import 'favorite_service.dart';
import 'package:url_launcher/url_launcher.dart' show LaunchMode;

class AuthService extends ChangeNotifier {
  app_user.User? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _lastError;
  String? _lastSignupEmail;

  app_user.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  String? get lastError => _lastError;
  String? get lastSignupEmail => _lastSignupEmail;

  AuthService() {
    _initializeAuth();
    _setupAuthListener();
  }

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('=== INITIALIZING AUTH ===');
      
      final session = supa.Supabase.instance.client.auth.currentSession;
      if (session != null) {
        debugPrint('Found existing session, loading user...');
        await _loadUserFromSession();
      } else {
        debugPrint('No existing session found - user will need to login');
        _currentUser = null;
      }
    } catch (e) {
      debugPrint('❌ Error initializing auth: $e');
      _lastError = 'Failed to initialize authentication';
      _currentUser = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Setup authentication state change listener
  void _setupAuthListener() {
    supa.Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      debugPrint('Auth state changed: ${data.event}');
      
      switch (data.event) {
        case supa.AuthChangeEvent.signedIn:
          _loadUserFromSession();
          break;
        case supa.AuthChangeEvent.signedOut:
          _currentUser = null;
          _clearAllLocalData();
          notifyListeners();
          break;
        case supa.AuthChangeEvent.tokenRefreshed:
          _loadUserFromSession();
          break;
        case supa.AuthChangeEvent.userUpdated:
          _loadUserFromSession();
          break;
        default:
          break;
      }
    });
  }

  /// Load user from current session
  Future<void> _loadUserFromSession() async {
    try {
      debugPrint('=== LOADING USER FROM SESSION ===');
      
      final user = supa.Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ No user found in session');
        _currentUser = null;
        notifyListeners();
        return;
      }

      debugPrint('Current session user ID: ${user.id}');
      debugPrint('Current session user email: ${user.email}');
      
      // Get fresh user data from user_profiles table
      final response = await supa.Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      debugPrint('User response: $response');
      
      final parsedRole = _parseUserRole(response['role'] ?? 'user');
      debugPrint('Parsed role: $parsedRole');
      debugPrint('Name from DB: ${response['name']}');
      debugPrint('Full name from DB: ${response['full_name']}');
      debugPrint('Email from DB: ${response['email']}');
      debugPrint('Phone from DB: ${response['phone']}');
      debugPrint('Avatar URL from DB: ${response['avatar_url']}');

      _currentUser = app_user.User(
        id: user.id,
        name: response['name'] ?? response['full_name'] ?? '',  // Try both column names
        email: user.email ?? '',
        phone: response['phone'],
        profileImage: response['avatar_url'],
        role: parsedRole,
        isEmailVerified: user.emailConfirmedAt != null,
        isPhoneVerified: false, // Will be implemented separately
        createdAt: DateTime.parse(response['created_at'] ?? DateTime.now().toIso8601String()),
        lastLoginAt: response['updated_at'] != null 
            ? DateTime.parse(response['updated_at'])
            : null,
        preferences: {}, // Will be implemented separately
        savedCars: [], // Will be implemented separately
        bookingHistory: [], // Will be implemented separately
      );
      
      // Update last login time
      await _updateLastLogin(user.id);
      
      notifyListeners();
      debugPrint('✅ User loaded successfully from session');
    } catch (e) {
      debugPrint('❌ Error loading user profile: $e');
      _lastError = 'Failed to load user profile';
      _currentUser = null;
      notifyListeners();
    }
  }

  /// Create user profile in user_profiles table
  Future<void> _createUserProfile(String userId, String fullName, String email) async {
    try {
      debugPrint('=== CREATING USER PROFILE ===');
      debugPrint('User ID: $userId');
      debugPrint('Full name: $fullName');
      debugPrint('Email: $email');
      
      // First check if profile already exists (created by trigger)
      final existing = await supa.Supabase.instance.client
          .from('user_profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      
      if (existing != null) {
        debugPrint('✅ User profile already exists (created by trigger)');
        return;
      }
      
      debugPrint('Profile doesn\'t exist, creating manually...');
      
      // Use upsert to handle cases where profile might be created between check and insert
      await supa.Supabase.instance.client
          .from('user_profiles')
          .upsert({
            'id': userId,
            'name': fullName.trim(),  // Use 'name' column (database uses this)
            'full_name': fullName.trim(),  // Also set full_name if it exists
            'email': email.trim(),
            'phone': null, // Will be set when user updates profile
            'avatar_url': null, // Will be set when user uploads profile image
            'role': 'user',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      debugPrint('✅ User profile created/updated successfully in user_profiles table');
    } catch (e) {
      debugPrint('❌ Error creating user profile: $e');
      debugPrint('This might be due to RLS policies or the trigger already handled it');
      
      // Try to verify the profile was created by the trigger
      try {
        final checkProfile = await supa.Supabase.instance.client
            .from('user_profiles')
            .select('id, name, full_name')
            .eq('id', userId)
            .maybeSingle();
        
        if (checkProfile != null) {
          final profileName = checkProfile['name'] ?? checkProfile['full_name'] ?? 'Unknown';
          debugPrint('✅ Profile exists (likely created by trigger): $profileName');
        } else {
          debugPrint('❌ Profile creation failed and no profile found');
        }
      } catch (checkError) {
        debugPrint('❌ Could not verify profile creation: $checkError');
      }
    }
  }

  /// Update last login time
  Future<void> _updateLastLogin(String userId) async {
    try {
      await supa.Supabase.instance.client
          .from('user_profiles')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      debugPrint('⚠️ Failed to update last login time: $e');
    }
  }

  /// Refresh user session and reload user data
  Future<void> refreshUserSession() async {
    try {
      debugPrint('=== REFRESHING USER SESSION ===');
      
      // Get fresh session from Supabase
      await supa.Supabase.instance.client.auth.refreshSession();
      
      // Reload user data
      await _loadUserFromSession();
      
      debugPrint('✅ User session refreshed successfully');
    } catch (e) {
      debugPrint('❌ Error refreshing user session: $e');
    }
  }

  /// Check if current user needs email verification
  bool get needsEmailVerification {
    final user = supa.Supabase.instance.client.auth.currentUser;
    return user != null && user.emailConfirmedAt == null;
  }

  /// Force check email verification status from server
  Future<bool> checkEmailVerificationStatus() async {
    try {
      final response = await supa.Supabase.instance.client.auth.getUser();
      final user = response.user;
      
      debugPrint('=== CHECKING EMAIL VERIFICATION STATUS ===');
      debugPrint('User ID: ${user?.id}');
      debugPrint('Email: ${user?.email}');
      debugPrint('Email confirmed at: ${user?.emailConfirmedAt}');
      
      if (user?.emailConfirmedAt != null) {
        debugPrint('✅ Email is verified!');
        // Reload user session to update local state
        await _loadUserFromSession();
        return true;
      } else {
        debugPrint('❌ Email still not verified');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error checking email verification: $e');
      return false;
    }
  }

  /// Sign up with email and password
  /// Returns: null if successful, error message if failed
  /// Use [lastSignupEmail] to get the email for verification if needed
  Future<String?> signUp(String fullName, String email, String password) async {
    try {
      _isLoading = true;
      _lastError = null;
      notifyListeners();
      
      debugPrint('=== SIGNUP DEBUG ===');
      debugPrint('Attempting signup with: $email');
      debugPrint('Full name: $fullName');
      debugPrint('Password length: ${password.length}');

      // Validate input
      if (fullName.trim().isEmpty) {
        return 'Full name is required';
      }
      if (email.trim().isEmpty || !email.contains('@')) {
        return 'Valid email is required';
      }
      if (password.length < 6) {
        return 'Password must be at least 6 characters';
      }

      final response = await supa.Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': fullName.trim(),
        },
      );
      
      debugPrint('Signup response received');
      debugPrint('Response user: ${response.user}');
      debugPrint('Response session: ${response.session}');
      
      final user = response.user;
      if (user != null) {
        debugPrint('✅ User created successfully!');
        debugPrint('User ID: ${user.id}');
        debugPrint('User email: ${user.email}');
        debugPrint('Email confirmed: ${user.emailConfirmedAt}');
        
        // Store the signup email for verification screen
        _lastSignupEmail = email.trim();
        
        // Create user profile in user_profiles table
        await _createUserProfile(user.id, fullName.trim(), email.trim());
        
        // Check if email verification is required
        if (user.emailConfirmedAt == null) {
          debugPrint('📧 Email verification required');
          // Profile created but don't load user session yet - wait for email verification
          debugPrint('✅ Signup completed - email verification needed');
          return null; // Success but needs verification
        } else {
          debugPrint('✅ Email already verified during signup');
          // Profile already created, now load the user session
          await _loadUserFromSession();
          debugPrint('✅ Signup completed successfully');
          return null;
        }
      } else {
        debugPrint('❌ Signup failed - no user returned');
        return 'Signup failed. Please try again.';
      }
    } on supa.AuthException catch (e) {
      debugPrint('❌ AuthException during signup: ${e.message}');
      _lastError = e.message;
      return _handleAuthError(e.message);
    } catch (e) {
      debugPrint('❌ Unexpected signup error: $e');
      _lastError = 'An unexpected error occurred';
      return 'An unexpected error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<String?> login(String email, String password) async {
    try {
      _isLoading = true;
      _lastError = null;
      notifyListeners();
      
      debugPrint('=== LOGIN DEBUG ===');
      debugPrint('Attempting login with: $email');
      
      // Validate input
      if (email.trim().isEmpty || !email.contains('@')) {
        return 'Valid email is required';
      }
      if (password.isEmpty) {
        return 'Password is required';
      }

      final response = await supa.Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      
      debugPrint('Login response received');
      debugPrint('Response user: ${response.user}');
      debugPrint('Response session: ${response.session}');

      if (response.user != null) {
        debugPrint('✅ Login successful!');
        await _loadUserFromSession();
        return null;
      } else {
        debugPrint('❌ Login failed - no user returned');
        return 'Login failed. Please check your credentials.';
      }
    } on supa.AuthException catch (e) {
      debugPrint('❌ AuthException during login: ${e.message}');
      _lastError = e.message;
      return _handleAuthError(e.message);
    } catch (e) {
      debugPrint('❌ Unexpected login error: $e');
      _lastError = 'An unexpected error occurred';
      return 'An unexpected error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with Google OAuth
  Future<String?> signInWithGoogle() async {
    try {
      _isLoading = true;
      _lastError = null;
      notifyListeners();
      
      debugPrint('=== GOOGLE OAUTH SIGN IN ===');
      
      await supa.Supabase.instance.client.auth.signInWithOAuth(
        supa.OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      
      debugPrint('✅ Google OAuth initiated successfully');
      return null;
    } on supa.AuthException catch (e) {
      debugPrint('❌ AuthException during Google OAuth: ${e.message}');
      _lastError = e.message;
      return _handleAuthError(e.message);
    } catch (e) {
      debugPrint('❌ Unexpected Google OAuth error: $e');
      _lastError = 'An unexpected error occurred';
      return 'An unexpected error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with Apple OAuth
  Future<String?> signInWithApple() async {
    try {
      _isLoading = true;
      _lastError = null;
      notifyListeners();
      
      debugPrint('=== APPLE OAUTH SIGN IN ===');
      
      await supa.Supabase.instance.client.auth.signInWithOAuth(
        supa.OAuthProvider.apple,
        redirectTo: 'io.supabase.flutter://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      
      debugPrint('✅ Apple OAuth initiated successfully');
      return null;
    } on supa.AuthException catch (e) {
      debugPrint('❌ AuthException during Apple OAuth: ${e.message}');
      _lastError = e.message;
      return _handleAuthError(e.message);
    } catch (e) {
      debugPrint('❌ Unexpected Apple OAuth error: $e');
      _lastError = 'An unexpected error occurred';
      return 'An unexpected error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<String?> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      debugPrint('=== UPDATING USER PROFILE ===');
      
      final user = supa.Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return 'No authenticated user found';
      }

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isEmpty) {
        return 'No updates provided';
      }

      await supa.Supabase.instance.client
          .from('user_profiles')
          .update(updates)
          .eq('id', user.id);

      // Reload user data
      await _loadUserFromSession();
      
      debugPrint('✅ Profile updated successfully');
      return null;
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      return 'Failed to update profile';
    }
  }

  /// Sign out
  Future<void> logout() async {
    try {
      await supa.Supabase.instance.client.auth.signOut();
      _currentUser = null;
      _clearAllLocalData();
      notifyListeners();
      debugPrint('✅ Logout successful');
    } catch (e) {
      debugPrint('❌ Error during logout: $e');
    }
  }

  /// Clear all local data
  void _clearAllLocalData() {
    // Clear any cached data, preferences, etc.
    debugPrint('Clearing local data...');
  }

  /// Parse user role from string
  app_user.UserRole _parseUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'guest':
        return app_user.UserRole.guest;
      case 'user':
        return app_user.UserRole.user;
      case 'host':
        return app_user.UserRole.host;
      case 'admin':
        return app_user.UserRole.admin;
      default:
        return app_user.UserRole.user;
    }
  }

  /// Handle authentication errors
  String _handleAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    } else if (message.contains('Email not confirmed')) {
      return 'Please check your email and confirm your account';
    } else if (message.contains('User already registered')) {
      return 'An account with this email already exists';
    } else if (message.contains('Password should be at least')) {
      return 'Password must be at least 6 characters';
    } else {
      return message;
    }
  }

  /// Debug current user state
  void debugCurrentUserState() {
    debugPrint('=== DEBUG CURRENT USER STATE ===');
    debugPrint('Current user: $_currentUser');
    debugPrint('Is authenticated: $isAuthenticated');
    debugPrint('Is loading: $_isLoading');
    debugPrint('Is initialized: $_isInitialized');
    debugPrint('Last error: $_lastError');
    
    final session = supa.Supabase.instance.client.auth.currentSession;
    debugPrint('Supabase session: ${session != null ? 'Active' : 'None'}');
    if (session != null) {
      debugPrint('Session user ID: ${session.user.id}');
      debugPrint('Session user email: ${session.user.email}');
    }
  }

  /// Force refresh user state
  Future<void> forceRefreshUserState() async {
    try {
      debugPrint('=== FORCE REFRESHING USER STATE ===');
      
      // Clear current user state
      _currentUser = null;
      notifyListeners();
      
      // Check for active session
      final session = supa.Supabase.instance.client.auth.currentSession;
      if (session != null) {
        debugPrint('Active session found, reloading user...');
        await _loadUserFromSession();
      } else {
        debugPrint('No active session found');
      }
    } catch (e) {
      debugPrint('❌ Error refreshing user state: $e');
    }
  }

  /// Reset app state completely
  Future<void> resetAppState() async {
    try {
      debugPrint('=== RESETTING APP STATE ===');
      
      // Sign out from any session
      try {
        await supa.Supabase.instance.client.auth.signOut();
        debugPrint('✅ Signed out from Supabase');
      } catch (e) {
        debugPrint('No session to sign out from');
      }
      
      // Clear all local data
      _clearAllLocalData();
      
      // Clear current user state
      _currentUser = null;
      _isLoading = false;
      _lastError = null;
      notifyListeners();
      
      debugPrint('✅ App state completely reset');
    } catch (e) {
      debugPrint('❌ Error resetting app state: $e');
    }
  }

  /// Debug method to create a test user
  Future<void> createTestUser() async {
    try {
      debugPrint('=== CREATING TEST USER ===');
      
      // Create a test user with proper data
      final response = await supa.Supabase.instance.client.auth.signUp(
        email: 'test@example.com',
        password: 'testpassword123',
        data: {
          'name': 'Test User',
        },
      );
      
      if (response.user != null) {
        debugPrint('✅ Test user created successfully!');
        debugPrint('User ID: ${response.user!.id}');
        debugPrint('User email: ${response.user!.email}');
        
        // Wait for trigger to complete
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Load the user data
        await _loadUserFromSession();
        
        debugPrint('✅ Test user loaded successfully!');
        debugPrint('Current user name: ${_currentUser?.name}');
        debugPrint('Current user email: ${_currentUser?.email}');
        debugPrint('Current user role: ${_currentUser?.role}');
      } else {
        debugPrint('❌ Test user creation failed');
      }
    } catch (e) {
      debugPrint('❌ Error creating test user: $e');
    }
  }

  /// Debug method to manually create a test user in the database
  Future<void> createManualTestUser() async {
    try {
      debugPrint('=== CREATING MANUAL TEST USER ===');
      
      final session = supa.Supabase.instance.client.auth.currentSession;
      if (session == null) {
        debugPrint('❌ No active session found');
        return;
      }
      
      final userId = session.user.id;
      debugPrint('Current user ID: $userId');
      
      // Manually insert a test user with proper data
      final response = await supa.Supabase.instance.client
          .from('user_profiles')
          .upsert({
            'id': userId,
            'full_name': 'Test User Full Name',
            'email': session.user.email,
            'role': 'user',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      debugPrint('✅ Manual test user created/updated successfully!');
      debugPrint('Response: $response');
      
      // Reload user data
      await _loadUserFromSession();
      
      debugPrint('✅ Test user loaded successfully!');
      debugPrint('Current user name: ${_currentUser?.name}');
      debugPrint('Current user email: ${_currentUser?.email}');
      debugPrint('Current user role: ${_currentUser?.role}');
    } catch (e) {
      debugPrint('❌ Error creating manual test user: $e');
    }
  }
} 