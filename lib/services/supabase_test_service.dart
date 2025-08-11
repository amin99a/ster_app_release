import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseTestService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Test basic connectivity to Supabase
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      debugPrint('🔍 Testing Supabase connection...');
      
      // Test 1: Basic connection
      final response = await _supabase.from('users').select('count').limit(1);
      debugPrint('✅ Basic connection successful');
      
      // Test 2: Auth status
      final user = _supabase.auth.currentUser;
      debugPrint('👤 Current user: ${user?.id ?? 'None'}');
      
      // Test 3: Project info
      final projectUrl = _supabase.supabaseUrl;
      debugPrint('🌐 Project URL: $projectUrl');
      
      return {
        'success': true,
        'message': 'Connection successful',
        'user': user?.id,
        'projectUrl': projectUrl,
      };
    } catch (e) {
      debugPrint('❌ Connection failed: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Connection failed',
      };
    }
  }

  /// Test authentication flow
  static Future<Map<String, dynamic>> testAuth() async {
    try {
      debugPrint('🔐 Testing authentication...');
      
      // Test signup
      final signupResponse = await _supabase.auth.signUp(
        email: 'test@example.com',
        password: 'testpassword123',
      );
      
      debugPrint('✅ Signup test completed');
      
      return {
        'success': true,
        'message': 'Authentication test successful',
        'signupResponse': signupResponse.user?.id,
      };
    } catch (e) {
      debugPrint('❌ Authentication test failed: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Authentication test failed',
      };
    }
  }

  /// Get diagnostic information
  static Map<String, dynamic> getDiagnostics() {
    return {
      'projectUrl': _supabase.supabaseUrl,
      'anonKey': _supabase.supabaseKey.substring(0, 20) + '...',
      'currentUser': _supabase.auth.currentUser?.id,
      'session': _supabase.auth.currentSession != null,
    };
  }
} 