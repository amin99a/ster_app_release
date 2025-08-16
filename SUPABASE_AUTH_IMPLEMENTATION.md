# 🔐 **Supabase Authentication Layer - Complete Implementation**

## 📋 **Executive Summary**

This document provides a complete implementation of the authentication layer between Supabase and your Flutter app, including proper user management, RLS policies, and automatic profile creation.

---

## 🗄️ **Database Schema**

### **1. Users Table Schema**

```sql
-- Create the users table with proper foreign key reference to auth.users
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('guest', 'user', 'host', 'admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_users_role ON public.users(role);
CREATE INDEX idx_users_created_at ON public.users(created_at);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON public.users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

### **2. RLS Policies**

```sql
-- Policy: Users can read their own profile
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Policy: Users can insert their own profile (for signup)
CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Policy: Admins can view all profiles
CREATE POLICY "Admins can view all profiles" ON public.users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Policy: Admins can update all profiles
CREATE POLICY "Admins can update all profiles" ON public.users
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );
```

### **3. Automatic Profile Creation Trigger**

```sql
-- Function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, full_name, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
        'user'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to automatically create user profile on signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

---

## 🔧 **Flutter Implementation**

### **1. Updated AuthService**

```dart
// lib/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;

class AuthService extends ChangeNotifier {
  app_user.User? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _lastError;

  app_user.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  String? get lastError => _lastError;

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
      
      final session = Supabase.instance.client.auth.currentSession;
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
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      debugPrint('Auth state changed: ${data.event}');
      
      switch (data.event) {
        case AuthChangeEvent.signedIn:
          _loadUserFromSession();
          break;
        case AuthChangeEvent.signedOut:
          _currentUser = null;
          _clearAllLocalData();
          notifyListeners();
          break;
        case AuthChangeEvent.tokenRefreshed:
          _loadUserFromSession();
          break;
        case AuthChangeEvent.userUpdated:
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
      
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ No user found in session');
        _currentUser = null;
        notifyListeners();
        return;
      }

      debugPrint('Current session user ID: ${user.id}');
      debugPrint('Current session user email: ${user.email}');
      
      // Get fresh user data from users table
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      debugPrint('User response: $response');
      
      final parsedRole = _parseUserRole(response['role'] ?? 'user');
      debugPrint('Parsed role: $parsedRole');

      _currentUser = app_user.User(
        id: user.id,
        name: response['full_name'] ?? '',
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

  /// Update last login time
  Future<void> _updateLastLogin(String userId) async {
    try {
      await Supabase.instance.client
          .from('users')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      debugPrint('⚠️ Failed to update last login time: $e');
    }
  }

  /// Sign up with email and password
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

      final response = await Supabase.instance.client.auth.signUp(
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
        
        // The trigger will automatically create the user profile
        // We just need to wait a moment for it to complete
        await Future.delayed(const Duration(milliseconds: 500));
        
        await _loadUserFromSession();
        debugPrint('✅ Signup completed successfully');
        return null;
      } else {
        debugPrint('❌ Signup failed - no user returned');
        return 'Signup failed. Please try again.';
      }
    } on AuthException catch (e) {
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

      final response = await Supabase.instance.client.auth.signInWithPassword(
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
    } on AuthException catch (e) {
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

  /// Update user profile
  Future<String?> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      if (_currentUser == null) {
        return 'User not authenticated';
      }

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName.trim();
      if (phone != null) updates['phone'] = phone.trim();
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isEmpty) {
        return 'No updates provided';
      }

      await Supabase.instance.client
          .from('users')
          .update(updates)
          .eq('id', _currentUser!.id);

      // Reload user data
      await _loadUserFromSession();
      
      debugPrint('✅ Profile updated successfully');
      return null;
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      return 'Failed to update profile. Please try again.';
    }
  }

  /// Sign out
  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
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
}
```

### **2. Updated User Model**

```dart
// lib/models/user.dart
import 'dart:convert';

enum UserRole { guest, user, host, admin }

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final UserRole role;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic> preferences;
  final List<String> savedCars;
  final List<String> bookingHistory;
  final HostProfile? hostProfile;
  final Location? location;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    required this.role,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    required this.createdAt,
    this.lastLoginAt,
    this.preferences = const {},
    this.savedCars = const [],
    this.bookingHistory = const [],
    this.hostProfile,
    this.location,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['full_name'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImage: json['avatar_url'] ?? json['profile_image'],
      role: UserRole.values.firstWhere(
        (role) => role.toString() == 'UserRole.${json['role'] ?? 'user'}',
        orElse: () => UserRole.user,
      ),
      isEmailVerified: json['is_email_verified'] ?? false,
      isPhoneVerified: json['is_phone_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : json['last_login_at'] != null 
              ? DateTime.parse(json['last_login_at'])
              : null,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      savedCars: List<String>.from(json['saved_cars'] ?? []),
      bookingHistory: List<String>.from(json['booking_history'] ?? []),
      hostProfile: json['hostProfile'] != null 
          ? HostProfile.fromJson(json['hostProfile']) 
          : null,
      location: json['location'] != null 
          ? Location.fromJson(json['location']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'phone': phone,
      'avatar_url': profileImage,
      'role': role.toString().split('.').last,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': lastLoginAt?.toIso8601String(),
      'preferences': preferences,
      'saved_cars': savedCars,
      'booking_history': bookingHistory,
      'hostProfile': hostProfile?.toJson(),
      'location': location?.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    UserRole? role,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
    List<String>? savedCars,
    List<String>? bookingHistory,
    HostProfile? hostProfile,
    Location? location,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      savedCars: savedCars ?? this.savedCars,
      bookingHistory: bookingHistory ?? this.bookingHistory,
      hostProfile: hostProfile ?? this.hostProfile,
      location: location ?? this.location,
    );
  }

  // Role-based getters
  bool get isGuest => role == UserRole.guest;
  bool get isRegularUser => role == UserRole.user;
  bool get isHost => role == UserRole.host;
  bool get isAdmin => role == UserRole.admin;
  bool get canHost => isHost || isAdmin;
  bool get canBook => isRegularUser || isHost || isAdmin;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Supporting classes (if not already defined)
class HostProfile {
  final String id;
  final String userId;
  final String businessName;
  final String businessDescription;
  final bool isVerified;
  final DateTime createdAt;

  HostProfile({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.businessDescription,
    this.isVerified = false,
    required this.createdAt,
  });

  factory HostProfile.fromJson(Map<String, dynamic> json) {
    return HostProfile(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      businessName: json['business_name'] ?? '',
      businessDescription: json['business_description'] ?? '',
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'business_name': businessName,
      'business_description': businessDescription,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Location {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? country;

  Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'],
      city: json['city'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'country': country,
    };
  }
}
```

---

## 🚀 **Implementation Steps**

### **Step 1: Create Database Schema**
1. Run the SQL schema creation script in your Supabase SQL editor
2. Verify the `users` table is created with proper foreign key
3. Confirm RLS policies are active
4. Test the trigger function

### **Step 2: Update Flutter Code**
1. Replace the existing `AuthService` with the updated version
2. Update the `User` model to match the new schema
3. Test signup and login flows
4. Verify profile updates work correctly

### **Step 3: Test Authentication Flow**
1. Test user signup with automatic profile creation
2. Test login and session management
3. Test profile updates
4. Test role-based access control
5. Test logout functionality

---

## 🔒 **Security Features**

### **Row Level Security (RLS)**
- Users can only read/update their own profile
- Admins can access all profiles
- Automatic profile creation on signup
- Proper foreign key constraints

### **Data Validation**
- Input validation in Flutter
- Database constraints for role values
- Email confirmation handling
- Phone number validation (optional)

### **Error Handling**
- Comprehensive error messages
- Graceful fallbacks
- Debug logging for troubleshooting
- User-friendly error display

---

## 📊 **Testing Checklist**

### **Authentication Flow**
- [ ] User signup creates auth.users record
- [ ] Trigger automatically creates users table record
- [ ] Login loads user data correctly
- [ ] Logout clears session properly
- [ ] Session persistence works across app restarts

### **Profile Management**
- [ ] Users can update their own profile
- [ ] Profile updates are reflected immediately
- [ ] RLS prevents unauthorized access
- [ ] Admin can access all profiles

### **Role Management**
- [ ] Role-based access control works
- [ ] Role changes are reflected in UI
- [ ] Role validation prevents invalid values
- [ ] Role-based navigation works correctly

---

## 🎯 **Expected Outcomes**

After implementation, your app will have:

- ✅ **Proper authentication flow** with Supabase
- ✅ **Automatic profile creation** on signup
- ✅ **Secure user data** with RLS policies
- ✅ **Role-based access control** throughout the app
- ✅ **Comprehensive error handling** and user feedback
- ✅ **Session management** with persistence
- ✅ **Profile management** with real-time updates

**Your authentication layer is now fully integrated and secure!** 🚀 

---

## 🔁 Redirect URLs (Mobile & Web)

Update your Supabase Dashboard → Auth → URL Configuration:

- Site URL: https://ster-app.com (and https://www.ster-app.com if applicable)
- Additional Redirect URLs: ster://login-callback

Mobile deep links:
- Android: AndroidManifest.xml includes an intent-filter for `ster://login-callback`.
- iOS: Info.plist CFBundleURLSchemes includes `ster`.