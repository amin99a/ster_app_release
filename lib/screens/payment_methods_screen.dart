import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/payment_service.dart';
import '../utils/animations.dart';
import 'add_payment_card_screen.dart';
import 'payment_history_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen>
    with TickerProviderStateMixin {
  final PaymentService _paymentService = PaymentService();
  
  List<PaymentCard> _cards = [];
  PaymentSettings _settings = PaymentSettings(userId: '');
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _cards = [];
    _settings = PaymentSettings(userId: '');
    // Do not load or add any mock/demo cards
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

  void _initializePaymentService() async {
    await _paymentService.initialize();
    _loadData();
  }

  void _setupListeners() {
    _paymentService.cardsStream.listen((cards) {
      if (mounted) {
        setState(() {
          _cards = cards;
        });
      }
    });
  }

  void _loadData() {
    setState(() {
      _cards = _paymentService.savedCards;
      _settings = _paymentService.settings;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
                child: Column(
                  children: [
                    // Quick Actions
                    AnimatedListItem(
                      index: 0,
                      child: _buildQuickActions(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Payment Methods
                    AnimatedListItem(
                      index: 1,
                      child: _buildPaymentMethodsSection(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Digital Wallets
                    AnimatedListItem(
                      index: 2,
                      child: _buildDigitalWalletsSection(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Settings
                    AnimatedListItem(
                      index: 3,
                      child: _buildSettingsSection(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPaymentMethod,
        backgroundColor: const Color(0xFF593CFB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'Add Card',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Methods',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Manage your payment options',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _openPaymentHistory,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            'Payment History',
            'View all transactions',
            Icons.receipt_long,
            Colors.blue,
            () => _openPaymentHistory(),
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: _buildQuickActionCard(
            'Auto-Pay',
            _settings.enableAutoPay ? 'Enabled' : 'Disabled',
            Icons.autorenew,
            _settings.enableAutoPay ? Colors.green : Colors.grey,
            () => _toggleAutoPay(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AnimatedButton(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildPaymentMethodsSection() {
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
              Icon(
                Icons.credit_card,
                color: const Color(0xFF593CFB),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Saved Cards',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              AnimatedButton(
                onPressed: _addPaymentMethod,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF593CFB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Add New',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF593CFB),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildEmptyCardsState(),
        ],
      ),
    );
  }

  Widget _buildEmptyCardsState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.credit_card_off,
            size: 48,
            color: Colors.grey.shade400,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'No Payment Cards',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Add a payment card to make booking easier',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          AnimatedButton(
            onPressed: _addPaymentMethod,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF593CFB), Color(0xFF7C5CFB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Add Your First Card',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCardItem(PaymentCard card) {
    return AnimatedButton(
      onPressed: () => _showCardOptions(card),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              card.brandColor,
              card.brandColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: card.brandColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  card.brandIcon,
                  color: Colors.white,
                  size: 24,
                ),
                
                const Spacer(),
                
                if (card.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'DEFAULT',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                
                const SizedBox(width: 8),
                
                Icon(
                  Icons.more_horiz,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              '**** **** **** ${card.last4}',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 12),
            
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
                        card.holderName ?? 'N/A',
                        style: GoogleFonts.inter(
                          fontSize: 12,
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
                    Row(
                      children: [
                        Text(
                          card.expiryString,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        
                        if (card.isExpiringSoon)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.warning,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            if (card.nickname != null) ...[
              const SizedBox(height: 8),
              Text(
                card.nickname!,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalWalletsSection() {
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
              Icon(
                Icons.account_balance_wallet,
                color: const Color(0xFF593CFB),
                size: 24,
              ),
              
              const SizedBox(width: 12),
              
              Text(
                'Digital Wallets',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildDigitalWalletItem(
            'Apple Pay',
            'Pay with Touch ID or Face ID',
            Icons.apple,
            Colors.black,
            _settings.enableApplePay,
            (value) => _updateSetting('applePay', value),
          ),
          
          const SizedBox(height: 12),
          
          _buildDigitalWalletItem(
            'Google Pay',
            'Quick and secure payments',
            Icons.g_mobiledata,
            const Color(0xFF4285F4),
            _settings.enableGooglePay,
            (value) => _updateSetting('googlePay', value),
          ),
          
          const SizedBox(height: 12),
          
          _buildDigitalWalletItem(
            'PayPal',
            'Pay with your PayPal account',
            Icons.payment,
            const Color(0xFF003087),
            _settings.enablePayPal,
            (value) => _updateSetting('paypal', value),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalWalletItem(
    String name,
    String description,
    IconData icon,
    Color color,
    bool isEnabled,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnabled ? color.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled ? color.withOpacity(0.2) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: const Color(0xFF593CFB),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
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
              Icon(
                Icons.settings,
                color: const Color(0xFF593CFB),
                size: 24,
              ),
              
              const SizedBox(width: 12),
              
              Text(
                'Payment Settings',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSettingToggle(
            'Save Payment Cards',
            'Store cards for faster checkout',
            Icons.save,
            _settings.saveCards,
            (value) => _updateSetting('saveCards', value),
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingToggle(
            'Require CVV',
            'Always ask for security code',
            Icons.security,
            _settings.requireCVV,
            (value) => _updateSetting('requireCVV', value),
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingToggle(
            'Auto-Pay',
            'Automatically pay for bookings',
            Icons.autorenew,
            _settings.enableAutoPay,
            (value) => _updateSetting('autoPay', value),
          ),
          
          if (_settings.enableAutoPay) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.blue.shade600,
                    size: 16,
                  ),
                  
                  const SizedBox(width: 8),
                  
                  Expanded(
                    child: Text(
                      'Auto-pay for bookings under £${_settings.autoPayThreshold.toInt()}',
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
        ],
      ),
    );
  }

  Widget _buildSettingToggle(
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
        
        const SizedBox(width: 16),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF593CFB),
        ),
      ],
    );
  }

  void _addPaymentMethod() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AddPaymentCardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: AppAnimations.medium,
      ),
    );
  }

  void _openPaymentHistory() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PaymentHistoryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: AppAnimations.medium,
      ),
    );
  }

  void _showCardOptions(PaymentCard card) {
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
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Card info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${card.brand} •••• ${card.last4}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Options
            if (!card.isDefault)
              _buildCardOption('Set as Default', Icons.star, () {
                Navigator.pop(context);
                _setDefaultCard(card);
              }),
            
            _buildCardOption('Edit Nickname', Icons.edit, () {
              Navigator.pop(context);
              _editCardNickname(card);
            }),
            
            _buildCardOption('Delete Card', Icons.delete, () {
              Navigator.pop(context);
              _deleteCard(card);
            }, isDestructive: true),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCardOption(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return AnimatedButton(
      onPressed: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.grey.shade600,
              size: 20,
            ),
            
            const SizedBox(width: 16),
            
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setDefaultCard(PaymentCard card) async {
    try {
      await _paymentService.updatePaymentCard(cardId: card.id, isDefault: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Default card updated',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF593CFB),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update default card',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editCardNickname(PaymentCard card) {
    final controller = TextEditingController(text: card.nickname);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Card Nickname',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter nickname',
            hintStyle: GoogleFonts.inter(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
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
            onPressed: () async {
              try {
                await _paymentService.updatePaymentCard(
                  cardId: card.id,
                  cardholderName: controller.text.trim().isEmpty ? null : controller.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Card nickname updated',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFF593CFB),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to update nickname',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.inter(color: const Color(0xFF593CFB)),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteCard(PaymentCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Payment Card',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this payment card? This action cannot be undone.',
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
            onPressed: () async {
              try {
                await _paymentService.deletePaymentCard(card.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Payment card deleted',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFF593CFB),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to delete card',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _updateSetting(String setting, bool value) async {
    bool success = false;
    
    switch (setting) {
      case 'saveCards':
        success = await _paymentService.updateSettings(saveCards: value);
        break;
      case 'requireCVV':
        success = await _paymentService.updateSettings(requireCVV: value);
        break;
      case 'autoPay':
        success = await _paymentService.updateSettings(enableAutoPay: value);
        break;
      case 'applePay':
        success = await _paymentService.updateSettings(enableApplePay: value);
        break;
      case 'googlePay':
        success = await _paymentService.updateSettings(enableGooglePay: value);
        break;
      case 'paypal':
        success = await _paymentService.updateSettings(enablePayPal: value);
        break;
      default:
        return;
    }
    
    if (success) {
      setState(() {
        // The settings will be updated via the stream
      });
    }
  }

  void _toggleAutoPay() {
    _updateSetting('autoPay', !_settings.enableAutoPay);
  }
}