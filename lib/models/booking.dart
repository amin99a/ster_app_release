import 'car.dart';
import 'user.dart' as app_user;

class Booking {
  final String id;
  final String carId;
  final String userId;
  final String? hostId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status; // pending, confirmed, active, completed, cancelled
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Car? car;
  final app_user.User? user;
  final app_user.User? host;

  Booking({
    required this.id,
    required this.carId,
    required this.userId,
    this.hostId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.car,
    this.user,
    this.host,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      carId: json['car_id'] ?? '',
      userId: json['user_id'] ?? '',
      hostId: json['host_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalPrice: (json['total_price'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      car: json['cars'] != null ? Car.fromJson(json['cars']) : null,
      user: json['users'] != null ? app_user.User.fromJson(json['users']) : null,
      host: json['host'] != null ? app_user.User.fromJson(json['host']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_id': carId,
      'user_id': userId,
      'host_id': hostId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_price': totalPrice,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }

  bool get isUpcoming {
    return startDate.isAfter(DateTime.now());
  }

  bool get isOngoing {
    final now = DateTime.now();
    return startDate.isBefore(now) && endDate.isAfter(now);
  }

  bool get isPast {
    return endDate.isBefore(DateTime.now());
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String get statusColor {
    switch (status) {
      case 'pending':
        return '#FFA500'; // Orange
      case 'confirmed':
        return '#4CAF50'; // Green
      case 'active':
        return '#2196F3'; // Blue
      case 'completed':
        return '#9E9E9E'; // Grey
      case 'cancelled':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  Booking copyWith({
    String? id,
    String? carId,
    String? userId,
    String? hostId,
    DateTime? startDate,
    DateTime? endDate,
    double? totalPrice,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Car? car,
    app_user.User? user,
    app_user.User? host,
  }) {
    return Booking(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      userId: userId ?? this.userId,
      hostId: hostId ?? this.hostId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      car: car ?? this.car,
      user: user ?? this.user,
      host: host ?? this.host,
    );
  }

  @override
  String toString() {
    return 'Booking(id: $id, carId: $carId, userId: $userId, status: $status, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 