import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled,
}

enum PaymentMethod {
  creditCard,
  debitCard,
  bankTransfer,
  cash,
  digitalWallet,
}

class PaymentCard {
  final String id;
  final String userId;
  final String cardNumber;
  final String cardholderName;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String cardType;
  final bool isDefault;
  final DateTime createdAt;
  final String? nickname;

  PaymentCard({
    required this.id,
    required this.userId,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.cardType,
    this.isDefault = false,
    required this.createdAt,
    this.nickname,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      cardNumber: json['card_number']?.toString() ?? '',
      cardholderName: json['cardholder_name']?.toString() ?? '',
      expiryMonth: json['expiry_month']?.toString() ?? '',
      expiryYear: json['expiry_year']?.toString() ?? '',
      cvv: json['cvv']?.toString() ?? '',
      cardType: json['card_type']?.toString() ?? '',
      isDefault: json['is_default'] ?? false,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      nickname: json['nickname']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'card_number': cardNumber,
      'cardholder_name': cardholderName,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'cvv': cvv,
      'card_type': cardType,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'nickname': nickname,
    };
  }

  // Computed properties
  String get last4 => cardNumber.length >= 4 ? cardNumber.substring(cardNumber.length - 4) : '';
  
  String get brand => cardType.toLowerCase();
  
  String get expiryString => '$expiryMonth/$expiryYear.substring(2)';
  
  bool get isExpiringSoon {
    final now = DateTime.now();
    final expYear = int.tryParse(expiryYear) ?? now.year;
    final expMonth = int.tryParse(expiryMonth) ?? now.month;
    final expiryDate = DateTime(expYear, expMonth + 1, 0);
    final monthsUntilExpiry = expiryDate.difference(now).inDays / 30;
    return monthsUntilExpiry <= 3;
  }
  
  String get holderName => cardholderName;
  
  IconData get brandIcon {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
      case 'american express':
        return Icons.credit_card;
      case 'discover':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  Color get brandColor {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'amex':
      case 'american express':
        return const Color(0xFF006FCF);
      case 'discover':
        return const Color(0xFFFF6000);
      default:
        return Colors.grey;
    }
  }
}

class PaymentSettings {
  final String userId;
  final bool autoPay;
  final String defaultCurrency;
  final bool notifications;
  final Map<String, dynamic> preferences;
  final bool saveCards;
  final bool enableApplePay;
  final bool enableGooglePay;
  final bool enablePayPal;
  final bool requireCVV;
  final bool enableAutoPay;
  final double autoPayThreshold;

  PaymentSettings({
    required this.userId,
    this.autoPay = false,
    this.defaultCurrency = 'DZD',
    this.notifications = true,
    this.preferences = const {},
    this.saveCards = true,
    this.enableApplePay = true,
    this.enableGooglePay = true,
    this.enablePayPal = true,
    this.requireCVV = true,
    this.enableAutoPay = false,
    this.autoPayThreshold = 50.0,
  });

  factory PaymentSettings.fromJson(Map<String, dynamic> json) {
    return PaymentSettings(
      userId: json['user_id']?.toString() ?? '',
      autoPay: json['auto_pay'] ?? false,
      defaultCurrency: json['default_currency']?.toString() ?? 'DZD',
      notifications: json['notifications'] ?? true,
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
      saveCards: json['save_cards'] ?? true,
      enableApplePay: json['enable_apple_pay'] ?? true,
      enableGooglePay: json['enable_google_pay'] ?? true,
      enablePayPal: json['enable_paypal'] ?? true,
      requireCVV: json['require_cvv'] ?? true,
      enableAutoPay: json['enable_auto_pay'] ?? false,
      autoPayThreshold: (json['auto_pay_threshold'] ?? 50.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'auto_pay': autoPay,
      'default_currency': defaultCurrency,
      'notifications': notifications,
      'preferences': preferences,
      'save_cards': saveCards,
      'enable_apple_pay': enableApplePay,
      'enable_google_pay': enableGooglePay,
      'enable_paypal': enablePayPal,
      'require_cvv': requireCVV,
      'enable_auto_pay': enableAutoPay,
      'auto_pay_threshold': autoPayThreshold,
    };
  }

  PaymentSettings copyWith({
    String? userId,
    bool? autoPay,
    String? defaultCurrency,
    bool? notifications,
    Map<String, dynamic>? preferences,
    bool? saveCards,
    bool? enableApplePay,
    bool? enableGooglePay,
    bool? enablePayPal,
    bool? requireCVV,
    bool? enableAutoPay,
    double? autoPayThreshold,
  }) {
    return PaymentSettings(
      userId: userId ?? this.userId,
      autoPay: autoPay ?? this.autoPay,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      notifications: notifications ?? this.notifications,
      preferences: preferences ?? this.preferences,
      saveCards: saveCards ?? this.saveCards,
      enableApplePay: enableApplePay ?? this.enableApplePay,
      enableGooglePay: enableGooglePay ?? this.enableGooglePay,
      enablePayPal: enablePayPal ?? this.enablePayPal,
      requireCVV: requireCVV ?? this.requireCVV,
      enableAutoPay: enableAutoPay ?? this.enableAutoPay,
      autoPayThreshold: autoPayThreshold ?? this.autoPayThreshold,
    );
  }
}

class Payment {
  final String id;
  final String bookingId;
  final String userId;
  final String? hostId;
  final double amount;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? transactionId;
  final String? currency;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    this.hostId,
    required this.amount,
    required this.status,
    required this.method,
    this.transactionId,
    this.currency = 'DZD',
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    this.metadata,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      hostId: json['host_id']?.toString(),
      amount: (json['amount'] ?? 0.0).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['payment_method'],
        orElse: () => PaymentMethod.creditCard,
      ),
      transactionId: json['transaction_id']?.toString(),
      currency: json['currency']?.toString() ?? 'DZD',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      completedAt: json['completed_at'] != null 
          ? DateTime.tryParse(json['completed_at'].toString()) 
          : null,
      failureReason: json['failure_reason']?.toString(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'host_id': hostId,
      'amount': amount,
      'status': status.name,
      'payment_method': method.name,
      'transaction_id': transactionId,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'failure_reason': failureReason,
      'metadata': metadata,
    };
  }

  // Computed properties for UI
  String get formattedAmount => '${currency == 'DZD' ? 'DA' : '\$'}${amount.toStringAsFixed(2)}';
  
  String get statusDisplayName {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  String get methodDisplayName {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.digitalWallet:
        return 'Digital Wallet';
    }
  }

  String get typeDisplayName => 'Payment';
  
  String? get description => metadata?['description'] as String?;
  
  String? get receiptUrl => metadata?['receipt_url'] as String?;
  
  Color get statusColor {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
      case PaymentStatus.refunded:
        return Colors.purple;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case PaymentStatus.pending:
        return Icons.schedule;
      case PaymentStatus.processing:
        return Icons.sync;
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.cancelled:
        return Icons.cancel;
      case PaymentStatus.refunded:
        return Icons.undo;
    }
  }

  String get timeString {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return '1 day ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool get isSuccessful => status == PaymentStatus.completed;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isPending => status == PaymentStatus.pending || status == PaymentStatus.processing;
  bool get isRefunded => status == PaymentStatus.refunded;
}

class PaymentService extends ChangeNotifier {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // Stream controllers
  final StreamController<List<Payment>> _paymentsController = StreamController<List<Payment>>.broadcast();
  final StreamController<List<PaymentCard>> _cardsController = StreamController<List<PaymentCard>>.broadcast();
  final StreamController<PaymentSettings> _settingsController = StreamController<PaymentSettings>.broadcast();

  // Getters for streams
  Stream<List<Payment>> get paymentsStream => _paymentsController.stream;
  Stream<List<PaymentCard>> get cardsStream => _cardsController.stream;
  Stream<PaymentSettings> get settingsStream => _settingsController.stream;

  // Cached data
  List<Payment> _payments = [];
  List<PaymentCard> _savedCards = [];
  PaymentSettings? _settings;

  // Getters for cached data
  List<Payment> get payments => _payments;
  List<PaymentCard> get savedCards => _savedCards;
  PaymentSettings? get settings => _settings;

  // Initialize the service
  Future<void> initialize() async {
    await _loadPayments();
    await _loadSavedCards();
    await _loadSettings();
  }

  // Load payments
  Future<void> _loadPayments() async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) return;

      final response = await client
          .from('payments')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      _payments = response.map((json) => Payment.fromJson(json)).toList();
      _paymentsController.add(_payments);
    } catch (e) {
      debugPrint('Error loading payments: $e');
    }
  }

  // Load saved cards
  Future<void> _loadSavedCards() async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) return;

      final response = await client
          .from('payment_cards')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      _savedCards = response.map((json) => PaymentCard.fromJson(json)).toList();
      _cardsController.add(_savedCards);
    } catch (e) {
      debugPrint('Error loading saved cards: $e');
    }
  }

  // Load settings
  Future<void> _loadSettings() async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) return;

      final response = await client
          .from('payment_settings')
          .select()
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (response != null) {
        _settings = PaymentSettings.fromJson(response);
        _settingsController.add(_settings!);
      } else {
        // Create default settings
        _settings = PaymentSettings(userId: currentUser.id);
        await _saveSettings(_settings!);
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  // Save settings
  Future<void> _saveSettings(PaymentSettings settings) async {
    try {
      await client
          .from('payment_settings')
          .upsert(settings.toJson());
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  // Validation methods
  bool validateCardNumber(String cardNumber) {
    // Remove spaces and dashes
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check if it's a valid length (13-19 digits)
    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return false;
    }
    
    // Luhn algorithm check
    int sum = 0;
    bool isEven = false;
    
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);
      
      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      
      sum += digit;
      isEven = !isEven;
    }
    
    return sum % 10 == 0;
  }

  bool validateExpiryDate(String expiryDate) {
    // Expected format: MM/YY
    final parts = expiryDate.split('/');
    if (parts.length != 2) return false;
    
    try {
      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]);
      
      if (month < 1 || month > 12) return false;
      
      final now = DateTime.now();
      final currentYear = now.year % 100;
      final currentMonth = now.month;
      
      if (year < currentYear) return false;
      if (year == currentYear && month < currentMonth) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  bool validateCVV(String cvv) {
    // CVV should be 3-4 digits
    return RegExp(r'^\d{3,4}$').hasMatch(cvv);
  }

  // Add payment card
  Future<PaymentCard?> addPaymentCard({
    required String cardNumber,
    required String cardholderName,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    bool isDefault = false,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) return null;

      // Determine card type based on number
      final cardType = _getCardType(cardNumber);

      final cardData = {
        'user_id': currentUser.id,
        'card_number': _maskCardNumber(cardNumber),
        'cardholder_name': cardholderName,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'cvv': cvv,
        'card_type': cardType,
        'is_default': isDefault,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('payment_cards')
          .insert(cardData)
          .select()
          .single();

      final card = PaymentCard.fromJson(response);
      _savedCards.add(card);
      _cardsController.add(_savedCards);
      notifyListeners();

      return card;
    } catch (e) {
      debugPrint('Error adding payment card: $e');
      return null;
    }
  }

  // Update payment card
  Future<PaymentCard?> updatePaymentCard({
    required String cardId,
    String? cardholderName,
    String? expiryMonth,
    String? expiryYear,
    bool? isDefault,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (cardholderName != null) updateData['cardholder_name'] = cardholderName;
      if (expiryMonth != null) updateData['expiry_month'] = expiryMonth;
      if (expiryYear != null) updateData['expiry_year'] = expiryYear;
      if (isDefault != null) updateData['is_default'] = isDefault;

      final response = await client
          .from('payment_cards')
          .update(updateData)
          .eq('id', cardId)
          .select()
          .single();

      final updatedCard = PaymentCard.fromJson(response);
      
      // Update in local list
      final index = _savedCards.indexWhere((card) => card.id == cardId);
      if (index != -1) {
        _savedCards[index] = updatedCard;
        _cardsController.add(_savedCards);
        notifyListeners();
      }

      return updatedCard;
    } catch (e) {
      debugPrint('Error updating payment card: $e');
      return null;
    }
  }

  // Delete payment card
  Future<bool> deletePaymentCard(String cardId) async {
    try {
      await client
          .from('payment_cards')
          .delete()
          .eq('id', cardId);

      // Remove from local list
      _savedCards.removeWhere((card) => card.id == cardId);
      _cardsController.add(_savedCards);
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error deleting payment card: $e');
      return false;
    }
  }

  // Update settings
  Future<bool> updateSettings({
    bool? autoPay,
    String? defaultCurrency,
    bool? notifications,
    Map<String, dynamic>? preferences,
    bool? saveCards,
    bool? enableApplePay,
    bool? enableGooglePay,
    bool? enablePayPal,
    bool? requireCVV,
    bool? enableAutoPay,
    double? autoPayThreshold,
  }) async {
    try {
      if (_settings == null) return false;

      final updatedSettings = PaymentSettings(
        userId: _settings!.userId,
        autoPay: autoPay ?? _settings!.autoPay,
        defaultCurrency: defaultCurrency ?? _settings!.defaultCurrency,
        notifications: notifications ?? _settings!.notifications,
        preferences: preferences ?? _settings!.preferences,
        saveCards: saveCards ?? _settings!.saveCards,
        enableApplePay: enableApplePay ?? _settings!.enableApplePay,
        enableGooglePay: enableGooglePay ?? _settings!.enableGooglePay,
        enablePayPal: enablePayPal ?? _settings!.enablePayPal,
        requireCVV: requireCVV ?? _settings!.requireCVV,
        enableAutoPay: enableAutoPay ?? _settings!.enableAutoPay,
        autoPayThreshold: autoPayThreshold ?? _settings!.autoPayThreshold,
      );

      await _saveSettings(updatedSettings);
      _settings = updatedSettings;
      _settingsController.add(_settings!);
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error updating settings: $e');
      return false;
    }
  }

  // Search payments
  Future<List<Payment>> searchPayments({
    String? query,
    PaymentStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  }) async {
    try {
      var searchQuery = client
          .from('payments')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      if (query != null && query.isNotEmpty) {
        searchQuery = client
            .from('payments')
            .select()
            .ilike('transaction_id', '%$query%')
            .order('created_at', ascending: false)
            .limit(limit);
      }
      if (status != null) {
        searchQuery = client
            .from('payments')
            .select()
            .eq('status', status.name)
            .order('created_at', ascending: false)
            .limit(limit);
      }
      if (startDate != null) {
        searchQuery = client
            .from('payments')
            .select()
            .gte('created_at', startDate.toIso8601String())
            .order('created_at', ascending: false)
            .limit(limit);
      }
      if (endDate != null) {
        searchQuery = client
            .from('payments')
            .select()
            .lte('created_at', endDate.toIso8601String())
            .order('created_at', ascending: false)
            .limit(limit);
      }

      final response = await searchQuery;
      return response.map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error searching payments: $e');
      return [];
    }
  }

  // Retry payment
  Future<Payment?> retryPayment(String paymentId) async {
    try {
      // Get the original payment
      final originalPayment = await client
          .from('payments')
          .select()
          .eq('id', paymentId)
          .single();

      if (originalPayment == null) return null;

      // Create a new payment with the same details
      final retryData = {
        'booking_id': originalPayment['booking_id'],
        'user_id': originalPayment['user_id'],
        'host_id': originalPayment['host_id'],
        'amount': originalPayment['amount'],
        'status': PaymentStatus.processing.name,
        'payment_method': originalPayment['payment_method'],
        'currency': originalPayment['currency'],
        'metadata': {
          ...originalPayment['metadata'] ?? {},
          'retry_of': paymentId,
        },
      };

      final response = await client
          .from('payments')
          .insert(retryData)
          .select()
          .single();

      final payment = Payment.fromJson(response);
      
      // Simulate payment processing
      await _simulatePaymentProcessing(payment);
      
      // Reload payments
      await _loadPayments();

      return payment;
    } catch (e) {
      debugPrint('Error retrying payment: $e');
      return null;
    }
  }

  // Request refund
  Future<Payment?> requestRefund({
    required String paymentId,
    required double refundAmount,
    required String reason,
  }) async {
    try {
      return await processRefund(
        originalPaymentId: paymentId,
        refundAmount: refundAmount,
        reason: reason,
      );
    } catch (e) {
      debugPrint('Error requesting refund: $e');
      return null;
    }
  }

  // Helper methods
  String _getCardType(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    
    if (cleanNumber.startsWith('4')) return 'visa';
    if (cleanNumber.startsWith('5')) return 'mastercard';
    if (cleanNumber.startsWith('34') || cleanNumber.startsWith('37')) return 'amex';
    if (cleanNumber.startsWith('6')) return 'discover';
    
    return 'unknown';
  }

  String _maskCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    if (cleanNumber.length < 4) return cleanNumber;
    
    return '**** **** **** ${cleanNumber.substring(cleanNumber.length - 4)}';
  }

  // Process payment (deposit or full amount)
  Future<Payment?> processPayment({
    required String bookingId,
    required double amount,
    required PaymentMethod method,
    required String userId,
    String? hostId,
    String? transactionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final paymentData = {
        'booking_id': bookingId,
        'user_id': userId,
        'host_id': hostId,
        'amount': amount,
        'status': PaymentStatus.processing.name,
        'payment_method': method.name,
        'transaction_id': transactionId,
        'currency': 'DZD',
        'metadata': metadata,
      };

      final response = await client
          .from('payments')
          .insert(paymentData)
          .select()
          .single();

      final payment = Payment.fromJson(response);

      // Simulate payment processing (replace with actual payment gateway)
      await _simulatePaymentProcessing(payment);

      return payment;
    } catch (e) {
      debugPrint('Error processing payment: $e');
      return null;
    }
  }

  // Simulate payment processing (replace with actual payment gateway)
  Future<void> _simulatePaymentProcessing(Payment payment) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulate 95% success rate
      final isSuccess = DateTime.now().millisecondsSinceEpoch % 100 < 95;

      if (isSuccess) {
        await _updatePaymentStatus(
          paymentId: payment.id,
          status: PaymentStatus.completed,
          transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        );
      } else {
        await _updatePaymentStatus(
          paymentId: payment.id,
          status: PaymentStatus.failed,
          failureReason: 'Payment declined by bank',
        );
      }
    } catch (e) {
      debugPrint('Error in payment processing simulation: $e');
    }
  }

  // Update payment status
  Future<bool> _updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
    String? transactionId,
    String? failureReason,
  }) async {
    try {
      final updateData = {
        'status': status.name,
        if (transactionId != null) 'transaction_id': transactionId,
        if (failureReason != null) 'failure_reason': failureReason,
        if (status == PaymentStatus.completed) 'completed_at': DateTime.now().toIso8601String(),
      };

      await client
          .from('payments')
          .update(updateData)
          .eq('id', paymentId);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating payment status: $e');
      return false;
    }
  }

  // Process deposit payment (20%)
  Future<Payment?> processDepositPayment({
    required String bookingId,
    required double depositAmount,
    required PaymentMethod method,
    required String userId,
    String? hostId,
  }) async {
    return await processPayment(
      bookingId: bookingId,
      amount: depositAmount,
      method: method,
      userId: userId,
      hostId: hostId,
      metadata: {'payment_type': 'deposit'},
    );
  }

  // Process full payment (100%)
  Future<Payment?> processFullPayment({
    required String bookingId,
    required double totalAmount,
    required PaymentMethod method,
    required String userId,
    String? hostId,
  }) async {
    return await processPayment(
      bookingId: bookingId,
      amount: totalAmount,
      method: method,
      userId: userId,
      hostId: hostId,
      metadata: {'payment_type': 'full'},
    );
  }

  // Process remaining payment (80% after deposit)
  Future<Payment?> processRemainingPayment({
    required String bookingId,
    required double remainingAmount,
    required PaymentMethod method,
    required String userId,
    String? hostId,
  }) async {
    return await processPayment(
      bookingId: bookingId,
      amount: remainingAmount,
      method: method,
      userId: userId,
      hostId: hostId,
      metadata: {'payment_type': 'remaining'},
    );
  }

  // Get payments for a booking
  Future<List<Payment>> getBookingPayments(String bookingId) async {
    try {
      final response = await client
          .from('payments')
          .select()
          .eq('booking_id', bookingId)
          .order('created_at', ascending: false);

      return response.map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching booking payments: $e');
      return [];
    }
  }

  // Get user payments
  Future<List<Payment>> getUserPayments({
    String? userId,
    PaymentStatus? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      final targetUserId = userId ?? currentUser?.id;
      
      if (targetUserId == null) {
        return [];
      }

      var query = client
          .from('payments')
          .select()
          .eq('user_id', targetUserId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (status != null) {
        query = client
            .from('payments')
            .select()
            .eq('user_id', targetUserId)
            .eq('status', status.name)
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
      }

      final response = await query;
      return response.map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching user payments: $e');
      return [];
    }
  }

  // Get host payments
  Future<List<Payment>> getHostPayments({
    String? hostId,
    PaymentStatus? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      final targetHostId = hostId ?? currentUser?.id;
      
      if (targetHostId == null) {
        return [];
      }

      var query = client
          .from('payments')
          .select()
          .eq('host_id', targetHostId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (status != null) {
        query = client
            .from('payments')
            .select()
            .eq('host_id', targetHostId)
            .eq('status', status.name)
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
      }

      final response = await query;
      return response.map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching host payments: $e');
      return [];
    }
  }

  // Process refund
  Future<Payment?> processRefund({
    required String originalPaymentId,
    required double refundAmount,
    required String reason,
    String? userId,
  }) async {
    try {
      final refundData = {
        'original_payment_id': originalPaymentId,
        'user_id': userId,
        'amount': -refundAmount, // Negative amount for refund
        'status': PaymentStatus.refunded.name,
        'payment_method': PaymentMethod.bankTransfer.name,
        'currency': 'DZD',
        'failure_reason': reason,
        'metadata': {
          'refund_reason': reason,
          'original_payment_id': originalPaymentId,
        },
      };

      final response = await client
          .from('payments')
          .insert(refundData)
          .select()
          .single();

      return Payment.fromJson(response);
    } catch (e) {
      debugPrint('Error processing refund: $e');
      return null;
    }
  }

  // Calculate payment split between platform and host
  Map<String, double> calculatePaymentSplit({
    required double totalAmount,
    double platformFeePercentage = 0.15, // 15% platform fee
  }) {
    final platformFee = totalAmount * platformFeePercentage;
    final hostAmount = totalAmount - platformFee;

    return {
      'totalAmount': totalAmount,
      'platformFee': platformFee,
      'hostAmount': hostAmount,
      'platformFeePercentage': platformFeePercentage,
    };
  }

  // Get payment statistics
  Future<Map<String, dynamic>> getPaymentStatistics({
    String? userId,
    String? hostId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = client
          .from('payments')
          .select('amount, status, created_at');

      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      if (hostId != null) {
        query = query.eq('host_id', hostId);
      }
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final payments = response.map((json) => Payment.fromJson(json)).toList();

      double totalAmount = 0.0;
      double completedAmount = 0.0;
      double pendingAmount = 0.0;
      int completedCount = 0;
      int pendingCount = 0;
      int failedCount = 0;

      for (final payment in payments) {
        totalAmount += payment.amount;
        
        switch (payment.status) {
          case PaymentStatus.completed:
            completedAmount += payment.amount;
            completedCount++;
            break;
          case PaymentStatus.pending:
          case PaymentStatus.processing:
            pendingAmount += payment.amount;
            pendingCount++;
            break;
          case PaymentStatus.failed:
            failedCount++;
            break;
          default:
            break;
        }
      }

      return {
        'totalAmount': totalAmount,
        'completedAmount': completedAmount,
        'pendingAmount': pendingAmount,
        'completedCount': completedCount,
        'pendingCount': pendingCount,
        'failedCount': failedCount,
        'totalCount': payments.length,
      };
    } catch (e) {
      debugPrint('Error getting payment statistics: $e');
      return {};
    }
  }

  @override
  void dispose() {
    _paymentsController.close();
    _cardsController.close();
    _settingsController.close();
    super.dispose();
  }
}