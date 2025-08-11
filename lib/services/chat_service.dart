import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class ChatService extends ChangeNotifier {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  // Mock data storage
  final Map<String, ChatRoom> _chatRooms = {};
  final Map<String, List<ChatMessage>> _messages = {};
  final Map<String, List<TypingIndicator>> _typingIndicators = {};
  
  // Stream controllers for real-time updates
  final StreamController<List<ChatRoom>> _chatRoomsController = StreamController<List<ChatRoom>>.broadcast();
  final StreamController<ChatMessage> _newMessageController = StreamController<ChatMessage>.broadcast();
  final StreamController<String> _messageStatusController = StreamController<String>.broadcast();
  final StreamController<TypingIndicator> _typingController = StreamController<TypingIndicator>.broadcast();
  
  // Current user ID (mock)
  final String _currentUserId = 'current_user_id';
  
  // Getters for streams
  Stream<List<ChatRoom>> get chatRoomsStream => _chatRoomsController.stream;
  Stream<ChatMessage> get newMessageStream => _newMessageController.stream;
  Stream<String> get messageStatusStream => _messageStatusController.stream;
  Stream<TypingIndicator> get typingStream => _typingController.stream;

  // Initialize with mock data
  void initialize() {
    _initializeMockData();
    _loadChatHistory(); // Load saved chat history
  }

  // Save chat history to local storage
  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = <String, List<Map<String, dynamic>>>{};
      
      for (final entry in _messages.entries) {
        messagesJson[entry.key] = entry.value.map((msg) => msg.toJson()).toList();
      }
      
      await prefs.setString('chat_history', jsonEncode(messagesJson));
      debugPrint('Chat history saved to local storage');
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }

  // Load chat history from local storage
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatHistoryString = prefs.getString('chat_history');
      
      if (chatHistoryString != null) {
        final messagesJson = Map<String, List<dynamic>>.from(
          jsonDecode(chatHistoryString) as Map<String, dynamic>
        );
        
        for (final entry in messagesJson.entries) {
          _messages[entry.key] = entry.value
              .map((msgJson) => ChatMessage.fromJson(Map<String, dynamic>.from(msgJson)))
              .toList();
        }
        
        debugPrint('Chat history loaded from local storage');
        _updateLastMessages();
        _chatRoomsController.add(getChatRooms());
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    }
  }

  void _initializeMockData() {
    // Create mock chat rooms
    final mockRooms = [
      ChatRoom(
        id: 'chat_1',
        name: 'Ahmed Hassan',
        avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        participantIds: ['current_user_id', 'ahmed_hassan'],
        participants: [
          ChatParticipant(
            id: 'current_user_id',
            name: 'You',
            isOnline: true,
          ),
          ChatParticipant(
            id: 'ahmed_hassan',
            name: 'Ahmed Hassan',
            avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
            isOnline: true,
            role: ChatParticipantRole.owner,
          ),
        ],
        bookingId: 'booking_123',
        carId: 'car_456',
        type: ChatRoomType.booking,
        unreadCount: 2,
        lastActivity: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatRoom(
        id: 'chat_2',
        name: 'Sara Benali',
        avatar: 'https://images.unsplash.com/photo-1494790108755-2616b2e3c24b?w=150&h=150&fit=crop&crop=face',
        participantIds: ['current_user_id', 'sara_benali'],
        participants: [
          ChatParticipant(
            id: 'current_user_id',
            name: 'You',
            isOnline: true,
          ),
          ChatParticipant(
            id: 'sara_benali',
            name: 'Sara Benali',
            avatar: 'https://images.unsplash.com/photo-1494790108755-2616b2e3c24b?w=150&h=150&fit=crop&crop=face',
            isOnline: false,
            lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
        type: ChatRoomType.direct,
        unreadCount: 0,
        lastActivity: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      ChatRoom(
        id: 'chat_3',
        name: 'STER Support',
        avatar: null,
        participantIds: ['current_user_id', 'support_agent'],
        participants: [
          ChatParticipant(
            id: 'current_user_id',
            name: 'You',
            isOnline: true,
          ),
          ChatParticipant(
            id: 'support_agent',
            name: 'Support Agent',
            isOnline: true,
            role: ChatParticipantRole.admin,
          ),
        ],
        type: ChatRoomType.support,
        unreadCount: 1,
        lastActivity: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];

    for (final room in mockRooms) {
      _chatRooms[room.id] = room;
    }

    // Create mock messages
    _initializeMockMessages();
    
    // Update last messages
    _updateLastMessages();
    
    // Notify listeners
    _chatRoomsController.add(_chatRooms.values.toList());
  }

  void _initializeMockMessages() {
    final now = DateTime.now();
    
    // Chat 1 messages (Ahmed Hassan - Booking related)
    _messages['chat_1'] = [
      ChatMessage(
        id: 'msg_1',
        chatId: 'chat_1',
        senderId: 'ahmed_hassan',
        senderName: 'Ahmed Hassan',
        senderAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        content: 'Hi! I see you\'re interested in my BMW X5. It\'s available for your requested dates.',
        timestamp: now.subtract(const Duration(hours: 2)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_2',
        chatId: 'chat_1',
        senderId: 'current_user_id',
        senderName: 'You',
        content: 'Great! Can you tell me more about the car\'s condition and any special requirements?',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_3',
        chatId: 'chat_1',
        senderId: 'ahmed_hassan',
        senderName: 'Ahmed Hassan',
        senderAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        content: 'The car is in excellent condition, recently serviced. Just need a valid license and credit card for security deposit.',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 30)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_4',
        chatId: 'chat_1',
        senderId: 'ahmed_hassan',
        senderName: 'Ahmed Hassan',
        senderAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        content: 'I can meet you at the Algiers Airport for pickup if that works for you?',
        timestamp: now.subtract(const Duration(minutes: 5)),
        status: MessageStatus.delivered,
      ),
    ];

    // Chat 2 messages (Sara Benali)
    _messages['chat_2'] = [
      ChatMessage(
        id: 'msg_5',
        chatId: 'chat_2',
        senderId: 'current_user_id',
        senderName: 'You',
        content: 'Hi Sara! I\'m interested in renting your Mercedes C-Class for the weekend.',
        timestamp: now.subtract(const Duration(hours: 4)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_6',
        chatId: 'chat_2',
        senderId: 'sara_benali',
        senderName: 'Sara Benali',
        senderAvatar: 'https://images.unsplash.com/photo-1494790108755-2616b2e3c24b?w=150&h=150&fit=crop&crop=face',
        content: 'Hello! The car is available. It comes with full insurance and GPS navigation.',
        timestamp: now.subtract(const Duration(hours: 3)),
        status: MessageStatus.read,
      ),
    ];

    // Chat 3 messages (Support)
    _messages['chat_3'] = [
      ChatMessage(
        id: 'msg_7',
        chatId: 'chat_3',
        senderId: 'current_user_id',
        senderName: 'You',
        content: 'I need help with my booking payment. The transaction seems to be stuck.',
        timestamp: now.subtract(const Duration(minutes: 45)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_8',
        chatId: 'chat_3',
        senderId: 'support_agent',
        senderName: 'Support Agent',
        content: 'Hi! I can help you with that. Can you please provide your booking reference number?',
        timestamp: now.subtract(const Duration(minutes: 30)),
        status: MessageStatus.delivered,
      ),
    ];
  }

  void _updateLastMessages() {
    for (final roomId in _chatRooms.keys) {
      final messages = _messages[roomId];
      if (messages != null && messages.isNotEmpty) {
        final lastMessage = messages.last;
        _chatRooms[roomId] = _chatRooms[roomId]!.copyWith(
          lastMessage: lastMessage,
          lastActivity: lastMessage.timestamp,
        );
      }
    }
  }

  // Get all chat rooms
  List<ChatRoom> getChatRooms() {
    final rooms = _chatRooms.values.toList();
    rooms.sort((a, b) => (b.lastActivity ?? DateTime(2000)).compareTo(a.lastActivity ?? DateTime(2000)));
    return rooms;
  }

  // Get messages for a specific chat room
  List<ChatMessage> getMessages(String chatId) {
    return _messages[chatId] ?? [];
  }

  // Send a new message
  Future<void> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToId,
    Map<String, dynamic>? metadata,
  }) async {
    final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final message = ChatMessage(
      id: messageId,
      chatId: chatId,
      senderId: _currentUserId,
      senderName: 'You',
      content: content,
      type: type,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
      replyToId: replyToId,
      metadata: metadata,
    );

    // Add message to local storage
    if (_messages[chatId] == null) {
      _messages[chatId] = [];
    }
    _messages[chatId]!.add(message);

    // Update chat room's last message
    if (_chatRooms.containsKey(chatId)) {
      _chatRooms[chatId] = _chatRooms[chatId]!.copyWith(
        lastMessage: message,
        lastActivity: message.timestamp,
      );
    }

    // Save chat history to local storage
    await _saveChatHistory();

    // Notify listeners
    _newMessageController.add(message);
    _chatRoomsController.add(getChatRooms());
    notifyListeners();

    // Simulate network delay and status updates
    await Future.delayed(const Duration(milliseconds: 500));
    _updateMessageStatus(messageId, MessageStatus.sent);

    await Future.delayed(const Duration(milliseconds: 1000));
    _updateMessageStatus(messageId, MessageStatus.delivered);

    // Simulate auto-reply for demo purposes
    if (chatId != 'chat_3') { // Don't auto-reply for support chat
      _simulateReply(chatId, content);
    }
  }

  // Update message status
  void _updateMessageStatus(String messageId, MessageStatus status) {
    for (final messages in _messages.values) {
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].id == messageId) {
          messages[i] = messages[i].copyWith(status: status);
          _messageStatusController.add(messageId);
          notifyListeners();
          return;
        }
      }
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    final messages = _messages[chatId];
    if (messages == null) return;

    bool hasChanges = false;
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].senderId != _currentUserId && !messages[i].isRead) {
        messages[i] = messages[i].copyWith(
          status: MessageStatus.read,
          readAt: DateTime.now(),
        );
        hasChanges = true;
      }
    }

    if (hasChanges) {
      // Update unread count
      if (_chatRooms.containsKey(chatId)) {
        _chatRooms[chatId] = _chatRooms[chatId]!.copyWith(unreadCount: 0);
      }
      
      _chatRoomsController.add(getChatRooms());
      notifyListeners();
    }
  }

  // Start typing indicator
  void startTyping(String chatId) {
    final indicator = TypingIndicator(
      userId: _currentUserId,
      userName: 'You',
      timestamp: DateTime.now(),
    );

    if (_typingIndicators[chatId] == null) {
      _typingIndicators[chatId] = [];
    }
    
    // Remove existing indicator for current user
    _typingIndicators[chatId]!.removeWhere((i) => i.userId == _currentUserId);
    
    // Add new indicator
    _typingIndicators[chatId]!.add(indicator);
    _typingController.add(indicator);
  }

  // Stop typing indicator
  void stopTyping(String chatId) {
    if (_typingIndicators[chatId] != null) {
      _typingIndicators[chatId]!.removeWhere((i) => i.userId == _currentUserId);
    }
  }

  // Get typing indicators for a chat
  List<TypingIndicator> getTypingIndicators(String chatId) {
    final indicators = _typingIndicators[chatId] ?? [];
    // Filter out expired indicators
    final now = DateTime.now();
    return indicators.where((i) => 
      i.userId != _currentUserId && 
      now.difference(i.timestamp).inSeconds < 5
    ).toList();
  }

  // Create a new chat room
  Future<ChatRoom> createChatRoom({
    required String name,
    required List<String> participantIds,
    String? description,
    String? avatar,
    ChatRoomType type = ChatRoomType.direct,
    String? bookingId,
    String? carId,
  }) async {
    final roomId = 'chat_${DateTime.now().millisecondsSinceEpoch}';
    
    // Create participants list (mock data)
    final participants = participantIds.map((id) {
      if (id == _currentUserId) {
        return const ChatParticipant(
          id: 'current_user_id',
          name: 'You',
          isOnline: true,
        );
      } else {
        return ChatParticipant(
          id: id,
          name: name, // In real app, fetch from user service
          isOnline: false,
        );
      }
    }).toList();

    final chatRoom = ChatRoom(
      id: roomId,
      name: name,
      description: description,
      avatar: avatar,
      participantIds: participantIds,
      participants: participants,
      type: type,
      bookingId: bookingId,
      carId: carId,
      lastActivity: DateTime.now(),
    );

    _chatRooms[roomId] = chatRoom;
    _messages[roomId] = [];
    
    _chatRoomsController.add(getChatRooms());
    notifyListeners();

    return chatRoom;
  }

  // Delete a chat room
  Future<void> deleteChatRoom(String chatId) async {
    _chatRooms.remove(chatId);
    _messages.remove(chatId);
    _typingIndicators.remove(chatId);
    
    _chatRoomsController.add(getChatRooms());
    notifyListeners();
  }

  // Search messages
  List<ChatMessage> searchMessages(String query, {String? chatId}) {
    final results = <ChatMessage>[];
    final searchTerm = query.toLowerCase();

    final messagesToSearch = chatId != null 
        ? {chatId: _messages[chatId] ?? []}
        : _messages;

    for (final messages in messagesToSearch.values) {
      for (final message in messages) {
        if (message.content.toLowerCase().contains(searchTerm)) {
          results.add(message);
        }
      }
    }

    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }

  // Get unread message count
  int getTotalUnreadCount() {
    return _chatRooms.values.fold(0, (sum, room) => sum + room.unreadCount);
  }

  // Simulate auto-reply for demo
  void _simulateReply(String chatId, String originalMessage) {
    final room = _chatRooms[chatId];
    if (room == null) return;

    final otherParticipant = room.participants.firstWhere(
      (p) => p.id != _currentUserId,
      orElse: () => const ChatParticipant(id: 'unknown', name: 'Unknown'),
    );

    // Generate random reply based on original message
    final replies = _getRandomReplies(originalMessage);
    final randomReply = replies[Random().nextInt(replies.length)];

        // Simulate typing delay
    Timer(const Duration(seconds: 2), () async {
      final replyMessage = ChatMessage(
        id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatId,
        senderId: otherParticipant.id,
        senderName: otherParticipant.name,
        senderAvatar: otherParticipant.avatar,
        content: randomReply,
        timestamp: DateTime.now(),
        status: MessageStatus.delivered,
      );

      _messages[chatId]!.add(replyMessage);

      // Update chat room
      _chatRooms[chatId] = _chatRooms[chatId]!.copyWith(
        lastMessage: replyMessage,
        lastActivity: replyMessage.timestamp,
        unreadCount: _chatRooms[chatId]!.unreadCount + 1,
      );

      // Save chat history to local storage
      await _saveChatHistory();

      _newMessageController.add(replyMessage);
      _chatRoomsController.add(getChatRooms());
      notifyListeners();
    });
  }

  List<String> _getRandomReplies(String originalMessage) {
    final message = originalMessage.toLowerCase();
    
    if (message.contains('hello') || message.contains('hi')) {
      return [
        'Hello! How can I help you?',
        'Hi there! Thanks for reaching out.',
        'Hey! Good to hear from you.',
      ];
    } else if (message.contains('available') || message.contains('book')) {
      return [
        'Yes, it\'s available for those dates!',
        'Let me check the availability for you.',
        'Sure, I can accommodate that booking.',
      ];
    } else if (message.contains('price') || message.contains('cost')) {
      return [
        'The price is as listed, but we can discuss if you\'re booking for multiple days.',
        'That\'s the daily rate. Are you interested?',
        'The pricing includes insurance and basic coverage.',
      ];
    } else if (message.contains('location') || message.contains('pickup')) {
      return [
        'I can meet you at a convenient location.',
        'Pickup is flexible - where would work best for you?',
        'I usually do pickups at the airport or city center.',
      ];
    } else {
      return [
        'Thanks for your message! Let me get back to you on that.',
        'That sounds good. Let me know if you have any other questions.',
        'Sure, I can help with that. What else would you like to know?',
        'Perfect! Feel free to ask if you need more details.',
      ];
    }
  }

  @override
  void dispose() {
    _chatRoomsController.close();
    _newMessageController.close();
    _messageStatusController.close();
    _typingController.close();
    super.dispose();
  }
}