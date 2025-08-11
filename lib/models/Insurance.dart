enum InsuranceType { 
  basic, 
  standard, 
  premium, 
  comprehensive, 
  collision, 
  liability, 
  personal_effects, 
  roadside_assistance 
}

enum InsuranceStatus { 
  active, 
  inactive, 
  expired, 
  cancelled, 
  pending_activation 
}

enum CoverageEvent { 
  collision, 
  theft, 
  vandalism, 
  natural_disaster, 
  mechanical_breakdown, 
  roadside_emergency, 
  personal_injury, 
  property_damage, 
  medical_expenses, 
  legal_expenses 
}

class Insurance {
  final String id;
  final String rentalId;
  final String carId;
  final String userId;
  final String? ownerId;
  final InsuranceType type;
  final InsuranceStatus status;
  final double coverageAmount;
  final double dailyRate;
  final double totalCost;
  final double deductible;
  final List<CoverageEvent> coveredEvents;
  final Map<String, dynamic> coverageDetails;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime? activatedAt;
  final DateTime? cancelledAt;
  final String? policyNumber;
  final String? insuranceProvider;
  final String? providerContact;
  final Map<String, dynamic>? terms;
  final List<String>? exclusions;
  final Map<String, dynamic>? claims;
  final bool isRequired;
  final bool isRefundable;
  final String? notes;
  final Map<String, dynamic>? metadata;

  Insurance({
    required this.id,
    required this.rentalId,
    required this.carId,
    required this.userId,
    this.ownerId,
    required this.type,
    this.status = InsuranceStatus.pending_activation,
    required this.coverageAmount,
    required this.dailyRate,
    required this.totalCost,
    required this.deductible,
    this.coveredEvents = const [],
    this.coverageDetails = const {},
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.activatedAt,
    this.cancelledAt,
    this.policyNumber,
    this.insuranceProvider,
    this.providerContact,
    this.terms,
    this.exclusions,
    this.claims,
    this.isRequired = false,
    this.isRefundable = true,
    this.notes,
    this.metadata,
  });

  factory Insurance.fromJson(Map<String, dynamic> json) {
    return Insurance(
      id: json['id'] ?? '',
      rentalId: json['rentalId'] ?? '',
      carId: json['carId'] ?? '',
      userId: json['userId'] ?? '',
      ownerId: json['ownerId'],
      type: InsuranceType.values.firstWhere(
        (type) => type.toString() == 'InsuranceType.${json['type'] ?? 'basic'}',
        orElse: () => InsuranceType.basic,
      ),
      status: InsuranceStatus.values.firstWhere(
        (status) => status.toString() == 'InsuranceStatus.${json['status'] ?? 'pending_activation'}',
        orElse: () => InsuranceStatus.pending_activation,
      ),
      coverageAmount: (json['coverageAmount'] ?? 0.0).toDouble(),
      dailyRate: (json['dailyRate'] ?? 0.0).toDouble(),
      totalCost: (json['totalCost'] ?? 0.0).toDouble(),
      deductible: (json['deductible'] ?? 0.0).toDouble(),
      coveredEvents: json['coveredEvents'] != null 
          ? json['coveredEvents'].map<CoverageEvent>((event) => 
              CoverageEvent.values.firstWhere(
                (e) => e.toString() == 'CoverageEvent.$event',
                orElse: () => CoverageEvent.collision,
              )).toList()
          : [],
      coverageDetails: Map<String, dynamic>.from(json['coverageDetails'] ?? {}),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      createdAt: DateTime.parse(json['createdAt']),
      activatedAt: json['activatedAt'] != null ? DateTime.parse(json['activatedAt']) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      policyNumber: json['policyNumber'],
      insuranceProvider: json['insuranceProvider'],
      providerContact: json['providerContact'],
      terms: json['terms'] != null 
          ? Map<String, dynamic>.from(json['terms']) 
          : null,
      exclusions: json['exclusions'] != null 
          ? List<String>.from(json['exclusions']) 
          : null,
      claims: json['claims'] != null 
          ? Map<String, dynamic>.from(json['claims']) 
          : null,
      isRequired: json['isRequired'] ?? false,
      isRefundable: json['isRefundable'] ?? true,
      notes: json['notes'],
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rentalId': rentalId,
      'carId': carId,
      'userId': userId,
      'ownerId': ownerId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'coverageAmount': coverageAmount,
      'dailyRate': dailyRate,
      'totalCost': totalCost,
      'deductible': deductible,
      'coveredEvents': coveredEvents.map((event) => event.toString().split('.').last).toList(),
      'coverageDetails': coverageDetails,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'activatedAt': activatedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'policyNumber': policyNumber,
      'insuranceProvider': insuranceProvider,
      'providerContact': providerContact,
      'terms': terms,
      'exclusions': exclusions,
      'claims': claims,
      'isRequired': isRequired,
      'isRefundable': isRefundable,
      'notes': notes,
      'metadata': metadata,
    };
  }

  Insurance copyWith({
    String? id,
    String? rentalId,
    String? carId,
    String? userId,
    String? ownerId,
    InsuranceType? type,
    InsuranceStatus? status,
    double? coverageAmount,
    double? dailyRate,
    double? totalCost,
    double? deductible,
    List<CoverageEvent>? coveredEvents,
    Map<String, dynamic>? coverageDetails,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? activatedAt,
    DateTime? cancelledAt,
    String? policyNumber,
    String? insuranceProvider,
    String? providerContact,
    Map<String, dynamic>? terms,
    List<String>? exclusions,
    Map<String, dynamic>? claims,
    bool? isRequired,
    bool? isRefundable,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return Insurance(
      id: id ?? this.id,
      rentalId: rentalId ?? this.rentalId,
      carId: carId ?? this.carId,
      userId: userId ?? this.userId,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
      status: status ?? this.status,
      coverageAmount: coverageAmount ?? this.coverageAmount,
      dailyRate: dailyRate ?? this.dailyRate,
      totalCost: totalCost ?? this.totalCost,
      deductible: deductible ?? this.deductible,
      coveredEvents: coveredEvents ?? this.coveredEvents,
      coverageDetails: coverageDetails ?? this.coverageDetails,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      activatedAt: activatedAt ?? this.activatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      policyNumber: policyNumber ?? this.policyNumber,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      providerContact: providerContact ?? this.providerContact,
      terms: terms ?? this.terms,
      exclusions: exclusions ?? this.exclusions,
      claims: claims ?? this.claims,
      isRequired: isRequired ?? this.isRequired,
      isRefundable: isRefundable ?? this.isRefundable,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  // Check if insurance is active
  bool get isActive {
    return status == InsuranceStatus.active;
  }

  // Check if insurance is expired
  bool get isExpired {
    final now = DateTime.now();
    return endDate.isBefore(now);
  }

  // Check if insurance is cancelled
  bool get isCancelled {
    return status == InsuranceStatus.cancelled;
  }

  // Check if insurance is pending activation
  bool get isPendingActivation {
    return status == InsuranceStatus.pending_activation;
  }

  // Check if insurance is comprehensive
  bool get isComprehensive {
    return type == InsuranceType.comprehensive;
  }

  // Check if insurance is basic
  bool get isBasic {
    return type == InsuranceType.basic;
  }

  // Check if insurance is premium
  bool get isPremium {
    return type == InsuranceType.premium;
  }

  // Get insurance duration in days
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  // Check if insurance covers specific event
  bool coversEvent(CoverageEvent event) {
    return coveredEvents.contains(event);
  }

  // Check if insurance covers collision
  bool get coversCollision {
    return coversEvent(CoverageEvent.collision);
  }

  // Check if insurance covers theft
  bool get coversTheft {
    return coversEvent(CoverageEvent.theft);
  }

  // Check if insurance covers vandalism
  bool get coversVandalism {
    return coversEvent(CoverageEvent.vandalism);
  }

  // Check if insurance covers roadside assistance
  bool get coversRoadsideAssistance {
    return coversEvent(CoverageEvent.roadside_emergency);
  }

  // Get insurance type display name
  String get typeDisplayName {
    switch (type) {
      case InsuranceType.basic:
        return 'Basic Coverage';
      case InsuranceType.standard:
        return 'Standard Coverage';
      case InsuranceType.premium:
        return 'Premium Coverage';
      case InsuranceType.comprehensive:
        return 'Comprehensive Coverage';
      case InsuranceType.collision:
        return 'Collision Coverage';
      case InsuranceType.liability:
        return 'Liability Coverage';
      case InsuranceType.personal_effects:
        return 'Personal Effects Coverage';
      case InsuranceType.roadside_assistance:
        return 'Roadside Assistance';
    }
  }

  // Get insurance type emoji
  String get typeEmoji {
    switch (type) {
      case InsuranceType.basic:
        return '🛡️';
      case InsuranceType.standard:
        return '🛡️🛡️';
      case InsuranceType.premium:
        return '🛡️🛡️🛡️';
      case InsuranceType.comprehensive:
        return '🛡️🛡️🛡️🛡️';
      case InsuranceType.collision:
        return '💥';
      case InsuranceType.liability:
        return '⚖️';
      case InsuranceType.personal_effects:
        return '💼';
      case InsuranceType.roadside_assistance:
        return '🚗';
    }
  }

  // Get status emoji
  String get statusEmoji {
    switch (status) {
      case InsuranceStatus.active:
        return '✅';
      case InsuranceStatus.inactive:
        return '❌';
      case InsuranceStatus.expired:
        return '⏰';
      case InsuranceStatus.cancelled:
        return '🚫';
      case InsuranceStatus.pending_activation:
        return '⏳';
    }
  }

  // Get display title with type and status
  String get displayTitle {
    return '$typeEmoji $statusEmoji $typeDisplayName';
  }

  // Get formatted coverage amount
  String get formattedCoverageAmount {
    return '\$${coverageAmount.toStringAsFixed(0)}';
  }

  // Get formatted daily rate
  String get formattedDailyRate {
    return '\$${dailyRate.toStringAsFixed(2)}/day';
  }

  // Get formatted total cost
  String get formattedTotalCost {
    return '\$${totalCost.toStringAsFixed(2)}';
  }

  // Get formatted deductible
  String get formattedDeductible {
    return '\$${deductible.toStringAsFixed(0)}';
  }

  // Get insurance summary
  String get summary {
    return '$formattedCoverageAmount coverage • $formattedDeductible deductible • $formattedTotalCost total';
  }

  // Check if insurance has policy number
  bool get hasPolicyNumber {
    return policyNumber != null && policyNumber!.isNotEmpty;
  }

  // Check if insurance has provider
  bool get hasProvider {
    return insuranceProvider != null && insuranceProvider!.isNotEmpty;
  }

  // Check if insurance has claims
  bool get hasClaims {
    return claims != null && claims!.isNotEmpty;
  }

  // Check if insurance has exclusions
  bool get hasExclusions {
    return exclusions != null && exclusions!.isNotEmpty;
  }

  // Get insurance age in days
  int get ageInDays {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  // Check if insurance is recent (within 7 days)
  bool get isRecent {
    return ageInDays <= 7;
  }

  // Get time until expiration in days
  int get daysUntilExpiration {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  // Check if insurance expires soon (within 3 days)
  bool get expiresSoon {
    return daysUntilExpiration <= 3 && daysUntilExpiration > 0;
  }

  // Get insurance value score
  double get valueScore {
    double score = 0.0;
    
    // Coverage amount score
    if (coverageAmount >= 50000) {
      score += 3.0;
    } else if (coverageAmount >= 25000) score += 2.0;
    else if (coverageAmount >= 10000) score += 1.0;
    
    // Coverage events score
    score += coveredEvents.length * 0.5;
    
    // Deductible score (lower is better)
    if (deductible <= 100) {
      score += 2.0;
    } else if (deductible <= 500) score += 1.0;
    
    // Type score
    switch (type) {
      case InsuranceType.comprehensive:
        score += 3.0;
        break;
      case InsuranceType.premium:
        score += 2.0;
        break;
      case InsuranceType.standard:
        score += 1.0;
        break;
      default:
        score += 0.5;
    }
    
    return score;
  }

  // Check if insurance is high value
  bool get isHighValue {
    return valueScore >= 6.0;
  }

  // Get insurance status display
  String get statusDisplay {
    switch (status) {
      case InsuranceStatus.active:
        return 'Active';
      case InsuranceStatus.inactive:
        return 'Inactive';
      case InsuranceStatus.expired:
        return 'Expired';
      case InsuranceStatus.cancelled:
        return 'Cancelled';
      case InsuranceStatus.pending_activation:
        return 'Pending Activation';
    }
  }

  // Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
} 