class FavoriteItem {
  final String id;
  final String userId;
  final String listId;
  final String carId;
  final String carModel;
  final String carImage;
  final double carRating;
  final int carTrips;
  final String hostName;
  final bool isAllStarHost;
  final String? carPrice;
  final String? carLocation;
  final DateTime savedAt;
  final Map<String, dynamic>? metadata;

  FavoriteItem({
    required this.id,
    required this.userId,
    required this.listId,
    required this.carId,
    required this.carModel,
    required this.carImage,
    required this.carRating,
    required this.carTrips,
    required this.hostName,
    this.isAllStarHost = false,
    this.carPrice,
    this.carLocation,
    required this.savedAt,
    this.metadata,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      listId: json['listId'] ?? '',
      carId: json['carId'] ?? '',
      carModel: json['carModel'] ?? '',
      carImage: json['carImage'] ?? '',
      carRating: (json['carRating'] ?? 0.0).toDouble(),
      carTrips: json['carTrips'] ?? 0,
      hostName: json['hostName'] ?? '',
      isAllStarHost: json['isAllStarHost'] ?? false,
      carPrice: json['carPrice'],
      carLocation: json['carLocation'],
      savedAt: DateTime.parse(json['savedAt']),
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'listId': listId,
      'carId': carId,
      'carModel': carModel,
      'carImage': carImage,
      'carRating': carRating,
      'carTrips': carTrips,
      'hostName': hostName,
      'isAllStarHost': isAllStarHost,
      'carPrice': carPrice,
      'carLocation': carLocation,
      'savedAt': savedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  FavoriteItem copyWith({
    String? id,
    String? userId,
    String? listId,
    String? carId,
    String? carModel,
    String? carImage,
    double? carRating,
    int? carTrips,
    String? hostName,
    bool? isAllStarHost,
    String? carPrice,
    String? carLocation,
    DateTime? savedAt,
    Map<String, dynamic>? metadata,
  }) {
    return FavoriteItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      listId: listId ?? this.listId,
      carId: carId ?? this.carId,
      carModel: carModel ?? this.carModel,
      carImage: carImage ?? this.carImage,
      carRating: carRating ?? this.carRating,
      carTrips: carTrips ?? this.carTrips,
      hostName: hostName ?? this.hostName,
      isAllStarHost: isAllStarHost ?? this.isAllStarHost,
      carPrice: carPrice ?? this.carPrice,
      carLocation: carLocation ?? this.carLocation,
      savedAt: savedAt ?? this.savedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FavoriteItem(id: $id, carModel: $carModel, listId: $listId)';
  }
} 