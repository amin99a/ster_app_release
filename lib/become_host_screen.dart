import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/error_logging_service.dart';
import 'services/car_service.dart';
import 'services/host_service.dart';
import 'services/auth_service.dart';
import 'screens/waiting_for_approval_screen.dart';
import 'screens/host_application_status_screen.dart';
import 'screens/host_dashboard_screen.dart';
import 'add_new_car_screen.dart';
import 'models/car.dart';
import 'models/host_request.dart';
import 'widgets/floating_header.dart';
import 'widgets/document_upload_tile.dart';
import 'services/host_document_service.dart';

class BecomeHostScreen extends StatefulWidget {
  const BecomeHostScreen({super.key});

  @override
  State<BecomeHostScreen> createState() => _BecomeHostScreenState();
}

class _BecomeHostScreenState extends State<BecomeHostScreen> {
  // Custom color constant for better maintainability
  static const Color primaryColor = Color(0xFF353935);
  
  @override
  void initState() {
    super.initState();
    // Check current host application status and route accordingly
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final status = await context.read<HostService>().getCurrentUserRequestStatus();
      if (!mounted) return;
      if (status == HostRequestStatus.approved) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HostDashboardScreen()),
        );
      } else if (status == HostRequestStatus.pending) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WaitingForApprovalScreen()),
        );
      } else if (status == HostRequestStatus.rejected) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HostApplicationStatusScreen(
              status: 'rejected',
              onResubmit: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      }
    });
  }
  int _currentStep = 0;
  final PageController _pageController = PageController();
  
  // Loading state
  bool _isSubmitting = false;
  
  // Error states for validation
  final Map<String, String> _fieldErrors = {};
  bool _hasValidationErrors = false;
  
  // Form controllers
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  // Form data
  String? _selectedBusinessType;
  final Set<String> _selectedVehicleTypes = {};
  String? _selectedInsuranceProvider;
  bool _hasCommercialLicense = false;
  bool _hasInsurance = false;
  bool _hasVehicleRegistration = false;
  bool _docIdFront = false;
  bool _docIdBack = false;
  bool _docLicense = false;
  bool _docOwnership = false;
  bool _docSelfieOptional = false;
  bool _agreesToTerms = false;
  String _selectedCountryCode = '+213'; // Algeria default
  
  // Vehicle details
  final List<Map<String, dynamic>> _vehicles = [];
  
  // Brands list from search screen
  final List<String> _brands = [
    'BMW',
    'Audi',
    'Mercedes',
    'Tesla',
    'Toyota',
    'Honda',
    'Ford',
    'Chevrolet',
    'Nissan',
    'Volkswagen',
    'Hyundai',
    'Kia',
    'Mazda',
    'Subaru',
    'Lexus',
    'Infiniti',
    'Acura',
    'Volvo',
    'Jaguar',
    'Land Rover',
    'Porsche',
    'Ferrari',
    'Lamborghini',
    'McLaren',
  ];

  // Wilayas list from search screen
  final List<Map<String, String>> _wilayas = [
    {'name': 'Adrar', 'code': '01'},
    {'name': 'Chlef', 'code': '02'},
    {'name': 'Laghouat', 'code': '03'},
    {'name': 'Oum El Bouaghi', 'code': '04'},
    {'name': 'Batna', 'code': '05'},
    {'name': 'Bejaia', 'code': '06'},
    {'name': 'Biskra', 'code': '07'},
    {'name': 'Bechar', 'code': '08'},
    {'name': 'Blida', 'code': '09'},
    {'name': 'Bouira', 'code': '10'},
    {'name': 'Tamanrasset', 'code': '11'},
    {'name': 'Tebessa', 'code': '12'},
    {'name': 'Tlemcen', 'code': '13'},
    {'name': 'Tiaret', 'code': '14'},
    {'name': 'Tizi Ouzou', 'code': '15'},
    {'name': 'Alger', 'code': '16'},
    {'name': 'Djelfa', 'code': '17'},
    {'name': 'Jijel', 'code': '18'},
    {'name': 'Setif', 'code': '19'},
    {'name': 'Saida', 'code': '20'},
    {'name': 'Skikda', 'code': '21'},
    {'name': 'Sidi Bel Abbes', 'code': '22'},
    {'name': 'Annaba', 'code': '23'},
    {'name': 'Guelma', 'code': '24'},
    {'name': 'Constantine', 'code': '25'},
    {'name': 'Medea', 'code': '26'},
    {'name': 'Mostaganem', 'code': '27'},
    {'name': 'M\'Sila', 'code': '28'},
    {'name': 'Mascara', 'code': '29'},
    {'name': 'Ouargla', 'code': '30'},
    {'name': 'Oran', 'code': '31'},
    {'name': 'El Bayadh', 'code': '32'},
    {'name': 'Illizi', 'code': '33'},
    {'name': 'Bordj Bou Arreridj', 'code': '34'},
    {'name': 'Boumerdes', 'code': '35'},
    {'name': 'El Tarf', 'code': '36'},
    {'name': 'Tindouf', 'code': '37'},
    {'name': 'Tissemsilt', 'code': '38'},
    {'name': 'El Oued', 'code': '39'},
    {'name': 'Khenchela', 'code': '40'},
    {'name': 'Souk Ahras', 'code': '41'},
    {'name': 'Tipaza', 'code': '42'},
    {'name': 'Mila', 'code': '43'},
    {'name': 'Ain Defla', 'code': '44'},
    {'name': 'Naama', 'code': '45'},
    {'name': 'Ain Temouchent', 'code': '46'},
    {'name': 'Ghardaia', 'code': '47'},
    {'name': 'Relizane', 'code': '48'},
    {'name': 'El M\'Ghair', 'code': '49'},
    {'name': 'El Meniaa', 'code': '50'},
    {'name': 'Ouled Djellal', 'code': '51'},
    {'name': 'Bordj Baji Mokhtar', 'code': '52'},
    {'name': 'Béni Abbès', 'code': '53'},
    {'name': 'Timimoun', 'code': '54'},
    {'name': 'Touggourt', 'code': '55'},
    {'name': 'Djanet', 'code': '56'},
    {'name': 'In Salah', 'code': '57'},
    {'name': 'In Guezzam', 'code': '58'},
  ];
  
  @override
  void dispose() {
    _pageController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _taxIdController.dispose();
    _bankAccountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildPersonalInfoStep(),
                _buildBusinessInfoStep(),
                _buildVehicleInfoStep(),
                _buildDocumentsStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FloatingHeader(
      height: 140,
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
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
              Text(
                'Become a Host',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(5, (index) {
        bool isActive = index <= _currentStep;
        bool isCompleted = index < _currentStep;
        
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? Colors.white 
                        : isActive 
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(Icons.check, color: primaryColor, size: 18)
                      : Icon(
                          _getStepIcon(index),
                          color: isActive ? primaryColor : Colors.white,
                          size: 18,
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStepTitle(index),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0: return Icons.person;
      case 1: return Icons.business;
      case 2: return Icons.directions_car;
      case 3: return Icons.folder_open;
      case 4: return Icons.check_circle;
      default: return Icons.circle;
    }
  }

  String _getStepTitle(int index) {
    switch (index) {
      case 0: return 'Personal';
      case 1: return 'Business';
      case 2: return 'Vehicle';
      case 3: return 'Documents';
      case 4: return 'Review';
      default: return '';
    }
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Personal Information',
            'Tell us about yourself and your hosting goals',
            Icons.person,
          ),
          const SizedBox(height: 24),
          _buildInputField(
            'Full Name',
            'Enter your full legal name',
            Icons.person_outline,
            controller: _businessNameController,
            fieldName: 'businessName',
          ),
          const SizedBox(height: 16),
          _buildPhoneNumberField(),
          const SizedBox(height: 16),
          _buildInputField(
            'Address',
            'Enter your residential address',
            Icons.location_on_outlined,
            controller: _addressController,
            fieldName: 'address',
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Business Type'),
          const SizedBox(height: 12),
          _buildSelectionCard(
            'Individual',
            'Rent your personal vehicle(s)',
            Icons.person,
            _selectedBusinessType == 'individual',
            () => setState(() => _selectedBusinessType = 'individual'),
          ),
          const SizedBox(height: 12),
          _buildSelectionCard(
            'Business',
            'Rent vehicles from your business fleet',
            Icons.business,
            _selectedBusinessType == 'business',
            () => setState(() => _selectedBusinessType = 'business'),
          ),
          const SizedBox(height: 12),
          _buildSelectionCard(
            'Dealership',
            'Rent vehicles from your dealership',
            Icons.local_shipping,
            _selectedBusinessType == 'dealership',
            () => setState(() => _selectedBusinessType = 'dealership'),
          ),
          if (_fieldErrors.containsKey('businessType')) ...[
            const SizedBox(height: 8),
            Text(
              _fieldErrors['businessType']!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBusinessInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Business Information',
            'Provide your business details and credentials',
            Icons.business,
          ),
          const SizedBox(height: 24),
          _buildInputField(
            'Business Name',
            'Enter your business name',
            Icons.store,
            controller: _businessNameController,
            fieldName: 'businessName',
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Tax ID / Registration Number (Optional)',
            'Enter your business registration number',
            Icons.receipt_long,
            controller: _taxIdController,
            fieldName: 'taxId',
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Bank Account (Optional)',
            'Enter your bank account for payments',
            Icons.account_balance,
            controller: _bankAccountController,
            fieldName: 'bankAccount',
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Vehicle Types'),
          const SizedBox(height: 12),
          _buildMultiSelectionCard(
            'Passenger Cars',
            'Sedans, hatchbacks, SUVs',
            Icons.directions_car,
            _selectedVehicleTypes.contains('passenger'),
            () => setState(() {
              if (_selectedVehicleTypes.contains('passenger')) {
                _selectedVehicleTypes.remove('passenger');
              } else {
                _selectedVehicleTypes.add('passenger');
              }
            }),
          ),
          const SizedBox(height: 12),
          _buildMultiSelectionCard(
            'Commercial Vehicles',
            'Vans, trucks, delivery vehicles',
            Icons.local_shipping,
            _selectedVehicleTypes.contains('commercial'),
            () => setState(() {
              if (_selectedVehicleTypes.contains('commercial')) {
                _selectedVehicleTypes.remove('commercial');
              } else {
                _selectedVehicleTypes.add('commercial');
              }
            }),
          ),
          const SizedBox(height: 12),
          _buildMultiSelectionCard(
            'Luxury Vehicles',
            'Premium and luxury vehicles',
            Icons.diamond,
            _selectedVehicleTypes.contains('luxury'),
            () => setState(() {
              if (_selectedVehicleTypes.contains('luxury')) {
                _selectedVehicleTypes.remove('luxury');
              } else {
                _selectedVehicleTypes.add('luxury');
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Vehicle Information (Optional)',
            'Add details about your vehicles - you can do this later',
            Icons.directions_car,
          ),
          const SizedBox(height: 24),
          _buildAddVehicleCard(),
          const SizedBox(height: 20),
          if (_vehicles.isNotEmpty) ...[
            _buildSectionTitle('Your Vehicles'),
            const SizedBox(height: 12),
            ..._vehicles.map((vehicle) => _buildVehicleCard(vehicle)),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Required Documents',
            'Upload necessary documents for verification',
            Icons.folder_open,
          ),
          const SizedBox(height: 24),
          ChangeNotifierProvider(
            create: (_) => HostDocumentService()..loadExistingUploads(),
            child: Consumer<HostDocumentService>(
              builder: (context, docSvc, _) {
                return Column(
                  children: [
                    DocumentUploadTile(
                      title: 'ID (front)',
                      docType: 'id_front',
                      initialUploaded: docSvc.uploadedByType['id_front'] == true,
                      onStateChanged: (v) { setState(() { _docIdFront = v; }); },
                    ),
                    DocumentUploadTile(
                      title: 'ID (back)',
                      docType: 'id_back',
                      initialUploaded: docSvc.uploadedByType['id_back'] == true,
                      onStateChanged: (v) { setState(() { _docIdBack = v; }); },
                    ),
                    DocumentUploadTile(
                      title: 'Driver license',
                      docType: 'license',
                      initialUploaded: docSvc.uploadedByType['license'] == true,
                      onStateChanged: (v) { setState(() { _docLicense = v; }); },
                    ),
                    DocumentUploadTile(
                      title: 'Proof of ownership',
                      docType: 'ownership',
                      initialUploaded: docSvc.uploadedByType['ownership'] == true,
                      onStateChanged: (v) { setState(() { _docOwnership = v; }); },
                    ),
                    DocumentUploadTile(
                      title: 'Selfie (optional)',
                      docType: 'selfie_optional',
                      initialUploaded: docSvc.uploadedByType['selfie_optional'] == true,
                      onStateChanged: (v) { setState(() { _docSelfieOptional = v; }); },
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildTermsCheckbox(),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Review & Submit',
            'Review your information before submitting',
            Icons.check_circle,
          ),
          const SizedBox(height: 24),
          _buildReviewSection('Personal Information', [
            'Name: ${_businessNameController.text}',
            'Phone: ${_phoneController.text}',
            'Address: ${_addressController.text}',
            'Business Type: ${_selectedBusinessType ?? 'Not selected'}',
          ]),
          const SizedBox(height: 20),
          _buildReviewSection('Business Information', [
            'Business Name: ${_businessNameController.text}',
            'Tax ID: ${_taxIdController.text.isNotEmpty ? _taxIdController.text : 'Not provided'}',
            'Bank Account: ${_bankAccountController.text.isNotEmpty ? _bankAccountController.text : 'Not provided'}',
            'Vehicle Types: ${_selectedVehicleTypes.isNotEmpty ? _selectedVehicleTypes.join(', ') : 'Not selected'}',
          ]),
          const SizedBox(height: 20),
          _buildSectionTitle('Application Note'),
          const SizedBox(height: 12),
          _buildInputField(
            'Tell us anything relevant to your request',
            'Why do you want to become a host? (required)',
            Icons.note_alt_outlined,
            controller: _noteController,
            fieldName: 'note',
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          _buildReviewSection('Vehicles', [
            'Number of Vehicles: ${_vehicles.length}',
            ..._vehicles.map((v) => '• ${v['make']} ${v['model']} (${v['year']})'),
          ]),
          const SizedBox(height: 20),
          _buildReviewSection('Documents', [
            if (_selectedBusinessType != 'individual') 'Commercial License: ${_hasCommercialLicense ? '✓' : '✗'}',
            'Vehicle Insurance: ${_hasInsurance ? '✓' : '✗'}',
            'Vehicle Registration: ${_hasVehicleRegistration ? '✓' : '✗'}',
          ]),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: primaryColor,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Application Review',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your application will be reviewed within 2-3 business days. We\'ll contact you via email or phone with the results.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: primaryColor,
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
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
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    final hasError = _fieldErrors.containsKey('phone');
    final errorMessage = hasError ? _fieldErrors['phone'] : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
            border: Border.all(
              color: hasError ? Colors.red : Colors.grey.withValues(alpha: 0.1),
              width: hasError ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: GestureDetector(
                  onTap: _showCountryCodeDialog,
                  child: Row(
                    children: [
                      Text(
                        _selectedCountryCode,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.withValues(alpha: 0.2),
              ),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => _validateField('phone', value),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your contact number',
                    prefixIcon: Icon(
                      Icons.phone_outlined, 
                      color: hasError ? Colors.red : const Color(0xFF593CFB)
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    labelStyle: GoogleFonts.inter(
                      color: hasError ? Colors.red : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError && errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  void _showCountryCodeDialog() {
    final List<Map<String, String>> countryCodes = [
      {'code': '+213', 'country': 'Algeria'},
      {'code': '+33', 'country': 'France'},
      {'code': '+1', 'country': 'USA/Canada'},
      {'code': '+44', 'country': 'UK'},
      {'code': '+49', 'country': 'Germany'},
      {'code': '+39', 'country': 'Italy'},
      {'code': '+34', 'country': 'Spain'},
      {'code': '+31', 'country': 'Netherlands'},
      {'code': '+32', 'country': 'Belgium'},
      {'code': '+41', 'country': 'Switzerland'},
      {'code': '+46', 'country': 'Sweden'},
      {'code': '+47', 'country': 'Norway'},
      {'code': '+45', 'country': 'Denmark'},
      {'code': '+358', 'country': 'Finland'},
      {'code': '+48', 'country': 'Poland'},
      {'code': '+420', 'country': 'Czech Republic'},
      {'code': '+43', 'country': 'Austria'},
      {'code': '+36', 'country': 'Hungary'},
      {'code': '+30', 'country': 'Greece'},
      {'code': '+351', 'country': 'Portugal'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Country Code'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: countryCodes.length,
            itemBuilder: (context, index) {
              final country = countryCodes[index];
              return ListTile(
                title: Text('${country['country']} (${country['code']})'),
                onTap: () {
                  setState(() {
                    _selectedCountryCode = country['code']!;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    IconData icon, {
    TextEditingController? controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? fieldName,
  }) {
    final hasError = fieldName != null && _fieldErrors.containsKey(fieldName);
    final errorMessage = hasError ? _fieldErrors[fieldName] : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
            border: Border.all(
              color: hasError ? Colors.red : Colors.grey.withValues(alpha: 0.1),
              width: hasError ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: fieldName != null ? (value) => _validateField(fieldName, value) : null,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: Icon(
                icon, 
                color: hasError ? Colors.red : const Color(0xFF593CFB)
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              labelStyle: GoogleFonts.inter(
                color: hasError ? Colors.red : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (hasError && errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildMultiSelectionCard(
    String title,
    String subtitle,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF593CFB).withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF593CFB) : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF593CFB) : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
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
                      color: isSelected ? const Color(0xFF593CFB) : Colors.black87,
                    ),
                  ),
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
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? const Color(0xFF593CFB) : Colors.grey[600],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(
    String title,
    String subtitle,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF593CFB).withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF593CFB) : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF593CFB) : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
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
                      color: isSelected ? const Color(0xFF593CFB) : Colors.black87,
                    ),
                  ),
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
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF593CFB),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddVehicleCard() {
    return GestureDetector(
      onTap: _openAddNewCar,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF593CFB).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF593CFB).withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.add_circle,
              size: 48,
              color: Color(0xFF593CFB),
            ),
            const SizedBox(height: 12),
            Text(
              'Add Vehicle',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF593CFB),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add details about your vehicle',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF593CFB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Color(0xFF593CFB),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle['make']} ${vehicle['model']}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${vehicle['year']} • ${vehicle['color']}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeVehicle(vehicle),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
    String title,
    String subtitle,
    IconData icon,
    bool isUploaded,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUploaded ? Colors.green.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded ? Colors.green : Colors.grey.withValues(alpha: 0.2),
            width: isUploaded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isUploaded ? Colors.green : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isUploaded ? Colors.white : Colors.grey[600],
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
                      color: isUploaded ? Colors.green : Colors.black87,
                    ),
                  ),
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
            Icon(
              isUploaded ? Icons.check_circle : Icons.upload,
              color: isUploaded ? Colors.green : Colors.grey[600],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreesToTerms,
          onChanged: (value) => setState(() => _agreesToTerms = value ?? false),
          activeColor: const Color(0xFF593CFB),
        ),
        Expanded(
          child: Text(
            'I agree to the Terms of Service and Privacy Policy',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              item,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF593CFB)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF593CFB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: (_canProceed() && !_isSubmitting && !_hasValidationErrors) ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF593CFB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Submitting...',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      _currentStep == 4 ? 'Submit Application' : 'Next',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _businessNameController.text.isNotEmpty &&
               _phoneController.text.isNotEmpty &&
               _addressController.text.isNotEmpty &&
               _selectedBusinessType != null;
      case 1:
        return _businessNameController.text.isNotEmpty &&
               _selectedVehicleTypes.isNotEmpty;
      case 2:
        return true; // Vehicle step is optional
      case 3:
        // Required uploads: id_front, id_back, license, ownership
        final uploadedRequiredDocs = _docIdFront && _docIdBack && _docLicense && _docOwnership;
        return uploadedRequiredDocs && _agreesToTerms;
      case 4:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    // Clear previous step errors
    _clearStepErrors();
    
    // Validate current step
    _validateCurrentStep();
    
    if (!_hasValidationErrors) {
      if (_currentStep < 4) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _submitApplication();
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors before proceeding'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _previousStep() {
    // Clear errors when going back
    _clearStepErrors();
    
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showAddVehicleDialog() {
    // Controllers for the vehicle form
    final makeController = TextEditingController();
    final modelController = TextEditingController();
    final yearController = TextEditingController();
    final colorController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'SUV';
    String selectedTransmission = 'Automatic';
    String selectedFuelType = 'Petrol';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Vehicle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: 'BMW',
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  border: OutlineInputBorder(),
                ),
                items: _brands.map((brand) {
                  return DropdownMenuItem<String>(
                    value: brand,
                    child: Text(brand),
                  );
                }).toList(),
                onChanged: (value) {
                  // Store selected brand
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(
                  labelText: 'Model (e.g., Camry)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: yearController,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: colorController,
                      decoration: const InputDecoration(
                        labelText: 'Color',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Daily Rate (UK£)',
                  border: OutlineInputBorder(),
                  prefixText: 'UK£',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: ['SUV', 'Sedan', 'Luxury', 'Electric', 'Sports', 'Compact', 'Van', 'Truck']
                    .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) => selectedCategory = value!,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedTransmission,
                      decoration: const InputDecoration(
                        labelText: 'Transmission',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Automatic', 'Manual', 'CVT', 'Semi-Automatic']
                          .map((transmission) => DropdownMenuItem(value: transmission, child: Text(transmission)))
                          .toList(),
                      onChanged: (value) => selectedTransmission = value!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedFuelType,
                      decoration: const InputDecoration(
                        labelText: 'Fuel Type',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Petrol', 'Diesel', 'Electric', 'Hybrid', 'Plug-in Hybrid']
                          .map((fuelType) => DropdownMenuItem(value: fuelType, child: Text(fuelType)))
                          .toList(),
                      onChanged: (value) => selectedFuelType = value!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validate form
              if (makeController.text.isEmpty || 
                  modelController.text.isEmpty || 
                  yearController.text.isEmpty || 
                  colorController.text.isEmpty ||
                  priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Show loading dialog
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Adding vehicle to database...'),
                    ],
                  ),
                ),
              );

              try {
                // Get selected brand and wilaya
                const selectedBrand = 'BMW'; // You can make this dynamic
                const selectedWilaya = 'Alger'; // You can make this dynamic
                
                // Prepare vehicle data for database
                final vehicleData = {
                  'name': '$selectedBrand ${modelController.text} ${yearController.text}',
                  'image': 'assets/images/car1.jpg', // Default image
                  'price': 'UK£${priceController.text} total',
                  'price_per_day': double.tryParse(priceController.text) ?? 0.0,
                  'category': selectedCategory,
                  'location': selectedWilaya,
                  'host_name': _businessNameController.text.isNotEmpty ? _businessNameController.text : 'Host',
                  'host_image': 'assets/images/host.jpg',
                  'host_rating': 4.8,
                  'response_time': '1 hour',
                  'description': descriptionController.text.isNotEmpty ? descriptionController.text : 'Vehicle available for rent',
                  'features': ['GPS', 'Bluetooth', 'Air Conditioning'],
                  'images': ['assets/images/car1.jpg'],
                  'specs': {
                    'engine': 'Standard',
                    'transmission': selectedTransmission,
                    'fuel': selectedFuelType,
                    'seats': '5',
                    'year': yearController.text,
                    'brand': selectedBrand,
                    'model': modelController.text,
                    'color': colorController.text,
                  },
                  'rating': 0.0,
                  'trips': 0,
                  'available': true,
                  'featured': false,
                  'transmission': selectedTransmission,
                  'fuel_type': selectedFuelType,
                  'passengers': 5,
                };

                // Save vehicle to database
                final carService = CarService();
                // Convert Map to Car object
                final car = Car.fromJson(vehicleData);
                final success = await carService.addCar(car);

                // Close loading dialog
                Navigator.of(context).pop();

                if (success == true) {
                  // Add to local list
    setState(() {
      _vehicles.add({
                      'make': makeController.text,
                      'model': modelController.text,
                      'year': yearController.text,
                      'color': colorController.text,
                      'price': priceController.text,
                      'category': selectedCategory,
      });
    });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vehicle added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to add vehicle to database'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                // Close loading dialog
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error adding vehicle: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Add Vehicle'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddNewCar() async {
    // Navigate to AddNewCarScreen and await result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddNewCarScreen()),
    );
    if (!mounted) return;
    if (result != null) {
      // Reflect new car in application summary
      setState(() {
        // Minimal: increment vehicle count; optionally store summary
        _vehicles.add({'source': 'created', 'name': (result as Car).name});
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle added')), 
      );
    }
  }

  void _removeVehicle(Map<String, dynamic> vehicle) {
    setState(() {
      _vehicles.remove(vehicle);
    });
  }

  void _submitApplication() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_noteController.text.trim().isEmpty) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please add an application note'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      // Get current user
      final authService = context.read<AuthService>();
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Log submission attempt
      ErrorLoggingService().logInfo(
        'Become Host application submission started',
        context: 'Become Host Form',
        additionalData: {
          'step': _currentStep,
          'businessType': _selectedBusinessType,
          'vehicleTypes': _selectedVehicleTypes.toList(),
        },
      );

      // Submit minimal host request via HostService
      final hostService = context.read<HostService>();
      final result = await hostService.submitOrResubmitHostRequest(note: _noteController.text.trim());
      if (result.isLeft) {
        throw Exception(result.left.message);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Request submitted'),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Log submission error
      ErrorLoggingService().logError(
        'Become Host application submission failed',
        error: e,
        context: 'Become Host Form',
        additionalData: {
          'step': _currentStep,
          'businessType': _selectedBusinessType,
          'vehicleTypes': _selectedVehicleTypes.toList(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Validation methods
  void _validateField(String fieldName, String value) {
    String? error;
    
    switch (fieldName) {
      case 'businessName':
        if (value.isEmpty) {
          error = 'Business name is required';
        } else if (value.length < 2) {
          error = 'Business name must be at least 2 characters';
        }
        break;
      case 'phone':
        if (value.isEmpty) {
          error = 'Phone number is required';
        } else if (!RegExp(r'^\d{8,15}$').hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
          error = 'Please enter a valid phone number';
        }
        break;
      case 'address':
        if (value.isEmpty) {
          error = 'Address is required';
        } else if (value.length < 10) {
          error = 'Please enter a complete address';
        }
        break;
      case 'taxId':
        if (value.isNotEmpty && value.length < 5) {
          error = 'Tax ID must be at least 5 characters';
        }
        break;
      case 'bankAccount':
        if (value.isNotEmpty && value.length < 8) {
          error = 'Bank account number must be at least 8 characters';
        }
        break;
    }
    
    setState(() {
      if (error != null) {
        _fieldErrors[fieldName] = error;
        // Log validation error
        ErrorLoggingService().logValidationError(
          fieldName,
          error,
          screen: 'Become Host Form',
          formData: {
            'field': fieldName,
            'value': value,
            'step': _currentStep,
          },
        );
      } else {
        _fieldErrors.remove(fieldName);
      }
      _hasValidationErrors = _fieldErrors.isNotEmpty;
    });
  }

  void _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        _validateField('businessName', _businessNameController.text);
        _validateField('phone', _phoneController.text);
        _validateField('address', _addressController.text);
        if (_selectedBusinessType == null) {
          setState(() {
            _fieldErrors['businessType'] = 'Please select a business type';
            _hasValidationErrors = true;
          });
        } else {
          setState(() {
            _fieldErrors.remove('businessType');
            _hasValidationErrors = _fieldErrors.isNotEmpty;
          });
        }
        break;
      case 1:
        _validateField('businessName', _businessNameController.text);
        if (_selectedVehicleTypes.isEmpty) {
          setState(() {
            _fieldErrors['vehicleTypes'] = 'Please select at least one vehicle type';
            _hasValidationErrors = true;
          });
        } else {
          setState(() {
            _fieldErrors.remove('vehicleTypes');
            _hasValidationErrors = _fieldErrors.isNotEmpty;
          });
        }
        break;
      case 3:
        if (!_hasInsurance) {
          setState(() {
            _fieldErrors['insurance'] = 'Vehicle insurance is required';
            _hasValidationErrors = true;
          });
        } else {
          setState(() {
            _fieldErrors.remove('insurance');
            _hasValidationErrors = _fieldErrors.isNotEmpty;
          });
        }
        if (!_hasVehicleRegistration) {
          setState(() {
            _fieldErrors['registration'] = 'Vehicle registration is required';
            _hasValidationErrors = true;
          });
        } else {
          setState(() {
            _fieldErrors.remove('registration');
            _hasValidationErrors = _fieldErrors.isNotEmpty;
          });
        }
        if (_selectedBusinessType != 'individual' && !_hasCommercialLicense) {
          setState(() {
            _fieldErrors['commercialLicense'] = 'Commercial license is required for business/dealership';
            _hasValidationErrors = true;
          });
        } else {
          setState(() {
            _fieldErrors.remove('commercialLicense');
            _hasValidationErrors = _fieldErrors.isNotEmpty;
          });
        }
        if (!_agreesToTerms) {
          setState(() {
            _fieldErrors['terms'] = 'You must agree to the terms and conditions';
            _hasValidationErrors = true;
          });
        } else {
          setState(() {
            _fieldErrors.remove('terms');
            _hasValidationErrors = _fieldErrors.isNotEmpty;
          });
        }
        break;
    }
  }

  void _clearStepErrors() {
    setState(() {
      _fieldErrors.clear();
      _hasValidationErrors = false;
    });
  }
} 