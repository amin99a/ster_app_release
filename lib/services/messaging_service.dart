import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';

class MessagingService extends ChangeNotifier {
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  SupabaseClient get client => Supabase.instance.client;
  
  // Real-time subscriptions
  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _conversationsChannel;
  
  // Stream controllers for real-time updates
  final StreamController<List<Message>> _messagesController = StreamController<List<Message>>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _conversationsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<Message> _newMessageController = StreamController<Message>.broadcast();
  final StreamController<String> _typingController = StreamController<String>.broadcast();

  // Getters for streams
  Stream<List<Message>> get messagesStream => _messagesController.stream;
  Stream<List<Map<String, dynamic>>> get conversationsStream => _conversationsController.stream;
  Stream<Message> get newMessageStream => _newMessageController.stream;
  Stream<String> get typingStream => _typingController.stream;

  // Initialize real-time subscriptions
  Future<void> initialize() async {
    await _setupRealtimeSubscriptions();
  }

  Future<void> _setupRealtimeSubscriptions() async {
    try {
      // Subscribe to messages table
      _messagesChannel = client.channel('messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final message = Message.fromJson(payload.newRecord);
            _newMessageController.add(message);
            debugPrint('New message received: ${message.content}');
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final message = Message.fromJson(payload.newRecord);
            debugPrint('Message updated: ${message.id}');
          },
        )
        .subscribe();

      // Subscribe to conversations table
      _conversationsChannel = client.channel('conversations')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'conversations',
          callback: (payload) {
            debugPrint('New conversation created');
          },
        )
        .subscribe();

      debugPrint('Real-time messaging subscriptions initialized');
    } catch (e) {
      debugPrint('Error setting up real-time subscriptions: $e');
    }
  }

  // Send a text message
  Future<Message?> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderImage,
    required String receiverId,
    required String receiverName,
    String? receiverImage,
    required String content,
    String? rentalId,
    String? carId,
  }) async {
    try {
      final messageData = {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_image': senderImage,
        'receiver_id': receiverId,
        'receiver_name': receiverName,
        'receiver_image': receiverImage,
        'type': 'text',
        'content': content,
        'rental_id': rentalId,
        'car_id': carId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('messages')
          .insert(messageData)
          .select()
          .single();

      return Message.fromJson(response);
    } catch (e) {
      debugPrint('Error sending text message: $e');
      return null;
    }
  }

  // Send a file message
  Future<Message?> sendFileMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required File file,
    String? caption,
    String? rentalId,
    String? carId,
  }) async {
    try {
      // Upload file to Supabase Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final filePath = 'messages/$conversationId/$fileName';
      
      await client.storage
          .from('message-files')
          .upload(filePath, file);

      final fileUrl = client.storage
          .from('message-files')
          .getPublicUrl(filePath);

      final messageData = {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_name': senderName,
        'receiver_id': receiverId,
        'receiver_name': receiverName,
        'type': 'file',
        'content': fileUrl,
        'caption': caption,
        'rental_id': rentalId,
        'car_id': carId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('messages')
          .insert(messageData)
          .select()
          .single();

      return Message.fromJson(response);
    } catch (e) {
      debugPrint('Error sending file message: $e');
      return null;
    }
  }

  // Send an image message
  Future<Message?> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required File imageFile,
    String? caption,
    String? rentalId,
    String? carId,
  }) async {
    try {
      // Upload image to Supabase Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final filePath = 'messages/$conversationId/$fileName';
      
      await client.storage
          .from('message-images')
          .upload(filePath, imageFile);

      final imageUrl = client.storage
          .from('message-images')
          .getPublicUrl(filePath);

      final messageData = {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_name': senderName,
        'receiver_id': receiverId,
        'receiver_name': receiverName,
        'type': 'image',
        'content': imageUrl,
        'caption': caption,
        'rental_id': rentalId,
        'car_id': carId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('messages')
          .insert(messageData)
          .select()
          .single();

      return Message.fromJson(response);
    } catch (e) {
      debugPrint('Error sending image message: $e');
      return null;
    }
  }

  // Send a location message
  Future<Message?> sendLocationMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required Map<String, dynamic> locationData,
    String? caption,
    String? rentalId,
    String? carId,
  }) async {
    try {
      final messageData = {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_name': senderName,
        'receiver_id': receiverId,
        'receiver_name': receiverName,
        'type': 'location',
        'content': jsonEncode(locationData),
        'caption': caption,
        'rental_id': rentalId,
        'car_id': carId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('messages')
          .insert(messageData)
          .select()
          .single();

      return Message.fromJson(response);
    } catch (e) {
      debugPrint('Error sending location message: $e');
      return null;
    }
  }

  // Get conversation messages
  Future<List<Message>> getConversationMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
    String? beforeMessageId,
  }) async {
    try {
      var query = client
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      if (beforeMessageId != null) {
        query = client
            .from('messages')
            .select()
            .eq('conversation_id', conversationId)
            .lt('id', beforeMessageId)
            .order('created_at', ascending: false)
            .range((page - 1) * limit, page * limit - 1);
      }

      final response = await query;
      return response.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting conversation messages: $e');
      return [];
    }
  }

  // Get user conversations
  Future<List<Map<String, dynamic>>> getUserConversations(String userId) async {
    try {
      final response = await client
          .from('conversations')
          .select('*, messages(*)')
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .order('updated_at', ascending: false);

      return response.map((json) => Map<String, dynamic>.from(json)).toList();
    } catch (e) {
      debugPrint('Error getting user conversations: $e');
      return [];
    }
  }

  // Get rental conversation
  Future<List<Message>> getRentalConversation(String rentalId) async {
    try {
      final response = await client
          .from('messages')
          .select()
          .eq('rental_id', rentalId)
          .order('created_at', ascending: true);

      return response.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting rental conversation: $e');
      return [];
    }
  }

  // Mark message as read
  Future<bool> markMessageAsRead(String messageId) async {
    try {
      await client
          .from('messages')
          .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('id', messageId);

      return true;
    } catch (e) {
      debugPrint('Error marking message as read: $e');
      return false;
    }
  }

  // Mark conversation as read
  Future<bool> markConversationAsRead(String conversationId, String userId) async {
    try {
      await client
          .from('messages')
          .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId);

      return true;
    } catch (e) {
      debugPrint('Error marking conversation as read: $e');
      return false;
    }
  }

  // Delete message
  Future<bool> deleteMessage(String messageId, String userId) async {
    try {
      await client
          .from('messages')
          .update({
            'deleted_at': DateTime.now().toIso8601String(),
            'deleted_by': userId,
          })
          .eq('id', messageId)
          .eq('sender_id', userId); // Only sender can delete

      return true;
    } catch (e) {
      debugPrint('Error deleting message: $e');
      return false;
    }
  }

  // Edit message
  Future<Message?> editMessage({
    required String messageId,
    required String newContent,
    required String editedBy,
  }) async {
    try {
      final response = await client
          .from('messages')
          .update({
            'content': newContent,
            'edited_at': DateTime.now().toIso8601String(),
            'edited_by': editedBy,
          })
          .eq('id', messageId)
          .eq('sender_id', editedBy) // Only sender can edit
          .select()
          .single();

      return Message.fromJson(response);
    } catch (e) {
      debugPrint('Error editing message: $e');
      return null;
    }
  }

  // Reply to message
  Future<Message?> replyToMessage({
    required String replyToMessageId,
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String content,
    String? caption,
  }) async {
    try {
      final messageData = {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_name': senderName,
        'receiver_id': receiverId,
        'receiver_name': receiverName,
        'type': 'text',
        'content': content,
        'caption': caption,
        'reply_to_message_id': replyToMessageId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('messages')
          .insert(messageData)
          .select()
          .single();

      return Message.fromJson(response);
    } catch (e) {
      debugPrint('Error replying to message: $e');
      return null;
    }
  }

  // Get unread message count
  Future<int> getUnreadMessageCount(String userId) async {
    try {
      final response = await client
          .from('messages')
          .select('id')
          .eq('receiver_id', userId)
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      debugPrint('Error getting unread message count: $e');
      return 0;
    }
  }

  // Search messages
  Future<List<Message>> searchMessages({
    required String userId,
    required String query,
    String? conversationId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      var searchQuery = client
          .from('messages')
          .select()
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .ilike('content', '%$query%')
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      if (conversationId != null) {
        searchQuery = client
            .from('messages')
            .select()
            .or('sender_id.eq.$userId,receiver_id.eq.$userId')
            .eq('conversation_id', conversationId)
            .ilike('content', '%$query%')
            .order('created_at', ascending: false)
            .range((page - 1) * limit, page * limit - 1);
      }
      if (type != null) {
        searchQuery = client
            .from('messages')
            .select()
            .or('sender_id.eq.$userId,receiver_id.eq.$userId')
            .eq('type', type)
            .ilike('content', '%$query%')
            .order('created_at', ascending: false)
            .range((page - 1) * limit, page * limit - 1);
      }
      if (startDate != null) {
        searchQuery = client
            .from('messages')
            .select()
            .or('sender_id.eq.$userId,receiver_id.eq.$userId')
            .gte('created_at', startDate.toIso8601String())
            .ilike('content', '%$query%')
            .order('created_at', ascending: false)
            .range((page - 1) * limit, page * limit - 1);
      }
      if (endDate != null) {
        searchQuery = client
            .from('messages')
            .select()
            .or('sender_id.eq.$userId,receiver_id.eq.$userId')
            .lte('created_at', endDate.toIso8601String())
            .ilike('content', '%$query%')
            .order('created_at', ascending: false)
            .range((page - 1) * limit, page * limit - 1);
      }

      final response = await searchQuery;
      return response.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error searching messages: $e');
      return [];
    }
  }

  // Create or get conversation
  Future<String?> createOrGetConversation({
    required String userId1,
    required String userId2,
    String type = 'rental_chat',
    String? rentalId,
    String? carId,
  }) async {
    try {
      // Check if conversation already exists
      final existingConversation = await client
          .from('conversations')
          .select('id')
          .or('and(user1_id.eq.$userId1,user2_id.eq.$userId2),and(user1_id.eq.$userId2,user2_id.eq.$userId1)')
          .eq('type', type)
          .maybeSingle();

      if (existingConversation != null) {
        return existingConversation['id'];
      }

      // Create new conversation
      final conversationData = {
        'user1_id': userId1,
        'user2_id': userId2,
        'type': type,
        'rental_id': rentalId,
        'car_id': carId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('conversations')
          .insert(conversationData)
          .select()
          .single();

      return response['id'];
    } catch (e) {
      debugPrint('Error creating or getting conversation: $e');
      return null;
    }
  }

  // Send typing indicator
  Future<void> sendTypingIndicator(String conversationId, String userId, bool isTyping) async {
    try {
      _typingController.add('$conversationId:$userId:$isTyping');
    } catch (e) {
      debugPrint('Error sending typing indicator: $e');
    }
  }

  // Dispose resources
  @override
  void dispose() {
    _messagesChannel?.unsubscribe();
    _conversationsChannel?.unsubscribe();
    _messagesController.close();
    _conversationsController.close();
    _newMessageController.close();
    _typingController.close();
    super.dispose();
  }
} 