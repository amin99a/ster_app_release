import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing demo/seeded data in development environment
/// This helps developers understand and work with the realistic test data
class DemoDataService {
  static const String _logPrefix = '[DemoDataService]';

  /// Demo user IDs for easy reference in development
  static const Map<String, String> demoUserIds = {
    'sarah_customer': '11111111-1111-1111-1111-111111111111',
    'ahmed_customer': '22222222-2222-2222-2222-222222222222',
    'mohamed_host': '33333333-3333-3333-3333-333333333333',
    'fatima_host': '44444444-4444-4444-4444-444444444444',
    'admin': '55555555-5555-5555-5555-555555555555',
    'yacine_pending_host': '66666666-6666-6666-6666-666666666666',
  };

  /// Demo car IDs for easy reference in development
  static const Map<String, String> demoCarIds = {
    'renault_clio': '77777777-7777-7777-7777-777777777777',
    'hyundai_tucson': '88888888-8888-8888-8888-888888888888',
    'mercedes_c_class': '99999999-9999-9999-9999-999999999999',
    'volkswagen_golf': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'tesla_model_3': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  };

  /// Get all demo users for testing different roles
  static Future<List<Map<String, dynamic>>> getDemoUsers() async {
    try {
      debugPrint('$_logPrefix Fetching demo users...');
      
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select('*')
          .in_('id', demoUserIds.values.toList())
          .order('created_at');

      debugPrint('$_logPrefix Found ${response.length} demo users');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('$_logPrefix Error fetching demo users: $e');
      return [];
    }
  }

  /// Get demo cars with full details
  static Future<List<Map<String, dynamic>>> getDemoCars() async {
    try {
      debugPrint('$_logPrefix Fetching demo cars...');
      
      final response = await Supabase.instance.client
          .from('cars')
          .select('*')
          .in_('id', demoCarIds.values.toList())
          .order('created_at');

      debugPrint('$_logPrefix Found ${response.length} demo cars');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('$_logPrefix Error fetching demo cars: $e');
      return [];
    }
  }

  /// Get demo bookings with user and car details
  static Future<List<Map<String, dynamic>>> getDemoBookings() async {
    try {
      debugPrint('$_logPrefix Fetching demo bookings...');
      
      final response = await Supabase.instance.client
          .from('bookings')
          .select('''
            *,
            user_profiles!bookings_user_id_fkey(name, email),
            cars(name, brand, model, image),
            host:user_profiles!bookings_host_id_fkey(name)
          ''')
          .order('created_at', ascending: false);

      debugPrint('$_logPrefix Found ${response.length} demo bookings');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('$_logPrefix Error fetching demo bookings: $e');
      return [];
    }
  }

  /// Get demo reviews with full context
  static Future<List<Map<String, dynamic>>> getDemoReviews() async {
    try {
      debugPrint('$_logPrefix Fetching demo reviews...');
      
      final response = await Supabase.instance.client
          .from('reviews')
          .select('''
            *,
            reviewer:user_profiles!reviews_reviewer_id_fkey(name),
            reviewed:user_profiles!reviews_reviewed_id_fkey(name),
            cars(name, brand, model),
            bookings(start_date, end_date)
          ''')
          .order('created_at', ascending: false);

      debugPrint('$_logPrefix Found ${response.length} demo reviews');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('$_logPrefix Error fetching demo reviews: $e');
      return [];
    }
  }

  /// Get host requests for admin testing
  static Future<List<Map<String, dynamic>>> getDemoHostRequests() async {
    try {
      debugPrint('$_logPrefix Fetching demo host requests...');
      
      final response = await Supabase.instance.client
          .from('host_requests')
          .select('''
            *,
            user_profiles!host_requests_user_id_fkey(name, email),
            reviewer:user_profiles!host_requests_reviewed_by_fkey(name)
          ''')
          .order('created_at', ascending: false);

      debugPrint('$_logPrefix Found ${response.length} demo host requests');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('$_logPrefix Error fetching demo host requests: $e');
      return [];
    }
  }

  /// Get admin activity logs
  static Future<List<Map<String, dynamic>>> getDemoAdminLogs() async {
    try {
      debugPrint('$_logPrefix Fetching demo admin logs...');
      
      final response = await Supabase.instance.client
          .from('admin_logs')
          .select('''
            *,
            admin:user_profiles!admin_logs_admin_id_fkey(name)
          ''')
          .order('created_at', ascending: false);

      debugPrint('$_logPrefix Found ${response.length} demo admin logs');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('$_logPrefix Error fetching demo admin logs: $e');
      return [];
    }
  }

  /// Get user's demo data by role
  static Future<Map<String, dynamic>> getUserDemoData(String userId) async {
    try {
      debugPrint('$_logPrefix Fetching demo data for user: $userId');
      
      // Get user profile
      final userProfile = await Supabase.instance.client
          .from('user_profiles')
          .select('*')
          .eq('id', userId)
          .single();

      final role = userProfile['role'] as String;
      Map<String, dynamic> demoData = {'profile': userProfile, 'role': role};

      // Get role-specific data
      switch (role) {
        case 'user':
          // Get user's bookings and reviews
          final bookings = await Supabase.instance.client
              .from('bookings')
              .select('''
                *,
                cars(name, brand, model, image),
                host:user_profiles!bookings_host_id_fkey(name)
              ''')
              .eq('user_id', userId)
              .order('created_at', ascending: false);

          final reviews = await Supabase.instance.client
              .from('reviews')
              .select('''
                *,
                cars(name, brand, model),
                reviewed:user_profiles!reviews_reviewed_id_fkey(name)
              ''')
              .eq('reviewer_id', userId)
              .order('created_at', ascending: false);

          demoData['bookings'] = bookings;
          demoData['reviews'] = reviews;
          break;

        case 'host':
          // Get host's cars, bookings, and received reviews
          final cars = await Supabase.instance.client
              .from('cars')
              .select('*')
              .eq('host_id', userId)
              .order('created_at', ascending: false);

          final hostBookings = await Supabase.instance.client
              .from('bookings')
              .select('''
                *,
                user_profiles!bookings_user_id_fkey(name, email),
                cars(name, brand, model)
              ''')
              .eq('host_id', userId)
              .order('created_at', ascending: false);

          final hostReviews = await Supabase.instance.client
              .from('reviews')
              .select('''
                *,
                reviewer:user_profiles!reviews_reviewer_id_fkey(name),
                cars(name, brand, model)
              ''')
              .eq('reviewed_id', userId)
              .order('created_at', ascending: false);

          demoData['cars'] = cars;
          demoData['host_bookings'] = hostBookings;
          demoData['host_reviews'] = hostReviews;
          break;

        case 'admin':
          // Get admin logs and pending requests
          final adminLogs = await getDemoAdminLogs();
          final hostRequests = await getDemoHostRequests();
          
          demoData['admin_logs'] = adminLogs;
          demoData['host_requests'] = hostRequests;
          break;
      }

      debugPrint('$_logPrefix Demo data prepared for $role user');
      return demoData;
    } catch (e) {
      debugPrint('$_logPrefix Error fetching user demo data: $e');
      return {};
    }
  }

  /// Verify data seeding was successful
  static Future<Map<String, int>> verifySeededData() async {
    try {
      debugPrint('$_logPrefix Verifying seeded data...');
      
      final userCount = await Supabase.instance.client
          .from('user_profiles')
          .select('id', const FetchOptions(count: CountOption.exact))
          .count();

      final carCount = await Supabase.instance.client
          .from('cars')
          .select('id', const FetchOptions(count: CountOption.exact))
          .count();

      final bookingCount = await Supabase.instance.client
          .from('bookings')
          .select('id', const FetchOptions(count: CountOption.exact))
          .count();

      final reviewCount = await Supabase.instance.client
          .from('reviews')
          .select('id', const FetchOptions(count: CountOption.exact))
          .count();

      final hostRequestCount = await Supabase.instance.client
          .from('host_requests')
          .select('id', const FetchOptions(count: CountOption.exact))
          .count();

      final adminLogCount = await Supabase.instance.client
          .from('admin_logs')
          .select('id', const FetchOptions(count: CountOption.exact))
          .count();

      final verification = {
        'users': userCount,
        'cars': carCount,
        'bookings': bookingCount,
        'reviews': reviewCount,
        'host_requests': hostRequestCount,
        'admin_logs': adminLogCount,
      };

      debugPrint('$_logPrefix Data verification: $verification');
      return verification;
    } catch (e) {
      debugPrint('$_logPrefix Error verifying seeded data: $e');
      return {};
    }
  }

  /// Get demo data summary for development dashboard
  static Future<String> getDemoDataSummary() async {
    final verification = await verifySeededData();
    
    return '''
📊 STER Demo Data Summary:
👥 Users: ${verification['users'] ?? 0}
🚗 Cars: ${verification['cars'] ?? 0}
📅 Bookings: ${verification['bookings'] ?? 0}
⭐ Reviews: ${verification['reviews'] ?? 0}
📝 Host Requests: ${verification['host_requests'] ?? 0}
🔧 Admin Logs: ${verification['admin_logs'] ?? 0}

🧪 Test Users:
• Sarah Johnson (Customer)
• Ahmed Benali (Customer) 
• Mohamed Kaci (Host)
• Fatima Boudiaf (Host)
• Admin Hadj (Admin)
• Yacine Meziani (Pending Host)
''';
  }

  /// Helper to print demo credentials for development
  static void printDemoCredentials() {
    debugPrint('$_logPrefix Demo User Credentials:');
    debugPrint('📧 Customers:');
    debugPrint('  - sarah.johnson@email.com (${demoUserIds['sarah_customer']})');
    debugPrint('  - ahmed.benali@email.com (${demoUserIds['ahmed_customer']})');
    debugPrint('🏠 Hosts:');
    debugPrint('  - mohamed.kaci@email.com (${demoUserIds['mohamed_host']})');
    debugPrint('  - fatima.boudiaf@email.com (${demoUserIds['fatima_host']})');
    debugPrint('⚡ Admin:');
    debugPrint('  - admin@ster.com (${demoUserIds['admin']})');
    debugPrint('⏳ Pending Host:');
    debugPrint('  - yacine.meziani@email.com (${demoUserIds['yacine_pending_host']})');
  }
}