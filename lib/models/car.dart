import 'dart:convert';

class Car {
  final String id;
  final String name;
  final String image;
  final String price;
  final String category;
  final double rating;
  final int trips;
  final String location;
  final String hostName;
  final String hostImage;
  final double hostRating;
  final String responseTime;
  final String description;
  final List<String> features;
  final List<String> images;
  final Map<String, String> specs;
  final Map<String, dynamic> requirements;
  final List<String> pickupLocations;
  final List<String> dropoffLocations;
  final bool isAvailable;
  final bool isFeatured;
  final String transmission;
  final String fuelType;
  final int passengers;
  
  // Additional properties that services are trying to access
  final String? brand;
  final String? model;
  final int? year;
  final double? dailyRate;
  final double? weeklyRate;
  final double? monthlyRate;
  final double? latitude;
  final double? longitude;
  final String? hostId;
  final String? hostResponseTime;
  final int? mileage;
  final int? seats;
  final int? doors;
  final String? color;
  final String? licensePlate;
  final String? insurance;
  final DateTime? createdAt;
  final int? reviewCount;
  final bool? isFavorite;
  final CarUseType useType;

  Car({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
    required this.rating,
    required this.trips,
    required this.location,
    required this.hostName,
    required this.hostImage,
    required this.hostRating,
    required this.responseTime,
    required this.description,
    required this.features,
    required this.images,
    required this.specs,
    this.requirements = const {},
    this.pickupLocations = const [],
    this.dropoffLocations = const [],
    this.isAvailable = true,
    this.isFeatured = false,
    this.transmission = '',
    this.fuelType = '',
    this.passengers = 4,
    this.brand,
    this.model,
    this.year,
    this.dailyRate,
    this.weeklyRate,
    this.monthlyRate,
    this.latitude,
    this.longitude,
    this.hostId,
    this.hostResponseTime,
    this.mileage,
    this.seats,
    this.doors,
    this.color,
    this.licensePlate,
    this.insurance,
    this.createdAt,
    this.reviewCount,
    this.isFavorite,
    this.useType = CarUseType.daily,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    // Handle different price formats
    String price = '';
    if (json['price'] != null) {
      if (json['price'] is String) {
        price = json['price'];
      } else if (json['price'] is num) {
        price = 'UK£${json['price']} total';
      } else {
        price = json['price'].toString();
      }
    } else if (json['price_per_day'] != null) {
      if (json['price_per_day'] is num) {
        price = 'UK£${json['price_per_day']} total';
      } else {
        price = json['price_per_day'].toString();
      }
    } else {
      price = 'UK£0 total';
    }

    // Handle features array - ensure it's always a List<String>
    List<String> features = [];
    if (json['features'] != null) {
      if (json['features'] is List) {
        features = (json['features'] as List).map((item) => item.toString()).toList();
      } else if (json['features'] is String) {
        // Handle case where features might be a JSON string
        try {
          final parsed = jsonDecode(json['features']);
          if (parsed is List) {
            features = parsed.map((item) => item.toString()).toList();
          }
        } catch (e) {
          features = [];
        }
      }
    }

    // Handle images array - ensure it's always a List<String>
    List<String> images = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        images = (json['images'] as List).map((item) => item.toString()).toList();
      } else if (json['images'] is String) {
        // Handle case where images might be a JSON string
        try {
          final parsed = jsonDecode(json['images']);
          if (parsed is List) {
            images = parsed.map((item) => item.toString()).toList();
          }
        } catch (e) {
          images = [];
        }
      }
    }

    // Handle pickup/dropoff locations
    List<String> pickupLocations = [];
    if (json['pickup_locations'] != null) {
      if (json['pickup_locations'] is List) {
        pickupLocations = (json['pickup_locations'] as List).map((e) => e.toString()).toList();
      } else if (json['pickup_locations'] is String) {
        try {
          final parsed = jsonDecode(json['pickup_locations']);
          if (parsed is List) {
            pickupLocations = parsed.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }
    }
    List<String> dropoffLocations = [];
    if (json['dropoff_locations'] != null) {
      if (json['dropoff_locations'] is List) {
        dropoffLocations = (json['dropoff_locations'] as List).map((e) => e.toString()).toList();
      } else if (json['dropoff_locations'] is String) {
        try {
          final parsed = jsonDecode(json['dropoff_locations']);
          if (parsed is List) {
            dropoffLocations = parsed.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }
    }

    // Handle specs map - ensure it's always a Map<String, String>
    Map<String, String> specs = {};
    if (json['specs'] != null) {
      if (json['specs'] is Map) {
        specs = (json['specs'] as Map).map((key, value) => MapEntry(key.toString(), value.toString()));
      } else if (json['specs'] is String) {
        // Handle case where specs might be a JSON string
        try {
          final parsed = jsonDecode(json['specs']);
          if (parsed is Map) {
            specs = (parsed as Map).map((key, value) => MapEntry(key.toString(), value.toString()));
          }
        } catch (e) {
          specs = {};
        }
      }
    }

    // Handle requirements map (driver requirements, policies, financial terms)
    Map<String, dynamic> requirements = {};
    if (json['requirements'] != null) {
      if (json['requirements'] is Map) {
        requirements = Map<String, dynamic>.from(json['requirements']);
      } else if (json['requirements'] is String) {
        try {
          final parsed = jsonDecode(json['requirements']);
          if (parsed is Map) requirements = Map<String, dynamic>.from(parsed);
        } catch (_) {}
      }
    }

    return Car(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      price: price,
      category: json['category']?.toString() ?? json['category_name']?.toString() ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      trips: json['trips'] ?? 0,
      location: json['location']?.toString() ?? '',
      hostName: json['host_name']?.toString() ?? json['host']?['name']?.toString() ?? '',
      hostImage: json['host_image']?.toString() ?? json['host']?['avatar_url']?.toString() ?? '',
      hostRating: (json['host_rating'] ?? json['host']?['rating'] ?? 0.0).toDouble(),
      responseTime: json['response_time']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      features: features,
      images: images,
      specs: specs,
      requirements: requirements,
      pickupLocations: pickupLocations,
      dropoffLocations: dropoffLocations,
      isAvailable: json['available'] ?? json['is_available'] ?? true,
      isFeatured: json['featured'] ?? json['is_featured'] ?? false,
      transmission: json['transmission']?.toString() ?? '',
      fuelType: json['fuel_type']?.toString() ?? '',
      passengers: json['passengers'] ?? 4,
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      year: json['year'],
      dailyRate: json['daily_rate']?.toDouble(),
      weeklyRate: json['weekly_rate']?.toDouble(),
      monthlyRate: json['monthly_rate']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      hostId: json['host_id']?.toString(),
      hostResponseTime: json['host_response_time']?.toString(),
      mileage: json['mileage'],
      seats: json['seats'],
      doors: json['doors'],
      color: json['color']?.toString(),
      licensePlate: json['license_plate']?.toString(),
      insurance: json['insurance']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      reviewCount: json['review_count'],
      isFavorite: json['is_favorite'],
      useType: _parseUseType(json['use_type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'category': category,
      'rating': rating,
      'trips': trips,
      'location': location,
      'host_name': hostName,
      'host_image': hostImage,
      'host_rating': hostRating,
      'response_time': responseTime,
      'description': description,
      'features': features,
      'images': images,
      'specs': specs,
      'requirements': requirements,
      'pickup_locations': pickupLocations,
      'dropoff_locations': dropoffLocations,
      'is_available': isAvailable,
      'is_featured': isFeatured,
      'transmission': transmission,
      'fuel_type': fuelType,
      'passengers': passengers,
      'brand': brand,
      'model': model,
      'year': year,
      'daily_rate': dailyRate,
      'weekly_rate': weeklyRate,
      'monthly_rate': monthlyRate,
      'latitude': latitude,
      'longitude': longitude,
      'host_id': hostId,
      'host_response_time': hostResponseTime,
      'mileage': mileage,
      'seats': seats,
      'doors': doors,
      'color': color,
      'license_plate': licensePlate,
      'insurance': insurance,
      'created_at': createdAt?.toIso8601String(),
      'review_count': reviewCount,
      'is_favorite': isFavorite,
      'use_type': useType.name,
    };
  }

  Car copyWith({
    String? id,
    String? name,
    String? image,
    String? price,
    String? category,
    double? rating,
    int? trips,
    String? location,
    String? hostName,
    String? hostImage,
    double? hostRating,
    String? responseTime,
    String? description,
    List<String>? features,
    List<String>? images,
    Map<String, String>? specs,
    Map<String, dynamic>? requirements,
    List<String>? pickupLocations,
    List<String>? dropoffLocations,
    bool? isAvailable,
    bool? isFeatured,
    String? transmission,
    String? fuelType,
    int? passengers,
    String? brand,
    String? model,
    int? year,
    double? dailyRate,
    double? weeklyRate,
    double? monthlyRate,
    double? latitude,
    double? longitude,
    String? hostId,
    String? hostResponseTime,
    int? mileage,
    int? seats,
    int? doors,
    String? color,
    String? licensePlate,
    String? insurance,
    DateTime? createdAt,
    int? reviewCount,
    bool? isFavorite,
    CarUseType? useType,
  }) {
    return Car(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      trips: trips ?? this.trips,
      location: location ?? this.location,
      hostName: hostName ?? this.hostName,
      hostImage: hostImage ?? this.hostImage,
      hostRating: hostRating ?? this.hostRating,
      responseTime: responseTime ?? this.responseTime,
      description: description ?? this.description,
      features: features ?? this.features,
      images: images ?? this.images,
      specs: specs ?? this.specs,
      requirements: requirements ?? this.requirements,
      pickupLocations: pickupLocations ?? this.pickupLocations,
      dropoffLocations: dropoffLocations ?? this.dropoffLocations,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      transmission: transmission ?? this.transmission,
      fuelType: fuelType ?? this.fuelType,
      passengers: passengers ?? this.passengers,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      dailyRate: dailyRate ?? this.dailyRate,
      weeklyRate: weeklyRate ?? this.weeklyRate,
      monthlyRate: monthlyRate ?? this.monthlyRate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      hostId: hostId ?? this.hostId,
      hostResponseTime: hostResponseTime ?? this.hostResponseTime,
      mileage: mileage ?? this.mileage,
      seats: seats ?? this.seats,
      doors: doors ?? this.doors,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      insurance: insurance ?? this.insurance,
      createdAt: createdAt ?? this.createdAt,
      reviewCount: reviewCount ?? this.reviewCount,
      isFavorite: isFavorite ?? this.isFavorite,
      useType: useType ?? this.useType,
    );
  }

  @override
  String toString() {
    return 'Car(id: $id, name: $name, price: $price, category: $category, rating: $rating, transmission: $transmission, fuelType: $fuelType, passengers: $passengers)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Car && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 

enum CarUseType { daily, business, event }

CarUseType _parseUseType(dynamic value) {
  if (value == null) return CarUseType.daily;
  final str = value.toString().toLowerCase();
  switch (str) {
    case 'business':
      return CarUseType.business;
    case 'event':
      return CarUseType.event;
    case 'daily':
    default:
      return CarUseType.daily;
  }
}