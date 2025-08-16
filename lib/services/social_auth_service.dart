import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SocialAuthService extends ChangeNotifier {
  static final SocialAuthService _instance = SocialAuthService._internal();
  factory SocialAuthService() => _instance;
  SocialAuthService._internal();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Google Sign-In using OAuth web flow
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'ster://login-callback/',
      );

      // For demo purposes, simulate successful login
      await Future.delayed(const Duration(seconds: 2));
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session?.user != null) {
        return {
          'success': true,
          'user': session!.user,
          'userInfo': {
            'id': session.user.id,
            'email': session.user.email,
            'name': session.user.userMetadata?['name'] ?? 'User',
            'photoUrl': session.user.userMetadata?['picture'],
          },
          'provider': 'google',
        };
      }

      return null;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apple Sign-In using OAuth web flow
  Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'ster://login-callback/',
      );

      // For demo purposes, simulate successful login
      await Future.delayed(const Duration(seconds: 2));
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session?.user != null) {
        return {
          'success': true,
          'user': session!.user,
          'userInfo': {
            'id': session.user.id,
            'email': session.user.email,
            'name': session.user.userMetadata?['name'] ?? 'User',
            'photoUrl': session.user.userMetadata?['picture'],
          },
          'provider': 'apple',
        };
      }

      return null;
    } catch (e) {
      print('Error signing in with Apple: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Facebook Sign-In using OAuth web flow
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'ster://login-callback/',
      );

      // For demo purposes, simulate successful login
      await Future.delayed(const Duration(seconds: 2));
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session?.user != null) {
        return {
          'success': true,
          'user': session!.user,
          'userInfo': {
            'id': session.user.id,
            'email': session.user.email,
            'name': session.user.userMetadata?['name'] ?? 'User',
            'photoUrl': session.user.userMetadata?['picture'],
          },
          'provider': 'facebook',
        };
      }

      return null;
    } catch (e) {
      print('Error signing in with Facebook: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out from all social providers
  Future<void> signOut() async {
    try {
      // Sign out from Supabase
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Check if user is signed in with any social provider
  Future<bool> isSignedIn() async {
    try {
      // Check Supabase session
      final session = Supabase.instance.client.auth.currentSession;
      return session != null;
    } catch (e) {
      print('Error checking sign-in status: $e');
      return false;
    }
  }

  // Get current user info from social providers
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      // Try Supabase session
      final session = Supabase.instance.client.auth.currentSession;
      if (session?.user != null) {
        return {
          'provider': 'supabase',
          'id': session!.user.id,
          'email': session.user.email,
          'name': session.user.userMetadata?['name'],
        };
      }

      return null;
    } catch (e) {
      print('Error getting current user info: $e');
      return null;
    }
  }
} 