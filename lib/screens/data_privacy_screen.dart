import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DataPrivacyScreen extends StatefulWidget {
  const DataPrivacyScreen({super.key});

  @override
  State<DataPrivacyScreen> createState() => _DataPrivacyScreenState();
}

class _DataPrivacyScreenState extends State<DataPrivacyScreen> {
  bool _dataCollectionEnabled = true;
  bool _analyticsEnabled = true;
  bool _marketingEmailsEnabled = false;
  bool _pushNotificationsEnabled = true;
  bool _locationSharingEnabled = true;
  bool _profileVisibilityPublic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Data & Privacy',
          style: TextStyle(
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy Overview Card
            _buildPrivacyOverviewCard(),
            const SizedBox(height: 16),

            // Data Collection Settings
            _buildSettingsCard(
              title: 'Data Collection',
              icon: LucideIcons.database,
              children: [
                _buildSwitchTile(
                  title: 'Enable Data Collection',
                  subtitle: 'Allow us to collect usage data to improve your experience',
                  value: _dataCollectionEnabled,
                  onChanged: (value) {
                    setState(() {
                      _dataCollectionEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Analytics',
                  subtitle: 'Help us improve by sharing anonymous usage statistics',
                  value: _analyticsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _analyticsEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Communication Settings
            _buildSettingsCard(
              title: 'Communication',
              icon: LucideIcons.mail,
              children: [
                _buildSwitchTile(
                  title: 'Marketing Emails',
                  subtitle: 'Receive promotional offers and updates',
                  value: _marketingEmailsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _marketingEmailsEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Push Notifications',
                  subtitle: 'Get notified about bookings, messages, and updates',
                  value: _pushNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _pushNotificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location & Profile Settings
            _buildSettingsCard(
              title: 'Location & Profile',
              icon: LucideIcons.mapPin,
              children: [
                _buildSwitchTile(
                  title: 'Location Sharing',
                  subtitle: 'Share your location for better car recommendations',
                  value: _locationSharingEnabled,
                  onChanged: (value) {
                    setState(() {
                      _locationSharingEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Public Profile',
                  subtitle: 'Make your profile visible to other users',
                  value: _profileVisibilityPublic,
                  onChanged: (value) {
                    setState(() {
                      _profileVisibilityPublic = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Privacy Actions
            _buildSettingsCard(
              title: 'Privacy Actions',
              icon: LucideIcons.shield,
              children: [
                _buildActionTile(
                  title: 'Download My Data',
                  subtitle: 'Get a copy of all your personal data',
                  icon: LucideIcons.download,
                  onTap: () {
                    _showDownloadDataDialog();
                  },
                ),
                _buildActionTile(
                  title: 'Delete My Account',
                  subtitle: 'Permanently delete your account and all data',
                  icon: LucideIcons.trash2,
                  onTap: () {
                    _showDeleteAccountDialog();
                  },
                ),
                _buildActionTile(
                  title: 'Privacy Policy',
                  subtitle: 'Read our complete privacy policy',
                  icon: LucideIcons.fileText,
                  onTap: () {
                    _showPrivacyPolicy();
                  },
                ),
                _buildActionTile(
                  title: 'Terms of Service',
                  subtitle: 'Read our terms and conditions',
                  icon: LucideIcons.fileText,
                  onTap: () {
                    _showTermsOfService();
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF593CFB),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.shield,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Privacy Matters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Control how your data is used and shared',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF593CFB),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF593CFB),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF593CFB),
        size: 20,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF593CFB),
      ),
      onTap: onTap,
    );
  }

  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Your Data'),
        content: const Text(
          'We\'ll prepare a file with all your personal data including profile information, booking history, and messages. This may take up to 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data download request submitted. You\'ll receive an email when ready.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF593CFB),
            ),
            child: const Text('Request Download'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data, including profile, bookings, and messages will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion request submitted. You\'ll receive a confirmation email.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Our Privacy Policy explains how we collect, use, and protect your personal information. '
            'We are committed to transparency and giving you control over your data. '
            'You can read the full policy on our website or contact our privacy team for any questions.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening privacy policy in browser...'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF593CFB),
            ),
            child: const Text('View Full Policy'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Our Terms of Service outline the rules and guidelines for using our platform. '
            'By using our service, you agree to these terms. '
            'Please read them carefully and contact us if you have any questions.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening terms of service in browser...'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF593CFB),
            ),
            child: const Text('View Full Terms'),
          ),
        ],
      ),
    );
  }
} 