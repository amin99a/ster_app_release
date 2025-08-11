import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../utils/animations.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with TickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  
  List<ChatRoom> _chatRooms = [];
  List<ChatRoom> _filteredChatRooms = [];
  bool _isSearching = false;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeChat();
    _setupListeners();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.smoothCurve,
    ));
    
    _fadeController.forward();
  }

  void _initializeChat() {
    _chatService.initialize();
    _loadChatRooms();
  }

  void _setupListeners() {
    _chatService.chatRoomsStream.listen((rooms) {
      if (mounted) {
        setState(() {
          _chatRooms = rooms;
          _filterChatRooms();
        });
      }
    });

    _searchController.addListener(() {
      _filterChatRooms();
    });
  }

  void _loadChatRooms() {
    setState(() {
      _chatRooms = _chatService.getChatRooms();
      _filterChatRooms();
    });
  }

  void _filterChatRooms() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredChatRooms = _chatRooms;
    } else {
      _filteredChatRooms = _chatRooms.where((room) {
        return room.name.toLowerCase().contains(query) ||
               (room.lastMessage?.content.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    setState(() {});
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Custom App Bar
          _buildCustomAppBar(),
          
          // Search Bar
          _buildSearchBar(),
          
          // Chat List
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildChatList(),
            ),
          ),
        ],
      ),
      
      // Floating Action Button
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF593CFB), Color(0xFF7C5CFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF593CFB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Messages',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${_chatRooms.length} conversation${_chatRooms.length != 1 ? 's' : ''}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // Unread count badge
          if (_chatService.getTotalUnreadCount() > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_chatService.getTotalUnreadCount()}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade400,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? AnimatedButton(
                  onPressed: () {
                    _searchController.clear();
                    _filterChatRooms();
                  },
                  child: Icon(
                    Icons.clear,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                )
              : null,
        ),
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.black87,
        ),
        onChanged: (value) {
          setState(() {
            _isSearching = value.isNotEmpty;
          });
        },
      ),
    );
  }

  Widget _buildChatList() {
    if (_filteredChatRooms.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredChatRooms.length,
      itemBuilder: (context, index) {
        final chatRoom = _filteredChatRooms[index];
        return AnimatedListItem(
          index: index,
          child: _buildChatListItem(chatRoom),
        );
      },
    );
  }

  Widget _buildChatListItem(ChatRoom chatRoom) {
    final otherParticipant = chatRoom.participants.firstWhere(
      (p) => p.id != 'current_user_id',
      orElse: () => const ChatParticipant(id: 'unknown', name: 'Unknown'),
    );

    return AnimatedButton(
      onPressed: () => _openChatDetail(chatRoom),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: chatRoom.avatar != null
                      ? NetworkImage(chatRoom.avatar!)
                      : null,
                  child: chatRoom.avatar == null
                      ? Icon(
                          _getChatRoomIcon(chatRoom.type),
                          color: Colors.grey.shade600,
                          size: 28,
                        )
                      : null,
                ),
                
                // Online indicator
                if (otherParticipant.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatRoom.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Booking badge
                      if (chatRoom.isBookingRelated)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF593CFB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'BOOKING',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF593CFB),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatRoom.lastMessage?.content ?? 'No messages yet',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: chatRoom.hasUnreadMessages
                                ? Colors.black87
                                : Colors.grey.shade600,
                            fontWeight: chatRoom.hasUnreadMessages
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      Text(
                        chatRoom.lastActivityString,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Unread count and status
            Column(
              children: [
                if (chatRoom.hasUnreadMessages)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF593CFB),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${chatRoom.unreadCount}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (chatRoom.lastMessage?.isFromCurrentUser == true)
                  Icon(
                    chatRoom.lastMessage!.statusIcon,
                    size: 16,
                    color: chatRoom.lastMessage!.statusColor,
                  ),
              ],
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
            _isSearching ? 'No conversations found' : 'No messages yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _isSearching
                ? 'Try searching with different keywords'
                : 'Start a conversation with a car owner or host',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedButton(
      onPressed: _showNewChatDialog,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF593CFB), Color(0xFF7C5CFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF593CFB).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
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

  void _openChatDetail(ChatRoom chatRoom) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChatDetailScreen(
          chatRoom: chatRoom,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: AppAnimations.medium,
      ),
    );
  }

  void _showNewChatDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
                    Icons.chat,
                    color: const Color(0xFF593CFB),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Start New Conversation',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildNewChatOption(
                      'Contact Host',
                      'Message a car owner about their listing',
                      Icons.person,
                      () => Navigator.pop(context),
                    ),
                    
                    _buildNewChatOption(
                      'Support Chat',
                      'Get help from our support team',
                      Icons.support_agent,
                      () => _createSupportChat(),
                    ),
                    
                    _buildNewChatOption(
                      'Booking Inquiry',
                      'Ask questions about a specific booking',
                      Icons.car_rental,
                      () => Navigator.pop(context),
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

  Widget _buildNewChatOption(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return AnimatedButton(
      onPressed: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF593CFB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF593CFB),
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _createSupportChat() async {
    Navigator.pop(context);
    
    // Check if support chat already exists
    final existingSupportChat = _chatRooms.firstWhere(
      (room) => room.type == ChatRoomType.support,
      orElse: () => const ChatRoom(
        id: '',
        name: '',
        participantIds: [],
        participants: [],
      ),
    );
    
    if (existingSupportChat.id.isNotEmpty) {
      _openChatDetail(existingSupportChat);
      return;
    }
    
    // Create new support chat
    final supportChat = await _chatService.createChatRoom(
      name: 'STER Support',
      participantIds: ['current_user_id', 'support_agent'],
      type: ChatRoomType.support,
    );
    
    _openChatDetail(supportChat);
  }
}