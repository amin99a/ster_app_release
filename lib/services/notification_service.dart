import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'context_aware_service.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  SupabaseClient get client => Supabase.instance.client;
  
  // Context-aware service for tracking
  final ContextAwareService _contextAware = ContextAwareService();

  // Stream controllers
  final StreamController<List<Map<String, dynamic>>> _notificationsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<int> _unreadCountController = StreamController<int>.broadcast();
  final StreamController<Map<String, dynamic>> _newNotificationController = StreamController<Map<String, dynamic>>.broadcast();

  // Getters for streams
  Stream<List<Map<String, dynamic>>> get notificationsStream => _notificationsController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;
  Stream<Map<String, dynamic>> get newNotificationStream => _newNotificationController.stream;

  // Cached data
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _isInitialized = false;
  RealtimeChannel? _notificationChannel;

  // Getters for cached data
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isInitialized => _isInitialized;

  // Initialize the service with context tracking
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      debugPrint('🚀 Initializing NotificationService with context tracking...');
      
      // Initialize context tracking
      await _contextAware.initialize();
      
    await _loadNotifications();
    await _setupRealtimeSubscriptions();
      
      _isInitialized = true;
      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
      rethrow;
    }
  }

  // Load notifications with context tracking
  Future<void> _loadNotifications() async {
    return await _contextAware.executeWithContext(
      operation: 'loadNotifications',
      service: 'NotificationService',
      operationFunction: () async {
    try {
      final currentUser = client.auth.currentUser;
          if (currentUser == null) {
            debugPrint('⚠️ No authenticated user found for notifications');
            return;
          }

          debugPrint('📥 Loading notifications for user: ${currentUser.id}');

      final response = await client
          .from('notifications')
          .select()
          .eq('user_id', currentUser.id)
              .order('created_at', ascending: false)
              .limit(50); // Limit to prevent memory issues

      _notifications = response.map((json) => Map<String, dynamic>.from(json)).toList();
      _notificationsController.add(_notifications);
      
      // Calculate unread count
      _unreadCount = _notifications.where((n) => !(n['is_read'] ?? false)).length;
      _unreadCountController.add(_unreadCount);
          
          debugPrint('✅ Loaded ${_notifications.length} notifications (${_unreadCount} unread)');
    } catch (e) {
          debugPrint('❌ Error loading notifications: $e');
          // Don't rethrow - allow app to continue without notifications
        }
      },
      metadata: {
        'operation': 'load_notifications',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Setup real-time subscriptions with enhanced error handling
  Future<void> _setupRealtimeSubscriptions() async {
    return await _contextAware.executeWithContext(
      operation: 'setupRealtimeSubscriptions',
      service: 'NotificationService',
      operationFunction: () async {
        try {
          final currentUser = client.auth.currentUser;
          if (currentUser == null) {
            debugPrint('⚠️ No authenticated user for real-time subscriptions');
            return;
          }

          // Clean up existing channel
          await _notificationChannel?.unsubscribe();

          // Create new channel with user-specific filter
          _notificationChannel = client.channel('notifications_${currentUser.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: currentUser.id,
              ),
              callback: (payload) {
                _handleNewNotification(payload);
              },
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.update,
              schema: 'public',
              table: 'notifications',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: currentUser.id,
              ),
          callback: (payload) {
                _handleNotificationUpdate(payload);
              },
            )
            .subscribe((status, [error]) {
              if (error != null) {
                debugPrint('❌ Real-time subscription error: $error');
              } else {
                debugPrint('✅ Real-time notification subscriptions active');
              }
            });

        } catch (e) {
          debugPrint('❌ Error setting up real-time subscriptions: $e');
          // Don't rethrow - allow app to continue without real-time updates
        }
      },
      metadata: {
        'operation': 'setup_realtime_subscriptions',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Handle new notification with context tracking
  void _handleNewNotification(PostgresChangePayload payload) {
    try {
            final notification = Map<String, dynamic>.from(payload.newRecord);
      
      debugPrint('📨 New notification received: ${notification['title']}');
      
      // Add to beginning of list
            _notifications.insert(0, notification);
            _notificationsController.add(_notifications);
            
            // Update unread count
            if (!(notification['is_read'] ?? false)) {
              _unreadCount++;
              _unreadCountController.add(_unreadCount);
            }
      
      // Emit new notification event
      _newNotificationController.add(notification);
      
      // Track in context
      _contextAware.trackEvent(
        eventName: 'notification_received',
        service: 'NotificationService',
        operation: 'handle_new_notification',
        metadata: {
          'notification_id': notification['id'],
          'notification_type': notification['type'],
          'user_id': notification['user_id'],
        },
      );
      
    } catch (e) {
      debugPrint('❌ Error handling new notification: $e');
    }
  }

  // Handle notification update
  void _handleNotificationUpdate(PostgresChangePayload payload) {
    try {
      final updatedNotification = Map<String, dynamic>.from(payload.newRecord);
      final notificationId = updatedNotification['id'];
      
      // Find and update existing notification
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index] = updatedNotification;
        _notificationsController.add(_notifications);
        
        // Recalculate unread count
        _unreadCount = _notifications.where((n) => !(n['is_read'] ?? false)).length;
        _unreadCountController.add(_unreadCount);
        
        debugPrint('📝 Notification updated: ${updatedNotification['title']}');
      }
    } catch (e) {
      debugPrint('❌ Error handling notification update: $e');
    }
  }

  // Send notification with context tracking
  Future<bool?> sendNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) async {
    return await _contextAware.executeDatabaseOperation(
      operation: 'Send Notification',
      table: 'notifications',
      operationType: 'insert',
      operationFunction: () async {
    try {
      final notificationData = {
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type ?? 'general',
        'action_url': actionUrl,
        'metadata': metadata,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      };

          final response = await client
          .from('notifications')
              .insert(notificationData)
              .select()
              .single();

          debugPrint('✅ Notification sent successfully: $title');
          
          // Track in context
          _contextAware.trackEvent(
            eventName: 'notification_sent',
            service: 'NotificationService',
            operation: 'send_notification',
            metadata: {
              'notification_id': response['id'],
              'user_id': userId,
              'notification_type': type ?? 'general',
            },
          );

      return true;
    } catch (e) {
          debugPrint('❌ Error sending notification: $e');
      return false;
    }
      },
      data: {
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type ?? 'general',
      },
      rlsPolicies: {
        'insert': 'auth.uid() = user_id OR auth.uid() IN (SELECT id FROM users WHERE role = \'admin\')',
      },
    );
  }

  // Mark notification as read
  Future<bool?> markAsRead(String notificationId) async {
    return await _contextAware.executeDatabaseOperation(
      operation: 'Mark Notification Read',
      table: 'notifications',
      operationType: 'update',
      operationFunction: () async {
    try {
      await client
          .from('notifications')
              .update({'is_read': true})
          .eq('id', notificationId);

          // Update local cache
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['is_read'] = true;
        _notificationsController.add(_notifications);
        
            // Recalculate unread count
        _unreadCount = _notifications.where((n) => !(n['is_read'] ?? false)).length;
        _unreadCountController.add(_unreadCount);
      }

          debugPrint('✅ Notification marked as read: $notificationId');
      return true;
    } catch (e) {
          debugPrint('❌ Error marking notification as read: $e');
      return false;
    }
      },
      data: {
        'notification_id': notificationId,
        'is_read': true,
      },
      rlsPolicies: {
        'update': 'auth.uid() = user_id',
      },
    );
  }

  // Mark all notifications as read
  Future<bool?> markAllAsRead() async {
    return await _contextAware.executeDatabaseOperation(
      operation: 'Mark All Notifications Read',
      table: 'notifications',
      operationType: 'update',
      operationFunction: () async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) return false;

      await client
          .from('notifications')
              .update({'is_read': true})
          .eq('user_id', currentUser.id)
          .eq('is_read', false);

          // Update local cache
      for (final notification in _notifications) {
        notification['is_read'] = true;
      }
      _notificationsController.add(_notifications);
      
      _unreadCount = 0;
      _unreadCountController.add(_unreadCount);

          debugPrint('✅ All notifications marked as read');
      return true;
    } catch (e) {
          debugPrint('❌ Error marking all notifications as read: $e');
      return false;
    }
      },
      data: {
        'is_read': true,
      },
      rlsPolicies: {
        'update': 'auth.uid() = user_id',
      },
    );
  }

  // Delete notification
  Future<bool?> deleteNotification(String notificationId) async {
    return await _contextAware.executeDatabaseOperation(
      operation: 'Delete Notification',
      table: 'notifications',
      operationType: 'delete',
      operationFunction: () async {
    try {
      await client
          .from('notifications')
          .delete()
          .eq('id', notificationId);

          // Update local cache
      _notifications.removeWhere((n) => n['id'] == notificationId);
      _notificationsController.add(_notifications);
      
          // Recalculate unread count
      _unreadCount = _notifications.where((n) => !(n['is_read'] ?? false)).length;
      _unreadCountController.add(_unreadCount);

          debugPrint('✅ Notification deleted: $notificationId');
      return true;
        } catch (e) {
          debugPrint('❌ Error deleting notification: $e');
          return false;
        }
      },
      data: {
        'notification_id': notificationId,
      },
      rlsPolicies: {
        'delete': 'auth.uid() = user_id',
      },
    );
  }

  // Get notification by ID
  Map<String, dynamic>? getNotificationById(String id) {
    try {
      return _notifications.firstWhere((n) => n['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get notifications by type
  List<Map<String, dynamic>> getNotificationsByType(String type) {
    return _notifications.where((n) => n['type'] == type).toList();
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) return;

      await client
          .from('notifications')
          .delete()
          .eq('user_id', currentUser.id);

      _notifications.clear();
      _unreadCount = 0;
      
      _notificationsController.add(_notifications);
      _unreadCountController.add(_unreadCount);

      debugPrint('✅ All notifications cleared');
    } catch (e) {
      debugPrint('❌ Error clearing notifications: $e');
    }
  }

  // Dispose resources
  @override
  void dispose() {
    _notificationChannel?.unsubscribe();
    _notificationsController.close();
    _unreadCountController.close();
    _newNotificationController.close();
    super.dispose();
  }

  // Get context summary
  Map<String, dynamic> getContextSummary() {
    return _contextAware.getContextSummary();
  }
} 