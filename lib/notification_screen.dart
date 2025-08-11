import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/app_notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final bool _pushNotificationsEnabled = true;
  final bool _emailNotificationsEnabled = true;
  final bool _marketingNotificationsEnabled = false;

  final List<String> _filterOptions = ['All', 'Bookings', 'Messages', 'Promotions', 'System'];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _notifications = [
        AppNotification(
          id: '1',
          title: 'Booking Confirmed',
          message: 'Your booking for BMW X5 has been confirmed for March 15-17.',
          type: 'Booking',
          isRead: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          icon: LucideIcons.checkCircle,
          iconColor: Colors.green,
        ),
        AppNotification(
          id: '2',
          title: 'New Message',
          message: 'Sarah Johnson sent you a message about your upcoming trip.',
          type: 'Message',
          isRead: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          icon: LucideIcons.messageCircle,
          iconColor: const Color(0xFF593CFB),
        ),
        AppNotification(
          id: '3',
          title: 'Special Offer',
          message: 'Get 20% off your next booking! Use code SPRING20.',
          type: 'Promotion',
          isRead: true,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          icon: LucideIcons.gift,
          iconColor: Colors.orange,
        ),
        AppNotification(
          id: '4',
          title: 'Payment Received',
          message: 'Payment of £150 has been received for your BMW X5 rental.',
          type: 'Booking',
          isRead: true,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          icon: LucideIcons.creditCard,
          iconColor: Colors.green,
        ),
        AppNotification(
          id: '5',
          title: 'System Update',
          message: 'New features are now available! Check out the latest updates.',
          type: 'System',
          isRead: true,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          icon: LucideIcons.info,
          iconColor: Colors.blue,
        ),
      ];
      _isLoading = false;
    });
  }

  List<AppNotification> get _filteredNotifications {
    if (_selectedFilter == 'All') {
      return _notifications;
    }
    return _notifications.where((notification) => notification.type == _selectedFilter).toList();
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final notification = _notifications.firstWhere((n) => n.id == notificationId);
      notification.isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      _notifications.removeWhere((n) => n.id == notificationId);
    });
  }

  void _clearAllNotifications() {
    setState(() {
      _notifications.clear();
    });
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) {
                switch (value) {
                  case 'mark_all_read':
                    _markAllAsRead();
                    break;
                  case 'clear_all':
                    _clearAllNotifications();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all, size: 20),
                      SizedBox(width: 8),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, size: 20),
                      SizedBox(width: 8),
                      Text('Clear all'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(
                        filter,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF593CFB),
                      checkmarkColor: Colors.white,
                      elevation: isSelected ? 4 : 1,
                      shadowColor: Colors.black.withValues(alpha: 0.1),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Notifications list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF593CFB),
                    ),
                  )
                : _filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredNotifications.length,
                        itemBuilder: (context, index) {
                          final notification = _filteredNotifications[index];
                          return _buildNotificationCard(notification);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.bell,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: notification.iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            notification.icon,
            color: notification.iconColor,
            size: 24,
          ),
        ),
        title: Text(
          notification.title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            color: notification.isRead ? Colors.black87 : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              _getTimeAgo(notification.timestamp),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF593CFB),
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
          // TODO: Navigate to specific notification details
        },
        onLongPress: () {
          _showNotificationOptions(notification);
        },
      ),
    );
  }

  void _showNotificationOptions(AppNotification notification) {
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
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete notification',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteNotification(notification.id);
              },
            ),
            if (!notification.isRead)
              ListTile(
                leading: const Icon(Icons.done, color: Color(0xFF593CFB)),
                title: Text(
                  'Mark as read',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF593CFB),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _markAsRead(notification.id);
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} 