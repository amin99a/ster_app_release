import 'package:flutter/material.dart';

enum PaymentMethod { 
  creditCard,
  debitCard,
  paypal,
  applePay,
  googlePay,
  bankTransfer,
  digitalWallet,
}

enum PaymentStatus { 
  pending, 
  processing, 
  completed, 
  failed, 
  cancelled, 
  refunded, 
  partialRefund,
}

enum TransactionType {
  booking,
  deposit, 
  refund, 
  fee,
  penalty,
  bonus,
}

class PaymentModel {
  final String id;
  final String bookingId;
  final String userId;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final PaymentStatus status;
  final TransactionType type;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? description;
  final Map<String, dynamic>? metadata;
  final String? receiptUrl;
  final String? failureReason;
  final PaymentBreakdown breakdown;

  const PaymentModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    this.currency = 'GBP',
    required this.method,
    required this.status,
    required this.type,
    required this.createdAt,
    this.completedAt,
    this.description,
    this.metadata,
    this.receiptUrl,
    this.failureReason,
    required this.breakdown,
  });

  PaymentModel copyWith({
    String? id,
    String? bookingId,
    String? userId,
    double? amount,
    String? currency,
    PaymentMethod? method,
    PaymentStatus? status,
    TransactionType? type,
    DateTime? createdAt,
    DateTime? completedAt,
    String? description,
    Map<String, dynamic>? metadata,
    String? receiptUrl,
    String? failureReason,
    PaymentBreakdown? breakdown,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      method: method ?? this.method,
      status: status ?? this.status,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      failureReason: failureReason ?? this.failureReason,
      breakdown: breakdown ?? this.breakdown,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'amount': amount,
      'currency': currency,
      'method': method.name,
      'status': status.name,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'description': description,
      'metadata': metadata,
      'receipt_url': receiptUrl,
      'failure_reason': failureReason,
      'breakdown': breakdown.toMap(),
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] ?? '',
      bookingId: map['booking_id'] ?? '',
      userId: map['user_id'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'GBP',
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == map['method'],
        orElse: () => PaymentMethod.creditCard,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PaymentStatus.pending,
      ),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.booking,
      ),
      createdAt: DateTime.parse(map['created_at']),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
      description: map['description'],
      metadata: map['metadata'],
      receiptUrl: map['receipt_url'],
      failureReason: map['failure_reason'],
      breakdown: PaymentBreakdown.fromMap(map['breakdown'] ?? {}),
    );
  }

  String get methodDisplayName {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.digitalWallet:
        return 'Digital Wallet';
    }
  }

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
      case PaymentStatus.partialRefund:
        return 'Partial Refund';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case TransactionType.booking:
        return 'Booking Payment';
      case TransactionType.deposit:
        return 'Security Deposit';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.fee:
        return 'Service Fee';
      case TransactionType.penalty:
        return 'Penalty Fee';
      case TransactionType.bonus:
        return 'Bonus Credit';
    }
  }

  IconData get methodIcon {
    switch (method) {
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return Icons.credit_card;
      case PaymentMethod.paypal:
        return Icons.payment;
      case PaymentMethod.applePay:
        return Icons.apple;
      case PaymentMethod.googlePay:
        return Icons.g_mobiledata;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.digitalWallet:
        return Icons.account_balance_wallet;
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
      case PaymentStatus.partialRefund:
        return Icons.undo;
    }
  }

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
      case PaymentStatus.partialRefund:
        return Colors.purple;
    }
  }

  String get formattedAmount {
    return '${currency == 'GBP' ? '£' : '\$'}${amount.toStringAsFixed(2)}';
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
  bool get isRefunded => status == PaymentStatus.refunded || status == PaymentStatus.partialRefund;
}

class PaymentBreakdown {
  final double subtotal;
  final double serviceFee;
  final double taxes;
  final double insurance;
  final double deposit;
  final double discount;
  final double total;
  final Map<String, double> additionalFees;

  const PaymentBreakdown({
    required this.subtotal,
    this.serviceFee = 0.0,
    this.taxes = 0.0,
    this.insurance = 0.0,
    this.deposit = 0.0,
    this.discount = 0.0,
    required this.total,
    this.additionalFees = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'subtotal': subtotal,
      'service_fee': serviceFee,
      'taxes': taxes,
      'insurance': insurance,
      'deposit': deposit,
      'discount': discount,
      'total': total,
      'additional_fees': additionalFees,
    };
  }

  factory PaymentBreakdown.fromMap(Map<String, dynamic> map) {
    return PaymentBreakdown(
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      serviceFee: (map['service_fee'] ?? 0.0).toDouble(),
      taxes: (map['taxes'] ?? 0.0).toDouble(),
      insurance: (map['insurance'] ?? 0.0).toDouble(),
      deposit: (map['deposit'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      additionalFees: Map<String, double>.from(map['additional_fees'] ?? {}),
    );
  }
}

class PaymentCardModel {
  final String id;
  final String userId;
  final String last4;
  final String brand;
  final int expMonth;
  final int expYear;
  final String? holderName;
  final bool isDefault;
  final DateTime createdAt;
  final String? nickname;

  const PaymentCardModel({
    required this.id,
    required this.userId,
    required this.last4,
    required this.brand,
    required this.expMonth,
    required this.expYear,
    this.holderName,
    this.isDefault = false,
    required this.createdAt,
    this.nickname,
  });

  PaymentCardModel copyWith({
    String? id,
    String? userId,
    String? last4,
    String? brand,
    int? expMonth,
    int? expYear,
    String? holderName,
    bool? isDefault,
    DateTime? createdAt,
    String? nickname,
  }) {
    return PaymentCardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      last4: last4 ?? this.last4,
      brand: brand ?? this.brand,
      expMonth: expMonth ?? this.expMonth,
      expYear: expYear ?? this.expYear,
      holderName: holderName ?? this.holderName,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      nickname: nickname ?? this.nickname,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'last4': last4,
      'brand': brand,
      'exp_month': expMonth,
      'exp_year': expYear,
      'holder_name': holderName,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'nickname': nickname,
    };
  }

  factory PaymentCardModel.fromMap(Map<String, dynamic> map) {
    return PaymentCardModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      last4: map['last4'] ?? '',
      brand: map['brand'] ?? '',
      expMonth: map['exp_month'] ?? 1,
      expYear: map['exp_year'] ?? 2024,
      holderName: map['holder_name'],
      isDefault: map['is_default'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
      nickname: map['nickname'],
    );
  }

  String get displayName {
    return nickname ?? '$brand •••• $last4';
  }

  String get expiryString {
    return '${expMonth.toString().padLeft(2, '0')}/${expYear.toString().substring(2)}';
  }

  bool get isExpired {
    final now = DateTime.now();
    return expYear < now.year || (expYear == now.year && expMonth < now.month);
  }

  bool get isExpiringSoon {
    final now = DateTime.now();
    final expiryDate = DateTime(expYear, expMonth + 1, 0);
    final monthsUntilExpiry = expiryDate.difference(now).inDays / 30;
    return monthsUntilExpiry <= 3;
  }

  IconData get brandIcon {
    switch (brand.toLowerCase()) {
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
    switch (brand.toLowerCase()) {
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

class PaymentSettingsModel {
  final bool saveCards;
  final bool enableApplePay;
  final bool enableGooglePay;
  final bool enablePayPal;
  final String defaultCurrency;
  final bool requireCVV;
  final bool enableAutoPay;
  final double autoPayThreshold;

  const PaymentSettingsModel({
    this.saveCards = true,
    this.enableApplePay = true,
    this.enableGooglePay = true,
    this.enablePayPal = true,
    this.defaultCurrency = 'GBP',
    this.requireCVV = true,
    this.enableAutoPay = false,
    this.autoPayThreshold = 50.0,
  });

  PaymentSettingsModel copyWith({
    bool? saveCards,
    bool? enableApplePay,
    bool? enableGooglePay,
    bool? enablePayPal,
    String? defaultCurrency,
    bool? requireCVV,
    bool? enableAutoPay,
    double? autoPayThreshold,
  }) {
    return PaymentSettingsModel(
      saveCards: saveCards ?? this.saveCards,
      enableApplePay: enableApplePay ?? this.enableApplePay,
      enableGooglePay: enableGooglePay ?? this.enableGooglePay,
      enablePayPal: enablePayPal ?? this.enablePayPal,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      requireCVV: requireCVV ?? this.requireCVV,
      enableAutoPay: enableAutoPay ?? this.enableAutoPay,
      autoPayThreshold: autoPayThreshold ?? this.autoPayThreshold,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'save_cards': saveCards,
      'enable_apple_pay': enableApplePay,
      'enable_google_pay': enableGooglePay,
      'enable_paypal': enablePayPal,
      'default_currency': defaultCurrency,
      'require_cvv': requireCVV,
      'enable_auto_pay': enableAutoPay,
      'auto_pay_threshold': autoPayThreshold,
    };
  }

  factory PaymentSettingsModel.fromMap(Map<String, dynamic> map) {
    return PaymentSettingsModel(
      saveCards: map['save_cards'] ?? true,
      enableApplePay: map['enable_apple_pay'] ?? true,
      enableGooglePay: map['enable_google_pay'] ?? true,
      enablePayPal: map['enable_paypal'] ?? true,
      defaultCurrency: map['default_currency'] ?? 'GBP',
      requireCVV: map['require_cvv'] ?? true,
      enableAutoPay: map['enable_auto_pay'] ?? false,
      autoPayThreshold: (map['auto_pay_threshold'] ?? 50.0).toDouble(),
    );
  }
}

// Alias for backward compatibility
typedef Payment = PaymentModel;