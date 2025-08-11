import 'dart:convert';
import 'location.dart';

enum UserRole { guest, user, host, admin }

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final UserRole role;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic> preferences;
  final List<String> savedCars;
  final List<String> bookingHistory;
  final HostProfile? hostProfile;
  final Location? location; // Add location property

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    required this.role,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    required this.createdAt,
    this.lastLoginAt,
    this.preferences = const {},
    this.savedCars = const [],
    this.bookingHistory = const [],
    this.hostProfile,
    this.location, // Add location parameter
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['full_name'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImage: json['avatar_url'] ?? json['profile_image'] ?? json['profileImage'],
      role: UserRole.values.firstWhere(
        (role) => role.toString() == 'UserRole.${json['role'] ?? 'user'}',
        orElse: () => UserRole.user,
      ),
      isEmailVerified: json['is_email_verified'] ?? json['isEmailVerified'] ?? false,
      isPhoneVerified: json['is_phone_verified'] ?? json['isPhoneVerified'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : json['last_login_at'] != null 
              ? DateTime.parse(json['last_login_at']) 
              : json['lastLoginAt'] != null 
                  ? DateTime.parse(json['lastLoginAt'])
                  : null,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      savedCars: List<String>.from(json['saved_cars'] ?? json['savedCars'] ?? []),
      bookingHistory: List<String>.from(json['booking_history'] ?? json['bookingHistory'] ?? []),
      hostProfile: json['hostProfile'] != null 
          ? HostProfile.fromJson(json['hostProfile']) 
          : null,
      location: json['location'] != null 
          ? Location.fromJson(json['location']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'phone': phone,
      'avatar_url': profileImage,
      'role': role.toString().split('.').last,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': lastLoginAt?.toIso8601String(),
      'preferences': preferences,
      'saved_cars': savedCars,
      'booking_history': bookingHistory,
      'hostProfile': hostProfile?.toJson(),
      'location': location?.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    UserRole? role,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
    List<String>? savedCars,
    List<String>? bookingHistory,
    HostProfile? hostProfile,
    Location? location,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      savedCars: savedCars ?? this.savedCars,
      bookingHistory: bookingHistory ?? this.bookingHistory,
      hostProfile: hostProfile ?? this.hostProfile,
      location: location ?? this.location,
    );
  }

  // Role-based getters
  bool get isGuest => role == UserRole.guest;
  bool get isRegularUser => role == UserRole.user;
  bool get isHost => role == UserRole.host;
  bool get isAdmin => role == UserRole.admin;
  bool get canHost => isHost || isAdmin;
  bool get canBook => isRegularUser || isHost || isAdmin;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Supporting classes (if not already defined)
class HostProfile {
  final String id;
  final String userId;
  final String businessName;
  final String businessDescription;
  final bool isVerified;
  final DateTime createdAt;

  HostProfile({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.businessDescription,
    this.isVerified = false,
    required this.createdAt,
  });

  factory HostProfile.fromJson(Map<String, dynamic> json) {
    return HostProfile(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      businessName: json['business_name'] ?? '',
      businessDescription: json['business_description'] ?? '',
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'business_name': businessName,
      'business_description': businessDescription,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 