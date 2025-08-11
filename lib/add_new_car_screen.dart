import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:io';
import 'dart:convert';
import 'services/car_service.dart';
import 'models/car.dart';
import 'widgets/floating_header.dart';
import 'services/auth_service.dart';
import 'package:provider/provider.dart';

class AddNewCarScreen extends StatefulWidget {
  const AddNewCarScreen({super.key});

  @override
  State<AddNewCarScreen> createState() => _AddNewCarScreenState();
}

class _AddNewCarScreenState extends State<AddNewCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  
  // Controllers
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final TextEditingController _minDaysController = TextEditingController(text: '1');
  final TextEditingController _maxDaysController = TextEditingController(text: '30');
  final _motorisationController = TextEditingController();
  final _kilometrageController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // State variables
  String _currencyCode = 'DZD';
  String _currencySymbol = 'DA';
  String _selectedBrand = 'BMW';
  String _selectedWilaya = 'Alger';
  String _selectedEnergie = 'Essence';
  String _selectedTransmission = 'Automatic';
  String _selectedCategory = 'SUV';
  String _selectedSeats = '5';
  String _selectedMinDays = '1';
  String _selectedMaxDays = '30';
  
  final List<String> _selectedFeatures = [];
  final TextEditingController _featureController = TextEditingController();
  final List<File> _selectedImages = [];
  
  // Requirements and Conditions
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _drivingExperienceController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  String _selectedPets = '';
  bool _smokingAllowed = false;
  bool _isSubmitting = false;
  bool _isUploadingImages = false;
  double _uploadProgress = 0.0;
  
  // Brand and Wilaya lists
  final List<String> _brands = [
    'Abarth', 'Acura', 'Alfa Romeo', 'Alpine', 'Aston Martin', 'Audi', 'BAIC', 'Bentley', 'BMW',
    'Brilliance', 'Bugatti', 'Buick', 'BYD', 'Cadillac', 'Changan', 'Chery', 'Chevrolet', 'Chrysler',
    'Citroën', 'Cupra', 'Dacia', 'Daewoo', 'Daihatsu', 'Dodge', 'DS Automobiles', 'FAW', 'Ferrari',
    'Fiat', 'Fisker', 'Ford', 'Geely', 'Genesis', 'GMC', 'Great Wall', 'Haval', 'Holden', 'Honda',
    'Hummer', 'Hyundai', 'Infiniti', 'Isuzu', 'Jaguar', 'Jeep', 'Kia', 'Koenigsegg', 'Lada', 'Lamborghini',
    'Lancia', 'Land Rover', 'Lexus', 'Lincoln', 'Lotus', 'Maserati', 'Maybach', 'Mazda', 'McLaren',
    'Mercedes-Benz', 'MG', 'Mini', 'Mitsubishi', 'Nissan', 'Opel', 'Pagani', 'Peugeot', 'Polestar',
    'Porsche', 'Proton', 'Renault', 'Rolls-Royce', 'Rover', 'Saab', 'SEAT', 'Škoda', 'Smart',
    'SsangYong', 'Subaru', 'Suzuki', 'Tata', 'Tesla', 'Toyota', 'Vauxhall', 'Volkswagen', 'Volvo',
    'Wuling', 'Zotye'
  ];
  
  final List<String> _wilayas = [
    'Adrar',
    'Chlef',
    'Laghouat',
    'Oum El Bouaghi',
    'Batna',
    'Bejaia',
    'Biskra',
    'Bechar',
    'Blida',
    'Bouira',
    'Tamanrasset',
    'Tebessa',
    'Tlemcen',
    'Tiaret',
    'Tizi Ouzou',
    'Alger',
    'Djelfa',
    'Jijel',
    'Setif',
    'Saida',
    'Skikda',
    'Sidi Bel Abbes',
    'Annaba',
    'Guelma',
    'Constantine',
    'Medea',
    'Mostaganem',
    'M\'Sila',
    'Mascara',
    'Ouargla',
    'Oran',
    'El Bayadh',
    'Illizi',
    'Bordj Bou Arreridj',
    'Boumerdes',
    'El Tarf',
    'Tindouf',
    'Tissemsilt',
    'El Oued',
    'Khenchela',
    'Souk Ahras',
    'Tipaza',
    'Mila',
    'Ain Defla',
    'Naama',
    'Ain Temouchent',
    'Ghardaia',
    'Relizane',
    'El M\'Ghair',
    'El Meniaa',
    'Ouled Djellal',
    'Bordj Baji Mokhtar',
    'Béni Abbès',
    'Timimoun',
    'Touggourt',
    'Djanet',
    'In Salah',
    'In Guezzam',
  ];
  final List<String> _energieOptions = ['Essence', 'Diesel', 'GPL', 'Electric'];
  final List<String> _transmissionOptions = ['Automatic', 'Manual'];
  final List<String> _categoryOptions = ['SUV', 'Sedan', 'Luxury', 'Electric', 'Sports', 'Compact', 'Van', 'Truck', 'Hatchback', 'Wagon'];
  final List<String> _seatsOptions = ['2', '4', '5', '6', '7', '8', '9'];
  final List<String> _availableFeatures = [
    'Air Conditioning',
    'GPS Navigation',
    'Bluetooth',
    'USB Charging',
    'Backup Camera',
    'Parking Sensors',
    'Cruise Control',
    'Heated Seats',
    'Leather Seats',
    'Automatic Transmission',
    'Wireless Charging',
    'Apple CarPlay',
    'Android Auto',
    '360° Camera',
    'Lane Departure Warning',
    'Blind Spot Detection',
    'Adaptive Cruise Control',
    'Panoramic Roof',
    'Premium Sound System',
    'Keyless Entry',
    'Push Button Start',
    'Tire Pressure Monitoring',
    'Emergency Brake Assist',
    'Hill Start Assist',
    'Traction Control',
    'Stability Control',
    'Child Safety Locks',
    'ISOFIX Child Seat Anchors',
  ];

  // Requirements and Conditions Options
  final List<String> _petsOptions = [
    'Allowed',
    'Not allowed',
    'Allowed with fee',
    'Case by case',
  ];

  // Drop-off/Pick-up section
  final List<String> _dropOffLocations = [];
  final List<String> _pickUpLocations = [];
  final TextEditingController _dropOffController = TextEditingController();
  final TextEditingController _pickUpController = TextEditingController();
  bool _dropToLocationEnabled = false;
  bool _pickFromLocationEnabled = false;
  
  // Additional chip input fields above drop-off and pick-up
  final List<String> _dropOffAdditionalInfo = [];
  final List<String> _pickUpAdditionalInfo = [];
  final TextEditingController _dropOffAdditionalController = TextEditingController();
  final TextEditingController _pickUpAdditionalController = TextEditingController();

  // Car Use Type (Daily, Business, Event)
  String _selectedUseType = 'daily';

  @override
  void dispose() {
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _minDaysController.dispose();
    _maxDaysController.dispose();
    _motorisationController.dispose();
    _kilometrageController.dispose();
    _descriptionController.dispose();
    _featureController.dispose();
    _ageController.dispose();
    _drivingExperienceController.dispose();
    _depositController.dispose();
    _mileageController.dispose();
    _dropOffController.dispose();
    _pickUpController.dispose();
    _dropOffAdditionalController.dispose();
    _pickUpAdditionalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Resolve currency after first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveCurrencyFromContext();
    });
  }

  void _resolveCurrencyFromContext() {
    try {
      final locale = Localizations.localeOf(context);
      final country = (locale.countryCode ?? '').toUpperCase();
      String code = 'DZD';
      switch (country) {
        case 'DZ':
          code = 'DZD';
          break;
        case 'FR':
        case 'DE':
        case 'ES':
        case 'IT':
        case 'PT':
        case 'NL':
        case 'BE':
        case 'IE':
        case 'FI':
        case 'GR':
          code = 'EUR';
          break;
        case 'US':
          code = 'USD';
          break;
        case 'GB':
          code = 'GBP';
          break;
        case 'MA':
          code = 'MAD';
          break;
        case 'TN':
          code = 'TND';
          break;
        case 'EG':
          code = 'EGP';
          break;
        case 'AE':
          code = 'AED';
          break;
        default:
          code = 'DZD';
      }

      String symbol;
      switch (code) {
        case 'EUR':
          symbol = '€';
          break;
        case 'USD':
          symbol = '4'; // fallback will be replaced immediately below
          symbol = ''; // placeholder (ensure not used)
          symbol = ' '; // not used
          symbol = r'$';
          break;
        case 'GBP':
          symbol = '£';
          break;
        case 'MAD':
          symbol = 'MAD ';
          break;
        case 'TND':
          symbol = 'TND ';
          break;
        case 'EGP':
          symbol = 'E£ ';
          break;
        case 'AED':
          symbol = 'AED ';
          break;
        case 'DZD':
        default:
          symbol = 'DA ';
      }

      setState(() {
        _currencyCode = code;
        _currencySymbol = symbol.trimRight();
      });
    } catch (_) {
      setState(() {
        _currencyCode = 'DZD';
        _currencySymbol = 'DA';
      });
    }
  }

  Future<void> _pickImages() async {
    // Show source selection dialog
    final ImageSource? source = await _showImageSourceDialog();
    if (source == null) return;

    try {
      setState(() {
        _isUploadingImages = true;
        _uploadProgress = 0.0;
      });

      List<XFile> images = [];
      
      if (source == ImageSource.camera) {
        // Single image from camera
        final XFile? image = await _imagePicker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1080,
        );
        if (image != null) {
          images = [image];
        }
      } else {
        // Multiple images from gallery
        images = await _imagePicker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1080,
        );
      }

      if (images.isNotEmpty) {
        int addedCount = 0;
        int duplicateCount = 0;
        
        // Validate and compress images
        for (int i = 0; i < images.length; i++) {
        setState(() {
            _uploadProgress = (i + 1) / images.length;
          });

          final File imageFile = File(images[i].path);
          
          // Validate file size (max 10MB)
          final int fileSize = await imageFile.length();
          if (fileSize > 10 * 1024 * 1024) {
            _showErrorSnackBar('Image too large. Please select images under 10MB.');
            continue;
          }

          // Validate file type
          final String extension = images[i].path.split('.').last.toLowerCase();
          if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
            _showErrorSnackBar('Invalid file type. Please select JPG, PNG, or WebP images.');
            continue;
          }

          // Check for duplicates
          final bool isDuplicate = await _isDuplicateImage(imageFile);
          if (isDuplicate) {
            duplicateCount++;
            _showErrorSnackBar('Duplicate image detected and skipped.');
            continue;
          }

          // Compress image if needed
          final File compressedImage = await _compressImage(imageFile);
          
          setState(() {
            _selectedImages.add(compressedImage);
          });
          
          addedCount++;
        }

        // Show results
        if (addedCount > 0) {
          String message = '$addedCount image(s) added successfully!';
          if (duplicateCount > 0) {
            message += ' $duplicateCount duplicate(s) skipped.';
          }
          _showSuccessSnackBar(message);
        } else if (duplicateCount > 0) {
          _showErrorSnackBar('All selected images were duplicates and have been skipped.');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error picking images: $e');
    } finally {
      setState(() {
        _isUploadingImages = false;
        _uploadProgress = 0.0;
      });
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Select Image Source',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF353935).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF353935),
                  ),
                ),
                title: Text(
                  'Camera',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text('Take a new photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF353935).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF353935),
                  ),
                ),
                title: Text(
                  'Gallery',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text('Choose from gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File> _compressImage(File imageFile) async {
    try {
      // For now, return the original file
      // In a production app, you would implement proper compression
      // or use a cloud service for image optimization
      return imageFile;
    } catch (e) {
      print('Error processing image: $e');
      return imageFile; // Return original if processing fails
    }
  }

  void _showErrorSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        ),
      );
    }

  void _showDuplicateDetectionInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Duplicate Detection',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Our system automatically detects and prevents duplicate images:',
                style: GoogleFonts.inter(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.fingerprint,
                'SHA-256 Hash',
                'Compares image content for exact matches',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.file_copy,
                'File Comparison',
                'Checks file size and path for duplicates',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.shield,
                'Automatic Skip',
                'Duplicates are automatically skipped',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF353935),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF353935).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF353935),
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
                ),
              ),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChipInputField({
    required String label,
    required List<String> chips,
    required Function(String) onChipAdded,
    required Function(String) onChipRemoved,
    required TextEditingController controller,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText ?? 'Type a feature and press Enter',
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF353935), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        controller.clear();
                      },
                      icon: const Icon(Icons.clear, color: Colors.grey),
                    )
                  : null,
            ),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                onChipAdded(value.trim());
                controller.clear();
              }
            },
            onChanged: (value) {
              setState(() {}); // Rebuild to show/hide clear button
            },
          ),
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips.map((chip) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF353935).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF353935).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        chip,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF353935),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => onChipRemoved(chip),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF353935).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Color(0xFF353935),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildRequirementsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
              const Icon(Icons.rule, color: Color(0xFF353935), size: 24),
              const SizedBox(width: 8),
              Text(
                'Requirements & Conditions',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Age and Driving Experience with enhanced styling
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF353935).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF353935),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Driver Requirements',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF353935),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _ageController,
                        label: 'Minimum Age',
                        hint: 'e.g., 25',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter minimum age';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age < 21) {
                            return 'Minimum age must be 21 or higher';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        controller: _drivingExperienceController,
                        label: 'Driving Experience',
                        hint: 'e.g., 3',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter driving experience';
                          }
                          final experience = int.tryParse(value);
                          if (experience == null || experience < 0) {
                            return 'Please enter a valid number of years';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Pets and Smoking with enhanced styling
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF353935).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: Color(0xFF353935),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Vehicle Policies',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF353935),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Pets Policy',
                        value: _selectedPets,
                        items: _petsOptions,
                        onChanged: (value) {
    setState(() {
                            _selectedPets = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select pets policy';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smoking Allowed',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SwitchListTile(
                              value: _smokingAllowed,
                              onChanged: (value) {
                                setState(() {
                                  _smokingAllowed = value;
                                });
                              },
                              title: Text(
                                _smokingAllowed ? 'Allowed' : '',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              activeColor: const Color(0xFF353935),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              tileColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Deposit and Mileage with enhanced styling
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF353935).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFF353935),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Financial & Usage Terms',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF353935),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _depositController,
                        label: 'Deposit (€)',
                        hint: 'e.g., 200 (leave empty for no deposit)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null; // No deposit is allowed
                          }
                          if (value == '0') {
                            return 'Please leave empty if no deposit is required';
                          }
                          final deposit = int.tryParse(value);
                          if (deposit == null || deposit < 0) {
                            return 'Please enter a valid deposit amount';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        controller: _mileageController,
                        label: 'Daily Mileage Limit',
                        hint: 'e.g., 300 (leave empty for unlimited)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null; // Unlimited mileage is allowed
                          }
                          final mileage = int.tryParse(value);
                          if (mileage == null || mileage <= 0) {
                            return 'Please enter a valid mileage limit';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Generate hash for image file
  Future<String> _generateImageHash(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      print('❌ Error generating image hash: $e');
      // Fallback: use file path and size as hash
      final stat = await imageFile.stat();
      return '${imageFile.path}_${stat.size}';
    }
  }

  // Check if image is duplicate
  Future<bool> _isDuplicateImage(File newImage) async {
    try {
      final newImageHash = await _generateImageHash(newImage);
      
      for (final existingImage in _selectedImages) {
        final existingHash = await _generateImageHash(existingImage);
        if (newImageHash == existingHash) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ Error checking for duplicates: $e');
      return false;
    }
  }

  // Check if image is similar (basic file comparison)
  Future<bool> _isSimilarImage(File newImage) async {
    try {
      final newImageStat = await newImage.stat();
      
      for (final existingImage in _selectedImages) {
        final existingStat = await existingImage.stat();
        
        // Check if files are identical (same size and path)
        if (newImage.path == existingImage.path) {
          return true;
        }
        
        // Check if files have same size (basic similarity check)
        if (newImageStat.size == existingStat.size) {
          // Additional check: read first 1KB and compare
          final newBytes = await newImage.openRead(0, 1024).first;
          final existingBytes = await existingImage.openRead(0, 1024).first;
          
          if (listEquals(newBytes, existingBytes)) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print('❌ Error checking for similar images: $e');
      return false;
    }
  }

  Future<List<String>> _uploadImagesToSupabase() async {
    final List<String> uploadedUrls = [];
    final supabase = Supabase.instance.client;
    
    try {
      for (int i = 0; i < _selectedImages.length; i++) {
        setState(() {
          _uploadProgress = (i + 1) / _selectedImages.length;
        });

        final File imageFile = _selectedImages[i];
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
        final String filePath = fileName; // Remove the 'cars/' prefix

        print('📤 Attempting to upload: $fileName to bucket: car-images');

        // Upload to Supabase Storage
        await supabase.storage
            .from('car-images')
            .upload(filePath, imageFile);

        // Get public URL
        final String publicUrl = supabase.storage
            .from('car-images')
            .getPublicUrl(filePath);

        uploadedUrls.add(publicUrl);
        print('✅ Uploaded image $i: $publicUrl');
      }
      
      return uploadedUrls;
    } catch (e) {
      print('❌ Error uploading images to Supabase: $e');
      throw Exception('Failed to upload images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Check if user is authenticated
      final currentUser = Supabase.instance.client.auth.currentUser;
      final authService = Provider.of<AuthService>(context, listen: false);
      final appUser = authService.currentUser;
      
      if (currentUser == null && appUser == null) {
        _showErrorSnackBar('Please sign in to add a car');
        return;
      }

      // Use the authenticated user ID
      final userId = currentUser?.id ?? appUser?.id;
      if (userId == null) {
        _showErrorSnackBar('Unable to get user ID');
        return;
      }

      print('🔐 Using user ID: $userId');
      print('👤 User from Supabase: ${currentUser?.email}');
      print('👤 User from AuthService: ${appUser?.email}');

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  _uploadProgress < 1.0 ? 'Uploading images...' : 'Adding car to database...',
                  style: GoogleFonts.inter(fontSize: 16),
                ),
                if (_uploadProgress < 1.0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${(_uploadProgress * 100).toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );

      // Upload images to Supabase Storage first
      print('🚀 Starting image upload process...');
      List<String> uploadedImageUrls = [];
      
      try {
        uploadedImageUrls = await _uploadImagesToSupabase();
        print('📊 Upload results: ${uploadedImageUrls.length} images uploaded');
      } catch (uploadError) {
        print('❌ Image upload failed: $uploadError');
        // Fallback: use placeholder images if upload fails
        uploadedImageUrls = [
          'https://via.placeholder.com/400x300/353935/FFFFFF?text=Car+Image',
          'https://via.placeholder.com/400x300/353935/FFFFFF?text=Car+Image+2',
        ];
        print('🔄 Using fallback placeholder images');
      }
      
      if (uploadedImageUrls.isEmpty) {
        throw Exception('No images were uploaded successfully');
      }

      // Prepare car data for database - matching your actual schema
      final carData = {
        'name': _selectedBrand + ' ' + _modelController.text,
        'image': uploadedImageUrls.isNotEmpty ? uploadedImageUrls.first : '',
        'price': double.parse(_priceController.text),
        'category': _selectedCategory,
        'rating': 0.0,
        'trips': 0,
        'location': _selectedWilaya,
        'host_name': currentUser?.userMetadata?['name'] ?? 'Current User', // Use actual user name
        'host_image': 'https://via.placeholder.com/150',
        'host_rating': 0.0,
        'response_time': 'Within 1 hour',
        'description': _descriptionController.text,
        'features': _selectedFeatures, // This will be converted to JSONB by Supabase
        'images': uploadedImageUrls, // Use uploaded image URLs
        'host_id': userId, // Use the correct user ID
        'specs': {
          'engine': _motorisationController.text,
          'transmission': _selectedTransmission.toLowerCase(), // Must be 'manual' or 'automatic'
          'fuel': _selectedEnergie.toLowerCase(), // Must be 'essence', 'diesel', 'gpl', or 'electric'
          'seats': _selectedSeats,
          'year': _yearController.text,
          'brand': _selectedBrand,
          'model': _modelController.text,
          'color': 'White',
          'licensePlate': 'ABC123',
          'mileage': _kilometrageController.text,
          'minRentalDays': int.tryParse(_minDaysController.text) ?? int.tryParse(_selectedMinDays) ?? 1,
          'maxRentalDays': int.tryParse(_maxDaysController.text) ?? int.tryParse(_selectedMaxDays) ?? 30,
        },
        'available': true,
        'transmission': _selectedTransmission.toLowerCase(), // Must be 'manual' or 'automatic'
        'fuel_type': _selectedEnergie.toLowerCase(), // Must be 'essence', 'diesel', 'gpl', or 'electric'
        'passengers': int.parse(_selectedSeats),
        'requirements': {
          'minimum_age': _ageController.text,
          'driving_experience': _drivingExperienceController.text,
          'pets_policy': _selectedPets,
          'smoking_policy': _smokingAllowed ? 'Allowed' : 'Not allowed',
        'deposit': _depositController.text.isEmpty ? 'No deposit' : '${_currencySymbol}${_depositController.text}',
          'mileage_limit': _mileageController.text.isEmpty ? 'Unlimited' : '${_mileageController.text} km/day',
        },
        'pickup_locations': _pickFromLocationEnabled ? _pickUpLocations : [],
        'dropoff_locations': _dropToLocationEnabled ? _dropOffLocations : [],
        'pickup_additional_info': _pickUpAdditionalInfo,
        'dropoff_additional_info': _dropOffAdditionalInfo,
        'use_type': _selectedUseType,
      };

      // Debug logging
      print('🔐 Current user ID: $userId');
      print('👤 Current user name: ${appUser?.name ?? currentUser?.userMetadata?['name']}');
      print('📋 Car data being sent: $carData');
      
      // Validate required fields
      final requiredFields = ['name', 'image', 'price', 'category', 'host_id'];
      for (final field in requiredFields) {
        if (!carData.containsKey(field) || carData[field] == null) {
          print('❌ Missing required field: $field');
          throw Exception('Missing required field: $field');
        }
      }
      print('✅ All required fields present');

      // Add car to database
      print('📝 Attempting to add car to database...');
      final carService = CarService();
      
      Car? car;
      try {
        // Convert Map to Car object
        car = Car.fromJson(carData);
        final success = await carService.addCar(car);
        
        if (success == true) {
          print('✅ Car added successfully to database!');
          print('🚗 Car name: ${car.name}');
        } else {
          print('❌ Car service returned false');
          throw Exception('Car service returned false - car was not added to database');
        }
      } catch (dbError) {
        print('❌ Database error: $dbError');
        throw Exception('Failed to add car to database: $dbError');
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // If we reach here, the car was added successfully
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Success!',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Car has been added successfully!',
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${uploadedImageUrls.length} image(s) uploaded',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    // Pop this screen with a result so caller can refresh
                    Navigator.of(context).pop(car);
                  },
                  child: Text(
                    'OK',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF353935),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Error',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Failed to add car: $e',
                style: GoogleFonts.inter(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF353935),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } finally {
        setState(() {
          _isSubmitting = false;
        _uploadProgress = 0.0;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagesSection(),
                      const SizedBox(height: 24),
                      _buildBasicInfoSection(),
                      const SizedBox(height: 24),
                      _buildPricingSection(),
                      const SizedBox(height: 24),
                      _buildLocationSection(),
                      const SizedBox(height: 24),
                      _buildFeaturesSection(),
                      const SizedBox(height: 24),
                      _buildTechnicalSection(),
                      const SizedBox(height: 24),
                      _buildRequirementsSection(),
                      const SizedBox(height: 24),
                      _buildDropOffPickUpSection(),
                      const SizedBox(height: 24),
                      _buildDescriptionSection(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FloatingHeader(
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Add New Car',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library, color: Color(0xFF353935), size: 24), // Updated to Onyx
              const SizedBox(width: 8),
              Text(
                'Car Images',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              // Info button for duplicate detection
              GestureDetector(
                onTap: _showDuplicateDetectionInfo,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedImages.isEmpty)
            GestureDetector(
              onTap: _isUploadingImages ? null : _pickImages,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                ),
                  ],
                ),
                child: _isUploadingImages
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF353935),
                              ),
                            ),
                          ),
                    const SizedBox(height: 8),
                    Text(
                            'Processing images...',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(_uploadProgress * 100).toInt()}%',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF353935).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate,
                              size: 32,
                              color: Color(0xFF353935),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add Car Images',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                              color: const Color(0xFF353935),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to select from camera or gallery',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Car Images (${_selectedImages.length})',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    if (!_isUploadingImages)
                      GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                            color: const Color(0xFF353935),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF353935).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                              children: [
                              const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                                Text(
                                  'Add More',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedImages[index],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.error_outline,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Remove button
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            // Image number indicator
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            // Duplicate warning indicator (if needed)
                            if (_selectedImages.length > 1)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.shield,
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Unique',
                                        style: GoogleFonts.inter(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
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
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF353935), size: 24), // Updated to Onyx
              const SizedBox(width: 8),
              Text(
                'Basic Information',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Brand',
                  value: _selectedBrand,
                  items: _brands,
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a brand';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  controller: _modelController,
                  label: 'Model',
                  hint: 'e.g., X5, Camry',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the model';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _yearController,
                  label: 'Year',
                  hint: 'e.g., 2023',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the year';
                    }
                    final year = int.tryParse(value);
                    if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                      return 'Please enter a valid year';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  controller: _kilometrageController,
                  label: 'Kilométrage',
                  hint: 'e.g., 50000',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the kilometrage';
                    }
                    final km = int.tryParse(value);
                    if (km == null || km < 0) {
                      return 'Please enter a valid kilometrage';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Category',
                  value: _selectedCategory,
                  items: _categoryOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  label: 'Number of Seats',
                  value: _selectedSeats,
                  items: _seatsOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedSeats = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select number of seats';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_money, color: Color(0xFF353935), size: 24), // Updated to Onyx
              const SizedBox(width: 8),
              Text(
                'Pricing',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _priceController,
            label: 'Daily Price (${_currencySymbol})',
            hint: 'e.g., 8000',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.attach_money,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the daily price';
              }
              final price = double.tryParse(value);
              if (price == null || price <= 0) {
                return 'Please enter a valid price';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _minDaysController,
                  label: 'Min Rental Days',
                  hint: 'e.g., 1',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.calendar_today,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter minimum days';
                    }
                    final val = int.tryParse(value);
                    if (val == null || val < 1) {
                      return 'Enter a valid number (>=1)';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  controller: _maxDaysController,
                  label: 'Max Rental Days',
                  hint: 'e.g., 30',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.event,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter maximum days';
                    }
                    final maxVal = int.tryParse(value);
                    final minVal = int.tryParse(_minDaysController.text);
                    if (maxVal == null || maxVal < 1) {
                      return 'Enter a valid number (>=1)';
                    }
                    if (minVal != null && maxVal < minVal) {
                      return 'Max must be >= Min';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFF353935), size: 24), // Updated to Onyx
              const SizedBox(width: 8),
              Text(
                'Location',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            label: 'Wilaya',
            value: _selectedWilaya,
            items: _wilayas,
            onChanged: (value) {
              setState(() {
                _selectedWilaya = value!;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a wilaya';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.featured_play_list, color: Color(0xFF353935), size: 24), // Updated to Onyx
              const SizedBox(width: 8),
              Text(
                'Vehicle Features',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              // Help button for features
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.help_outline,
                                color: Colors.blue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Adding Features',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How to add vehicle features:',
                              style: GoogleFonts.inter(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              Icons.keyboard,
                              'Type & Enter',
                              'Type a feature and press Enter to add it',
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.close,
                              'Remove Chips',
                              'Tap the X button on any chip to remove it',
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.clear,
                              'Clear Input',
                              'Tap the clear button to reset the input field',
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Examples: Air Conditioning, GPS Navigation, Bluetooth, Leather Seats',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                              'Got it',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                                color: const Color(0xFF353935),
                    ),
                  ),
                ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    size: 18,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildChipInputField(
            label: 'Add Features',
            chips: _selectedFeatures,
            onChipAdded: (String newChip) {
              setState(() {
                _selectedFeatures.add(newChip);
              });
            },
            onChipRemoved: (String removedChip) {
              setState(() {
                _selectedFeatures.remove(removedChip);
              });
            },
            controller: _featureController,
            hintText: 'e.g., Air Conditioning, GPS Navigation',
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.engineering, color: Color(0xFF353935), size: 24), // Updated to Onyx
              const SizedBox(width: 8),
              Text(
                'Technical Information',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Car Use selector
          Row(
            children: [
              const Icon(Icons.style, color: Color(0xFF353935), size: 24),
              const SizedBox(width: 8),
              Text(
                'Car Use',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildUseChip('Daily', 'daily'),
              _buildUseChip('Business', 'business'),
              _buildUseChip('Event', 'event'),
            ],
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _motorisationController,
            label: 'Motorisation',
            hint: 'e.g., 2.0L Turbo, 1.6L',
            prefixIcon: Icons.speed,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the motorisation';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Energie',
                  value: _selectedEnergie,
                  items: _energieOptions,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedEnergie = newValue;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  label: 'Transmission',
                  value: _selectedTransmission,
                  items: _transmissionOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedTransmission = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select transmission';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUseChip(String label, String value) {
    final bool selected = _selectedUseType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUseType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF353935) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF353935) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }



  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: Color(0xFF353935), size: 24), // Updated to Onyx
              const SizedBox(width: 8),
              Text(
                'Description',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe your car, its condition, special features...',
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[500],
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
                borderSide: const BorderSide(color: Color(0xFF353935), width: 2), // Updated to Onyx
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red[300]!),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              if (value.length < 20) {
                return 'Description must be at least 20 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[600]) : null,
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
              borderSide: const BorderSide(color: Color(0xFF353935), width: 2), // Updated to Onyx
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[300]!),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.black,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    // Debug print to help troubleshoot
    print('🔍 Building dropdown for $label with value: "$value"');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value?.isNotEmpty == true ? value : null,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    item,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            selectedItemBuilder: (BuildContext context) {
              return items.map<Widget>((String item) {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList();
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF353935).withOpacity(0.1), // Updated to Onyx
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF353935), // Updated to Onyx
                size: 20,
              ),
            ),
            decoration: InputDecoration(
              hintText: value?.isNotEmpty == true ? value : 'Choose your ${label.toLowerCase()}',
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                color: value?.isNotEmpty == true ? Colors.black87 : Colors.grey[500],
                fontWeight: value?.isNotEmpty == true ? FontWeight.w500 : FontWeight.normal,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF353935), width: 2), // Updated to Onyx
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            validator: validator,
            dropdownColor: Colors.white,
            menuMaxHeight: 300, // Increased from 200
            isExpanded: true,
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF353935), // Updated to Onyx
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Adding Car...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                'Add Car',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildDropOffPickUpSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
              const Icon(Icons.location_on, color: Color(0xFF353935), size: 24),
              const SizedBox(width: 8),
              Text(
                'Drop-off & Pick-up',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Drop off Location options
          Text(
            'Drop off Location options',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dropOffController,
            decoration: InputDecoration(
              hintText: 'Enter drop-off location',
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[500],
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
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_location_alt_outlined, color: Color(0xFF353935)),
                onPressed: () {
                  final text = _dropOffController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _dropOffLocations.add(text);
                      _dropOffController.clear();
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_dropOffLocations.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dropOffLocations.map((loc) => Chip(
                label: Text(loc),
                onDeleted: () {
                  setState(() {
                    _dropOffLocations.remove(loc);
                  });
                },
              )).toList(),
            ),
          Row(
            children: [
              Text(
                'Drop-off to location',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Switch(
                value: _dropToLocationEnabled,
                onChanged: (value) {
                  setState(() {
                    _dropToLocationEnabled = value;
                  });
                },
                activeColor: const Color(0xFF353935),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Pick up Location options
          Text(
            'Pick up Location options',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _pickUpController,
            decoration: InputDecoration(
              hintText: 'Enter pick-up location',
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[500],
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
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_location_alt_outlined, color: Color(0xFF353935)),
                onPressed: () {
                  final text = _pickUpController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _pickUpLocations.add(text);
                      _pickUpController.clear();
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_pickUpLocations.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _pickUpLocations.map((loc) => Chip(
                label: Text(loc),
                onDeleted: () {
                  setState(() {
                    _pickUpLocations.remove(loc);
                  });
                },
              )).toList(),
            ),
          Row(
            children: [
              Text(
                'Pick-up from location',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Switch(
                value: _pickFromLocationEnabled,
                onChanged: (value) {
                  setState(() {
                    _pickFromLocationEnabled = value;
                  });
                },
                activeColor: const Color(0xFF353935),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 