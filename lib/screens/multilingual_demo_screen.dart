import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../widgets/localized_text.dart';
import '../widgets/floating_header.dart';

class MultilingualDemoScreen extends StatelessWidget {
  const MultilingualDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          FloatingHeader(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LocalizedText(
                    'multilingual_demo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<SettingsService>(
              builder: (context, settingsService, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Language Selector
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.language,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  LocalizedText(
                                    'language',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Language Options
                              for (final language in AppLanguage.values) ...[
                                Builder(
                                  builder: (context) {
                                    final isSelected = settingsService.currentLanguage == language;
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Text(
                                        language.flag,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      title: Text(
                                        language.name,
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? Theme.of(context).primaryColor : null,
                                        ),
                                      ),
                                      subtitle: Text('Code: ${language.code}'),
                                      trailing: isSelected 
                                          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                                          : null,
                                      onTap: () {
                                        settingsService.setLanguage(language);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: LocalizedText('language_changed'),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Demo Content
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LocalizedText(
                                'demo_content',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              
                              _buildDemoSection(context, 'Navigation', [
                                'home',
                                'search_tab',
                                'saved',
                                'bookings',
                                'more',
                              ]),
                              
                              _buildDemoSection(context, 'Authentication', [
                                'sign_in',
                                'sign_up',
                                'email',
                                'password',
                                'forgot_password',
                              ]),
                              
                              _buildDemoSection(context, 'Car Rental', [
                                'car_rental',
                                'book_now',
                                'available_cars',
                                'car_details',
                                'per_day',
                              ]),
                              
                              _buildDemoSection(context, 'Common Actions', [
                                'save',
                                'cancel',
                                'ok',
                                'search',
                                'filter',
                              ]),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // RTL Demo (only for Arabic)
                      if (context.isRTL)
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LocalizedText(
                                  'rtl_demo',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.amber),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info, color: Colors.amber),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: LocalizedText(
                                          'rtl_notice',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Test Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showTestDialog(context);
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: LocalizedText('test_localization'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoSection(BuildContext context, String sectionTitle, List<String> keys) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keys.map((key) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: LocalizedText(
                key,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: LocalizedText('test_dialog_title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocalizedText('test_dialog_content'),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                LocalizedText('success'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: LocalizedText('close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: LocalizedText('test_completed'),
                ),
              );
            },
            child: LocalizedText('ok'),
          ),
        ],
      ),
    );
  }
}