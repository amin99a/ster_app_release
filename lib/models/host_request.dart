enum HostRequestStatus { 
  pending, 
  approved, 
  rejected,
  under_review
}

class HostRequest {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final String? userImage;
  final String businessName;
  final String? businessType;
  final String? businessAddress;
  final String? taxId;
  final String? bankAccount;
  final Set<String> vehicleTypes;
  final String? insuranceProvider;
  final bool hasCommercialLicense;
  final bool hasInsurance;
  final bool hasVehicleRegistration;
  final int plannedCarsCount;
  final HostRequestStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? reviewedAt;
  final String? reviewerId;
  final String? reviewerName;
  final String? rejectionReason;
  final Map<String, dynamic>? documents;
  final Map<String, dynamic>? additionalInfo;
  final List<Map<String, dynamic>>? plannedVehicles;

  HostRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    this.userImage,
    required this.businessName,
    this.businessType,
    this.businessAddress,
    this.taxId,
    this.bankAccount,
    this.vehicleTypes = const {},
    this.insuranceProvider,
    this.hasCommercialLicense = false,
    this.hasInsurance = false,
    this.hasVehicleRegistration = false,
    this.plannedCarsCount = 0,
    this.status = HostRequestStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.reviewedAt,
    this.reviewerId,
    this.reviewerName,
    this.rejectionReason,
    this.documents,
    this.additionalInfo,
    this.plannedVehicles,
  });

  factory HostRequest.fromJson(Map<String, dynamic> json) {
    return HostRequest(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      userPhone: json['user_phone'],
      userImage: json['user_image'],
      businessName: json['business_name'] ?? '',
      businessType: json['business_type'],
      businessAddress: json['business_address'],
      taxId: json['tax_id'],
      bankAccount: json['bank_account'],
      vehicleTypes: Set<String>.from(json['vehicle_types'] ?? []),
      insuranceProvider: json['insurance_provider'],
      hasCommercialLicense: json['has_commercial_license'] ?? false,
      hasInsurance: json['has_insurance'] ?? false,
      hasVehicleRegistration: json['has_vehicle_registration'] ?? false,
      plannedCarsCount: json['planned_cars_count'] ?? 0,
      status: HostRequestStatus.values.firstWhere(
        (status) => status.toString() == 'HostRequestStatus.${json['status'] ?? 'pending'}',
        orElse: () => HostRequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at']) : null,
      reviewerId: json['reviewer_id'],
      reviewerName: json['reviewer_name'],
      rejectionReason: json['rejection_reason'],
      documents: json['documents'] != null ? Map<String, dynamic>.from(json['documents']) : null,
      additionalInfo: json['additional_info'] != null ? Map<String, dynamic>.from(json['additional_info']) : null,
      plannedVehicles: json['planned_vehicles'] != null 
          ? List<Map<String, dynamic>>.from(json['planned_vehicles']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'user_phone': userPhone,
      'user_image': userImage,
      'business_name': businessName,
      'business_type': businessType,
      'business_address': businessAddress,
      'tax_id': taxId,
      'bank_account': bankAccount,
      'vehicle_types': vehicleTypes.toList(),
      'insurance_provider': insuranceProvider,
      'has_commercial_license': hasCommercialLicense,
      'has_insurance': hasInsurance,
      'has_vehicle_registration': hasVehicleRegistration,
      'planned_cars_count': plannedCarsCount,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewer_id': reviewerId,
      'reviewer_name': reviewerName,
      'rejection_reason': rejectionReason,
      'documents': documents,
      'additional_info': additionalInfo,
      'planned_vehicles': plannedVehicles,
    };
  }

  HostRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userImage,
    String? businessName,
    String? businessType,
    String? businessAddress,
    String? taxId,
    String? bankAccount,
    Set<String>? vehicleTypes,
    String? insuranceProvider,
    bool? hasCommercialLicense,
    bool? hasInsurance,
    bool? hasVehicleRegistration,
    int? plannedCarsCount,
    HostRequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reviewedAt,
    String? reviewerId,
    String? reviewerName,
    String? rejectionReason,
    Map<String, dynamic>? documents,
    Map<String, dynamic>? additionalInfo,
    List<Map<String, dynamic>>? plannedVehicles,
  }) {
    return HostRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      userImage: userImage ?? this.userImage,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      businessAddress: businessAddress ?? this.businessAddress,
      taxId: taxId ?? this.taxId,
      bankAccount: bankAccount ?? this.bankAccount,
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      hasCommercialLicense: hasCommercialLicense ?? this.hasCommercialLicense,
      hasInsurance: hasInsurance ?? this.hasInsurance,
      hasVehicleRegistration: hasVehicleRegistration ?? this.hasVehicleRegistration,
      plannedCarsCount: plannedCarsCount ?? this.plannedCarsCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      documents: documents ?? this.documents,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      plannedVehicles: plannedVehicles ?? this.plannedVehicles,
    );
  }

  // Getters for convenience
  bool get isPending => status == HostRequestStatus.pending;
  bool get isApproved => status == HostRequestStatus.approved;
  bool get isRejected => status == HostRequestStatus.rejected;
  bool get isUnderReview => status == HostRequestStatus.under_review;
  
  String get statusDisplayName {
    switch (status) {
      case HostRequestStatus.pending:
        return 'Pending Review';
      case HostRequestStatus.approved:
        return 'Approved';
      case HostRequestStatus.rejected:
        return 'Rejected';
      case HostRequestStatus.under_review:
        return 'Under Review';
    }
  }

  String get vehicleTypesDisplay {
    if (vehicleTypes.isEmpty) return 'Not specified';
    return vehicleTypes.join(', ');
  }

  bool get hasRequiredDocuments {
    return hasCommercialLicense && hasInsurance && hasVehicleRegistration;
  }

  @override
  String toString() {
    return 'HostRequest(id: $id, userName: $userName, businessName: $businessName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HostRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
