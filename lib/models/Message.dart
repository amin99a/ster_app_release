import 'dart:convert';

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderImage;
  final String receiverId;
  final String receiverName;
  final String? receiverImage;
  final String content;
  final String type;
  final String? caption;
  final String? rentalId;
  final String? carId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime? editedAt;
  final String? editedBy;
  final DateTime? deletedAt;
  final String? deletedBy;
  final String? replyToMessageId;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderImage,
    required this.receiverId,
    required this.receiverName,
    this.receiverImage,
    required this.content,
    required this.type,
    this.caption,
    this.rentalId,
    this.carId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.editedAt,
    this.editedBy,
    this.deletedAt,
    this.deletedBy,
    this.replyToMessageId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      senderName: json['sender_name'] ?? '',
      senderImage: json['sender_image'],
      receiverId: json['receiver_id'] ?? '',
      receiverName: json['receiver_name'] ?? '',
      receiverImage: json['receiver_image'],
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      caption: json['caption'],
      rentalId: json['rental_id'],
      carId: json['car_id'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      editedAt: json['edited_at'] != null ? DateTime.parse(json['edited_at']) : null,
      editedBy: json['edited_by'],
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      deletedBy: json['deleted_by'],
      replyToMessageId: json['reply_to_message_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_image': senderImage,
      'receiver_id': receiverId,
      'receiver_name': receiverName,
      'receiver_image': receiverImage,
      'content': content,
      'type': type,
      'caption': caption,
      'rental_id': rentalId,
      'car_id': carId,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
      'edited_by': editedBy,
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by': deletedBy,
      'reply_to_message_id': replyToMessageId,
    };
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderImage,
    String? receiverId,
    String? receiverName,
    String? receiverImage,
    String? content,
    String? type,
    String? caption,
    String? rentalId,
    String? carId,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? editedAt,
    String? editedBy,
    DateTime? deletedAt,
    String? deletedBy,
    String? replyToMessageId,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverImage: receiverImage ?? this.receiverImage,
      content: content ?? this.content,
      type: type ?? this.type,
      caption: caption ?? this.caption,
      rentalId: rentalId ?? this.rentalId,
      carId: carId ?? this.carId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      editedBy: editedBy ?? this.editedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    );
  }
} 