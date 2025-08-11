import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum MessageType {
  text,
  image,
  location,
  booking,
  system,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;
  final String? replyToId;
  final ChatMessage? replyToMessage;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.readAt,
    this.metadata,
    this.replyToId,
    this.replyToMessage,
  });

  ChatMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
    String? replyToId,
    ChatMessage? replyToMessage,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
      replyToId: replyToId ?? this.replyToId,
      replyToMessage: replyToMessage ?? this.replyToMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'metadata': metadata,
      'replyToId': replyToId,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage.fromJson(map);
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderAvatar: json['senderAvatar'],
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      metadata: json['metadata'],
      replyToId: json['replyToId'],
    );
  }

  // Get current user ID from auth service
  static String? get currentUserId {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (e) {
      debugPrint('Error getting current user ID: $e');
      return null;
    }
  }

  // Check if message is from current user
  bool get isFromCurrentUser {
    final currentId = currentUserId;
    return currentId != null && senderId == currentId;
  }

  // Check if current user is involved in this message (as sender)
  bool get isCurrentUserInvolved {
    final currentId = currentUserId;
    return currentId != null && senderId == currentId;
  }

  // Check if current user is a participant in the chat
  bool get isCurrentUserParticipant {
    final currentId = currentUserId;
    return currentId != null && senderId == currentId;
  }

  bool get isRead => readAt != null;
  bool get isSystem => type == MessageType.system;
  bool get hasReply => replyToId != null;

  String get timeString {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[timestamp.weekday - 1];
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

  IconData get statusIcon {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }

  Color get statusColor {
    switch (status) {
      case MessageStatus.sending:
        return Colors.grey;
      case MessageStatus.sent:
        return Colors.grey;
      case MessageStatus.delivered:
        return Colors.blue;
      case MessageStatus.read:
        return Colors.green;
      case MessageStatus.failed:
        return Colors.red;
    }
  }
}

class ChatRoom {
  final String id;
  final String name;
  final String? description;
  final String? avatar;
  final List<String> participantIds;
  final List<ChatParticipant> participants;
  final ChatMessage? lastMessage;
  final DateTime? lastActivity;
  final int unreadCount;
  final String? bookingId;
  final String? carId;
  final ChatRoomType type;
  final Map<String, dynamic>? metadata;

  const ChatRoom({
    required this.id,
    required this.name,
    this.description,
    this.avatar,
    required this.participantIds,
    required this.participants,
    this.lastMessage,
    this.lastActivity,
    this.unreadCount = 0,
    this.bookingId,
    this.carId,
    this.type = ChatRoomType.direct,
    this.metadata,
  });

  ChatRoom copyWith({
    String? id,
    String? name,
    String? description,
    String? avatar,
    List<String>? participantIds,
    List<ChatParticipant>? participants,
    ChatMessage? lastMessage,
    DateTime? lastActivity,
    int? unreadCount,
    String? bookingId,
    String? carId,
    ChatRoomType? type,
    Map<String, dynamic>? metadata,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      participantIds: participantIds ?? this.participantIds,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastActivity: lastActivity ?? this.lastActivity,
      unreadCount: unreadCount ?? this.unreadCount,
      bookingId: bookingId ?? this.bookingId,
      carId: carId ?? this.carId,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatar': avatar,
      'participantIds': participantIds,
      'participants': participants.map((p) => p.toMap()).toList(),
      'lastMessage': lastMessage?.toMap(),
      'lastActivity': lastActivity?.toIso8601String(),
      'unreadCount': unreadCount,
      'bookingId': bookingId,
      'carId': carId,
      'type': type.name,
      'metadata': metadata,
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      avatar: map['avatar'],
      participantIds: List<String>.from(map['participantIds'] ?? []),
      participants: (map['participants'] as List<dynamic>?)
              ?.map((p) => ChatParticipant.fromMap(p))
              .toList() ??
          [],
      lastMessage: map['lastMessage'] != null
          ? ChatMessage.fromMap(map['lastMessage'])
          : null,
      lastActivity: map['lastActivity'] != null
          ? DateTime.parse(map['lastActivity'])
          : null,
      unreadCount: map['unreadCount'] ?? 0,
      bookingId: map['bookingId'],
      carId: map['carId'],
      type: ChatRoomType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ChatRoomType.direct,
      ),
      metadata: map['metadata'],
    );
  }

  bool get hasUnreadMessages => unreadCount > 0;
  bool get isBookingRelated => bookingId != null;
  String get lastActivityString {
    if (lastActivity == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(lastActivity!);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return '1d ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${lastActivity!.day}/${lastActivity!.month}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class ChatParticipant {
  final String id;
  final String name;
  final String? avatar;
  final String? email;
  final bool isOnline;
  final DateTime? lastSeen;
  final ChatParticipantRole role;

  const ChatParticipant({
    required this.id,
    required this.name,
    this.avatar,
    this.email,
    this.isOnline = false,
    this.lastSeen,
    this.role = ChatParticipantRole.member,
  });

  ChatParticipant copyWith({
    String? id,
    String? name,
    String? avatar,
    String? email,
    bool? isOnline,
    DateTime? lastSeen,
    ChatParticipantRole? role,
  }) {
    return ChatParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'email': email,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'role': role.name,
    };
  }

  factory ChatParticipant.fromMap(Map<String, dynamic> map) {
    return ChatParticipant(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      avatar: map['avatar'],
      email: map['email'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null ? DateTime.parse(map['lastSeen']) : null,
      role: ChatParticipantRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => ChatParticipantRole.member,
      ),
    );
  }

  String get statusText {
    if (isOnline) return 'Online';
    if (lastSeen == null) return 'Offline';
    
    final now = DateTime.now();
    final difference = now.difference(lastSeen!);

    if (difference.inDays > 0) {
      return 'Last seen ${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return 'Last seen ${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return 'Last seen ${difference.inMinutes}m ago';
    } else {
      return 'Last seen just now';
    }
  }
}

enum ChatRoomType {
  direct,
  group,
  support,
  booking,
}

enum ChatParticipantRole {
  owner,
  admin,
  member,
}

// Typing indicator model
class TypingIndicator {
  final String userId;
  final String userName;
  final DateTime timestamp;

  const TypingIndicator({
    required this.userId,
    required this.userName,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TypingIndicator.fromMap(Map<String, dynamic> map) {
    return TypingIndicator(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  bool get isExpired {
    final now = DateTime.now();
    return now.difference(timestamp).inSeconds > 5; // 5 seconds timeout
  }
}