import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/settings_service.dart';
import '../widgets/floating_header.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadPackageInfo();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = packageInfo;
      });
    } catch (e) {
      debugPrint('Error loading package info: $e');
    }
  }

  void _showLanguageSelector(BuildContext context, SettingsService settingsService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _LanguageSelectorModal(
        currentLanguage: settingsService.currentLanguage,
        onLanguageSelected: (language) {
          settingsService.setLanguage(language);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCurrencySelector(BuildContext context, SettingsService settingsService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CurrencySelectorModal(
        currentCurrency: settingsService.currentCurrency,
        onCurrencySelected: (currency) {
          settingsService.setCurrency(currency);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsService settingsService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Settings',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(),
            ),
          ),
          TextButton(
            onPressed: () async {
              await settingsService.resetToDefaults();
              if (context.mounted) {
                Navigator.pop(context);
                _showSuccessSnackBar('Settings reset to defaults');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[600],
            ),
            child: Text(
              'Reset',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: Column(
              children: [
                // Header
                FloatingHeader(
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          settingsService.getLocalizedText('settings'),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showResetDialog(context, settingsService),
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Localization Section
                          _buildSection(
                            title: 'Localization',
                            icon: Icons.language,
                            children: [
                              _buildSettingsTile(
                                icon: Icons.translate,
                                title: settingsService.getLocalizedText('language'),
                                subtitle: settingsService.currentLanguage.name,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      settingsService.currentLanguage.flag,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                                onTap: () => _showLanguageSelector(context, settingsService),
                              ),
                              _buildSettingsTile(
                                icon: Icons.attach_money,
                                title: settingsService.getLocalizedText('currency'),
                                subtitle: '${settingsService.currentCurrency.name} (${settingsService.currentCurrency.symbol})',
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _showCurrencySelector(context, settingsService),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Appearance Section
                          _buildSection(
                            title: 'Appearance',
                            icon: Icons.palette,
                            children: [
                              _buildSwitchTile(
                                icon: Icons.dark_mode,
                                title: settingsService.getLocalizedText('dark_mode'),
                                subtitle: 'Enable dark theme for better night viewing',
                                value: settingsService.isDarkMode,
                                onChanged: (value) => settingsService.setDarkMode(value),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Privacy & Permissions Section
                          _buildSection(
                            title: 'Privacy & Permissions',
                            icon: Icons.security,
                            children: [
                              _buildSwitchTile(
                                icon: Icons.notifications,
                                title: settingsService.getLocalizedText('notifications'),
                                subtitle: 'Receive booking updates and offers',
                                value: settingsService.notificationsEnabled,
                                onChanged: (value) => settingsService.setNotificationsEnabled(value),
                              ),
                              _buildSwitchTile(
                                icon: Icons.location_on,
                                title: settingsService.getLocalizedText('location'),
                                subtitle: 'Enable location for nearby car search',
                                value: settingsService.locationEnabled,
                                onChanged: (value) => settingsService.setLocationEnabled(value),
                              ),
                              _buildSwitchTile(
                                icon: Icons.analytics,
                                title: settingsService.getLocalizedText('analytics'),
                                subtitle: 'Help improve the app with usage data',
                                value: settingsService.analyticsEnabled,
                                onChanged: (value) => settingsService.setAnalyticsEnabled(value),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // About Section
                          _buildSection(
                            title: 'About',
                            icon: Icons.info,
                            children: [
                              _buildSettingsTile(
                                icon: Icons.info_outline,
                                title: 'App Version',
                                subtitle: _packageInfo?.version ?? '1.0.0',
                                trailing: null,
                                onTap: null,
                              ),
                              _buildSettingsTile(
                                icon: Icons.build,
                                title: 'Build Number',
                                subtitle: _packageInfo?.buildNumber ?? '1',
                                trailing: null,
                                onTap: null,
                              ),
                              _buildSettingsTile(
                                icon: Icons.support,
                                title: 'Support',
                                subtitle: 'Get help and contact support',
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  // In a real app, open support/contact screen
                                  _showSuccessSnackBar('Support feature coming soon!');
                                },
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 100), // Space for navigation
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                Icon(icon, color: const Color(0xFF353935), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
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

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF353935).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF353935),
                size: 20,
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
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF353935).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF353935),
              size: 20,
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
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
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
            activeColor: const Color(0xFF353935),
            activeTrackColor: const Color(0xFF353935).withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _LanguageSelectorModal extends StatelessWidget {
  final AppLanguage currentLanguage;
  final void Function(AppLanguage) onLanguageSelected;

  const _LanguageSelectorModal({
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Select Language',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Languages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: AppLanguage.values.length,
              itemBuilder: (context, index) {
                final language = AppLanguage.values[index];
                final isSelected = language == currentLanguage;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF353935).withValues(alpha: 0.1) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected 
                        ? Border.all(color: const Color(0xFF353935), width: 2)
                        : null,
                  ),
                  child: ListTile(
                    onTap: () => onLanguageSelected(language),
                    leading: Text(
                      language.flag,
                      style: const TextStyle(fontSize: 32),
                    ),
                    title: Text(
                      language.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF353935) : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      language.code.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: isSelected 
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF353935),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencySelectorModal extends StatelessWidget {
  final AppCurrency currentCurrency;
  final void Function(AppCurrency) onCurrencySelected;

  const _CurrencySelectorModal({
    required this.currentCurrency,
    required this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Select Currency',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Currencies
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: AppCurrency.values.length,
              itemBuilder: (context, index) {
                final currency = AppCurrency.values[index];
                final isSelected = currency == currentCurrency;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF353935).withValues(alpha: 0.1) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected 
                        ? Border.all(color: const Color(0xFF353935), width: 2)
                        : null,
                  ),
                  child: ListTile(
                    onTap: () => onCurrencySelected(currency),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF353935).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          currency.symbol,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF353935),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      currency.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF353935) : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      currency.code,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: isSelected 
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF353935),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}