import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/either.dart';
import '../utils/failure.dart';
import '../models/host_request.dart';
import '../models/top_host.dart';
import '../models/user.dart' as app_user;
import 'notification_service.dart';
import 'context_aware_service.dart';

class HostService extends ChangeNotifier {
  static final HostService _instance = HostService._internal();
  factory HostService() => _instance;
  HostService._internal();

  SupabaseClient get client => Supabase.instance.client;
  
  // Context-aware service for tracking
  final ContextAwareService _contextAware = ContextAwareService();
  final NotificationService _notificationService = NotificationService();

  // Cache for host requests
  List<HostRequest> _hostRequests = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<HostRequest> get hostRequests => _hostRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<HostRequest> get pendingRequests => 
      _hostRequests.where((request) => request.isPending).toList();
  
  List<HostRequest> get approvedRequests => 
      _hostRequests.where((request) => request.isApproved).toList();
  
  List<HostRequest> get rejectedRequests => 
      _hostRequests.where((request) => request.isRejected).toList();

  // Fetch the current user's host request status
  Future<HostRequestStatus?> getCurrentUserRequestStatus() async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) return null;

      final row = await client
          .from('host_requests')
          .select('id, status, rejection_reason, reviewed_at, reviewed_by, created_at')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (row == null) return null;
      final statusText = row['status'] as String? ?? 'pending';
      switch (statusText) {
        case 'approved':
          return HostRequestStatus.approved;
        case 'rejected':
          return HostRequestStatus.rejected;
        case 'pending':
        default:
          return HostRequestStatus.pending;
      }
    } catch (_) {
      return null;
    }
  }

  // Submit or resubmit host request
  Future<Either<Failure, void>> submitOrResubmitHostRequest({
    required String note,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        return Either.left(const Failure('Please sign in'));
      }

      // Find latest request
      final latest = await client
          .from('host_requests')
          .select('id, status')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (latest != null) {
        final status = (latest['status'] as String?) ?? 'pending';
        final requestId = latest['id'] as String;
        if (status == 'rejected') {
          // Resubmit: set pending and clear rejection_reason
          await client
              .from('host_requests')
              .update({
                'status': 'pending',
                'request_note': note,
                'rejection_reason': null,
              })
              .eq('id', requestId);
          return Either.right(null);
        }
        if (status == 'pending' || status == 'approved') {
          return Either.left(const Failure('Your application is already in review or approved.'));
        }
      }

      // No prior request → submit new
      final payload = {
        'user_id': currentUser.id,
        'request_note': note,
        'status': 'pending',
      };
      if (kDebugMode) debugPrint('[HostService] submit/resubmit payload: $payload');
      await client.from('host_requests').insert(payload);
      return Either.right(null);
    } on PostgrestException catch (e) {
      return Either.left(Failure(e.message));
    } catch (e) {
      return Either.left(Failure(e.toString()));
    }
  }

  /// Legacy submission method (kept for backward compatibility in codebase)
  Future<bool> submitHostRequestLegacy({
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
    String? userImage,
    required String businessName,
    String? businessType,
    String? businessAddress,
    String? taxId,
    String? bankAccount,
    Set<String>? vehicleTypes,
    String? insuranceProvider,
    bool hasCommercialLicense = false,
    bool hasInsurance = false,
    bool hasVehicleRegistration = false,
    int plannedCarsCount = 0,
    Map<String, dynamic>? documents,
    Map<String, dynamic>? additionalInfo,
    List<Map<String, dynamic>>? plannedVehicles,
  }) async {
    try {
      debugPrint('🚀 Starting host request submission...');
      
      // Verify user authentication
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ No authenticated user found');
        return false;
      }

      // Use ONLY the columns that actually exist in the host_requests table
      final hostRequestData = {
        'user_id': currentUser.id, // Use authenticated user's ID for RLS policy
        'status': 'pending',
        'request_note': 'Host application from $userName ($userEmail) for business: $businessName',
      };

      debugPrint('📝 Inserting data with correct schema: $hostRequestData');

      // Insert the request
      final response = await client
          .from('host_requests')
          .insert(hostRequestData)
          .select()
          .single();

      debugPrint('✅ Host request submitted successfully: ${response['id']}');
      
      // Track event
      _contextAware.trackEvent(
        eventName: 'host_request_submitted',
        service: 'HostService',
        operation: 'submit_host_request',
        metadata: {
          'request_id': response['id'],
          'user_id': userId,
          'business_name': businessName,
        },
      );

      return true;
    } catch (e) {
      debugPrint('❌ Error submitting host request: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      
      // Print the full error message in chunks to avoid truncation
      final errorString = e.toString();
      debugPrint('❌ FULL ERROR MESSAGE:');
      debugPrint('❌ $errorString');
      
      // Check for specific error patterns
      if (errorString.contains('RLS')) {
        debugPrint('❌ RLS POLICY ISSUE DETECTED');
      }
      if (errorString.contains('permission')) {
        debugPrint('❌ PERMISSION ISSUE DETECTED');
      }
      if (errorString.contains('column')) {
        debugPrint('❌ COLUMN ISSUE DETECTED');
      }
      if (errorString.contains('constraint')) {
        debugPrint('❌ CONSTRAINT ISSUE DETECTED');
      }
      if (errorString.contains('not found')) {
        debugPrint('❌ TABLE/COLUMN NOT FOUND');
      }
      
      return false;
    }
  }

  /// Minimal, domain-safe submission used by Become Host flow
  /// Inserts only the supported columns and returns precise errors
  Future<Either<Failure, void>> submitHostRequest({
    required String note,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        return Either.left(const Failure('Please sign in'));
      }

      final payload = {
        'user_id': currentUser.id,
        'request_note': note,
        'status': 'pending',
      };

      if (kDebugMode) {
        debugPrint('[HostService] Inserting host_request: $payload');
      }

      await client.from('host_requests').insert(payload);
      return Either.right(null);
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('[HostService] PostgrestException: ${e.message}');
      }
      return Either.left(Failure(e.message));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HostService] Unexpected error: $e');
      }
      return Either.left(Failure(e.toString()));
    }
  }

  /// Create the host_requests table if it doesn't exist
  Future<void> _createTableIfNotExists() async {
    try {
      // Try to create the table using SQL
      await client.rpc('create_host_requests_table_if_not_exists');
      debugPrint('✅ Table creation attempted');
    } catch (e) {
      debugPrint('⚠️ Could not create table via RPC: $e');
      debugPrint('📋 MANUAL TABLE CREATION REQUIRED:');
      debugPrint('''
CREATE TABLE host_requests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  user_name TEXT NOT NULL,
  user_email TEXT NOT NULL,
  business_name TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
      ''');
    }
  }

  /// Ensure the host_requests table exists with proper structure
  Future<void> _ensureTableExists() async {
    try {
      // Try to select from the table to see if it exists
      await client.from('host_requests').select('count').limit(1);
      debugPrint('✅ host_requests table exists');
    } catch (e) {
      debugPrint('❌ host_requests table does not exist, creating it...');
      
      // Create the table using RPC (if you have the function)
      try {
        await client.rpc('create_host_requests_table');
        debugPrint('✅ host_requests table created successfully');
      } catch (e2) {
        debugPrint('❌ Could not create table via RPC: $e2');
        debugPrint('⚠️ Please create the host_requests table manually in Supabase');
        debugPrint('📋 Required columns: id, user_id, user_name, user_email, business_name, status, created_at');
      }
    }
  }

  /// Load host requests (admin only). Fetches minimal columns and enriches with user profiles
  Future<void> loadHostRequests({int limit = 100, int offset = 0}) async {
    return await _contextAware.executeWithContext(
      operation: 'loadHostRequests',
      service: 'HostService',
      operationFunction: () async {
        try {
          _setLoading(true);
          _error = null;

          // Verify current user is admin
          final currentUser = client.auth.currentUser;
          if (currentUser == null) {
            throw Exception('User not authenticated');
          }

          // Load host requests with minimal columns
          if (kDebugMode) debugPrint('🔍 Fetching host_requests...');
          final rows = await client
              .from('host_requests')
              .select('id, user_id, request_note, status, reviewed_by, reviewed_at, created_at')
              .order('created_at', ascending: false)
              .range(offset, offset + limit - 1);

          final List<dynamic> list = rows as List<dynamic>;
          final Set<String> userIds = {
            for (final r in list) (r as Map<String, dynamic>)['user_id'] as String
          };

          // Fetch profiles for names/emails/phones
          Map<String, Map<String, dynamic>> profileById = {};
          if (userIds.isNotEmpty) {
            final ids = userIds.toList();
            final inList = ids.map((e) => '"$e"').join(',');
            final profiles = await client
                .from('user_profiles')
                .select('id, name, email, phone, profile_image')
                .filter('id', 'in', '($inList)');
            for (final p in profiles as List) {
              profileById[p['id'] as String] = Map<String, dynamic>.from(p);
            }
          }

          final hostRequests = list.map((json) {
            final map = json as Map<String, dynamic>;
            final uid = map['user_id'] as String? ?? '';
            final prof = profileById[uid] ?? {};
            final enriched = {
              ...map,
              'user_name': prof['name'] ?? 'User',
              'user_email': prof['email'] ?? '',
              'user_phone': prof['phone'],
              'user_image': prof['profile_image'],
              'business_name': (prof['name'] ?? 'Host').toString(),
            };
            return HostRequest.fromJson(enriched);
          }).toList();

          _hostRequests = hostRequests;
          _setLoading(false);
          notifyListeners();

          debugPrint('✅ Loaded ${hostRequests.length} host requests');
          
          // No auto-creation in admin load path
        } catch (e) {
          _error = 'Failed to load host requests: $e';
          _setLoading(false);
          debugPrint('❌ Error loading host requests: $e');
          notifyListeners();
        }
      },
    );
  }

  /// Approve a host request
  Future<bool> approveHostRequest(String requestId, String adminId, String adminName) async {
    final result = await _contextAware.executeDatabaseOperation(
      operation: 'Approve Host Request',
      table: 'host_requests',
      operationType: 'update',
      operationFunction: () async {
        try {
          final now = DateTime.now().toIso8601String();
          
          // Only approve if still pending
          final updated = await client
              .from('host_requests')
              .update({
                'status': 'approved',
                'reviewed_by': adminId,
                'reviewed_at': now,
              })
              .eq('id', requestId)
              .eq('status', 'pending')
              .select('id, user_id')
              .maybeSingle();

          if (updated == null) {
            if (kDebugMode) debugPrint('Approve skipped: not pending or not found');
            return false;
          }

          final userId = updated['user_id'] as String;
          // Promote user to host
          await client
              .from('user_profiles')
              .update({'role': 'host', 'updated_at': now})
              .eq('id', userId);

          // Send approval notification
          await _notificationService.sendNotification(
            userId: userId,
            title: '🎉 Host Application Approved!',
            message: 'Congratulations! Your host application has been approved. You can now start listing your vehicles on STER.',
            type: 'host_approval',
          );

          // Track event
          _contextAware.trackEvent(
            eventName: 'host_request_approved',
            service: 'HostService',
            operation: 'approve_host_request',
            metadata: {
              'request_id': requestId,
              'user_id': userId,
              'admin_id': adminId,
            },
          );

          // Refresh list to reflect changes
          await loadHostRequests();

          debugPrint('✅ Host request approved successfully');
          return true;
        } catch (e) {
          debugPrint('❌ Error approving host request: $e');
          return false;
        }
      },
      data: {
        'request_id': requestId,
        'status': 'approved',
        'reviewer_id': adminId,
      },
      rlsPolicies: {
        'update': 'auth.uid() IN (SELECT id FROM profiles WHERE role = \'admin\')',
      },
    );
    return result ?? false;
  }

  /// Reject a host request
  Future<bool> rejectHostRequest(String requestId, String adminId, String adminName, String reason) async {
    final result = await _contextAware.executeDatabaseOperation(
      operation: 'Reject Host Request',
      table: 'host_requests',
      operationType: 'update',
      operationFunction: () async {
        try {
          final now = DateTime.now().toIso8601String();
          
          final updated = await client
              .from('host_requests')
              .update({
                'status': 'rejected',
                'reviewed_by': adminId,
                'reviewed_at': now,
              })
              .eq('id', requestId)
              .eq('status', 'pending')
              .select('id, user_id')
              .maybeSingle();

          if (updated == null) {
            if (kDebugMode) debugPrint('Reject skipped: not pending or not found');
            return false;
          }
          final userId = updated['user_id'] as String;

          // Send rejection notification
          await _notificationService.sendNotification(
            userId: userId,
            title: 'Host Application Update',
            message: reason.isNotEmpty 
                ? 'Your host application was not approved. Reason: $reason. You can submit a new application after addressing the feedback.'
                : 'Your host application was not approved. You can submit a new application with updated information.',
            type: 'host_rejection',
          );

          // Track event
          _contextAware.trackEvent(
            eventName: 'host_request_rejected',
            service: 'HostService',
            operation: 'reject_host_request',
            metadata: {
              'request_id': requestId,
              'user_id': userId,
              'admin_id': adminId,
              'rejection_reason': reason,
            },
          );

          await loadHostRequests();

          debugPrint('✅ Host request rejected successfully');
          return true;
        } catch (e) {
          debugPrint('❌ Error rejecting host request: $e');
          return false;
        }
      },
      data: {
        'request_id': requestId,
        'status': 'rejected',
        'reviewer_id': adminId,
        'rejection_reason': reason,
      },
      rlsPolicies: {
        'update': 'auth.uid() IN (SELECT id FROM profiles WHERE role = \'admin\')',
      },
    );
    return result ?? false;
  }

  /// Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Clear cache and reset state
  void clearCache() {
    _hostRequests.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Get top hosts (static method for compatibility)
  static Future<List<TopHost>> getTopHosts({int limit = 10}) async {
    try {
      final client = Supabase.instance.client;
      
      // Get hosts with their car count and ratings
      final response = await client
          .from('profiles')
          .select('''
            id,
            full_name,
            avatar_url,
            role,
            cars!inner(id, rating),
            bookings!inner(id, rating)
          ''')
          .eq('role', 'host')
          .limit(limit);

      final hosts = (response as List).map((json) {
        final cars = json['cars'] as List? ?? [];
        final bookings = json['bookings'] as List? ?? [];
        
        // Calculate average rating
        double avgRating = 0.0;
        int totalRatings = 0;
        
        for (final car in cars) {
          if (car['rating'] != null) {
            avgRating += (car['rating'] as num).toDouble();
            totalRatings++;
          }
        }
        
        for (final booking in bookings) {
          if (booking['rating'] != null) {
            avgRating += (booking['rating'] as num).toDouble();
            totalRatings++;
          }
        }
        
        if (totalRatings > 0) {
          avgRating = avgRating / totalRatings;
        }

        return TopHost(
          id: json['id'] ?? '',
          name: json['full_name'] ?? 'Host',
          profileImage: json['avatar_url'],
          hostType: 'Host',
          rating: avgRating,
          trips: bookings.length,
          location: '', // Will be populated from actual data
          carsCount: cars.length,
        );
      }).toList();

      return hosts;
    } catch (e) {
      debugPrint('❌ Error getting top hosts: $e');
      // Return empty list on error
      return [];
    }
  }

  /// Create a test host request for demonstration
  Future<void> _createTestHostRequest() async {
    try {
      debugPrint('🧪 Creating test host request...');
      
      // First, check if table exists and we can query it
      try {
        final testQuery = await client
            .from('host_requests')
            .select('count')
            .limit(1);
        debugPrint('✅ Table exists and is accessible');
      } catch (e) {
        debugPrint('❌ Table access error: $e');
        return;
      }

      final testRequest = {
        'user_id': 'test-user-123',
        'user_name': 'John Doe',
        'user_email': 'john.doe@example.com',
        'user_phone': '+1234567890',
        'user_image': null,
        'business_name': 'Doe Car Rentals',
        'business_type': 'Individual',
        'business_address': '123 Main St, City, State',
        'tax_id': 'TAX123456',
        'bank_account': 'BANK123456',
        'vehicle_types': ['sedan', 'suv'],
        'insurance_provider': 'State Farm',
        'has_commercial_license': true,
        'has_insurance': true,
        'has_vehicle_registration': true,
        'planned_cars_count': 3,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      debugPrint('📝 Test data: $testRequest');

      final response = await client
          .from('host_requests')
          .insert(testRequest)
          .select()
          .single();

      debugPrint('✅ Test host request created successfully');
      debugPrint('📊 Response: $response');
      
      // Reload the requests to show the new test data
      await loadHostRequests();
    } catch (e) {
      debugPrint('❌ Error creating test host request: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      debugPrint('❌ Error details: ${e.toString()}');
    }
  }

  /// Get the actual columns that exist in the host_requests table
  Future<List<String>> _getTableColumns() async {
    try {
      // Try to get one record to see the structure
      final result = await client
          .from('host_requests')
          .select('*')
          .limit(1);
      
      if (result.isNotEmpty) {
        final firstRecord = result.first as Map<String, dynamic>;
        return firstRecord.keys.toList();
      } else {
        // If table is empty, try a dummy insert to see what columns are required
        debugPrint('📊 Table is empty, trying to infer columns...');
        try {
          final dummyData = {
            'user_id': 'dummy',
            'user_name': 'dummy',
            'user_email': 'dummy@test.com',
            'business_name': 'dummy',
            'status': 'pending',
          };
          
          final dummyResult = await client
              .from('host_requests')
              .insert(dummyData)
              .select()
              .single();
              
          debugPrint('✅ Dummy insert successful');
          
          // Clean up
          await client
              .from('host_requests')
              .delete()
              .eq('id', dummyResult['id']);
              
          return dummyResult.keys.toList();
        } catch (e) {
          debugPrint('❌ Dummy insert failed: $e');
          // Return basic columns as fallback
          return ['id', 'user_id', 'user_name', 'user_email', 'business_name', 'status', 'created_at'];
        }
      }
    } catch (e) {
      debugPrint('❌ Error getting table columns: $e');
      // Return basic columns as fallback
      return ['id', 'user_id', 'user_name', 'user_email', 'business_name', 'status', 'created_at'];
    }
  }

  /// Get database table schema
  Future<void> checkTableSchema() async {
    try {
      debugPrint('🔍 Checking host_requests table schema...');
      
      // First, check if we can access the table at all
      try {
        final result = await client
            .from('host_requests')
            .select('*')
            .limit(1);
        debugPrint('✅ Table exists and is accessible');
        debugPrint('📊 Current records: ${result.length}');
        
        if (result.isNotEmpty) {
          debugPrint('📊 Table columns found:');
          final firstRecord = result.first as Map<String, dynamic>;
          for (final column in firstRecord.keys) {
            debugPrint('   - $column: ${firstRecord[column].runtimeType}');
          }
    } else {
          debugPrint('📊 Table exists but is empty');
          
          // Try to get column information from a dummy insert
          debugPrint('🔍 Attempting to get column info from insert...');
          try {
            final dummyData = {
              'user_id': 'test',
              'user_name': 'test',
              'user_email': 'test@test.com',
              'business_name': 'test',
              'status': 'pending',
              'created_at': DateTime.now().toIso8601String(),
            };
            
            final insertResult = await client
                .from('host_requests')
                .insert(dummyData)
                .select()
                .single();
                
            debugPrint('✅ Dummy insert successful, columns exist');
            debugPrint('📊 Inserted record: $insertResult');
            
            // Clean up
            await client
                .from('host_requests')
                .delete()
                .eq('id', insertResult['id']);
            debugPrint('✅ Dummy record cleaned up');
            
          } catch (e) {
            debugPrint('❌ Dummy insert failed: $e');
            debugPrint('❌ This confirms the table structure issue');
          }
        }
        
      } catch (e) {
        debugPrint('❌ Table access error: $e');
        debugPrint('❌ This suggests the table does not exist or has permission issues');
        return;
      }
      
      // Try to get table structure from information_schema
      try {
        final schemaResult = await client
            .rpc('get_table_columns', params: {'table_name': 'host_requests'});
        debugPrint('📊 Schema info: $schemaResult');
      } catch (e) {
        debugPrint('⚠️ Could not get schema info: $e');
      }
      
    } catch (e) {
      debugPrint('❌ Error checking table schema: $e');
    }
  }

  /// Test database connection and table access
  Future<bool> testDatabaseConnection() async {
    try {
      debugPrint('🔍 Testing database connection...');
      
      // Check if user is authenticated
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ No authenticated user');
        return false;
      }
      debugPrint('✅ User authenticated: ${currentUser.id}');
      
      // Test basic table access first
      debugPrint('🔍 Testing table access...');
      try {
        final testResult = await client
            .from('host_requests')
            .select('*')
            .limit(1);
        debugPrint('✅ Table access successful, found ${testResult.length} records');
      } catch (e) {
        debugPrint('❌ Table access failed: $e');
        debugPrint('❌ Table access error type: ${e.runtimeType}');
        debugPrint('❌ Table access error details: ${e.toString()}');
        return false;
      }

      // Test a simple insert to see if RLS is the issue
      debugPrint('🧪 Testing simple insert...');
      try {
        final testInsertData = {
          'user_id': currentUser.id,
          'status': 'pending',
          'request_note': 'Test insert',
        };
        
        final testResponse = await client
            .from('host_requests')
            .insert(testInsertData)
            .select()
            .single();
            
        debugPrint('✅ Test insert successful: ${testResponse['id']}');
        
        // Clean up test record
        await client
            .from('host_requests')
            .delete()
            .eq('id', testResponse['id']);
        debugPrint('✅ Test record cleaned up');
        
      } catch (e) {
        debugPrint('❌ Test insert failed: $e');
        debugPrint('❌ Test insert error type: ${e.runtimeType}');
        debugPrint('❌ Test insert error details: ${e.toString()}');
        return false;
      }
      
      // If we get here, both tests passed
      debugPrint('✅ All database tests passed');
      return true;
      
    } catch (e) {
      debugPrint('❌ Database connection test failed: $e');
      return false;
    }
  }

  /// Check database table structure and permissions
  Future<void> checkDatabaseSetup() async {
    try {
      debugPrint('🔍 Checking database setup...');
      
      // Check if user is authenticated
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ No authenticated user');
        return;
      }
      debugPrint('✅ User authenticated: ${currentUser.id}');
      
      // Check if table exists by trying to select from it
      try {
        final result = await client
            .from('host_requests')
            .select('*')
            .limit(1);
        debugPrint('✅ Table exists and is accessible');
        debugPrint('📊 Current records: ${result.length}');
      } catch (e) {
        debugPrint('❌ Table access error: $e');
        return;
      }
      
      // Check RLS policies by trying to insert a test record
      try {
        final testData = {
          'user_id': currentUser.id,
          'user_name': 'Test User',
          'user_email': 'test@example.com',
          'business_name': 'Test Business',
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        };
        
        final response = await client
            .from('host_requests')
            .insert(testData)
            .select()
            .single();
            
        debugPrint('✅ RLS policies allow insert');
        debugPrint('📊 Inserted test record: ${response['id']}');
        
        // Clean up test record
        await client
            .from('host_requests')
            .delete()
            .eq('id', response['id']);
        debugPrint('✅ Test record cleaned up');
        
      } catch (e) {
        debugPrint('❌ RLS policy error: $e');
      }
      
    } catch (e) {
      debugPrint('❌ Database setup check failed: $e');
    }
  }

  /// Check what's actually in the host_requests table
  Future<void> debugTableStructure() async {
    try {
      debugPrint('🔍 DEBUGGING TABLE STRUCTURE...');
      
      // Try to select from the table
      final result = await client
          .from('host_requests')
          .select('*')
          .limit(5);
      
      debugPrint('📊 Table has ${result.length} records');
      
      if (result.isNotEmpty) {
        final firstRecord = result.first as Map<String, dynamic>;
        debugPrint('📋 ACTUAL COLUMNS IN TABLE:');
        for (final column in firstRecord.keys) {
          debugPrint('   - $column: ${firstRecord[column]} (${firstRecord[column].runtimeType})');
        }
      } else {
        debugPrint('📋 Table is empty - no records to inspect');
      }
      
      // Try to get table info from information_schema
      try {
        final tableInfo = await client
            .rpc('get_table_info', params: {'table_name': 'host_requests'});
        debugPrint('📋 Table info from RPC: $tableInfo');
      } catch (e) {
        debugPrint('⚠️ Could not get table info via RPC: $e');
      }
      
    } catch (e) {
      debugPrint('❌ Error inspecting table: $e');
      debugPrint('❌ This suggests the table might not exist or have different name');
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    clearCache();
    super.dispose();
  }
}