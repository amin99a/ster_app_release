import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';
import '../widgets/floating_header.dart';
import '../utils/animations.dart';
import 'notification_settings_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _filteredNotifications = [];
  String? _selectedType;
  bool _showOnlyUnread = false;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeNotifications();
    _setupListeners();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.smoothCurve,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppAnimations.smoothCurve,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeNotifications() async {
    await _notificationService.initialize();
    _loadNotifications();
  }

  void _setupListeners() {
    _notificationService.notificationsStream.listen((notifications) {
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _filterNotifications();
        });
      }
    });
  }

  void _loadNotifications() {
    setState(() {
      _notifications = _notificationService.notifications;
      _filterNotifications();
    });
  }

  void _filterNotifications() {
    List<Map<String, dynamic>> filtered = _notifications;
    
    // Apply type filter
    if (_selectedType != null) {
      filtered = filtered.where((n) => n['type'] == _selectedType).toList();
    }
    
    // Apply unread filter
    if (_showOnlyUnread) {
      filtered = filtered.where((n) => !(n['is_read'] ?? false)).toList();
    }
    
    setState(() {
      _filteredNotifications = filtered;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Content
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildNotificationsList(),
            ),
          ),
          Positioned(
            top: 0,
            left: 10,
            right: 10,
            child: SafeArea(
              top: true,
              minimum: EdgeInsets.zero,
              child: FloatingHeader(
                margin: EdgeInsets.zero,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Notifications',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: _markAllAsRead,
                      child: const Icon(Icons.done_all, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _openSettings,
                      child: const Icon(Icons.settings, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Filters bar (Unread toggle + type chips)
  Widget _buildFiltersBar() {
    final types = <String>['booking', 'message', 'payment', 'reminder', 'promotion', 'system', 'review'];
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.08), blurRadius: 16, offset: Offset(0, 8)),
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 32, offset: Offset(0, 16)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Unread Only', _showOnlyUnread, () {
              setState(() {
                _showOnlyUnread = !_showOnlyUnread;
                _filterNotifications();
              });
            }, icon: Icons.mark_email_unread),
            const SizedBox(width: 8),
            ...types.map((t) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    t[0].toUpperCase() + t.substring(1),
                    _selectedType == t,
                    () {
                      setState(() {
                        _selectedType = _selectedType == t ? null : t;
                        _filterNotifications();
                      });
                    },
                    icon: Icons.label_outline,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    final topPadding = MediaQuery.of(context).padding.top + 80; // status bar + header height + spacing
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 20),
      itemCount: _filteredNotifications.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildFiltersBar();
        }
        final notification = _filteredNotifications[index - 1];
        return AnimatedListItem(index: index, child: _buildNotificationItem(notification));
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Dismissible(
      key: Key(notification['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (direction) {
        _notificationService.deleteNotification(notification['id'].toString());
      },
      child: AnimatedButton(
        onPressed: () => _handleNotificationTap(notification),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (notification['is_read'] ?? false) ? Colors.white : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: (notification['is_read'] ?? false)
                ? null
                : Border.all(color: Colors.blue.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      notification['message'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Text(
                          _formatTime(notification['created_at']),
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
              
              // Unread indicator
              if (!(notification['is_read'] ?? false))
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF593CFB),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(dynamic ts) {
    try {
      final dt = ts is String ? DateTime.parse(ts) : (ts as DateTime);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      return '${dt.year}/${dt.month}/${dt.day}';
    } catch (_) {
      return '';
    }
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
              _filteredNotifications.isNotEmpty ? Icons.search_off : Icons.notifications_none,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            _filteredNotifications.isNotEmpty ? 'No notifications found' : 'No notifications yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _filteredNotifications.isNotEmpty
                ? 'Try searching with different keywords'
                : 'You\'ll see notifications about bookings, messages, and more here',
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

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final id = notification['id'].toString();
    _notificationService.markAsRead(id);
  }

  void _handleNotificationAction(Map<String, dynamic> notification, dynamic action) {}

  void _markAllAsRead() {
    _notificationService.markAllAsRead();
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, {IconData? icon}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF353935) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF353935) : Colors.grey.shade300),
          boxShadow: isSelected
              ? const [
                  BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 12, offset: Offset(0, 6)),
                  BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.08), blurRadius: 24, offset: Offset(0, 12)),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isSelected ? Colors.white : Colors.grey.shade700),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const NotificationSettingsScreen(),
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
}