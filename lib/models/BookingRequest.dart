enum BookingRequestStatus { 
  pending, 
  approved, 
  rejected, 
  cancelled, 
  expired 
}

enum RequestPriority { 
  low, 
  normal, 
  high, 
  urgent 
}

class BookingRequest {
  final String id;
  final String userId;
  final String userName;
  final String? userImage;
  final String carId;
  final String carName;
  final String carImage;
  final String hostId;
  final String hostName;
  final DateTime startDate;
  final DateTime endDate;
  final int requestedDays;
  final double requestedPrice;
  final double dailyRate;
  final String pickupLocation;
  final String returnLocation;
  final String? message;
  final BookingRequestStatus status;
  final RequestPriority priority;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? respondedAt;
  final DateTime? expiresAt;
  final String? rejectionReason;
  final String? hostResponse;
  final Map<String, dynamic>? specialRequests;
  final List<String>? additionalServices;
  final Map<String, dynamic>? userPreferences;
  final bool isUrgent;
  final bool isFlexibleDates;
  final DateTime? alternativeStartDate;
  final DateTime? alternativeEndDate;
  final Map<String, dynamic>? metadata;

  BookingRequest({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.carId,
    required this.carName,
    required this.carImage,
    required this.hostId,
    required this.hostName,
    required this.startDate,
    required this.endDate,
    required this.requestedDays,
    required this.requestedPrice,
    required this.dailyRate,
    required this.pickupLocation,
    required this.returnLocation,
    this.message,
    this.status = BookingRequestStatus.pending,
    this.priority = RequestPriority.normal,
    required this.createdAt,
    this.updatedAt,
    this.respondedAt,
    this.expiresAt,
    this.rejectionReason,
    this.hostResponse,
    this.specialRequests,
    this.additionalServices,
    this.userPreferences,
    this.isUrgent = false,
    this.isFlexibleDates = false,
    this.alternativeStartDate,
    this.alternativeEndDate,
    this.metadata,
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequest(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userImage: json['userImage'],
      carId: json['carId'] ?? '',
      carName: json['carName'] ?? '',
      carImage: json['carImage'] ?? '',
      hostId: json['hostId'] ?? '',
      hostName: json['hostName'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      requestedDays: json['requestedDays'] ?? 0,
      requestedPrice: (json['requestedPrice'] ?? 0.0).toDouble(),
      dailyRate: (json['dailyRate'] ?? 0.0).toDouble(),
      pickupLocation: json['pickupLocation'] ?? '',
      returnLocation: json['returnLocation'] ?? '',
      message: json['message'],
      status: BookingRequestStatus.values.firstWhere(
        (status) => status.toString() == 'BookingRequestStatus.${json['status'] ?? 'pending'}',
        orElse: () => BookingRequestStatus.pending,
      ),
      priority: RequestPriority.values.firstWhere(
        (priority) => priority.toString() == 'RequestPriority.${json['priority'] ?? 'normal'}',
        orElse: () => RequestPriority.normal,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      respondedAt: json['respondedAt'] != null ? DateTime.parse(json['respondedAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      rejectionReason: json['rejectionReason'],
      hostResponse: json['hostResponse'],
      specialRequests: json['specialRequests'] != null 
          ? Map<String, dynamic>.from(json['specialRequests']) 
          : null,
      additionalServices: json['additionalServices'] != null 
          ? List<String>.from(json['additionalServices']) 
          : null,
      userPreferences: json['userPreferences'] != null 
          ? Map<String, dynamic>.from(json['userPreferences']) 
          : null,
      isUrgent: json['isUrgent'] ?? false,
      isFlexibleDates: json['isFlexibleDates'] ?? false,
      alternativeStartDate: json['alternativeStartDate'] != null 
          ? DateTime.parse(json['alternativeStartDate']) 
          : null,
      alternativeEndDate: json['alternativeEndDate'] != null 
          ? DateTime.parse(json['alternativeEndDate']) 
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
      'userName': userName,
      'userImage': userImage,
      'carId': carId,
      'carName': carName,
      'carImage': carImage,
      'hostId': hostId,
      'hostName': hostName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'requestedDays': requestedDays,
      'requestedPrice': requestedPrice,
      'dailyRate': dailyRate,
      'pickupLocation': pickupLocation,
      'returnLocation': returnLocation,
      'message': message,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'hostResponse': hostResponse,
      'specialRequests': specialRequests,
      'additionalServices': additionalServices,
      'userPreferences': userPreferences,
      'isUrgent': isUrgent,
      'isFlexibleDates': isFlexibleDates,
      'alternativeStartDate': alternativeStartDate?.toIso8601String(),
      'alternativeEndDate': alternativeEndDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  BookingRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userImage,
    String? carId,
    String? carName,
    String? carImage,
    String? hostId,
    String? hostName,
    DateTime? startDate,
    DateTime? endDate,
    int? requestedDays,
    double? requestedPrice,
    double? dailyRate,
    String? pickupLocation,
    String? returnLocation,
    String? message,
    BookingRequestStatus? status,
    RequestPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? respondedAt,
    DateTime? expiresAt,
    String? rejectionReason,
    String? hostResponse,
    Map<String, dynamic>? specialRequests,
    List<String>? additionalServices,
    Map<String, dynamic>? userPreferences,
    bool? isUrgent,
    bool? isFlexibleDates,
    DateTime? alternativeStartDate,
    DateTime? alternativeEndDate,
    Map<String, dynamic>? metadata,
  }) {
    return BookingRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      carId: carId ?? this.carId,
      carName: carName ?? this.carName,
      carImage: carImage ?? this.carImage,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      requestedDays: requestedDays ?? this.requestedDays,
      requestedPrice: requestedPrice ?? this.requestedPrice,
      dailyRate: dailyRate ?? this.dailyRate,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      returnLocation: returnLocation ?? this.returnLocation,
      message: message ?? this.message,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      hostResponse: hostResponse ?? this.hostResponse,
      specialRequests: specialRequests ?? this.specialRequests,
      additionalServices: additionalServices ?? this.additionalServices,
      userPreferences: userPreferences ?? this.userPreferences,
      isUrgent: isUrgent ?? this.isUrgent,
      isFlexibleDates: isFlexibleDates ?? this.isFlexibleDates,
      alternativeStartDate: alternativeStartDate ?? this.alternativeStartDate,
      alternativeEndDate: alternativeEndDate ?? this.alternativeEndDate,
      metadata: metadata ?? this.metadata,
    );
  }

  // Check if request is pending
  bool get isPending {
    return status == BookingRequestStatus.pending;
  }

  // Check if request is approved
  bool get isApproved {
    return status == BookingRequestStatus.approved;
  }

  // Check if request is rejected
  bool get isRejected {
    return status == BookingRequestStatus.rejected;
  }

  // Check if request is cancelled
  bool get isCancelled {
    return status == BookingRequestStatus.cancelled;
  }

  // Check if request is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // Check if request is urgent
  bool get isUrgentRequest {
    return isUrgent || priority == RequestPriority.urgent || priority == RequestPriority.high;
  }

  // Check if request has been responded to
  bool get hasResponse {
    return respondedAt != null;
  }

  // Check if request has message
  bool get hasMessage {
    return message != null && message!.isNotEmpty;
  }

  // Check if request has host response
  bool get hasHostResponse {
    return hostResponse != null && hostResponse!.isNotEmpty;
  }

  // Check if request has special requests
  bool get hasSpecialRequests {
    return specialRequests != null && specialRequests!.isNotEmpty;
  }

  // Check if request has additional services
  bool get hasAdditionalServices {
    return additionalServices != null && additionalServices!.isNotEmpty;
  }

  // Check if request has flexible dates
  bool get hasFlexibleDates {
    return isFlexibleDates && alternativeStartDate != null && alternativeEndDate != null;
  }

  // Get request age in hours
  int get ageInHours {
    final now = DateTime.now();
    return now.difference(createdAt).inHours;
  }

  // Check if request is recent (within 24 hours)
  bool get isRecent {
    return ageInHours <= 24;
  }

  // Check if request is old (more than 7 days)
  bool get isOld {
    return ageInHours >= 168; // 7 days * 24 hours
  }

  // Get time until expiration in hours
  int? get timeUntilExpiration {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return 0;
    return expiresAt!.difference(now).inHours;
  }

  // Get request status display name
  String get statusDisplayName {
    switch (status) {
      case BookingRequestStatus.pending:
        return 'Pending';
      case BookingRequestStatus.approved:
        return 'Approved';
      case BookingRequestStatus.rejected:
        return 'Rejected';
      case BookingRequestStatus.cancelled:
        return 'Cancelled';
      case BookingRequestStatus.expired:
        return 'Expired';
    }
  }

  // Get priority display name
  String get priorityDisplayName {
    switch (priority) {
      case RequestPriority.low:
        return 'Low';
      case RequestPriority.normal:
        return 'Normal';
      case RequestPriority.high:
        return 'High';
      case RequestPriority.urgent:
        return 'Urgent';
    }
  }

  // Get priority emoji
  String get priorityEmoji {
    switch (priority) {
      case RequestPriority.low:
        return '🟢';
      case RequestPriority.normal:
        return '🟡';
      case RequestPriority.high:
        return '🟠';
      case RequestPriority.urgent:
        return '🔴';
    }
  }

  // Get status emoji
  String get statusEmoji {
    switch (status) {
      case BookingRequestStatus.pending:
        return '⏳';
      case BookingRequestStatus.approved:
        return '✅';
      case BookingRequestStatus.rejected:
        return '❌';
      case BookingRequestStatus.cancelled:
        return '🚫';
      case BookingRequestStatus.expired:
        return '⏰';
    }
  }

  // Get display title with status and priority
  String get displayTitle {
    return '$statusEmoji $priorityEmoji $carName';
  }

  // Get request summary
  String get summary {
    final dateRange = '${startDate.day}/${startDate.month} - ${endDate.day}/${endDate.month}';
    return '$dateRange • $requestedDays days • \$${requestedPrice.toStringAsFixed(0)}';
  }

  // Get message preview (first 50 characters)
  String get messagePreview {
    if (!hasMessage) return 'No message';
    if (message!.length <= 50) return message!;
    return '${message!.substring(0, 50)}...';
  }

  // Get host response preview
  String get hostResponsePreview {
    if (!hasHostResponse) return 'No response yet';
    if (hostResponse!.length <= 50) return hostResponse!;
    return '${hostResponse!.substring(0, 50)}...';
  }

  // Calculate total price difference from daily rate
  double get priceDifference {
    final expectedPrice = dailyRate * requestedDays;
    return requestedPrice - expectedPrice;
  }

  // Check if request is a discount request
  bool get isDiscountRequest {
    return priceDifference < 0;
  }

  // Check if request is a premium request
  bool get isPremiumRequest {
    return priceDifference > 0;
  }

  // Get price difference percentage
  double get priceDifferencePercentage {
    final expectedPrice = dailyRate * requestedDays;
    if (expectedPrice == 0) return 0.0;
    return (priceDifference / expectedPrice) * 100;
  }

  // Check if request can be cancelled
  bool get canBeCancelled {
    return status == BookingRequestStatus.pending && !isExpired;
  }

  // Check if request can be modified
  bool get canBeModified {
    return status == BookingRequestStatus.pending && !isExpired;
  }

  // Check if request needs immediate attention
  bool get needsImmediateAttention {
    return isUrgentRequest || 
           (isRecent && priority == RequestPriority.high) ||
           (timeUntilExpiration != null && timeUntilExpiration! <= 2);
  }

  // Get request urgency level
  String get urgencyLevel {
    if (priority == RequestPriority.urgent || isUrgent) return 'Critical';
    if (priority == RequestPriority.high) return 'High';
    if (timeUntilExpiration != null && timeUntilExpiration! <= 6) return 'Expiring Soon';
    if (isRecent) return 'New';
    return 'Normal';
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

  // Get response time (if responded)
  String? get responseTime {
    if (respondedAt == null) return null;
    final difference = respondedAt!.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'Immediate';
    }
  }
} 