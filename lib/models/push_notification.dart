import 'package:flutter/material.dart';

enum NotificationType {
  booking,
  message,
  payment,
  reminder,
  promotion,
  system,
  review,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

class PushNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? actionUrl;
  final List<NotificationAction> actions;

  const PushNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.data,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.actionUrl,
    this.actions = const [],
  });

  PushNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
    String? actionUrl,
    List<NotificationAction>? actions,
  }) {
    return PushNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      actions: actions ?? this.actions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'priority': priority.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'actions': actions.map((a) => a.toMap()).toList(),
    };
  }

  factory PushNotification.fromMap(Map<String, dynamic> map) {
    return PushNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      data: map['data'],
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] ?? false,
      imageUrl: map['imageUrl'],
      actionUrl: map['actionUrl'],
      actions: (map['actions'] as List<dynamic>?)
              ?.map((a) => NotificationAction.fromMap(a))
              .toList() ??
          [],
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.booking:
        return Icons.car_rental;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.review:
        return Icons.star;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.booking:
        return const Color(0xFF593CFB);
      case NotificationType.message:
        return Colors.blue;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.promotion:
        return Colors.red;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.review:
        return Colors.amber;
    }
  }

  String get timeString {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return '1 day ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get priorityText {
    switch (priority) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }
}

class NotificationAction {
  final String id;
  final String title;
  final String? actionUrl;
  final Map<String, dynamic>? data;
  final bool destructive;

  const NotificationAction({
    required this.id,
    required this.title,
    this.actionUrl,
    this.data,
    this.destructive = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'actionUrl': actionUrl,
      'data': data,
      'destructive': destructive,
    };
  }

  factory NotificationAction.fromMap(Map<String, dynamic> map) {
    return NotificationAction(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      actionUrl: map['actionUrl'],
      data: map['data'],
      destructive: map['destructive'] ?? false,
    );
  }
}

class NotificationSettings {
  final bool enabled;
  final bool bookingNotifications;
  final bool messageNotifications;
  final bool paymentNotifications;
  final bool reminderNotifications;
  final bool promotionNotifications;
  final bool systemNotifications;
  final bool reviewNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String? soundPath;
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;

  const NotificationSettings({
    this.enabled = true,
    this.bookingNotifications = true,
    this.messageNotifications = true,
    this.paymentNotifications = true,
    this.reminderNotifications = true,
    this.promotionNotifications = true,
    this.systemNotifications = true,
    this.reviewNotifications = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.soundPath,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  NotificationSettings copyWith({
    bool? enabled,
    bool? bookingNotifications,
    bool? messageNotifications,
    bool? paymentNotifications,
    bool? reminderNotifications,
    bool? promotionNotifications,
    bool? systemNotifications,
    bool? reviewNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? soundPath,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      bookingNotifications: bookingNotifications ?? this.bookingNotifications,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      paymentNotifications: paymentNotifications ?? this.paymentNotifications,
      reminderNotifications: reminderNotifications ?? this.reminderNotifications,
      promotionNotifications: promotionNotifications ?? this.promotionNotifications,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      reviewNotifications: reviewNotifications ?? this.reviewNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundPath: soundPath ?? this.soundPath,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'bookingNotifications': bookingNotifications,
      'messageNotifications': messageNotifications,
      'paymentNotifications': paymentNotifications,
      'reminderNotifications': reminderNotifications,
      'promotionNotifications': promotionNotifications,
      'systemNotifications': systemNotifications,
      'reviewNotifications': reviewNotifications,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'soundPath': soundPath,
      'quietHoursStart': quietHoursStart != null
          ? '${quietHoursStart!.hour}:${quietHoursStart!.minute}'
          : null,
      'quietHoursEnd': quietHoursEnd != null
          ? '${quietHoursEnd!.hour}:${quietHoursEnd!.minute}'
          : null,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      enabled: map['enabled'] ?? true,
      bookingNotifications: map['bookingNotifications'] ?? true,
      messageNotifications: map['messageNotifications'] ?? true,
      paymentNotifications: map['paymentNotifications'] ?? true,
      reminderNotifications: map['reminderNotifications'] ?? true,
      promotionNotifications: map['promotionNotifications'] ?? true,
      systemNotifications: map['systemNotifications'] ?? true,
      reviewNotifications: map['reviewNotifications'] ?? true,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      soundPath: map['soundPath'],
      quietHoursStart: map['quietHoursStart'] != null
          ? _parseTimeOfDay(map['quietHoursStart'])
          : null,
      quietHoursEnd: map['quietHoursEnd'] != null
          ? _parseTimeOfDay(map['quietHoursEnd'])
          : null,
    );
  }

  static TimeOfDay? _parseTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  bool isNotificationTypeEnabled(NotificationType type) {
    if (!enabled) return false;

    switch (type) {
      case NotificationType.booking:
        return bookingNotifications;
      case NotificationType.message:
        return messageNotifications;
      case NotificationType.payment:
        return paymentNotifications;
      case NotificationType.reminder:
        return reminderNotifications;
      case NotificationType.promotion:
        return promotionNotifications;
      case NotificationType.system:
        return systemNotifications;
      case NotificationType.review:
        return reviewNotifications;
    }
  }

  bool get isInQuietHours {
    if (quietHoursStart == null || quietHoursEnd == null) return false;

    final now = TimeOfDay.now();
    final start = quietHoursStart!;
    final end = quietHoursEnd!;

    // Handle overnight quiet hours (e.g., 22:00 to 08:00)
    if (start.hour > end.hour) {
      return (now.hour >= start.hour || now.hour < end.hour) ||
             (now.hour == start.hour && now.minute >= start.minute) ||
             (now.hour == end.hour && now.minute < end.minute);
    } else {
      // Same day quiet hours (e.g., 12:00 to 14:00)
      return (now.hour > start.hour && now.hour < end.hour) ||
             (now.hour == start.hour && now.minute >= start.minute) ||
             (now.hour == end.hour && now.minute < end.minute);
    }
  }
}

// Notification channel configuration
class NotificationChannel {
  final String id;
  final String name;
  final String description;
  final NotificationPriority importance;
  final bool enableLights;
  final bool enableVibration;
  final Color? lightColor;
  final List<int>? vibrationPattern;
  final String? soundPath;

  const NotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    this.importance = NotificationPriority.normal,
    this.enableLights = true,
    this.enableVibration = true,
    this.lightColor,
    this.vibrationPattern,
    this.soundPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'importance': importance.name,
      'enableLights': enableLights,
      'enableVibration': enableVibration,
      'lightColor': lightColor?.value,
      'vibrationPattern': vibrationPattern,
      'soundPath': soundPath,
    };
  }

  factory NotificationChannel.fromMap(Map<String, dynamic> map) {
    return NotificationChannel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      importance: NotificationPriority.values.firstWhere(
        (e) => e.name == map['importance'],
        orElse: () => NotificationPriority.normal,
      ),
      enableLights: map['enableLights'] ?? true,
      enableVibration: map['enableVibration'] ?? true,
      lightColor: map['lightColor'] != null ? Color(map['lightColor']) : null,
      vibrationPattern: map['vibrationPattern'] != null
          ? List<int>.from(map['vibrationPattern'])
          : null,
      soundPath: map['soundPath'],
    );
  }

  static List<NotificationChannel> get defaultChannels => [
        const NotificationChannel(
          id: 'booking',
          name: 'Booking Notifications',
          description: 'Notifications about your car bookings',
          importance: NotificationPriority.high,
          lightColor: Color(0xFF593CFB),
        ),
        const NotificationChannel(
          id: 'messages',
          name: 'Messages',
          description: 'New messages from hosts and other users',
          importance: NotificationPriority.high,
        ),
        const NotificationChannel(
          id: 'payments',
          name: 'Payment Notifications',
          description: 'Payment confirmations and alerts',
          importance: NotificationPriority.high,
          lightColor: Colors.green,
        ),
        const NotificationChannel(
          id: 'reminders',
          name: 'Reminders',
          description: 'Booking reminders and important dates',
          importance: NotificationPriority.normal,
          lightColor: Colors.orange,
        ),
        const NotificationChannel(
          id: 'promotions',
          name: 'Promotions',
          description: 'Special offers and discounts',
          importance: NotificationPriority.low,
          lightColor: Colors.red,
        ),
        const NotificationChannel(
          id: 'system',
          name: 'System Notifications',
          description: 'App updates and system messages',
          importance: NotificationPriority.low,
        ),
        const NotificationChannel(
          id: 'reviews',
          name: 'Review Notifications',
          description: 'Review requests and responses',
          importance: NotificationPriority.normal,
          lightColor: Colors.amber,
        ),
      ];
}