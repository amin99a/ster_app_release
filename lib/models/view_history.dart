class ViewHistory {
  final String id;
  final String userId;
  final String carId;
  final String carModel;
  final String carImage;
  final double carRating;
  final int carTrips;
  final String hostName;
  final bool isAllStarHost;
  final DateTime viewedAt;
  final Map<String, dynamic>? metadata;

  ViewHistory({
    required this.id,
    required this.userId,
    required this.carId,
    required this.carModel,
    required this.carImage,
    required this.carRating,
    required this.carTrips,
    required this.hostName,
    this.isAllStarHost = false,
    required this.viewedAt,
    this.metadata,
  });

  factory ViewHistory.fromJson(Map<String, dynamic> json) {
    return ViewHistory(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      carId: json['carId'] ?? '',
      carModel: json['carModel'] ?? '',
      carImage: json['carImage'] ?? '',
      carRating: (json['carRating'] ?? 0.0).toDouble(),
      carTrips: json['carTrips'] ?? 0,
      hostName: json['hostName'] ?? '',
      isAllStarHost: json['isAllStarHost'] ?? false,
      viewedAt: DateTime.parse(json['viewedAt']),
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'carId': carId,
      'carModel': carModel,
      'carImage': carImage,
      'carRating': carRating,
      'carTrips': carTrips,
      'hostName': hostName,
      'isAllStarHost': isAllStarHost,
      'viewedAt': viewedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  ViewHistory copyWith({
    String? id,
    String? userId,
    String? carId,
    String? carModel,
    String? carImage,
    double? carRating,
    int? carTrips,
    String? hostName,
    bool? isAllStarHost,
    DateTime? viewedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ViewHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      carId: carId ?? this.carId,
      carModel: carModel ?? this.carModel,
      carImage: carImage ?? this.carImage,
      carRating: carRating ?? this.carRating,
      carTrips: carTrips ?? this.carTrips,
      hostName: hostName ?? this.hostName,
      isAllStarHost: isAllStarHost ?? this.isAllStarHost,
      viewedAt: viewedAt ?? this.viewedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ViewHistory &&
        other.id == id &&
        other.userId == userId &&
        other.carId == carId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ carId.hashCode;
  }

  @override
  String toString() {
    return 'ViewHistory(id: $id, userId: $userId, carId: $carId, carModel: $carModel, viewedAt: $viewedAt)';
  }
} 