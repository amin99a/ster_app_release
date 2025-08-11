enum DisputeType { 
  damage_claim, 
  payment_dispute, 
  service_quality, 
  cancellation_fee, 
  late_return, 
  vehicle_condition, 
  insurance_claim, 
  communication_issue, 
  fraud_allegation, 
  safety_concern, 
  other 
}

enum DisputeStatus { 
  opened, 
  under_review, 
  evidence_required, 
  mediation, 
  resolved, 
  closed, 
  escalated 
}

enum DisputePriority { 
  low, 
  normal, 
  high, 
  urgent 
}

enum DisputeResolution { 
  resolved_in_favor_renter, 
  resolved_in_favor_owner, 
  partial_refund, 
  full_refund, 
  no_action, 
  mediation_agreement, 
  escalated_to_legal 
}

class Dispute {
  final String id;
  final String rentalId;
  final String carId;
  final String initiatorId;
  final String initiatorName;
  final String respondentId;
  final String respondentName;
  final DisputeType type;
  final DisputeStatus status;
  final DisputePriority priority;
  final String title;
  final String description;
  final double claimedAmount;
  final String? currency;
  final List<String> evidence;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final String? assignedTo;
  final String? resolvedBy;
  final DisputeResolution? resolution;
  final String? resolutionNotes;
  final double? resolvedAmount;
  final List<Map<String, dynamic>> messages;
  final List<Map<String, dynamic>> timeline;
  final Map<String, dynamic>? metadata;
  final bool isUrgent;
  final bool isEscalated;
  final String? escalationReason;
  final DateTime? escalatedAt;
  final String? escalatedBy;
  final List<String>? tags;
  final Map<String, dynamic>? customFields;

  Dispute({
    required this.id,
    required this.rentalId,
    required this.carId,
    required this.initiatorId,
    required this.initiatorName,
    required this.respondentId,
    required this.respondentName,
    required this.type,
    this.status = DisputeStatus.opened,
    this.priority = DisputePriority.normal,
    required this.title,
    required this.description,
    this.claimedAmount = 0.0,
    this.currency,
    this.evidence = const [],
    this.attachments = const [],
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.closedAt,
    this.assignedTo,
    this.resolvedBy,
    this.resolution,
    this.resolutionNotes,
    this.resolvedAmount,
    this.messages = const [],
    this.timeline = const [],
    this.metadata,
    this.isUrgent = false,
    this.isEscalated = false,
    this.escalationReason,
    this.escalatedAt,
    this.escalatedBy,
    this.tags,
    this.customFields,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(
      id: json['id'] ?? '',
      rentalId: json['rentalId'] ?? '',
      carId: json['carId'] ?? '',
      initiatorId: json['initiatorId'] ?? '',
      initiatorName: json['initiatorName'] ?? '',
      respondentId: json['respondentId'] ?? '',
      respondentName: json['respondentName'] ?? '',
      type: DisputeType.values.firstWhere(
        (type) => type.toString() == 'DisputeType.${json['type'] ?? 'other'}',
        orElse: () => DisputeType.other,
      ),
      status: DisputeStatus.values.firstWhere(
        (status) => status.toString() == 'DisputeStatus.${json['status'] ?? 'opened'}',
        orElse: () => DisputeStatus.opened,
      ),
      priority: DisputePriority.values.firstWhere(
        (priority) => priority.toString() == 'DisputePriority.${json['priority'] ?? 'normal'}',
        orElse: () => DisputePriority.normal,
      ),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      claimedAmount: (json['claimedAmount'] ?? 0.0).toDouble(),
      currency: json['currency'],
      evidence: List<String>.from(json['evidence'] ?? []),
      attachments: List<String>.from(json['attachments'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      closedAt: json['closedAt'] != null ? DateTime.parse(json['closedAt']) : null,
      assignedTo: json['assignedTo'],
      resolvedBy: json['resolvedBy'],
      resolution: json['resolution'] != null 
          ? DisputeResolution.values.firstWhere(
              (res) => res.toString() == 'DisputeResolution.${json['resolution']}',
              orElse: () => DisputeResolution.no_action,
            )
          : null,
      resolutionNotes: json['resolutionNotes'],
      resolvedAmount: json['resolvedAmount'] != null 
          ? (json['resolvedAmount'] as num).toDouble() 
          : null,
      messages: json['messages'] != null 
          ? List<Map<String, dynamic>>.from(json['messages']) 
          : [],
      timeline: json['timeline'] != null 
          ? List<Map<String, dynamic>>.from(json['timeline']) 
          : [],
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : null,
      isUrgent: json['isUrgent'] ?? false,
      isEscalated: json['isEscalated'] ?? false,
      escalationReason: json['escalationReason'],
      escalatedAt: json['escalatedAt'] != null ? DateTime.parse(json['escalatedAt']) : null,
      escalatedBy: json['escalatedBy'],
      tags: json['tags'] != null 
          ? List<String>.from(json['tags']) 
          : null,
      customFields: json['customFields'] != null 
          ? Map<String, dynamic>.from(json['customFields']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rentalId': rentalId,
      'carId': carId,
      'initiatorId': initiatorId,
      'initiatorName': initiatorName,
      'respondentId': respondentId,
      'respondentName': respondentName,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'title': title,
      'description': description,
      'claimedAmount': claimedAmount,
      'currency': currency,
      'evidence': evidence,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'assignedTo': assignedTo,
      'resolvedBy': resolvedBy,
      'resolution': resolution?.toString().split('.').last,
      'resolutionNotes': resolutionNotes,
      'resolvedAmount': resolvedAmount,
      'messages': messages,
      'timeline': timeline,
      'metadata': metadata,
      'isUrgent': isUrgent,
      'isEscalated': isEscalated,
      'escalationReason': escalationReason,
      'escalatedAt': escalatedAt?.toIso8601String(),
      'escalatedBy': escalatedBy,
      'tags': tags,
      'customFields': customFields,
    };
  }

  Dispute copyWith({
    String? id,
    String? rentalId,
    String? carId,
    String? initiatorId,
    String? initiatorName,
    String? respondentId,
    String? respondentName,
    DisputeType? type,
    DisputeStatus? status,
    DisputePriority? priority,
    String? title,
    String? description,
    double? claimedAmount,
    String? currency,
    List<String>? evidence,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    DateTime? closedAt,
    String? assignedTo,
    String? resolvedBy,
    DisputeResolution? resolution,
    String? resolutionNotes,
    double? resolvedAmount,
    List<Map<String, dynamic>>? messages,
    List<Map<String, dynamic>>? timeline,
    Map<String, dynamic>? metadata,
    bool? isUrgent,
    bool? isEscalated,
    String? escalationReason,
    DateTime? escalatedAt,
    String? escalatedBy,
    List<String>? tags,
    Map<String, dynamic>? customFields,
  }) {
    return Dispute(
      id: id ?? this.id,
      rentalId: rentalId ?? this.rentalId,
      carId: carId ?? this.carId,
      initiatorId: initiatorId ?? this.initiatorId,
      initiatorName: initiatorName ?? this.initiatorName,
      respondentId: respondentId ?? this.respondentId,
      respondentName: respondentName ?? this.respondentName,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      claimedAmount: claimedAmount ?? this.claimedAmount,
      currency: currency ?? this.currency,
      evidence: evidence ?? this.evidence,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      closedAt: closedAt ?? this.closedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolution: resolution ?? this.resolution,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      resolvedAmount: resolvedAmount ?? this.resolvedAmount,
      messages: messages ?? this.messages,
      timeline: timeline ?? this.timeline,
      metadata: metadata ?? this.metadata,
      isUrgent: isUrgent ?? this.isUrgent,
      isEscalated: isEscalated ?? this.isEscalated,
      escalationReason: escalationReason ?? this.escalationReason,
      escalatedAt: escalatedAt ?? this.escalatedAt,
      escalatedBy: escalatedBy ?? this.escalatedBy,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
    );
  }

  // Check if dispute is opened
  bool get isOpened {
    return status == DisputeStatus.opened;
  }

  // Check if dispute is under review
  bool get isUnderReview {
    return status == DisputeStatus.under_review;
  }

  // Check if dispute requires evidence
  bool get requiresEvidence {
    return status == DisputeStatus.evidence_required;
  }

  // Check if dispute is in mediation
  bool get isInMediation {
    return status == DisputeStatus.mediation;
  }

  // Check if dispute is resolved
  bool get isResolved {
    return status == DisputeStatus.resolved;
  }

  // Check if dispute is closed
  bool get isClosed {
    return status == DisputeStatus.closed;
  }

  // Check if dispute is escalated
  bool get isEscalatedStatus {
    return status == DisputeStatus.escalated;
  }

  // Check if dispute is urgent
  bool get isUrgentStatus {
    return priority == DisputePriority.urgent || isUrgent;
  }

  // Check if dispute is high priority
  bool get isHighPriority {
    return priority == DisputePriority.high || priority == DisputePriority.urgent;
  }

  // Check if dispute has evidence
  bool get hasEvidence {
    return evidence.isNotEmpty;
  }

  // Check if dispute has attachments
  bool get hasAttachments {
    return attachments.isNotEmpty;
  }

  // Check if dispute has messages
  bool get hasMessages {
    return messages.isNotEmpty;
  }

  // Check if dispute has timeline
  bool get hasTimeline {
    return timeline.isNotEmpty;
  }

  // Check if dispute has resolution
  bool get hasResolution {
    return resolution != null;
  }

  // Check if dispute has resolved amount
  bool get hasResolvedAmount {
    return resolvedAmount != null && resolvedAmount! > 0;
  }

  // Check if dispute has resolution notes
  bool get hasResolutionNotes {
    return resolutionNotes != null && resolutionNotes!.isNotEmpty;
  }

  // Check if dispute is assigned
  bool get isAssigned {
    return assignedTo != null && assignedTo!.isNotEmpty;
  }

  // Check if dispute is damage related
  bool get isDamageRelated {
    return type == DisputeType.damage_claim || type == DisputeType.vehicle_condition;
  }

  // Check if dispute is payment related
  bool get isPaymentRelated {
    return type == DisputeType.payment_dispute || type == DisputeType.cancellation_fee;
  }

  // Check if dispute is service related
  bool get isServiceRelated {
    return type == DisputeType.service_quality || type == DisputeType.communication_issue;
  }

  // Get dispute type display name
  String get typeDisplayName {
    switch (type) {
      case DisputeType.damage_claim:
        return 'Damage Claim';
      case DisputeType.payment_dispute:
        return 'Payment Dispute';
      case DisputeType.service_quality:
        return 'Service Quality';
      case DisputeType.cancellation_fee:
        return 'Cancellation Fee';
      case DisputeType.late_return:
        return 'Late Return';
      case DisputeType.vehicle_condition:
        return 'Vehicle Condition';
      case DisputeType.insurance_claim:
        return 'Insurance Claim';
      case DisputeType.communication_issue:
        return 'Communication Issue';
      case DisputeType.fraud_allegation:
        return 'Fraud Allegation';
      case DisputeType.safety_concern:
        return 'Safety Concern';
      case DisputeType.other:
        return 'Other';
    }
  }

  // Get dispute type emoji
  String get typeEmoji {
    switch (type) {
      case DisputeType.damage_claim:
        return '💥';
      case DisputeType.payment_dispute:
        return '💳';
      case DisputeType.service_quality:
        return '⭐';
      case DisputeType.cancellation_fee:
        return '❌';
      case DisputeType.late_return:
        return '⏰';
      case DisputeType.vehicle_condition:
        return '🚗';
      case DisputeType.insurance_claim:
        return '🛡️';
      case DisputeType.communication_issue:
        return '💬';
      case DisputeType.fraud_allegation:
        return '🚨';
      case DisputeType.safety_concern:
        return '⚠️';
      case DisputeType.other:
        return '❓';
    }
  }

  // Get status emoji
  String get statusEmoji {
    switch (status) {
      case DisputeStatus.opened:
        return '📝';
      case DisputeStatus.under_review:
        return '🔍';
      case DisputeStatus.evidence_required:
        return '📋';
      case DisputeStatus.mediation:
        return '🤝';
      case DisputeStatus.resolved:
        return '✅';
      case DisputeStatus.closed:
        return '🔒';
      case DisputeStatus.escalated:
        return '🚨';
    }
  }

  // Get priority emoji
  String get priorityEmoji {
    switch (priority) {
      case DisputePriority.low:
        return '🟢';
      case DisputePriority.normal:
        return '🟡';
      case DisputePriority.high:
        return '🟠';
      case DisputePriority.urgent:
        return '🔴';
    }
  }

  // Get display title with type and status
  String get displayTitle {
    return '$typeEmoji $statusEmoji $priorityEmoji $title';
  }

  // Get formatted claimed amount
  String get formattedClaimedAmount {
    final symbol = getCurrencySymbol();
    return '$symbol${claimedAmount.toStringAsFixed(2)}';
  }

  // Get formatted resolved amount
  String? get formattedResolvedAmount {
    if (resolvedAmount == null) return null;
    final symbol = getCurrencySymbol();
    return '$symbol${resolvedAmount!.toStringAsFixed(2)}';
  }

  // Get currency symbol
  String getCurrencySymbol() {
    switch (currency?.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      case 'QAR':
        return 'ر.ق';
      case 'KWD':
        return 'د.ك';
      case 'BHD':
        return 'د.ب';
      case 'OMR':
        return 'ر.ع';
      case 'JOD':
        return 'د.أ';
      case 'EGP':
        return 'ج.م';
      case 'MAD':
        return 'د.م';
      case 'TND':
        return 'د.ت';
      case 'DZD':
        return 'د.ج';
      case 'LYD':
        return 'د.ل';
      default:
        return '\$';
    }
  }

  // Get dispute summary
  String get summary {
    final amount = formattedClaimedAmount;
    final status = statusDisplayName;
    return '$amount • $status';
  }

  // Get dispute age in days
  int get ageInDays {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  // Check if dispute is recent (within 3 days)
  bool get isRecent {
    return ageInDays <= 3;
  }

  // Check if dispute is old (more than 30 days)
  bool get isOld {
    return ageInDays >= 30;
  }

  // Get resolution time in days
  int? get resolutionTimeDays {
    if (resolvedAt == null) return null;
    return resolvedAt!.difference(createdAt).inDays;
  }

  // Get closure time in days
  int? get closureTimeDays {
    if (closedAt == null) return null;
    return closedAt!.difference(createdAt).inDays;
  }

  // Get dispute status display name
  String get statusDisplayName {
    switch (status) {
      case DisputeStatus.opened:
        return 'Opened';
      case DisputeStatus.under_review:
        return 'Under Review';
      case DisputeStatus.evidence_required:
        return 'Evidence Required';
      case DisputeStatus.mediation:
        return 'In Mediation';
      case DisputeStatus.resolved:
        return 'Resolved';
      case DisputeStatus.closed:
        return 'Closed';
      case DisputeStatus.escalated:
        return 'Escalated';
    }
  }

  // Get priority display name
  String get priorityDisplayName {
    switch (priority) {
      case DisputePriority.low:
        return 'Low';
      case DisputePriority.normal:
        return 'Normal';
      case DisputePriority.high:
        return 'High';
      case DisputePriority.urgent:
        return 'Urgent';
    }
  }

  // Get resolution display name
  String? get resolutionDisplayName {
    if (resolution == null) return null;
    switch (resolution!) {
      case DisputeResolution.resolved_in_favor_renter:
        return 'Resolved in Favor of Renter';
      case DisputeResolution.resolved_in_favor_owner:
        return 'Resolved in Favor of Owner';
      case DisputeResolution.partial_refund:
        return 'Partial Refund';
      case DisputeResolution.full_refund:
        return 'Full Refund';
      case DisputeResolution.no_action:
        return 'No Action';
      case DisputeResolution.mediation_agreement:
        return 'Mediation Agreement';
      case DisputeResolution.escalated_to_legal:
        return 'Escalated to Legal';
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

  // Check if dispute can be resolved
  bool get canBeResolved {
    return status == DisputeStatus.under_review || 
           status == DisputeStatus.mediation ||
           status == DisputeStatus.evidence_required;
  }

  // Check if dispute can be escalated
  bool get canBeEscalated {
    return !isEscalated && ageInDays >= 7;
  }

  // Check if dispute can be closed
  bool get canBeClosed {
    return isResolved || isEscalated;
  }

  // Get dispute severity score
  double get severityScore {
    double score = 0.0;
    
    // Priority score
    switch (priority) {
      case DisputePriority.urgent:
        score += 4.0;
        break;
      case DisputePriority.high:
        score += 3.0;
        break;
      case DisputePriority.normal:
        score += 2.0;
        break;
      case DisputePriority.low:
        score += 1.0;
        break;
    }
    
    // Type score
    if (type == DisputeType.fraud_allegation) score += 3.0;
    if (type == DisputeType.safety_concern) score += 2.5;
    if (type == DisputeType.damage_claim) score += 2.0;
    if (type == DisputeType.payment_dispute) score += 1.5;
    
    // Amount score
    if (claimedAmount >= 1000) {
      score += 2.0;
    } else if (claimedAmount >= 500) score += 1.5;
    else if (claimedAmount >= 100) score += 1.0;
    
    // Status score
    if (isEscalated) score += 2.0;
    if (isUrgent) score += 1.5;
    
    // Age score (older disputes are more severe)
    if (ageInDays >= 14) score += 1.0;
    if (ageInDays >= 30) score += 1.5;
    
    return score;
  }

  // Check if dispute is severe
  bool get isSevere {
    return severityScore >= 8.0;
  }
} 