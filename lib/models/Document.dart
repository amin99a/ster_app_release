enum DocumentType { 
  driver_license, 
  passport, 
  national_id, 
  vehicle_registration, 
  insurance_certificate, 
  vehicle_inspection, 
  business_license, 
  tax_certificate, 
  bank_statement, 
  proof_of_address, 
  proof_of_income, 
  rental_agreement, 
  damage_report, 
  police_report, 
  medical_certificate, 
  other 
}

enum DocumentStatus { 
  pending, 
  under_review, 
  approved, 
  rejected, 
  expired 
}

enum DocumentCategory { 
  personal_identification, 
  vehicle_documents, 
  business_documents, 
  financial_documents, 
  legal_documents, 
  medical_documents, 
  other 
}

class Document {
  final String id;
  final String userId;
  final String fileName;
  final String originalFileName;
  final String fileUrl;
  final String? thumbnailUrl;
  final DocumentType type;
  final DocumentStatus status;
  final DocumentCategory category;
  final String? description;
  final DateTime createdAt;
  final DateTime? uploadedAt;
  final DateTime? reviewedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime? expiresAt;
  final String? reviewedBy;
  final String? rejectionReason;
  final String? approvalNotes;
  final int fileSize;
  final String fileType;
  final String? mimeType;
  final Map<String, dynamic>? metadata;
  final List<String> tags;
  final bool isPublic;
  final bool isRequired;
  final bool isVerified;
  final String? verificationMethod;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final Map<String, dynamic>? extractedData;
  final List<String>? relatedDocuments;
  final String? rentalId;
  final String? carId;
  final Map<String, dynamic>? customFields;

  Document({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.originalFileName,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.type,
    this.status = DocumentStatus.pending,
    required this.category,
    this.description,
    required this.createdAt,
    this.uploadedAt,
    this.reviewedAt,
    this.approvedAt,
    this.rejectedAt,
    this.expiresAt,
    this.reviewedBy,
    this.rejectionReason,
    this.approvalNotes,
    required this.fileSize,
    required this.fileType,
    this.mimeType,
    this.metadata,
    this.tags = const [],
    this.isPublic = false,
    this.isRequired = false,
    this.isVerified = false,
    this.verificationMethod,
    this.verifiedAt,
    this.verifiedBy,
    this.extractedData,
    this.relatedDocuments,
    this.rentalId,
    this.carId,
    this.customFields,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      fileName: json['fileName'] ?? '',
      originalFileName: json['originalFileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      type: DocumentType.values.firstWhere(
        (type) => type.toString() == 'DocumentType.${json['type'] ?? 'other'}',
        orElse: () => DocumentType.other,
      ),
      status: DocumentStatus.values.firstWhere(
        (status) => status.toString() == 'DocumentStatus.${json['status'] ?? 'pending'}',
        orElse: () => DocumentStatus.pending,
      ),
      category: DocumentCategory.values.firstWhere(
        (category) => category.toString() == 'DocumentCategory.${json['category'] ?? 'other'}',
        orElse: () => DocumentCategory.other,
      ),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      uploadedAt: json['uploadedAt'] != null ? DateTime.parse(json['uploadedAt']) : null,
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      rejectedAt: json['rejectedAt'] != null ? DateTime.parse(json['rejectedAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      reviewedBy: json['reviewedBy'],
      rejectionReason: json['rejectionReason'],
      approvalNotes: json['approvalNotes'],
      fileSize: json['fileSize'] ?? 0,
      fileType: json['fileType'] ?? '',
      mimeType: json['mimeType'],
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      isPublic: json['isPublic'] ?? false,
      isRequired: json['isRequired'] ?? false,
      isVerified: json['isVerified'] ?? false,
      verificationMethod: json['verificationMethod'],
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : null,
      verifiedBy: json['verifiedBy'],
      extractedData: json['extractedData'] != null 
          ? Map<String, dynamic>.from(json['extractedData']) 
          : null,
      relatedDocuments: json['relatedDocuments'] != null 
          ? List<String>.from(json['relatedDocuments']) 
          : null,
      rentalId: json['rentalId'],
      carId: json['carId'],
      customFields: json['customFields'] != null 
          ? Map<String, dynamic>.from(json['customFields']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fileName': fileName,
      'originalFileName': originalFileName,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'category': category.toString().split('.').last,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'uploadedAt': uploadedAt?.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectedAt': rejectedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'rejectionReason': rejectionReason,
      'approvalNotes': approvalNotes,
      'fileSize': fileSize,
      'fileType': fileType,
      'mimeType': mimeType,
      'metadata': metadata,
      'tags': tags,
      'isPublic': isPublic,
      'isRequired': isRequired,
      'isVerified': isVerified,
      'verificationMethod': verificationMethod,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'verifiedBy': verifiedBy,
      'extractedData': extractedData,
      'relatedDocuments': relatedDocuments,
      'rentalId': rentalId,
      'carId': carId,
      'customFields': customFields,
    };
  }

  Document copyWith({
    String? id,
    String? userId,
    String? fileName,
    String? originalFileName,
    String? fileUrl,
    String? thumbnailUrl,
    DocumentType? type,
    DocumentStatus? status,
    DocumentCategory? category,
    String? description,
    DateTime? createdAt,
    DateTime? uploadedAt,
    DateTime? reviewedAt,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    DateTime? expiresAt,
    String? reviewedBy,
    String? rejectionReason,
    String? approvalNotes,
    int? fileSize,
    String? fileType,
    String? mimeType,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    bool? isPublic,
    bool? isRequired,
    bool? isVerified,
    String? verificationMethod,
    DateTime? verifiedAt,
    String? verifiedBy,
    Map<String, dynamic>? extractedData,
    List<String>? relatedDocuments,
    String? rentalId,
    String? carId,
    Map<String, dynamic>? customFields,
  }) {
    return Document(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fileName: fileName ?? this.fileName,
      originalFileName: originalFileName ?? this.originalFileName,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      type: type ?? this.type,
      status: status ?? this.status,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvalNotes: approvalNotes ?? this.approvalNotes,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      mimeType: mimeType ?? this.mimeType,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      isRequired: isRequired ?? this.isRequired,
      isVerified: isVerified ?? this.isVerified,
      verificationMethod: verificationMethod ?? this.verificationMethod,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      extractedData: extractedData ?? this.extractedData,
      relatedDocuments: relatedDocuments ?? this.relatedDocuments,
      rentalId: rentalId ?? this.rentalId,
      carId: carId ?? this.carId,
      customFields: customFields ?? this.customFields,
    );
  }

  // Check if document is pending
  bool get isPending {
    return status == DocumentStatus.pending;
  }

  // Check if document is under review
  bool get isUnderReview {
    return status == DocumentStatus.under_review;
  }

  // Check if document is approved
  bool get isApproved {
    return status == DocumentStatus.approved;
  }

  // Check if document is rejected
  bool get isRejected {
    return status == DocumentStatus.rejected;
  }

  // Check if document is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // Check if document is verified
  bool get isVerifiedStatus {
    return isVerified && verifiedAt != null;
  }

  // Check if document has thumbnail
  bool get hasThumbnail {
    return thumbnailUrl != null && thumbnailUrl!.isNotEmpty;
  }

  // Check if document has description
  bool get hasDescription {
    return description != null && description!.isNotEmpty;
  }

  // Check if document has rejection reason
  bool get hasRejectionReason {
    return rejectionReason != null && rejectionReason!.isNotEmpty;
  }

  // Check if document has approval notes
  bool get hasApprovalNotes {
    return approvalNotes != null && approvalNotes!.isNotEmpty;
  }

  // Check if document has extracted data
  bool get hasExtractedData {
    return extractedData != null && extractedData!.isNotEmpty;
  }

  // Check if document has related documents
  bool get hasRelatedDocuments {
    return relatedDocuments != null && relatedDocuments!.isNotEmpty;
  }

  // Check if document is rental related
  bool get isRentalRelated {
    return rentalId != null && rentalId!.isNotEmpty;
  }

  // Check if document is car related
  bool get isCarRelated {
    return carId != null && carId!.isNotEmpty;
  }

  // Get document type display name
  String get typeDisplayName {
    switch (type) {
      case DocumentType.driver_license:
        return 'Driver License';
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.national_id:
        return 'National ID';
      case DocumentType.vehicle_registration:
        return 'Vehicle Registration';
      case DocumentType.insurance_certificate:
        return 'Insurance Certificate';
      case DocumentType.vehicle_inspection:
        return 'Vehicle Inspection';
      case DocumentType.business_license:
        return 'Business License';
      case DocumentType.tax_certificate:
        return 'Tax Certificate';
      case DocumentType.bank_statement:
        return 'Bank Statement';
      case DocumentType.proof_of_address:
        return 'Proof of Address';
      case DocumentType.proof_of_income:
        return 'Proof of Income';
      case DocumentType.rental_agreement:
        return 'Rental Agreement';
      case DocumentType.damage_report:
        return 'Damage Report';
      case DocumentType.police_report:
        return 'Police Report';
      case DocumentType.medical_certificate:
        return 'Medical Certificate';
      case DocumentType.other:
        return 'Other Document';
    }
  }

  // Get document type emoji
  String get typeEmoji {
    switch (type) {
      case DocumentType.driver_license:
        return '🚗';
      case DocumentType.passport:
        return '📘';
      case DocumentType.national_id:
        return '🆔';
      case DocumentType.vehicle_registration:
        return '📋';
      case DocumentType.insurance_certificate:
        return '🛡️';
      case DocumentType.vehicle_inspection:
        return '🔧';
      case DocumentType.business_license:
        return '🏢';
      case DocumentType.tax_certificate:
        return '💰';
      case DocumentType.bank_statement:
        return '🏦';
      case DocumentType.proof_of_address:
        return '🏠';
      case DocumentType.proof_of_income:
        return '💵';
      case DocumentType.rental_agreement:
        return '📄';
      case DocumentType.damage_report:
        return '💥';
      case DocumentType.police_report:
        return '👮';
      case DocumentType.medical_certificate:
        return '🏥';
      case DocumentType.other:
        return '📎';
    }
  }

  // Get status emoji
  String get statusEmoji {
    switch (status) {
      case DocumentStatus.pending:
        return '⏳';
      case DocumentStatus.under_review:
        return '🔍';
      case DocumentStatus.approved:
        return '✅';
      case DocumentStatus.rejected:
        return '❌';
      case DocumentStatus.expired:
        return '⏰';
    }
  }

  // Get display title with type and status
  String get displayTitle {
    return '$typeEmoji $statusEmoji $typeDisplayName';
  }

  // Get formatted file size
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Get document summary
  String get summary {
    final size = formattedFileSize;
    final status = statusDisplayName;
    return '$size • $status';
  }

  // Get document age in days
  int get ageInDays {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  // Check if document is recent (within 7 days)
  bool get isRecent {
    return ageInDays <= 7;
  }

  // Check if document is old (more than 30 days)
  bool get isOld {
    return ageInDays >= 30;
  }

  // Get time until expiration in days
  int? get daysUntilExpiration {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return 0;
    return expiresAt!.difference(now).inDays;
  }

  // Check if document expires soon (within 30 days)
  bool get expiresSoon {
    final days = daysUntilExpiration;
    return days != null && days <= 30 && days > 0;
  }

  // Get review time in days
  int? get reviewTimeDays {
    if (reviewedAt == null) return null;
    return reviewedAt!.difference(createdAt).inDays;
  }

  // Get approval time in days
  int? get approvalTimeDays {
    if (approvedAt == null) return null;
    return approvedAt!.difference(createdAt).inDays;
  }

  // Get document status display name
  String get statusDisplayName {
    switch (status) {
      case DocumentStatus.pending:
        return 'Pending';
      case DocumentStatus.under_review:
        return 'Under Review';
      case DocumentStatus.approved:
        return 'Approved';
      case DocumentStatus.rejected:
        return 'Rejected';
      case DocumentStatus.expired:
        return 'Expired';
    }
  }

  // Get category display name
  String get categoryDisplayName {
    switch (category) {
      case DocumentCategory.personal_identification:
        return 'Personal Identification';
      case DocumentCategory.vehicle_documents:
        return 'Vehicle Documents';
      case DocumentCategory.business_documents:
        return 'Business Documents';
      case DocumentCategory.financial_documents:
        return 'Financial Documents';
      case DocumentCategory.legal_documents:
        return 'Legal Documents';
      case DocumentCategory.medical_documents:
        return 'Medical Documents';
      case DocumentCategory.other:
        return 'Other';
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

  // Check if document can be reviewed
  bool get canBeReviewed {
    return status == DocumentStatus.pending || status == DocumentStatus.under_review;
  }

  // Check if document can be approved
  bool get canBeApproved {
    return status == DocumentStatus.under_review;
  }

  // Check if document can be rejected
  bool get canBeRejected {
    return status == DocumentStatus.under_review;
  }

  // Get document quality score
  double get qualityScore {
    double score = 0.0;
    
    // File size score (reasonable size)
    if (fileSize >= 10000 && fileSize <= 10000000) score += 1.0;
    
    // File type score
    if (fileType.toLowerCase() == 'pdf') {
      score += 2.0;
    } else if (['jpg', 'jpeg', 'png'].contains(fileType.toLowerCase())) score += 1.5;
    
    // Status score
    if (isApproved) {
      score += 3.0;
    } else if (isUnderReview) score += 1.0;
    
    // Verification score
    if (isVerified) score += 2.0;
    
    // Required score
    if (isRequired) score += 1.0;
    
    // Description score
    if (hasDescription) score += 0.5;
    
    // Tags score
    score += tags.length * 0.2;
    
    return score;
  }

  // Check if document is high quality
  bool get isHighQuality {
    return qualityScore >= 6.0;
  }
} 