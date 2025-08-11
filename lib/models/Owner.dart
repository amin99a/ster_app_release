enum OwnerType { 
  individual, 
  business, 
  dealership, 
  fleet_company 
}

enum OwnerStatus { 
  active, 
  inactive, 
  suspended, 
  pending_verification, 
  verified 
}

enum VerificationLevel { 
  unverified, 
  basic, 
  enhanced, 
  premium 
}

class Owner {
  final String id;
  final String userId; // Reference to User model
  final String name;
  final String? businessName;
  final String? businessLicense;
  final OwnerType type;
  final OwnerStatus status;
  final VerificationLevel verificationLevel;
  final String email;
  final String phone;
  final String? profileImage;
  final String? coverImage;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String? website;
  final String? description;
  final Map<String, dynamic> businessHours;
  final List<String> acceptedPaymentMethods;
  final Map<String, dynamic> policies;
  final Map<String, dynamic> insurance;
  final List<String> documents; // IDs of uploaded documents
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? verifiedAt;
  final DateTime? lastActiveAt;
  final int totalCars;
  final int activeCars;
  final int totalRentals;
  final int completedRentals;
  final double averageRating;
  final int totalReviews;
  final double totalEarnings;
  final double monthlyEarnings;
  final Map<String, dynamic>? bankDetails;
  final List<String>? socialMediaLinks;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? metadata;

  Owner({
    required this.id,
    required this.userId,
    required this.name,
    this.businessName,
    this.businessLicense,
    required this.type,
    this.status = OwnerStatus.pending_verification,
    this.verificationLevel = VerificationLevel.unverified,
    required this.email,
    required this.phone,
    this.profileImage,
    this.coverImage,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    this.website,
    this.description,
    this.businessHours = const {},
    this.acceptedPaymentMethods = const [],
    this.policies = const {},
    this.insurance = const {},
    this.documents = const [],
    required this.createdAt,
    this.updatedAt,
    this.verifiedAt,
    this.lastActiveAt,
    this.totalCars = 0,
    this.activeCars = 0,
    this.totalRentals = 0,
    this.completedRentals = 0,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.totalEarnings = 0.0,
    this.monthlyEarnings = 0.0,
    this.bankDetails,
    this.socialMediaLinks,
    this.preferences,
    this.metadata,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      businessName: json['businessName'],
      businessLicense: json['businessLicense'],
      type: OwnerType.values.firstWhere(
        (type) => type.toString() == 'OwnerType.${json['type'] ?? 'individual'}',
        orElse: () => OwnerType.individual,
      ),
      status: OwnerStatus.values.firstWhere(
        (status) => status.toString() == 'OwnerStatus.${json['status'] ?? 'pending_verification'}',
        orElse: () => OwnerStatus.pending_verification,
      ),
      verificationLevel: VerificationLevel.values.firstWhere(
        (level) => level.toString() == 'VerificationLevel.${json['verificationLevel'] ?? 'unverified'}',
        orElse: () => VerificationLevel.unverified,
      ),
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'],
      coverImage: json['coverImage'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      website: json['website'],
      description: json['description'],
      businessHours: Map<String, dynamic>.from(json['businessHours'] ?? {}),
      acceptedPaymentMethods: List<String>.from(json['acceptedPaymentMethods'] ?? []),
      policies: Map<String, dynamic>.from(json['policies'] ?? {}),
      insurance: Map<String, dynamic>.from(json['insurance'] ?? {}),
      documents: List<String>.from(json['documents'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : null,
      lastActiveAt: json['lastActiveAt'] != null ? DateTime.parse(json['lastActiveAt']) : null,
      totalCars: json['totalCars'] ?? 0,
      activeCars: json['activeCars'] ?? 0,
      totalRentals: json['totalRentals'] ?? 0,
      completedRentals: json['completedRentals'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      monthlyEarnings: (json['monthlyEarnings'] ?? 0.0).toDouble(),
      bankDetails: json['bankDetails'] != null 
          ? Map<String, dynamic>.from(json['bankDetails']) 
          : null,
      socialMediaLinks: json['socialMediaLinks'] != null 
          ? List<String>.from(json['socialMediaLinks']) 
          : null,
      preferences: json['preferences'] != null 
          ? Map<String, dynamic>.from(json['preferences']) 
          : null,
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'businessName': businessName,
      'businessLicense': businessLicense,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'verificationLevel': verificationLevel.toString().split('.').last,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'coverImage': coverImage,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'website': website,
      'description': description,
      'businessHours': businessHours,
      'acceptedPaymentMethods': acceptedPaymentMethods,
      'policies': policies,
      'insurance': insurance,
      'documents': documents,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'totalCars': totalCars,
      'activeCars': activeCars,
      'totalRentals': totalRentals,
      'completedRentals': completedRentals,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'totalEarnings': totalEarnings,
      'monthlyEarnings': monthlyEarnings,
      'bankDetails': bankDetails,
      'socialMediaLinks': socialMediaLinks,
      'preferences': preferences,
      'metadata': metadata,
    };
  }

  Owner copyWith({
    String? id,
    String? userId,
    String? name,
    String? businessName,
    String? businessLicense,
    OwnerType? type,
    OwnerStatus? status,
    VerificationLevel? verificationLevel,
    String? email,
    String? phone,
    String? profileImage,
    String? coverImage,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? website,
    String? description,
    Map<String, dynamic>? businessHours,
    List<String>? acceptedPaymentMethods,
    Map<String, dynamic>? policies,
    Map<String, dynamic>? insurance,
    List<String>? documents,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? verifiedAt,
    DateTime? lastActiveAt,
    int? totalCars,
    int? activeCars,
    int? totalRentals,
    int? completedRentals,
    double? averageRating,
    int? totalReviews,
    double? totalEarnings,
    double? monthlyEarnings,
    Map<String, dynamic>? bankDetails,
    List<String>? socialMediaLinks,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? metadata,
  }) {
    return Owner(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      businessLicense: businessLicense ?? this.businessLicense,
      type: type ?? this.type,
      status: status ?? this.status,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      coverImage: coverImage ?? this.coverImage,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      website: website ?? this.website,
      description: description ?? this.description,
      businessHours: businessHours ?? this.businessHours,
      acceptedPaymentMethods: acceptedPaymentMethods ?? this.acceptedPaymentMethods,
      policies: policies ?? this.policies,
      insurance: insurance ?? this.insurance,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      totalCars: totalCars ?? this.totalCars,
      activeCars: activeCars ?? this.activeCars,
      totalRentals: totalRentals ?? this.totalRentals,
      completedRentals: completedRentals ?? this.completedRentals,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      bankDetails: bankDetails ?? this.bankDetails,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
      preferences: preferences ?? this.preferences,
      metadata: metadata ?? this.metadata,
    );
  }

  // Check if owner is active
  bool get isActive {
    return status == OwnerStatus.active;
  }

  // Check if owner is verified
  bool get isVerified {
    return verificationLevel != VerificationLevel.unverified;
  }

  // Check if owner is premium verified
  bool get isPremiumVerified {
    return verificationLevel == VerificationLevel.premium;
  }

  // Check if owner is business type
  bool get isBusiness {
    return type == OwnerType.business || 
           type == OwnerType.dealership || 
           type == OwnerType.fleet_company;
  }

  // Check if owner is individual
  bool get isIndividual {
    return type == OwnerType.individual;
  }

  // Check if owner has cars
  bool get hasCars {
    return totalCars > 0;
  }

  // Check if owner has active cars
  bool get hasActiveCars {
    return activeCars > 0;
  }

  // Check if owner is well-rated
  bool get isWellRated {
    return averageRating >= 4.0;
  }

  // Check if owner has completed rentals
  bool get hasCompletedRentals {
    return completedRentals > 0;
  }

  // Check if owner has documents uploaded
  bool get hasDocuments {
    return documents.isNotEmpty;
  }

  // Check if owner has profile image
  bool get hasProfileImage {
    return profileImage != null && profileImage!.isNotEmpty;
  }

  // Check if owner has cover image
  bool get hasCoverImage {
    return coverImage != null && coverImage!.isNotEmpty;
  }

  // Get full address string
  String get fullAddress {
    return '$address, $city, $state $postalCode, $country';
  }

  // Get short address (city, state)
  String get shortAddress {
    return '$city, $state';
  }

  // Get owner type display name
  String get typeDisplayName {
    switch (type) {
      case OwnerType.individual:
        return 'Individual Owner';
      case OwnerType.business:
        return 'Business Owner';
      case OwnerType.dealership:
        return 'Dealership';
      case OwnerType.fleet_company:
        return 'Fleet Company';
    }
  }

  // Get owner type emoji
  String get typeEmoji {
    switch (type) {
      case OwnerType.individual:
        return '👤';
      case OwnerType.business:
        return '🏢';
      case OwnerType.dealership:
        return '🚗';
      case OwnerType.fleet_company:
        return '🚛';
    }
  }

  // Get verification level emoji
  String get verificationEmoji {
    switch (verificationLevel) {
      case VerificationLevel.unverified:
        return '❌';
      case VerificationLevel.basic:
        return '✅';
      case VerificationLevel.enhanced:
        return '✅✅';
      case VerificationLevel.premium:
        return '✅✅✅';
    }
  }

  // Get status emoji
  String get statusEmoji {
    switch (status) {
      case OwnerStatus.active:
        return '🟢';
      case OwnerStatus.inactive:
        return '🔴';
      case OwnerStatus.suspended:
        return '⚠️';
      case OwnerStatus.pending_verification:
        return '⏳';
      case OwnerStatus.verified:
        return '✅';
    }
  }

  // Get display name with type and verification
  String get displayName {
    final displayName = businessName ?? name;
    return '$typeEmoji $verificationEmoji $displayName';
  }

  // Get owner rating display
  String get ratingDisplay {
    if (totalReviews == 0) return 'No reviews';
    return '${averageRating.toStringAsFixed(1)} ($totalReviews reviews)';
  }

  // Get earnings display
  String get earningsDisplay {
    return '\$${totalEarnings.toStringAsFixed(0)} total';
  }

  // Get monthly earnings display
  String get monthlyEarningsDisplay {
    return '\$${monthlyEarnings.toStringAsFixed(0)} this month';
  }

  // Get car availability percentage
  double get carAvailabilityPercentage {
    if (totalCars == 0) return 0.0;
    return (activeCars / totalCars) * 100;
  }

  // Get rental completion rate
  double get rentalCompletionRate {
    if (totalRentals == 0) return 0.0;
    return (completedRentals / totalRentals) * 100;
  }

  // Check if owner is experienced (has many rentals)
  bool get isExperienced {
    return completedRentals >= 10;
  }

  // Check if owner is new (few rentals)
  bool get isNew {
    return completedRentals < 5;
  }

  // Check if owner is popular (high rating and many reviews)
  bool get isPopular {
    return averageRating >= 4.0 && totalReviews >= 20;
  }

  // Check if owner is professional (business with good rating)
  bool get isProfessional {
    return isBusiness && averageRating >= 4.0;
  }

  // Get owner quality score
  double get qualityScore {
    double score = 0.0;
    
    // Rating score
    score += averageRating * 2;
    
    // Review count score
    if (totalReviews >= 50) {
      score += 2.0;
    } else if (totalReviews >= 20) score += 1.0;
    else if (totalReviews >= 5) score += 0.5;
    
    // Verification score
    switch (verificationLevel) {
      case VerificationLevel.premium:
        score += 3.0;
        break;
      case VerificationLevel.enhanced:
        score += 2.0;
        break;
      case VerificationLevel.basic:
        score += 1.0;
        break;
      case VerificationLevel.unverified:
        score += 0.0;
        break;
    }
    
    // Experience score
    if (completedRentals >= 50) {
      score += 2.0;
    } else if (completedRentals >= 20) score += 1.0;
    else if (completedRentals >= 5) score += 0.5;
    
    // Business type score
    if (isBusiness) score += 1.0;
    
    // Document score
    if (hasDocuments) score += 1.0;
    
    return score;
  }

  // Check if owner is high quality
  bool get isHighQuality {
    return qualityScore >= 8.0;
  }

  // Get owner age in days
  int get ageInDays {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  // Check if owner is recent (within 30 days)
  bool get isRecent {
    return ageInDays <= 30;
  }

  // Check if owner is established (more than 6 months)
  bool get isEstablished {
    return ageInDays >= 180;
  }

  // Get last active time ago
  String? get lastActiveTimeAgo {
    if (lastActiveAt == null) return null;
    final now = DateTime.now();
    final difference = now.difference(lastActiveAt!);
    
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

  // Check if owner is online (active within 24 hours)
  bool get isOnline {
    if (lastActiveAt == null) return false;
    final now = DateTime.now();
    return now.difference(lastActiveAt!).inHours <= 24;
  }

  // Get owner status display
  String get statusDisplay {
    switch (status) {
      case OwnerStatus.active:
        return 'Active';
      case OwnerStatus.inactive:
        return 'Inactive';
      case OwnerStatus.suspended:
        return 'Suspended';
      case OwnerStatus.pending_verification:
        return 'Pending Verification';
      case OwnerStatus.verified:
        return 'Verified';
    }
  }

  // Get verification level display
  String get verificationDisplay {
    switch (verificationLevel) {
      case VerificationLevel.unverified:
        return 'Unverified';
      case VerificationLevel.basic:
        return 'Basic Verification';
      case VerificationLevel.enhanced:
        return 'Enhanced Verification';
      case VerificationLevel.premium:
        return 'Premium Verification';
    }
  }
} 