import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/accessibility_widgets.dart';

class AccessibilitySettings extends StatefulWidget {
  const AccessibilitySettings({super.key});

  @override
  State<AccessibilitySettings> createState() => _AccessibilitySettingsState();
}

class _AccessibilitySettingsState extends State<AccessibilitySettings> {
  bool _screenReaderEnabled = false;
  bool _highContrastEnabled = false;
  bool _largeTextEnabled = false;
  bool _reduceMotionEnabled = false;
  bool _boldTextEnabled = false;
  double _textScaleFactor = 1.0;
  double _touchTargetSize = 48.0;
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'French',
    'Arabic',
    'Spanish',
    'German',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // Load saved settings
    setState(() {
      _screenReaderEnabled = AccessibilitySettingsManager.isScreenReaderEnabled;
      _highContrastEnabled = AccessibilitySettingsManager.isHighContrastEnabled;
      _largeTextEnabled = AccessibilitySettingsManager.isLargeTextEnabled;
      _textScaleFactor = AccessibilitySettingsManager.textScaleFactor;
    });
  }

  void _saveSettings() {
    AccessibilitySettingsManager.updateSettings(
      screenReader: _screenReaderEnabled,
      highContrast: _highContrastEnabled,
      largeText: _largeTextEnabled,
      textScale: _textScaleFactor,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Accessibility settings saved'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text('Accessibility'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF593CFB),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildVisionCard(),
            const SizedBox(height: 16),
            _buildInteractionCard(),
            const SizedBox(height: 16),
            _buildLanguageCard(),
            const SizedBox(height: 16),
            _buildPreviewCard(),
            const SizedBox(height: 16),
            _buildTestCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.accessibility, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Accessibility Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Customize your experience to make the app more accessible and easier to use.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.eye, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  'Vision',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // High Contrast
            SwitchListTile(
              title: const Text('High Contrast'),
              subtitle: const Text('Increase contrast for better visibility'),
              value: _highContrastEnabled,
              onChanged: (value) {
                setState(() {
                  _highContrastEnabled = value;
                });
              },
              secondary: Icon(
                LucideIcons.contrast,
                color: _highContrastEnabled ? Colors.green : Colors.grey,
              ),
            ),
            
            // Large Text
            SwitchListTile(
              title: const Text('Large Text'),
              subtitle: const Text('Increase text size for better readability'),
              value: _largeTextEnabled,
              onChanged: (value) {
                setState(() {
                  _largeTextEnabled = value;
                  if (value) {
                    _textScaleFactor = 1.2;
                  } else {
                    _textScaleFactor = 1.0;
                  }
                });
              },
              secondary: Icon(
                LucideIcons.type,
                color: _largeTextEnabled ? Colors.green : Colors.grey,
              ),
            ),
            
            // Text Scale
            if (_largeTextEnabled) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Text Size: ${(_textScaleFactor * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _textScaleFactor,
                    min: 1.0,
                    max: 2.0,
                    divisions: 10,
                    onChanged: (value) {
                      setState(() {
                        _textScaleFactor = value;
                      });
                    },
                  ),
                ],
              ),
            ],
            
            // Bold Text
            SwitchListTile(
              title: const Text('Bold Text'),
              subtitle: const Text('Make text bold for better visibility'),
              value: _boldTextEnabled,
              onChanged: (value) {
                setState(() {
                  _boldTextEnabled = value;
                });
              },
              secondary: Icon(
                LucideIcons.bold,
                color: _boldTextEnabled ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.hand, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'Interaction',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Screen Reader
            SwitchListTile(
              title: const Text('Screen Reader'),
              subtitle: const Text('Enable voice feedback for navigation'),
              value: _screenReaderEnabled,
              onChanged: (value) {
                setState(() {
                  _screenReaderEnabled = value;
                });
              },
              secondary: Icon(
                LucideIcons.volume2,
                color: _screenReaderEnabled ? Colors.green : Colors.grey,
              ),
            ),
            
            // Reduce Motion
            SwitchListTile(
              title: const Text('Reduce Motion'),
              subtitle: const Text('Minimize animations and transitions'),
              value: _reduceMotionEnabled,
              onChanged: (value) {
                setState(() {
                  _reduceMotionEnabled = value;
                });
              },
              secondary: Icon(
                LucideIcons.zap,
                color: _reduceMotionEnabled ? Colors.green : Colors.grey,
              ),
            ),
            
            // Touch Target Size
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Touch Target Size: ${_touchTargetSize.round()}px',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _touchTargetSize,
                  min: 44.0,
                  max: 60.0,
                  divisions: 8,
                  onChanged: (value) {
                    setState(() {
                      _touchTargetSize = value;
                    });
                  },
                ),
                Text(
                  'Minimum recommended: 44px',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.globe, color: Colors.purple[600]),
                const SizedBox(width: 8),
                const Text(
                  'Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'App Language',
                border: OutlineInputBorder(),
              ),
              items: _languages.map((language) {
                return DropdownMenuItem(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.eye, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Preview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _highContrastEnabled ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _highContrastEnabled ? Colors.white : Colors.grey[300]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sample Text',
                    style: AccessibilitySettingsManager.getAccessibleTextStyle(
                      TextStyle(
                        fontSize: 16,
                        fontWeight: _boldTextEnabled ? FontWeight.bold : FontWeight.normal,
                        color: _highContrastEnabled ? Colors.white : Colors.black,
                      ),
                    ).copyWith(fontSize: 16 * _textScaleFactor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is how your text will appear with the current settings.',
                    style: AccessibilitySettingsManager.getAccessibleTextStyle(
                      TextStyle(
                        fontSize: 14,
                        fontWeight: _boldTextEnabled ? FontWeight.bold : FontWeight.normal,
                        color: _highContrastEnabled ? Colors.white : Colors.black,
                      ),
                    ).copyWith(fontSize: 14 * _textScaleFactor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.testTube, color: Colors.red[600]),
                const SizedBox(width: 8),
                const Text(
                  'Test Your Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            LargeTouchTarget(
              minSize: _touchTargetSize,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Touch target test successful!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF593CFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Test Touch Target',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            FocusableWidget(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Focus test successful!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Test Focus (Tab to focus)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            if (_screenReaderEnabled) ...[
              const SizedBox(height: 12),
              AccessibleButton(
                label: 'Test Screen Reader',
                hint: 'Double tap to test screen reader functionality',
                onPressed: () {
                  const ScreenReaderAnnouncement(
                    message: 'Screen reader test successful!',
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Test Screen Reader',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 