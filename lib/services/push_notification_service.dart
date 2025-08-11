import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/push_notification.dart';

class PushNotificationService extends ChangeNotifier {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  // Mock storage for notifications
  final List<PushNotification> _notifications = [];
  NotificationSettings _settings = const NotificationSettings();
  
  // Stream controllers
  final StreamController<PushNotification> _notificationController = 
      StreamController<PushNotification>.broadcast();
  final StreamController<List<PushNotification>> _notificationsListController = 
      StreamController<List<PushNotification>>.broadcast();
  final StreamController<int> _unreadCountController = 
      StreamController<int>.broadcast();

  // Getters for streams
  Stream<PushNotification> get notificationStream => _notificationController.stream;
  Stream<List<PushNotification>> get notificationsListStream => _notificationsListController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  // Mock FCM token
  String? _fcmToken;
  bool _isInitialized = false;

  // Getters
  List<PushNotification> get notifications => List.unmodifiable(_notifications);
  NotificationSettings get settings => _settings;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  // Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Mock FCM initialization
      await _initializeFCM();
      
      // Create notification channels
      await _createNotificationChannels();
      
      // Load settings
      await _loadSettings();
      
      // Generate mock notifications
      _generateMockNotifications();
      
      // Set up periodic notifications for demo
      _setupPeriodicNotifications();
      
      _isInitialized = true;
      
      // Emit initial state
      _notificationsListController.add(_notifications);
      _unreadCountController.add(unreadCount);
      
      debugPrint('PushNotificationService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize PushNotificationService: $e');
    }
  }

  Future<void> _initializeFCM() async {
    // Mock FCM token generation
    _fcmToken = 'mock_fcm_token_${Random().nextInt(999999)}';
    
    // In a real app, you would:
    // - Initialize Firebase Messaging
    // - Request permissions
    // - Get FCM token
    // - Set up message handlers
    
    debugPrint('FCM Token: $_fcmToken');
  }

  Future<void> _createNotificationChannels() async {
    // Create default notification channels
    for (final channel in NotificationChannel.defaultChannels) {
      await _createChannel(channel);
    }
  }

  Future<void> _createChannel(NotificationChannel channel) async {
    // In a real app, this would create platform-specific notification channels
    debugPrint('Created notification channel: ${channel.name}');
  }

  Future<void> _loadSettings() async {
    // In a real app, load from SharedPreferences or secure storage
    // For now, use default settings
    _settings = const NotificationSettings();
  }

  Future<void> _saveSettings() async {
    // In a real app, save to SharedPreferences or secure storage
    debugPrint('Notification settings saved');
    notifyListeners();
  }

  void _generateMockNotifications() {
    final now = DateTime.now();
    
    final mockNotifications = [
      PushNotification(
        id: 'notif_1',
        title: 'Booking Confirmed!',
        body: 'Your BMW X5 booking for Dec 15-18 has been confirmed.',
        type: NotificationType.booking,
        priority: NotificationPriority.high,
        timestamp: now.subtract(const Duration(minutes: 5)),
        data: {'bookingId': 'booking_123', 'carId': 'car_456'},
        actions: [
          const NotificationAction(
            id: 'view_booking',
            title: 'View Booking',
            actionUrl: '/booking/booking_123',
          ),
          const NotificationAction(
            id: 'contact_host',
            title: 'Contact Host',
            actionUrl: '/chat/host_123',
          ),
        ],
      ),
      
      PushNotification(
        id: 'notif_2',
        title: 'New Message from Ahmed',
        body: 'I can meet you at the airport for pickup if that works for you?',
        type: NotificationType.message,
        priority: NotificationPriority.high,
        timestamp: now.subtract(const Duration(minutes: 15)),
        data: {'chatId': 'chat_1', 'senderId': 'ahmed_hassan'},
        actions: [
          const NotificationAction(
            id: 'reply',
            title: 'Reply',
            actionUrl: '/chat/chat_1',
          ),
        ],
      ),
      
      PushNotification(
        id: 'notif_3',
        title: 'Payment Successful',
        body: 'Your payment of UK£450 has been processed successfully.',
        type: NotificationType.payment,
        priority: NotificationPriority.normal,
        timestamp: now.subtract(const Duration(hours: 2)),
        data: {'paymentId': 'payment_789', 'amount': 450},
        actions: [
          const NotificationAction(
            id: 'view_receipt',
            title: 'View Receipt',
            actionUrl: '/payment/payment_789',
          ),
        ],
      ),
      
      PushNotification(
        id: 'notif_4',
        title: 'Booking Reminder',
        body: 'Your car rental starts tomorrow at 10:00 AM. Don\'t forget to bring your license!',
        type: NotificationType.reminder,
        priority: NotificationPriority.normal,
        timestamp: now.subtract(const Duration(hours: 4)),
        isRead: true,
        data: {'bookingId': 'booking_456'},
      ),
      
      PushNotification(
        id: 'notif_5',
        title: 'Special Offer: 20% Off',
        body: 'Book any luxury car this weekend and get 20% off your rental!',
        type: NotificationType.promotion,
        priority: NotificationPriority.low,
        timestamp: now.subtract(const Duration(hours: 6)),
        imageUrl: 'https://images.unsplash.com/photo-1549924231-f129b911e442?w=400&h=200&fit=crop',
        actions: [
          const NotificationAction(
            id: 'browse_cars',
            title: 'Browse Cars',
            actionUrl: '/search?category=luxury',
          ),
        ],
      ),
      
      PushNotification(
        id: 'notif_6',
        title: 'Rate Your Recent Trip',
        body: 'How was your experience with the Mercedes C-Class?',
        type: NotificationType.review,
        priority: NotificationPriority.normal,
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        data: {'bookingId': 'booking_789', 'carId': 'car_123'},
        actions: [
          const NotificationAction(
            id: 'rate_trip',
            title: 'Rate Trip',
            actionUrl: '/review/booking_789',
          ),
        ],
      ),
    ];

    _notifications.addAll(mockNotifications);
    _sortNotifications();
  }

  void _setupPeriodicNotifications() {
    // Set up a timer to send periodic demo notifications
    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_notifications.length < 20) { // Limit mock notifications
        _sendRandomNotification();
      }
    });
  }

  void _sendRandomNotification() {
    final random = Random();
    final types = NotificationType.values;
    final type = types[random.nextInt(types.length)];
    
    final notification = _generateRandomNotification(type);
    _addNotification(notification);
  }

  PushNotification _generateRandomNotification(NotificationType type) {
    final now = DateTime.now();
    final id = 'notif_${now.millisecondsSinceEpoch}';
    
    switch (type) {
      case NotificationType.booking:
        return PushNotification(
          id: id,
          title: 'Booking Update',
          body: 'Your booking status has been updated.',
          type: type,
          timestamp: now,
          data: {'bookingId': 'booking_${Random().nextInt(999)}'},
        );
        
      case NotificationType.message:
        final senders = ['Ahmed', 'Sara', 'Mohamed', 'Fatima', 'Youssef'];
        final sender = senders[Random().nextInt(senders.length)];
        return PushNotification(
          id: id,
          title: 'New Message from $sender',
          body: 'You have a new message waiting.',
          type: type,
          timestamp: now,
          data: {'chatId': 'chat_${Random().nextInt(999)}'},
        );
        
      case NotificationType.payment:
        return PushNotification(
          id: id,
          title: 'Payment Notification',
          body: 'Your payment has been processed.',
          type: type,
          timestamp: now,
          data: {'paymentId': 'payment_${Random().nextInt(999)}'},
        );
        
      case NotificationType.reminder:
        return PushNotification(
          id: id,
          title: 'Reminder',
          body: 'Don\'t forget about your upcoming booking!',
          type: type,
          timestamp: now,
        );
        
      case NotificationType.promotion:
        return PushNotification(
          id: id,
          title: 'Special Offer',
          body: 'Limited time offer - don\'t miss out!',
          type: type,
          priority: NotificationPriority.low,
          timestamp: now,
        );
        
      case NotificationType.system:
        return PushNotification(
          id: id,
          title: 'System Update',
          body: 'The app has been updated with new features.',
          type: type,
          timestamp: now,
        );
        
      case NotificationType.review:
        return PushNotification(
          id: id,
          title: 'Review Request',
          body: 'Please rate your recent car rental experience.',
          type: type,
          timestamp: now,
        );
    }
  }

  // Send a notification
  Future<void> sendNotification(PushNotification notification) async {
    if (!_settings.isNotificationTypeEnabled(notification.type)) {
      debugPrint('Notification type ${notification.type} is disabled');
      return;
    }

    if (_settings.isInQuietHours && notification.priority != NotificationPriority.urgent) {
      debugPrint('Notification suppressed due to quiet hours');
      return;
    }

    _addNotification(notification);
    
    // Show local notification
    await _showLocalNotification(notification);
    
    // Vibrate if enabled
    if (_settings.vibrationEnabled) {
      await _vibrate();
    }
  }

  void _addNotification(PushNotification notification) {
    _notifications.insert(0, notification);
    _sortNotifications();
    
    // Emit events
    _notificationController.add(notification);
    _notificationsListController.add(_notifications);
    _unreadCountController.add(unreadCount);
    
    notifyListeners();
  }

  Future<void> _showLocalNotification(PushNotification notification) async {
    // In a real app, this would use flutter_local_notifications
    debugPrint('Showing notification: ${notification.title}');
    
    // Mock platform channel call
    try {
      await _mockShowNotification(notification);
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  Future<void> _mockShowNotification(PushNotification notification) async {
    // Simulate platform-specific notification display
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint('Local notification displayed: ${notification.title}');
  }

  Future<void> _vibrate() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Vibration failed: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      
      _notificationsListController.add(_notifications);
      _unreadCountController.add(unreadCount);
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    bool hasChanges = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      _notificationsListController.add(_notifications);
      _unreadCountController.add(unreadCount);
      notifyListeners();
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications.removeAt(index);
      
      _notificationsListController.add(_notifications);
      _unreadCountController.add(unreadCount);
      notifyListeners();
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    
    _notificationsListController.add(_notifications);
    _unreadCountController.add(unreadCount);
    notifyListeners();
  }

  // Update settings
  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
  }

  // Get notifications by type
  List<PushNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get unread notifications
  List<PushNotification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Search notifications
  List<PushNotification> searchNotifications(String query) {
    final lowerQuery = query.toLowerCase();
    return _notifications.where((n) {
      return n.title.toLowerCase().contains(lowerQuery) ||
             n.body.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void _sortNotifications() {
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Handle notification tap
  Future<void> handleNotificationTap(String notificationId) async {
    await markAsRead(notificationId);
    
    final notification = _notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => PushNotification(
        id: '',
        title: '',
        body: '',
        type: NotificationType.system,
        timestamp: DateTime.now(),
      ),
    );
    
    if (notification.id.isNotEmpty && notification.actionUrl != null) {
      // In a real app, navigate to the appropriate screen
      debugPrint('Navigating to: ${notification.actionUrl}');
    }
  }

  // Handle notification action
  Future<void> handleNotificationAction(String notificationId, String actionId) async {
    await markAsRead(notificationId);
    
    final notification = _notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => PushNotification(
        id: '',
        title: '',
        body: '',
        type: NotificationType.system,
        timestamp: DateTime.now(),
      ),
    );
    
    final action = notification.actions.firstWhere(
      (a) => a.id == actionId,
      orElse: () => const NotificationAction(id: '', title: ''),
    );
    
    if (action.id.isNotEmpty && action.actionUrl != null) {
      // In a real app, navigate to the appropriate screen
      debugPrint('Executing action: ${action.title} -> ${action.actionUrl}');
    }
  }

  // Request permissions
  Future<bool> requestPermissions() async {
    // In a real app, this would request notification permissions
    // For demo purposes, always return true
    return true;
  }

  // Check if permissions are granted
  Future<bool> arePermissionsGranted() async {
    // In a real app, check actual permissions
    return true;
  }

  // Schedule a notification
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    NotificationType type = NotificationType.reminder,
    Map<String, dynamic>? data,
  }) async {
    // In a real app, use flutter_local_notifications to schedule
    debugPrint('Scheduled notification: $title for $scheduledTime');
    
    // For demo, create a timer
    final delay = scheduledTime.difference(DateTime.now());
    if (delay.isNegative) return;
    
    Timer(delay, () {
      final notification = PushNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        timestamp: DateTime.now(),
        data: data,
      );
      
      sendNotification(notification);
    });
  }

  // Cancel scheduled notification
  Future<void> cancelScheduledNotification(String id) async {
    // In a real app, cancel the scheduled notification
    debugPrint('Cancelled scheduled notification: $id');
  }

  @override
  void dispose() {
    _notificationController.close();
    _notificationsListController.close();
    _unreadCountController.close();
    super.dispose();
  }
}