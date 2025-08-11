import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../services/messaging_service.dart';
import '../utils/animations.dart';
import '../widgets/floating_header.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatDetailScreen({
    super.key,
    required this.chatRoom,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with TickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  late MessagingService _messagingService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  List<TypingIndicator> _typingIndicators = [];
  bool _isTyping = false;
  Timer? _typingTimer;
  
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  StreamSubscription? _newMessageSubscription;
  StreamSubscription? _typingSubscription;

  @override
  void initState() {
    super.initState();
    _messagingService = Provider.of<MessagingService>(context, listen: false);
    _initializeAnimations();
    _loadMessages();
    _setupListeners();
    _markMessagesAsRead();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppAnimations.smoothCurve,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.smoothCurve,
    ));
    
    _slideController.forward();
    _fadeController.forward();
  }

  void _loadMessages() async {
    // Load messages from ChatService for immediate display
    setState(() {
      _messages = _chatService.getMessages(widget.chatRoom.id);
    });
    
    // Also try to load messages from database for persistence
    try {
      // Get conversation ID
      final conversationId = await _messagingService.createOrGetConversation(
        userId1: 'current_user_id', // Replace with actual user ID
        userId2: widget.chatRoom.participants.firstWhere((p) => p.id != 'current_user_id').id,
        type: 'rental_chat',
        carId: widget.chatRoom.carId,
      );
      
      if (conversationId != null) {
        final dbMessages = await _messagingService.getConversationMessages(
          conversationId: conversationId,
        );
        
        // Convert database messages to ChatMessage format and merge
        if (dbMessages.isNotEmpty) {
          final convertedMessages = dbMessages.map((dbMsg) => ChatMessage(
            id: dbMsg.id,
            chatId: widget.chatRoom.id,
            senderId: dbMsg.senderId,
            senderName: dbMsg.senderName,
            senderAvatar: dbMsg.senderImage,
            content: dbMsg.content,
            timestamp: dbMsg.createdAt,
            status: dbMsg.isRead ? MessageStatus.read : MessageStatus.delivered,
          )).toList();
          
          setState(() {
            _messages = convertedMessages;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading messages from database: $e');
      // Continue with mock data if database fails
    }
    
    _scrollToBottom();
  }

  void _setupListeners() {
    _newMessageSubscription = _chatService.newMessageStream.listen((message) {
      if (message.chatId == widget.chatRoom.id) {
        setState(() {
          if (!_messages.any((m) => m.id == message.id)) {
            _messages.add(message);
          }
        });
        _scrollToBottom();
        _markMessagesAsRead();
      }
    });

    _typingSubscription = _chatService.typingStream.listen((indicator) {
      if (indicator.userId != 'current_user_id') {
        setState(() {
          _typingIndicators = _chatService.getTypingIndicators(widget.chatRoom.id);
        });
      }
    });

    _messageController.addListener(_onMessageChanged);
  }

  void _onMessageChanged() {
    final text = _messageController.text.trim();
    
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      _chatService.startTyping(widget.chatRoom.id);
    } else if (text.isEmpty && _isTyping) {
      _isTyping = false;
      _chatService.stopTyping(widget.chatRoom.id);
    }
    
    // Reset typing timer
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        _chatService.stopTyping(widget.chatRoom.id);
      }
    });
  }

  void _markMessagesAsRead() {
    _chatService.markMessagesAsRead(widget.chatRoom.id);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppAnimations.fast,
          curve: AppAnimations.smoothCurve,
        );
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _newMessageSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    
    if (_isTyping) {
      _chatService.stopTyping(widget.chatRoom.id);
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Custom Floating Header
          _buildCustomHeader(),
          
          // Messages List
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildMessagesList(),
            ),
          ),
          
          // Typing Indicators
          if (_typingIndicators.isNotEmpty)
            _buildTypingIndicators(),
          
          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    final otherParticipant = widget.chatRoom.participants.firstWhere(
      (p) => p.id != 'current_user_id',
      orElse: () => const ChatParticipant(id: 'unknown', name: 'Unknown'),
    );

    return FloatingHeader(
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF353935),
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: widget.chatRoom.avatar != null
                    ? NetworkImage(widget.chatRoom.avatar!)
                    : null,
                child: widget.chatRoom.avatar == null
                    ? Icon(
                        _getChatRoomIcon(widget.chatRoom.type),
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
              
              if (otherParticipant.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 12),
          
          // Chat info - centered vertically
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatRoom.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  otherParticipant.statusText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.chatRoom.isBookingRelated) ...[
                GestureDetector(
                  onTap: _showBookingDetails,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.car_rental,
                      color: Color(0xFF353935),
                      size: 20,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
              ],
              
                             // More button - no container, just icon
               GestureDetector(
                 onTap: _showChatOptions,
                 child: const Icon(
                   Icons.more_vert,
                   color: Colors.white,
                   size: 24,
                 ),
               ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final previousMessage = index > 0 ? _messages[index - 1] : null;
        final showDateSeparator = _shouldShowDateSeparator(message, previousMessage);
        
        return Column(
          children: [
            if (showDateSeparator)
              _buildDateSeparator(message.timestamp),
            
            SlideTransition(
              position: _slideAnimation,
              child: _buildMessageBubble(message, index),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isFromCurrentUser = message.isFromCurrentUser;
    final isSystem = message.isSystem;
    
    if (isSystem) {
      return _buildSystemMessage(message);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isFromCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: message.senderAvatar != null
                  ? NetworkImage(message.senderAvatar!)
                  : null,
              child: message.senderAvatar == null
                  ? Text(
                      message.senderName.isNotEmpty
                          ? message.senderName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromCurrentUser ? const Color(0xFF353935) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isFromCurrentUser ? 16 : 4),
                  bottomRight: Radius.circular(isFromCurrentUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.hasReply)
                    _buildReplyPreview(message),
                  
                  Text(
                    message.content,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isFromCurrentUser ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.timeString,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isFromCurrentUser
                              ? Colors.white70
                              : Colors.grey.shade500,
                        ),
                      ),
                      
                      if (isFromCurrentUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.statusIcon,
                          size: 12,
                          color: message.status == MessageStatus.read
                              ? Colors.white
                              : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (isFromCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF353935),
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.content,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildReplyPreview(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Replying to: ${message.replyToMessage?.content ?? 'Message'}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDateSeparator(date),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicators() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey.shade200,
            child: Icon(
              Icons.more_horiz,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _typingIndicators.length == 1
                ? '${_typingIndicators.first.userName} is typing...'
                : '${_typingIndicators.length} people are typing...',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, -16),
            spreadRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Message input with + button inside
            Expanded(
                               child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                   decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // + button inside text field
                    GestureDetector(
                      onTap: _showAttachmentOptions,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF353935),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Text field
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 4,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                                         // Send button inside text field
                     ValueListenableBuilder<TextEditingValue>(
                       valueListenable: _messageController,
                       builder: (context, value, child) {
                         final hasText = value.text.trim().isNotEmpty;
                         return GestureDetector(
                           onTap: hasText ? _sendMessage : null,
                           child: Container(
                             padding: const EdgeInsets.all(8),
                             decoration: BoxDecoration(
                               color: hasText 
                                   ? const Color(0xFF353935)
                                   : Colors.grey.shade300,
                               shape: BoxShape.circle,
                             ),
                             child: Icon(
                               Icons.send,
                               color: hasText 
                                   ? Colors.white
                                   : Colors.grey.shade500,
                               size: 16,
                             ),
                           ),
                         );
                       },
                     ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Start the conversation',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Send a message to begin chatting',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowDateSeparator(ChatMessage message, ChatMessage? previousMessage) {
    if (previousMessage == null) return true;
    
    final messageDate = DateTime(
      message.timestamp.year,
      message.timestamp.month,
      message.timestamp.day,
    );
    
    final previousDate = DateTime(
      previousMessage.timestamp.year,
      previousMessage.timestamp.month,
      previousMessage.timestamp.day,
    );
    
    return !messageDate.isAtSameMomentAs(previousDate);
  }

  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);
    
    if (messageDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (messageDate.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  IconData _getChatRoomIcon(ChatRoomType type) {
    switch (type) {
      case ChatRoomType.direct:
        return Icons.person;
      case ChatRoomType.group:
        return Icons.group;
      case ChatRoomType.support:
        return Icons.support_agent;
      case ChatRoomType.booking:
        return Icons.car_rental;
    }
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    
    // Send message using ChatService for immediate UI update
    await _chatService.sendMessage(
      chatId: widget.chatRoom.id,
      content: content,
    );
    
    // Also save to database using MessagingService for persistence
    try {
      // Get conversation ID or create one
      final conversationId = await _messagingService.createOrGetConversation(
        userId1: 'current_user_id', // Replace with actual user ID
        userId2: widget.chatRoom.participants.firstWhere((p) => p.id != 'current_user_id').id,
        type: 'rental_chat',
        carId: widget.chatRoom.carId,
      );
      
      if (conversationId != null) {
        await _messagingService.sendTextMessage(
          conversationId: conversationId,
          senderId: 'current_user_id', // Replace with actual user ID
          senderName: 'You',
          receiverId: widget.chatRoom.participants.firstWhere((p) => p.id != 'current_user_id').id,
          receiverName: widget.chatRoom.participants.firstWhere((p) => p.id != 'current_user_id').name,
          content: content,
          carId: widget.chatRoom.carId,
        );
      }
    } catch (e) {
      debugPrint('Error saving message to database: $e');
      // Continue with UI update even if database save fails
    }
    
    _scrollToBottom();
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Options
            _buildAttachmentOption('Photo', Icons.photo, () {}),
            _buildAttachmentOption('Location', Icons.location_on, () {}),
            _buildAttachmentOption('Document', Icons.description, () {}),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(String title, IconData icon, VoidCallback onTap) {
    return AnimatedButton(
      onPressed: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF353935).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF353935),
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.car_rental,
                    color: const Color(0xFF353935),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Booking Details',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            // Booking info (mock)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBookingInfoItem('Booking ID', '#BK123456'),
                    _buildBookingInfoItem('Car', 'BMW X5 2023'),
                    _buildBookingInfoItem('Dates', 'Dec 15 - Dec 18, 2024'),
                    _buildBookingInfoItem('Total', 'UK£450'),
                    _buildBookingInfoItem('Status', 'Confirmed'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 20),
            
            _buildChatOption('Search Messages', Icons.search, () {}),
            _buildChatOption('Clear Chat', Icons.clear_all, () {}),
            _buildChatOption('Block User', Icons.block, () {}),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChatOption(String title, IconData icon, VoidCallback onTap) {
    return AnimatedButton(
      onPressed: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey.shade600,
              size: 20,
            ),
            
            const SizedBox(width: 16),
            
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}