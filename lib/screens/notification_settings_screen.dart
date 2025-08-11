import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/push_notification.dart';
import '../services/push_notification_service.dart';
import '../utils/animations.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with TickerProviderStateMixin {
  final PushNotificationService _notificationService = PushNotificationService();
  
  late NotificationSettings _settings;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _settings = _notificationService.settings;
    _initializeAnimations();
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

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _updateSettings(NotificationSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    _notificationService.updateSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Custom App Bar
          _buildCustomAppBar(),
          
          // Settings Content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Master Toggle
                    AnimatedListItem(
                      index: 0,
                      child: _buildMasterToggleCard(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Notification Types
                    AnimatedListItem(
                      index: 1,
                      child: _buildNotificationTypesCard(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Sound & Vibration
                    AnimatedListItem(
                      index: 2,
                      child: _buildSoundVibrationCard(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Quiet Hours
                    AnimatedListItem(
                      index: 3,
                      child: _buildQuietHoursCard(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Advanced Settings
                    AnimatedListItem(
                      index: 4,
                      child: _buildAdvancedSettingsCard(),
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
          AnimatedButton(
            onPressed: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Settings',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Customize your notification preferences',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterToggleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF593CFB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Color(0xFF593CFB),
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Push Notifications',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Enable or disable all notifications',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              Switch(
                value: _settings.enabled,
                onChanged: (value) {
                  _updateSettings(_settings.copyWith(enabled: value));
                },
                activeColor: const Color(0xFF593CFB),
              ),
            ],
          ),
          
          if (!_settings.enabled)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.orange.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You won\'t receive any notifications while this is disabled',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Types',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            'Choose which types of notifications you want to receive',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildNotificationTypeToggle(
            'Booking Notifications',
            'Updates about your car bookings',
            Icons.car_rental,
            _settings.bookingNotifications,
            (value) => _updateSettings(_settings.copyWith(bookingNotifications: value)),
          ),
          
          _buildNotificationTypeToggle(
            'Messages',
            'New messages from hosts and other users',
            Icons.message,
            _settings.messageNotifications,
            (value) => _updateSettings(_settings.copyWith(messageNotifications: value)),
          ),
          
          _buildNotificationTypeToggle(
            'Payment Notifications',
            'Payment confirmations and alerts',
            Icons.payment,
            _settings.paymentNotifications,
            (value) => _updateSettings(_settings.copyWith(paymentNotifications: value)),
          ),
          
          _buildNotificationTypeToggle(
            'Reminders',
            'Booking reminders and important dates',
            Icons.alarm,
            _settings.reminderNotifications,
            (value) => _updateSettings(_settings.copyWith(reminderNotifications: value)),
          ),
          
          _buildNotificationTypeToggle(
            'Promotions & Offers',
            'Special deals and discounts',
            Icons.local_offer,
            _settings.promotionNotifications,
            (value) => _updateSettings(_settings.copyWith(promotionNotifications: value)),
          ),
          
          _buildNotificationTypeToggle(
            'Review Notifications',
            'Review requests and responses',
            Icons.star,
            _settings.reviewNotifications,
            (value) => _updateSettings(_settings.copyWith(reviewNotifications: value)),
          ),
          
          _buildNotificationTypeToggle(
            'System Notifications',
            'App updates and system messages',
            Icons.info,
            _settings.systemNotifications,
            (value) => _updateSettings(_settings.copyWith(systemNotifications: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypeToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value ? const Color(0xFF593CFB).withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? const Color(0xFF593CFB).withOpacity(0.2) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? const Color(0xFF593CFB).withOpacity(0.1) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? const Color(0xFF593CFB) : Colors.grey.shade600,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
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
          
          Switch(
            value: value && _settings.enabled,
            onChanged: _settings.enabled ? onChanged : null,
            activeColor: const Color(0xFF593CFB),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundVibrationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sound & Vibration',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            'Customize notification sounds and vibration',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildSoundVibrationToggle(
            'Sound',
            'Play notification sounds',
            Icons.volume_up,
            _settings.soundEnabled,
            (value) => _updateSettings(_settings.copyWith(soundEnabled: value)),
          ),
          
          const SizedBox(height: 16),
          
          _buildSoundVibrationToggle(
            'Vibration',
            'Vibrate for notifications',
            Icons.vibration,
            _settings.vibrationEnabled,
            (value) => _updateSettings(_settings.copyWith(vibrationEnabled: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundVibrationToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF593CFB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF593CFB),
            size: 20,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
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
        
        Switch(
          value: value && _settings.enabled,
          onChanged: _settings.enabled ? onChanged : null,
          activeColor: const Color(0xFF593CFB),
        ),
      ],
    );
  }

  Widget _buildQuietHoursCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF593CFB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bedtime,
                  color: Color(0xFF593CFB),
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiet Hours',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Silence notifications during specific hours',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildTimeSelector(
                  'Start Time',
                  _settings.quietHoursStart ?? const TimeOfDay(hour: 22, minute: 0),
                  (time) => _updateSettings(_settings.copyWith(quietHoursStart: time)),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: _buildTimeSelector(
                  'End Time',
                  _settings.quietHoursEnd ?? const TimeOfDay(hour: 8, minute: 0),
                  (time) => _updateSettings(_settings.copyWith(quietHoursEnd: time)),
                ),
              ),
            ],
          ),
          
          if (_settings.quietHoursStart != null && _settings.quietHoursEnd != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only urgent notifications will be shown during quiet hours',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(String label, TimeOfDay selectedTime, ValueChanged<TimeOfDay> onChanged) {
    return AnimatedButton(
      onPressed: _settings.enabled ? () => _selectTime(selectedTime, onChanged) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _settings.enabled ? Colors.grey.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              selectedTime.format(context),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _settings.enabled ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Settings',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildAdvancedOption(
            'Test Notification',
            'Send a test notification',
            Icons.bug_report,
            () => _sendTestNotification(),
          ),
          
          const SizedBox(height: 16),
          
          _buildAdvancedOption(
            'Clear All Notifications',
            'Remove all notifications from history',
            Icons.clear_all,
            () => _clearAllNotifications(),
          ),
          
          const SizedBox(height: 16),
          
          _buildAdvancedOption(
            'Reset to Defaults',
            'Reset all notification settings to default',
            Icons.restore,
            () => _resetToDefaults(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOption(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return AnimatedButton(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
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

  Future<void> _selectTime(TimeOfDay currentTime, ValueChanged<TimeOfDay> onChanged) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (selectedTime != null) {
      onChanged(selectedTime);
    }
  }

  void _sendTestNotification() {
    final testNotification = PushNotification(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Test Notification',
      body: 'This is a test notification to verify your settings are working correctly.',
      type: NotificationType.system,
      timestamp: DateTime.now(),
      data: {'test': true},
    );

    _notificationService.sendNotification(testNotification);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Test notification sent!',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF593CFB),
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear All Notifications',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will permanently delete all notifications from your history. Are you sure?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () {
              _notificationService.clearAllNotifications();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'All notifications cleared',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF593CFB),
                ),
              );
            },
            child: Text(
              'Clear All',
              style: GoogleFonts.inter(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset to Defaults',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will reset all notification settings to their default values. Are you sure?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () {
              _updateSettings(const NotificationSettings());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Settings reset to defaults',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF593CFB),
                ),
              );
            },
            child: Text(
              'Reset',
              style: GoogleFonts.inter(color: const Color(0xFF593CFB)),
            ),
          ),
        ],
      ),
    );
  }
}