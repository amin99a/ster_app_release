import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

import '../models/location.dart';
import '../services/auth_service.dart';
import '../services/image_upload_service.dart';
import '../widgets/floating_header.dart';

class UserProfileEditScreen extends StatefulWidget {
  const UserProfileEditScreen({super.key});

  @override
  State<UserProfileEditScreen> createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  File? _profileImage;
  String? _profileImageUrl;
  bool _isLoading = false;
  bool _hasChanges = false;
  
  // Location data
  String? _selectedWilaya;

  
  // Preferences
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  String _preferredLanguage = 'English';
  String _preferredCurrency = 'DZD';

  final List<Map<String, String>> _wilayas = [
    {'name': 'Algiers', 'code': '16'},
    {'name': 'Oran', 'code': '31'},
    {'name': 'Constantine', 'code': '25'},
    {'name': 'Blida', 'code': '09'},
    {'name': 'Batna', 'code': '05'},
    {'name': 'Djelfa', 'code': '17'},
    {'name': 'Sétif', 'code': '19'},
    {'name': 'Sidi Bel Abbès', 'code': '22'},
    {'name': 'Biskra', 'code': '07'},
    {'name': 'Tébessa', 'code': '12'},
  ];

  final List<String> _languages = ['English', 'Français', 'العربية'];
  final List<String> _currencies = ['DZD', 'EUR', 'USD'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _profileImageUrl = user.profileImage;
      
      // Load location data
      if (user.location != null) {
        _selectedWilaya = user.location!.city;
        _addressController.text = user.location!.address;
      }
      
      // Load preferences
      _emailNotifications = user.preferences['email_notifications'] ?? true;
      _smsNotifications = user.preferences['sms_notifications'] ?? false;
      _pushNotifications = user.preferences['push_notifications'] ?? true;
      _preferredLanguage = user.preferences['language'] ?? 'English';
      _preferredCurrency = user.preferences['currency'] ?? 'DZD';
    }
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _profileImageUrl;
      
      // Upload new profile image if selected
      if (_profileImage != null) {
        final imageUploadService = ImageUploadService();
        final uploadResult = await imageUploadService.uploadProfileImage(_profileImage!);
        
        if (uploadResult['success'] == true) {
          imageUrl = uploadResult['url'];
        } else {
          throw Exception('Failed to upload profile image');
        }
      }

      // Create location object if wilaya is selected
      Location? location;
      if (_selectedWilaya != null) {
        location = Location(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _selectedWilaya!,
          description: 'User location in $_selectedWilaya',
          type: LocationType.pickup_point, // Default type
          city: _selectedWilaya!,
          state: _selectedWilaya!,
          country: 'Algeria',
          address: _addressController.text.trim().isEmpty ? 'Not specified' : _addressController.text.trim(),
          postalCode: '00000', // Default postal code
          latitude: 0.0, // Would be set by geocoding in real app
          longitude: 0.0,
          createdAt: DateTime.now(),
        );
      }

      // Create updated user preferences
      final preferences = {
        'email_notifications': _emailNotifications,
        'sms_notifications': _smsNotifications,
        'push_notifications': _pushNotifications,
        'language': _preferredLanguage,
        'currency': _preferredCurrency,
      };

      // Update user profile in Supabase
      await _updateUserInSupabase(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        profileImage: imageUrl,
        location: location,
        preferences: preferences,
      );

      setState(() {
        _hasChanges = false;
        _profileImageUrl = imageUrl;
        _profileImage = null;
      });

      _showSuccessSnackBar('Profile updated successfully!');
      
    } catch (e) {
      _showErrorSnackBar('Failed to update profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserInSupabase({
    required String name,
    String? phone,
    String? profileImage,
    Location? location,
    required Map<String, dynamic> preferences,
  }) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    
    if (user == null) throw Exception('No authenticated user');

            // Update in Supabase users table
    final updateData = {
      'name': name,
      'phone': phone,
      'profile_image': profileImage,
      'preferences': preferences,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (location != null) {
      updateData['location'] = location.toJson();
    }

    await Supabase.instance.client
        .from('users')
        .update(updateData)
        .eq('id', user.id);

    // Force refresh user state in AuthService
    await authService.forceRefreshUserState();
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _canSave() {
    return _hasChanges && !_isLoading;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Discard Changes?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to leave?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Stay',
              style: GoogleFonts.inter(),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[600],
            ),
            child: Text(
              'Discard',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              // Header
              FloatingHeader(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final shouldPop = await _onWillPop();
                        if (shouldPop && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'My Profile',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (_canSave())
                      TextButton(
                        onPressed: _updateProfile,
                        child: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Save',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Image Section
                        _buildProfileImageSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Personal Information
                        _buildPersonalInfoSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Contact Information
                        _buildContactInfoSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Location Information
                        _buildLocationSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Preferences
                        _buildPreferencesSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Notification Settings
                        _buildNotificationSection(),
                        
                        const SizedBox(height: 100), // Space for floating save button
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _canSave()
            ? FloatingActionButton.extended(
                onPressed: _isLoading ? null : _updateProfile,
                backgroundColor: const Color(0xFF353935),
                foregroundColor: Colors.white,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading ? 'Saving...' : 'Save Changes',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Text(
            'Profile Photo',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF353935).withValues(alpha: 0.2),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(
                            _profileImage!,
                            fit: BoxFit.cover,
                          )
                        : _profileImageUrl != null
                            ? Image.network(
                                _profileImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultAvatar();
                                },
                              )
                            : _buildDefaultAvatar(),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF353935),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap the camera icon to change your photo',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final user = Provider.of<AuthService>(context).currentUser;
    final initials = user?.name.split(' ').map((n) => n[0]).take(2).join() ?? '?';
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF353935).withValues(alpha: 0.1),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF353935),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Full name is required';
            }
            if (value.trim().length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return _buildSection(
      title: 'Contact Information',
      icon: Icons.contact_phone,
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          prefixIcon: Icons.email_outlined,
          enabled: false, // Email usually can't be changed
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number (Optional)',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              if (value.trim().length < 10) {
                return 'Please enter a valid phone number';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      title: 'Location',
      icon: Icons.location_on,
      children: [
        _buildDropdownField(
          value: _selectedWilaya,
          label: 'Wilaya',
          prefixIcon: Icons.location_city_outlined,
          items: _wilayas.map((wilaya) => wilaya['name']!).toList(),
          onChanged: (value) {
            setState(() {
              _selectedWilaya = value;
              _onFieldChanged();
            });
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'Address (Optional)',
          prefixIcon: Icons.home_outlined,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      title: 'Preferences',
      icon: Icons.settings,
      children: [
        _buildDropdownField(
          value: _preferredLanguage,
          label: 'Preferred Language',
          prefixIcon: Icons.language_outlined,
          items: _languages,
          onChanged: (value) {
            setState(() {
              _preferredLanguage = value!;
              _onFieldChanged();
            });
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          value: _preferredCurrency,
          label: 'Preferred Currency',
          prefixIcon: Icons.attach_money_outlined,
          items: _currencies,
          onChanged: (value) {
            setState(() {
              _preferredCurrency = value!;
              _onFieldChanged();
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      title: 'Notification Settings',
      icon: Icons.notifications,
      children: [
        _buildSwitchTile(
          title: 'Email Notifications',
          subtitle: 'Receive booking updates and offers via email',
          value: _emailNotifications,
          onChanged: (value) {
            setState(() {
              _emailNotifications = value;
              _onFieldChanged();
            });
          },
        ),
        _buildSwitchTile(
          title: 'SMS Notifications',
          subtitle: 'Receive important updates via SMS',
          value: _smsNotifications,
          onChanged: (value) {
            setState(() {
              _smsNotifications = value;
              _onFieldChanged();
            });
          },
        ),
        _buildSwitchTile(
          title: 'Push Notifications',
          subtitle: 'Receive notifications on your device',
          value: _pushNotifications,
          onChanged: (value) {
            setState(() {
              _pushNotifications = value;
              _onFieldChanged();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(icon, color: const Color(0xFF353935), size: 24),
              const SizedBox(width: 8),
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
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      maxLines: maxLines,
      onChanged: (_) => _onFieldChanged(),
      style: GoogleFonts.inter(
        color: enabled ? Colors.black : Colors.grey[600],
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefixIcon,
          color: enabled ? const Color(0xFF353935) : Colors.grey[400],
        ),
        labelStyle: GoogleFonts.inter(
          color: enabled ? Colors.grey[700] : Colors.grey[500],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF353935), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[50],
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData prefixIcon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: GoogleFonts.inter(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF353935)),
        labelStyle: GoogleFonts.inter(color: Colors.grey[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF353935), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: GoogleFonts.inter(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
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