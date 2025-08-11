import 'package:flutter/material.dart';

class SearchFilter {
  // Price range
  double minPrice;
  double maxPrice;
  
  // Location
  String? selectedWilaya;
  double? locationRadius; // in km
  
  // Car specifications
  Set<String> carTypes;
  Set<String> brands;
  Set<String> transmissions;
  Set<String> fuelTypes;
  
  // Features
  Set<String> features;
  
  // Ratings and reviews
  double? minRating;
  int? minTrips;
  
  // Availability
  DateTime? startDate;
  DateTime? endDate;
  bool instantBookOnly;
  
  // Host preferences
  bool allStarHostsOnly;
  String? responseTime; // 'within_hour', 'within_day', 'any'
  // Car use type filter: 'daily' | 'business' | 'event'
  String? useType;
  
  // Sorting
  SortOption sortBy;
  bool sortAscending;
  
  SearchFilter({
    this.minPrice = 0,
    this.maxPrice = 2000,
    this.selectedWilaya,
    this.locationRadius,
    Set<String>? carTypes,
    Set<String>? brands,
    Set<String>? transmissions,
    Set<String>? fuelTypes,
    Set<String>? features,
    this.minRating,
    this.minTrips,
    this.startDate,
    this.endDate,
    this.instantBookOnly = false,
    this.allStarHostsOnly = false,
    this.responseTime,
    this.useType,
    this.sortBy = SortOption.relevance,
    this.sortAscending = true,
  }) : carTypes = carTypes ?? {},
       brands = brands ?? {},
       transmissions = transmissions ?? {},
       fuelTypes = fuelTypes ?? {},
       features = features ?? {};

  // Copy with method for immutable updates
  SearchFilter copyWith({
    double? minPrice,
    double? maxPrice,
    String? selectedWilaya,
    double? locationRadius,
    Set<String>? carTypes,
    Set<String>? brands,
    Set<String>? transmissions,
    Set<String>? fuelTypes,
    Set<String>? features,
    double? minRating,
    int? minTrips,
    DateTime? startDate,
    DateTime? endDate,
    bool? instantBookOnly,
    bool? allStarHostsOnly,
    String? responseTime,
    String? useType,
    SortOption? sortBy,
    bool? sortAscending,
  }) {
    return SearchFilter(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      selectedWilaya: selectedWilaya ?? this.selectedWilaya,
      locationRadius: locationRadius ?? this.locationRadius,
      carTypes: carTypes ?? Set.from(this.carTypes),
      brands: brands ?? Set.from(this.brands),
      transmissions: transmissions ?? Set.from(this.transmissions),
      fuelTypes: fuelTypes ?? Set.from(this.fuelTypes),
      features: features ?? Set.from(this.features),
      minRating: minRating ?? this.minRating,
      minTrips: minTrips ?? this.minTrips,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      instantBookOnly: instantBookOnly ?? this.instantBookOnly,
      allStarHostsOnly: allStarHostsOnly ?? this.allStarHostsOnly,
      responseTime: responseTime ?? this.responseTime,
      useType: useType ?? this.useType,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  // Check if filter is empty (default state)
  bool get isEmpty {
    return minPrice == 0 &&
           maxPrice == 2000 &&
           selectedWilaya == null &&
           locationRadius == null &&
           carTypes.isEmpty &&
           brands.isEmpty &&
           transmissions.isEmpty &&
           fuelTypes.isEmpty &&
           features.isEmpty &&
           minRating == null &&
           minTrips == null &&
           startDate == null &&
           endDate == null &&
           !instantBookOnly &&
           !allStarHostsOnly &&
           responseTime == null &&
           useType == null &&
           sortBy == SortOption.relevance;
  }

  // Get active filter count
  int get activeFilterCount {
    int count = 0;
    if (minPrice > 0 || maxPrice < 2000) count++;
    if (selectedWilaya != null) count++;
    if (locationRadius != null) count++;
    if (carTypes.isNotEmpty) count++;
    if (brands.isNotEmpty) count++;
    if (transmissions.isNotEmpty) count++;
    if (fuelTypes.isNotEmpty) count++;
    if (features.isNotEmpty) count++;
    if (minRating != null) count++;
    if (minTrips != null) count++;
    if (startDate != null || endDate != null) count++;
    if (instantBookOnly) count++;
    if (allStarHostsOnly) count++;
    if (responseTime != null) count++;
    if (useType != null) count++;
    return count;
  }

  // Reset to default
  SearchFilter reset() {
    return SearchFilter();
  }

  // Convert to map for API calls
  Map<String, dynamic> toMap() {
    return {
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'selectedWilaya': selectedWilaya,
      'locationRadius': locationRadius,
      'carTypes': carTypes.toList(),
      'brands': brands.toList(),
      'transmissions': transmissions.toList(),
      'fuelTypes': fuelTypes.toList(),
      'features': features.toList(),
      'minRating': minRating,
      'minTrips': minTrips,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'instantBookOnly': instantBookOnly,
      'allStarHostsOnly': allStarHostsOnly,
      'responseTime': responseTime,
      'useType': useType,
      'sortBy': sortBy.name,
      'sortAscending': sortAscending,
    };
  }
}

enum SortOption {
  relevance,
  priceAsc,
  priceDesc,
  ratingDesc,
  tripsDesc,
  newest,
  distance,
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.priceAsc:
        return 'Price: Low to High';
      case SortOption.priceDesc:
        return 'Price: High to Low';
      case SortOption.ratingDesc:
        return 'Highest Rated';
      case SortOption.tripsDesc:
        return 'Most Popular';
      case SortOption.newest:
        return 'Newest First';
      case SortOption.distance:
        return 'Distance';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.relevance:
        return Icons.sort;
      case SortOption.priceAsc:
        return Icons.arrow_upward;
      case SortOption.priceDesc:
        return Icons.arrow_downward;
      case SortOption.ratingDesc:
        return Icons.star;
      case SortOption.tripsDesc:
        return Icons.trending_up;
      case SortOption.newest:
        return Icons.new_releases;
      case SortOption.distance:
        return Icons.location_on;
    }
  }
}

// Static filter data
class FilterData {
  static const List<String> carTypes = [
    'Sedan',
    'SUV',
    'Hatchback',
    'Coupe',
    'Convertible',
    'Wagon',
    'Pickup',
    'Van',
    'Luxury',
    'Sports',
  ];

  static const List<String> brands = [
    'BMW',
    'Mercedes-Benz',
    'Audi',
    'Toyota',
    'Honda',
    'Ford',
    'Volkswagen',
    'Nissan',
    'Hyundai',
    'Kia',
    'Mazda',
    'Volvo',
    'Jaguar',
    'Land Rover',
    'Porsche',
    'Lexus',
  ];

  static const List<String> transmissions = [
    'Automatic',
    'Manual',
    'CVT',
  ];

  static const List<String> fuelTypes = [
    'Petrol',
    'Diesel',
    'Electric',
    'Hybrid',
    'Plug-in Hybrid',
  ];

  static const List<String> features = [
    'GPS Navigation',
    'Bluetooth',
    'USB Ports',
    'Wireless Charging',
    'Backup Camera',
    'Parking Sensors',
    'Sunroof',
    'Leather Seats',
    'Heated Seats',
    'Air Conditioning',
    'Cruise Control',
    'Lane Assist',
    'Collision Detection',
    'Keyless Entry',
    'Push Start',
    'Premium Sound',
    'Apple CarPlay',
    'Android Auto',
  ];

  static const List<String> wilayas = [
    'Adrar',
    'Chlef',
    'Laghouat',
    'Oum El Bouaghi',
    'Batna',
    'Béjaïa',
    'Biskra',
    'Béchar',
    'Blida',
    'Bouira',
    'Tamanrasset',
    'Tébessa',
    'Tlemcen',
    'Tiaret',
    'Tizi Ouzou',
    'Alger',
    'Djelfa',
    'Jijel',
    'Sétif',
    'Saïda',
    'Skikda',
    'Sidi Bel Abbès',
    'Annaba',
    'Guelma',
    'Constantine',
    'Médéa',
    'Mostaganem',
    'M\'Sila',
    'Mascara',
    'Ouargla',
    'Oran',
    'El Bayadh',
    'Illizi',
    'Bordj Bou Arréridj',
    'Boumerdès',
    'El Tarf',
    'Tindouf',
    'Tissemsilt',
    'El Oued',
    'Khenchela',
    'Souk Ahras',
    'Tipaza',
    'Mila',
    'Aïn Defla',
    'Naâma',
    'Aïn Témouchent',
    'Ghardaïa',
    'Relizane',
  ];

  static const List<String> responseTimeOptions = [
    'within_hour',
    'within_day',
    'any',
  ];

  static String getResponseTimeDisplayName(String responseTime) {
    switch (responseTime) {
      case 'within_hour':
        return 'Within 1 hour';
      case 'within_day':
        return 'Within 24 hours';
      case 'any':
        return 'Any time';
      default:
        return 'Any time';
    }
  }
}