enum RentalStatus { 
  pending, 
  confirmed, 
  active, 
  completed, 
  cancelled, 
  returned 
}

enum RentalPaymentStatus { 
  pending, 
  paid, 
  refunded, 
  failed 
}

enum FuelLevel {
  empty,
  quarter,
  half,
  threeQuarter,
  full
}

enum CarCondition {
  excellent,
  good,
  fair,
  poor
}

enum FuelPolicy {
  fullToFull,
  sameToSame,
  freeFuel,
  full_to_full, // Add missing constant
  electric_charge // Add missing constant
}

enum DepositStatus {
  pending,
  held,
  returned,
  forfeited,
  paid // Add missing constant
}

class Rental {
  final String id;
  final String carId;
  final String userId;
  final String hostId;
  final DateTime startDate;
  final DateTime endDate;
  final int rentalDays;
  final double totalPrice;
  final double dailyRate;
  final double depositAmount;
  final RentalStatus status;
  final RentalPaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? actualStartDate;
  final DateTime? actualEndDate;
  final String? notes;
  final String? cancellationReason;
  final Map<String, dynamic>? additionalServices;
  final Map<String, double>? additionalCharges;
  final String pickupLocation;
  final String returnLocation;
  final String? actualPickupLocation;
  final String? actualReturnLocation;
  final double? fuelLevelAtPickup;
  final double? fuelLevelAtReturn;
  final int? mileageAtPickup;
  final int? mileageAtReturn;
  final List<String>? damageReports;
  final Map<String, dynamic>? insuranceDetails;
  final double? finalPrice;
  final double? refundAmount;
  
  // Additional properties that services are trying to access
  final String? carName;
  final String? carImage;
  final String? userName;
  final String? userImage;
  final String? ownerId;
  final String? ownerName;
  final String? ownerImage;
  final DateTime? pickupTime;
  final DateTime? returnTime;
  final int? totalDays;
  final double? subtotal;
  final double? serviceFee;
  final double? taxAmount;
  final double? totalAmount;
  final DateTime? confirmedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final FuelLevel? fuelLevel;
  final FuelLevel? returnFuelLevel;
  final CarCondition? carCondition;
  final CarCondition? returnCarCondition;
  final List<String>? specialRequests;
  final bool? insuranceIncluded;
  final String? insuranceType;
  final double? insuranceAmount;
  final double? insuranceDailyRate;
  final double? insuranceTotal;
  final String? cancellationPolicy;
  final String? lateReturnPolicy;
  final int? mileageLimit;
  final double? mileageRate;
  final FuelPolicy? fuelPolicy;
  final DepositStatus? depositStatus;
  final DateTime? depositReturnedAt;
  final String? damageReport;
  final List<String>? damagePhotos;
  final double? damageAmount;
  final String? refundReason;
  final DateTime? refundedAt;
  final double? rating;
  final String? review;
  final bool? isUrgent;
  final bool? isFlexible;
  final Map<String, dynamic>? metadata;

  Rental({
    required this.id,
    required this.carId,
    required this.userId,
    required this.hostId,
    required this.startDate,
    required this.endDate,
    required this.rentalDays,
    required this.totalPrice,
    required this.dailyRate,
    required this.depositAmount,
    this.status = RentalStatus.pending,
    this.paymentStatus = RentalPaymentStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.actualStartDate,
    this.actualEndDate,
    this.notes,
    this.cancellationReason,
    this.additionalServices,
    this.additionalCharges,
    required this.pickupLocation,
    required this.returnLocation,
    this.actualPickupLocation,
    this.actualReturnLocation,
    this.fuelLevelAtPickup,
    this.fuelLevelAtReturn,
    this.mileageAtPickup,
    this.mileageAtReturn,
    this.damageReports,
    this.insuranceDetails,
    this.finalPrice,
    this.refundAmount,
    this.carName,
    this.carImage,
    this.userName,
    this.userImage,
    this.ownerId,
    this.ownerName,
    this.ownerImage,
    this.pickupTime,
    this.returnTime,
    this.totalDays,
    this.subtotal,
    this.serviceFee,
    this.taxAmount,
    this.totalAmount,
    this.confirmedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.fuelLevel,
    this.returnFuelLevel,
    this.carCondition,
    this.returnCarCondition,
    this.specialRequests,
    this.insuranceIncluded,
    this.insuranceType,
    this.insuranceAmount,
    this.insuranceDailyRate,
    this.insuranceTotal,
    this.cancellationPolicy,
    this.lateReturnPolicy,
    this.mileageLimit,
    this.mileageRate,
    this.fuelPolicy,
    this.depositStatus,
    this.depositReturnedAt,
    this.damageReport,
    this.damagePhotos,
    this.damageAmount,
    this.refundReason,
    this.refundedAt,
    this.rating,
    this.review,
    this.isUrgent,
    this.isFlexible,
    this.metadata,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'] ?? '',
      carId: json['carId'] ?? '',
      userId: json['userId'] ?? '',
      hostId: json['hostId'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      rentalDays: json['rentalDays'] ?? 0,
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      dailyRate: (json['dailyRate'] ?? 0.0).toDouble(),
      depositAmount: (json['depositAmount'] ?? 0.0).toDouble(),
      status: RentalStatus.values.firstWhere(
        (status) => status.toString() == 'RentalStatus.${json['status'] ?? 'pending'}',
        orElse: () => RentalStatus.pending,
      ),
      paymentStatus: RentalPaymentStatus.values.firstWhere(
        (status) => status.toString() == 'RentalPaymentStatus.${json['paymentStatus'] ?? 'pending'}',
        orElse: () => RentalPaymentStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      actualStartDate: json['actualStartDate'] != null ? DateTime.parse(json['actualStartDate']) : null,
      actualEndDate: json['actualEndDate'] != null ? DateTime.parse(json['actualEndDate']) : null,
      notes: json['notes'],
      cancellationReason: json['cancellationReason'],
      additionalServices: json['additionalServices'],
      additionalCharges: json['additionalCharges'] != null 
          ? Map<String, double>.from(json['additionalCharges'])
          : null,
      pickupLocation: json['pickupLocation'] ?? '',
      returnLocation: json['returnLocation'] ?? '',
      actualPickupLocation: json['actualPickupLocation'],
      actualReturnLocation: json['actualReturnLocation'],
      fuelLevelAtPickup: json['fuelLevelAtPickup']?.toDouble(),
      fuelLevelAtReturn: json['fuelLevelAtReturn']?.toDouble(),
      mileageAtPickup: json['mileageAtPickup'],
      mileageAtReturn: json['mileageAtReturn'],
      damageReports: json['damageReports'] != null 
          ? List<String>.from(json['damageReports'])
          : null,
      insuranceDetails: json['insuranceDetails'],
      finalPrice: json['finalPrice']?.toDouble(),
      refundAmount: json['refundAmount']?.toDouble(),
      carName: json['carName'],
      carImage: json['carImage'],
      userName: json['userName'],
      userImage: json['userImage'],
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      ownerImage: json['ownerImage'],
      pickupTime: json['pickupTime'] != null ? DateTime.parse(json['pickupTime']) : null,
      returnTime: json['returnTime'] != null ? DateTime.parse(json['returnTime']) : null,
      totalDays: json['totalDays'],
      subtotal: json['subtotal']?.toDouble(),
      serviceFee: json['serviceFee']?.toDouble(),
      taxAmount: json['taxAmount']?.toDouble(),
      totalAmount: json['totalAmount']?.toDouble(),
      confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt']) : null,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      fuelLevel: json['fuelLevel'] != null 
          ? FuelLevel.values.firstWhere(
              (level) => level.toString() == 'FuelLevel.${json['fuelLevel']}',
              orElse: () => FuelLevel.half,
            )
          : null,
      returnFuelLevel: json['returnFuelLevel'] != null 
          ? FuelLevel.values.firstWhere(
              (level) => level.toString() == 'FuelLevel.${json['returnFuelLevel']}',
              orElse: () => FuelLevel.half,
            )
          : null,
      carCondition: json['carCondition'] != null 
          ? CarCondition.values.firstWhere(
              (condition) => condition.toString() == 'CarCondition.${json['carCondition']}',
              orElse: () => CarCondition.good,
            )
          : null,
      returnCarCondition: json['returnCarCondition'] != null 
          ? CarCondition.values.firstWhere(
              (condition) => condition.toString() == 'CarCondition.${json['returnCarCondition']}',
              orElse: () => CarCondition.good,
            )
          : null,
      specialRequests: json['specialRequests'] != null 
          ? List<String>.from(json['specialRequests'])
          : null,
      insuranceIncluded: json['insuranceIncluded'],
      insuranceType: json['insuranceType'],
      insuranceAmount: json['insuranceAmount']?.toDouble(),
      insuranceDailyRate: json['insuranceDailyRate']?.toDouble(),
      insuranceTotal: json['insuranceTotal']?.toDouble(),
      cancellationPolicy: json['cancellationPolicy'],
      lateReturnPolicy: json['lateReturnPolicy'],
      mileageLimit: json['mileageLimit'],
      mileageRate: json['mileageRate']?.toDouble(),
      fuelPolicy: json['fuelPolicy'] != null 
          ? FuelPolicy.values.firstWhere(
              (policy) => policy.toString() == 'FuelPolicy.${json['fuelPolicy']}',
              orElse: () => FuelPolicy.fullToFull,
            )
          : null,
      depositStatus: json['depositStatus'] != null 
          ? DepositStatus.values.firstWhere(
              (status) => status.toString() == 'DepositStatus.${json['depositStatus']}',
              orElse: () => DepositStatus.pending,
            )
          : null,
      depositReturnedAt: json['depositReturnedAt'] != null ? DateTime.parse(json['depositReturnedAt']) : null,
      damageReport: json['damageReport'],
      damagePhotos: json['damagePhotos'] != null 
          ? List<String>.from(json['damagePhotos'])
          : null,
      damageAmount: json['damageAmount']?.toDouble(),
      refundReason: json['refundReason'],
      refundedAt: json['refundedAt'] != null ? DateTime.parse(json['refundedAt']) : null,
      rating: json['rating']?.toDouble(),
      review: json['review'],
      isUrgent: json['isUrgent'],
      isFlexible: json['isFlexible'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'userId': userId,
      'hostId': hostId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'rentalDays': rentalDays,
      'totalPrice': totalPrice,
      'dailyRate': dailyRate,
      'depositAmount': depositAmount,
      'status': status.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'actualStartDate': actualStartDate?.toIso8601String(),
      'actualEndDate': actualEndDate?.toIso8601String(),
      'notes': notes,
      'cancellationReason': cancellationReason,
      'additionalServices': additionalServices,
      'additionalCharges': additionalCharges,
      'pickupLocation': pickupLocation,
      'returnLocation': returnLocation,
      'actualPickupLocation': actualPickupLocation,
      'actualReturnLocation': actualReturnLocation,
      'fuelLevelAtPickup': fuelLevelAtPickup,
      'fuelLevelAtReturn': fuelLevelAtReturn,
      'mileageAtPickup': mileageAtPickup,
      'mileageAtReturn': mileageAtReturn,
      'damageReports': damageReports,
      'insuranceDetails': insuranceDetails,
      'finalPrice': finalPrice,
      'refundAmount': refundAmount,
      'carName': carName,
      'carImage': carImage,
      'userName': userName,
      'userImage': userImage,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerImage': ownerImage,
      'pickupTime': pickupTime?.toIso8601String(),
      'returnTime': returnTime?.toIso8601String(),
      'totalDays': totalDays,
      'subtotal': subtotal,
      'serviceFee': serviceFee,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'confirmedAt': confirmedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'fuelLevel': fuelLevel?.toString().split('.').last,
      'returnFuelLevel': returnFuelLevel?.toString().split('.').last,
      'carCondition': carCondition?.toString().split('.').last,
      'returnCarCondition': returnCarCondition?.toString().split('.').last,
      'specialRequests': specialRequests,
      'insuranceIncluded': insuranceIncluded,
      'insuranceType': insuranceType,
      'insuranceAmount': insuranceAmount,
      'insuranceDailyRate': insuranceDailyRate,
      'insuranceTotal': insuranceTotal,
      'cancellationPolicy': cancellationPolicy,
      'lateReturnPolicy': lateReturnPolicy,
      'mileageLimit': mileageLimit,
      'mileageRate': mileageRate,
      'fuelPolicy': fuelPolicy?.toString().split('.').last,
      'depositStatus': depositStatus?.toString().split('.').last,
      'depositReturnedAt': depositReturnedAt?.toIso8601String(),
      'damageReport': damageReport,
      'damagePhotos': damagePhotos,
      'damageAmount': damageAmount,
      'refundReason': refundReason,
      'refundedAt': refundedAt?.toIso8601String(),
      'rating': rating,
      'review': review,
      'isUrgent': isUrgent,
      'isFlexible': isFlexible,
      'metadata': metadata,
    };
  }

  Rental copyWith({
    String? id,
    String? carId,
    String? userId,
    String? hostId,
    DateTime? startDate,
    DateTime? endDate,
    int? rentalDays,
    double? totalPrice,
    double? dailyRate,
    double? depositAmount,
    RentalStatus? status,
    RentalPaymentStatus? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? actualStartDate,
    DateTime? actualEndDate,
    String? notes,
    String? cancellationReason,
    Map<String, dynamic>? additionalServices,
    Map<String, double>? additionalCharges,
    String? pickupLocation,
    String? returnLocation,
    String? actualPickupLocation,
    String? actualReturnLocation,
    double? fuelLevelAtPickup,
    double? fuelLevelAtReturn,
    int? mileageAtPickup,
    int? mileageAtReturn,
    List<String>? damageReports,
    Map<String, dynamic>? insuranceDetails,
    double? finalPrice,
    double? refundAmount,
    String? carName,
    String? carImage,
    String? userName,
    String? userImage,
    String? ownerId,
    String? ownerName,
    String? ownerImage,
    DateTime? pickupTime,
    DateTime? returnTime,
    int? totalDays,
    double? subtotal,
    double? serviceFee,
    double? taxAmount,
    double? totalAmount,
    DateTime? confirmedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    FuelLevel? fuelLevel,
    FuelLevel? returnFuelLevel,
    CarCondition? carCondition,
    CarCondition? returnCarCondition,
    List<String>? specialRequests,
    bool? insuranceIncluded,
    String? insuranceType,
    double? insuranceAmount,
    double? insuranceDailyRate,
    double? insuranceTotal,
    String? cancellationPolicy,
    String? lateReturnPolicy,
    int? mileageLimit,
    double? mileageRate,
    FuelPolicy? fuelPolicy,
    DepositStatus? depositStatus,
    DateTime? depositReturnedAt,
    String? damageReport,
    List<String>? damagePhotos,
    double? damageAmount,
    String? refundReason,
    DateTime? refundedAt,
    double? rating,
    String? review,
    bool? isUrgent,
    bool? isFlexible,
    Map<String, dynamic>? metadata,
  }) {
    return Rental(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      userId: userId ?? this.userId,
      hostId: hostId ?? this.hostId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rentalDays: rentalDays ?? this.rentalDays,
      totalPrice: totalPrice ?? this.totalPrice,
      dailyRate: dailyRate ?? this.dailyRate,
      depositAmount: depositAmount ?? this.depositAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      actualStartDate: actualStartDate ?? this.actualStartDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      additionalServices: additionalServices ?? this.additionalServices,
      additionalCharges: additionalCharges ?? this.additionalCharges,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      returnLocation: returnLocation ?? this.returnLocation,
      actualPickupLocation: actualPickupLocation ?? this.actualPickupLocation,
      actualReturnLocation: actualReturnLocation ?? this.actualReturnLocation,
      fuelLevelAtPickup: fuelLevelAtPickup ?? this.fuelLevelAtPickup,
      fuelLevelAtReturn: fuelLevelAtReturn ?? this.fuelLevelAtReturn,
      mileageAtPickup: mileageAtPickup ?? this.mileageAtPickup,
      mileageAtReturn: mileageAtReturn ?? this.mileageAtReturn,
      damageReports: damageReports ?? this.damageReports,
      insuranceDetails: insuranceDetails ?? this.insuranceDetails,
      finalPrice: finalPrice ?? this.finalPrice,
      refundAmount: refundAmount ?? this.refundAmount,
      carName: carName ?? this.carName,
      carImage: carImage ?? this.carImage,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerImage: ownerImage ?? this.ownerImage,
      pickupTime: pickupTime ?? this.pickupTime,
      returnTime: returnTime ?? this.returnTime,
      totalDays: totalDays ?? this.totalDays,
      subtotal: subtotal ?? this.subtotal,
      serviceFee: serviceFee ?? this.serviceFee,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      returnFuelLevel: returnFuelLevel ?? this.returnFuelLevel,
      carCondition: carCondition ?? this.carCondition,
      returnCarCondition: returnCarCondition ?? this.returnCarCondition,
      specialRequests: specialRequests ?? this.specialRequests,
      insuranceIncluded: insuranceIncluded ?? this.insuranceIncluded,
      insuranceType: insuranceType ?? this.insuranceType,
      insuranceAmount: insuranceAmount ?? this.insuranceAmount,
      insuranceDailyRate: insuranceDailyRate ?? this.insuranceDailyRate,
      insuranceTotal: insuranceTotal ?? this.insuranceTotal,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      lateReturnPolicy: lateReturnPolicy ?? this.lateReturnPolicy,
      mileageLimit: mileageLimit ?? this.mileageLimit,
      mileageRate: mileageRate ?? this.mileageRate,
      fuelPolicy: fuelPolicy ?? this.fuelPolicy,
      depositStatus: depositStatus ?? this.depositStatus,
      depositReturnedAt: depositReturnedAt ?? this.depositReturnedAt,
      damageReport: damageReport ?? this.damageReport,
      damagePhotos: damagePhotos ?? this.damagePhotos,
      damageAmount: damageAmount ?? this.damageAmount,
      refundReason: refundReason ?? this.refundReason,
      refundedAt: refundedAt ?? this.refundedAt,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      isUrgent: isUrgent ?? this.isUrgent,
      isFlexible: isFlexible ?? this.isFlexible,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'Rental(id: $id, carId: $carId, userId: $userId, status: $status, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Rental && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 