import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/payment_service.dart';
import '../utils/animations.dart';

class AddPaymentCardScreen extends StatefulWidget {
  const AddPaymentCardScreen({super.key});

  @override
  State<AddPaymentCardScreen> createState() => _AddPaymentCardScreenState();
}

class _AddPaymentCardScreenState extends State<AddPaymentCardScreen>
    with TickerProviderStateMixin {
  final PaymentService _paymentService = PaymentService();
  final _formKey = GlobalKey<FormState>();
  
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  
  final _cardNumberFocus = FocusNode();
  final _expiryFocus = FocusNode();
  final _cvvFocus = FocusNode();
  final _holderNameFocus = FocusNode();
  final _nicknameFocus = FocusNode();
  
  String _cardBrand = '';
  bool _isDefault = false;
  bool _isLoading = false;
  
  late AnimationController _fadeController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _cardFlipAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupListeners();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _cardController = AnimationController(
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
    
    _cardFlipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: AppAnimations.smoothCurve,
    ));
    
    _fadeController.forward();
  }

  void _setupListeners() {
    _cardNumberController.addListener(() {
      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      final newBrand = _detectCardBrand(cardNumber);
      if (newBrand != _cardBrand) {
        setState(() {
          _cardBrand = newBrand;
        });
      }
    });
    
    _cvvFocus.addListener(() {
      if (_cvvFocus.hasFocus) {
        _cardController.forward();
      } else {
        _cardController.reverse();
      }
    });
  }

  String _detectCardBrand(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return 'Visa';
    } else if (cardNumber.startsWith(RegExp(r'^5[1-5]')) || 
               cardNumber.startsWith(RegExp(r'^2[2-7]'))) {
      return 'Mastercard';
    } else if (cardNumber.startsWith(RegExp(r'^3[47]'))) {
      return 'American Express';
    } else if (cardNumber.startsWith('6')) {
      return 'Discover';
    } else {
      return '';
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _cardController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderNameController.dispose();
    _nicknameController.dispose();
    _cardNumberFocus.dispose();
    _expiryFocus.dispose();
    _cvvFocus.dispose();
    _holderNameFocus.dispose();
    _nicknameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Custom App Bar
          _buildCustomAppBar(),
          
          // Content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Card Preview
                      AnimatedListItem(
                        index: 0,
                        child: _buildCardPreview(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Card Details Form
                      AnimatedListItem(
                        index: 1,
                        child: _buildCardDetailsForm(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Additional Options
                      AnimatedListItem(
                        index: 2,
                        child: _buildAdditionalOptions(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Add Card Button
                      AnimatedListItem(
                        index: 3,
                        child: _buildAddCardButton(),
                      ),
                    ],
                  ),
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
                  'Add Payment Card',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Securely add a new payment method',
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

  Widget _buildCardPreview() {
    return AnimatedBuilder(
      animation: _cardFlipAnimation,
      builder: (context, child) {
        final isShowingBack = _cardFlipAnimation.value > 0.5;
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_cardFlipAnimation.value * 3.14159),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getCardGradient(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: isShowingBack ? _buildCardBack() : _buildCardFront(),
          ),
        );
      },
    );
  }

  Widget _buildCardFront() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCardIcon(),
                color: Colors.white,
                size: 32,
              ),
              
              const Spacer(),
              
              Text(
                _cardBrand,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Text(
            _formatCardNumber(_cardNumberController.text),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          
          const Spacer(),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARDHOLDER',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      _holderNameController.text.isNotEmpty
                          ? _holderNameController.text.toUpperCase()
                          : 'YOUR NAME',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'EXPIRES',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    _expiryController.text.isNotEmpty
                        ? _expiryController.text
                        : 'MM/YY',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Magnetic stripe
            Container(
              height: 40,
              color: Colors.black,
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                Container(
                  width: 60,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      _cvvController.text.isNotEmpty
                          ? _cvvController.text
                          : 'CVV',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            Text(
              'This card is protected by advanced security features',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDetailsForm() {
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
            'Card Details',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Card Number
          TextFormField(
            controller: _cardNumberController,
            focusNode: _cardNumberFocus,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberInputFormatter(),
            ],
            decoration: InputDecoration(
              labelText: 'Card Number',
              labelStyle: GoogleFonts.inter(),
              hintText: '1234 5678 9012 3456',
              hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
              prefixIcon: Icon(
                _getCardIcon(),
                color: _getCardColor(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF593CFB), width: 2),
              ),
            ),
            style: GoogleFonts.inter(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter card number';
              }
              if (!_paymentService.validateCardNumber(value.replaceAll(' ', ''))) {
                return 'Please enter a valid card number';
              }
              return null;
            },
            onFieldSubmitted: (_) => _expiryFocus.requestFocus(),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              // Expiry Date
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  focusNode: _expiryFocus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ExpiryDateInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Expiry Date',
                    labelStyle: GoogleFonts.inter(),
                    hintText: 'MM/YY',
                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: Colors.grey.shade600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF593CFB), width: 2),
                    ),
                  ),
                  style: GoogleFonts.inter(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter expiry date';
                    }
                    if (value.length != 5) {
                      return 'Please enter MM/YY format';
                    }
                    
                    final parts = value.split('/');
                    final month = int.tryParse(parts[0]);
                    final year = int.tryParse('20${parts[1]}');
                    
                    if (month == null || year == null) {
                      return 'Invalid date format';
                    }
                    
                    if (!_paymentService.validateExpiryDate('$month/$year')) {
                      return 'Card has expired';
                    }
                    
                    return null;
                  },
                  onFieldSubmitted: (_) => _cvvFocus.requestFocus(),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // CVV
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  focusNode: _cvvFocus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    labelStyle: GoogleFonts.inter(),
                    hintText: _cardBrand == 'American Express' ? '1234' : '123',
                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                    prefixIcon: Icon(
                      Icons.security,
                      color: Colors.grey.shade600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF593CFB), width: 2),
                    ),
                  ),
                  style: GoogleFonts.inter(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter CVV';
                    }
                    if (!_paymentService.validateCVV(value)) {
                      return 'Invalid CVV';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _holderNameFocus.requestFocus(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Cardholder Name
          TextFormField(
            controller: _holderNameController,
            focusNode: _holderNameFocus,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              labelStyle: GoogleFonts.inter(),
              hintText: 'John Doe',
              hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.grey.shade600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF593CFB), width: 2),
              ),
            ),
            style: GoogleFonts.inter(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter cardholder name';
              }
              if (value.length < 2) {
                return 'Please enter a valid name';
              }
              return null;
            },
            onFieldSubmitted: (_) => _nicknameFocus.requestFocus(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptions() {
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
            'Additional Options',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Nickname
          TextFormField(
            controller: _nicknameController,
            focusNode: _nicknameFocus,
            decoration: InputDecoration(
              labelText: 'Card Nickname (Optional)',
              labelStyle: GoogleFonts.inter(),
              hintText: 'Personal Card, Business Card, etc.',
              hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
              prefixIcon: Icon(
                Icons.label,
                color: Colors.grey.shade600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF593CFB), width: 2),
              ),
            ),
            style: GoogleFonts.inter(),
          ),
          
          const SizedBox(height: 16),
          
          // Set as Default
          Row(
            children: [
              Checkbox(
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value ?? false),
                activeColor: const Color(0xFF593CFB),
              ),
              
              Expanded(
                child: Text(
                  'Set as default payment method',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedButton(
        onPressed: _isLoading ? null : _addCard,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF593CFB), Color(0xFF7C5CFB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF593CFB).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Add Payment Card',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  List<Color> _getCardGradient() {
    switch (_cardBrand) {
      case 'Visa':
        return [const Color(0xFF1A1F71), const Color(0xFF2E3A87)];
      case 'Mastercard':
        return [const Color(0xFFEB001B), const Color(0xFFFF5F00)];
      case 'American Express':
        return [const Color(0xFF006FCF), const Color(0xFF0099CC)];
      case 'Discover':
        return [const Color(0xFFFF6000), const Color(0xFFFF8C00)];
      default:
        return [const Color(0xFF593CFB), const Color(0xFF7C5CFB)];
    }
  }

  IconData _getCardIcon() {
    return Icons.credit_card;
  }

  Color _getCardColor() {
    switch (_cardBrand) {
      case 'Visa':
        return const Color(0xFF1A1F71);
      case 'Mastercard':
        return const Color(0xFFEB001B);
      case 'American Express':
        return const Color(0xFF006FCF);
      case 'Discover':
        return const Color(0xFFFF6000);
      default:
        return Colors.grey.shade600;
    }
  }

  String _formatCardNumber(String value) {
    final cleanValue = value.replaceAll(' ', '');
    if (cleanValue.isEmpty) return '**** **** **** ****';
    
    final buffer = StringBuffer();
    for (int i = 0; i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      
      if (i < cleanValue.length) {
        buffer.write(cleanValue[i]);
      } else {
        buffer.write('*');
      }
    }
    
    return buffer.toString();
  }

  void _addCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final expiryParts = _expiryController.text.split('/');
      final expMonth = int.parse(expiryParts[0]);
      final expYear = int.parse('20${expiryParts[1]}');

      await _paymentService.addPaymentCard(
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        cardholderName: _holderNameController.text,
        expiryMonth: expMonth.toString(),
        expiryYear: expYear.toString(),
        cvv: _cvvController.text,
        isDefault: _isDefault,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment card added successfully!',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF593CFB),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add payment card: ${e.toString()}',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}