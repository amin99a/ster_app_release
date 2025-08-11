import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  bool isRead; // Made mutable
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      isRead: json['isRead'] ?? false,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      icon: IconData(json['iconCodePoint'] ?? 0, fontFamily: 'MaterialIcons'),
      iconColor: Color(json['iconColor'] ?? 0xFF593CFB),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
      'iconCodePoint': icon.codePoint,
      'iconColor': iconColor.value,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? timestamp,
    IconData? icon,
    Color? iconColor,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
    );
  }
} 