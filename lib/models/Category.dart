enum CategoryType { 
  economy, 
  compact, 
  midsize, 
  fullsize, 
  luxury, 
  suv, 
  truck, 
  van, 
  sports, 
  electric, 
  hybrid 
}

class Category {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String image;
  final CategoryType type;
  final double minPrice;
  final double maxPrice;
  final int totalCars;
  final double averageRating;
  final List<String> features;
  final List<String> popularBrands;
  final Map<String, dynamic> specifications;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.image,
    required this.type,
    required this.minPrice,
    required this.maxPrice,
    this.totalCars = 0,
    this.averageRating = 0.0,
    this.features = const [],
    this.popularBrands = const [],
    this.specifications = const {},
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      image: json['image'] ?? '',
      type: CategoryType.values.firstWhere(
        (type) => type.toString() == 'CategoryType.${json['type'] ?? 'economy'}',
        orElse: () => CategoryType.economy,
      ),
      minPrice: (json['minPrice'] ?? 0.0).toDouble(),
      maxPrice: (json['maxPrice'] ?? 0.0).toDouble(),
      totalCars: json['totalCars'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      features: List<String>.from(json['features'] ?? []),
      popularBrands: List<String>.from(json['popularBrands'] ?? []),
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
      isActive: json['isActive'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'image': image,
      'type': type.toString().split('.').last,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'totalCars': totalCars,
      'averageRating': averageRating,
      'features': features,
      'popularBrands': popularBrands,
      'specifications': specifications,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? image,
    CategoryType? type,
    double? minPrice,
    double? maxPrice,
    int? totalCars,
    double? averageRating,
    List<String>? features,
    List<String>? popularBrands,
    Map<String, dynamic>? specifications,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      image: image ?? this.image,
      type: type ?? this.type,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      totalCars: totalCars ?? this.totalCars,
      averageRating: averageRating ?? this.averageRating,
      features: features ?? this.features,
      popularBrands: popularBrands ?? this.popularBrands,
      specifications: specifications ?? this.specifications,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Calculate average price for the category
  double get averagePrice {
    return (minPrice + maxPrice) / 2;
  }

  // Get price range as a formatted string
  String get priceRange {
    return '\$${minPrice.toStringAsFixed(0)} - \$${maxPrice.toStringAsFixed(0)}';
  }

  // Check if category has cars available
  bool get hasCars {
    return totalCars > 0;
  }

  // Check if category is premium (luxury, sports, etc.)
  bool get isPremium {
    return type == CategoryType.luxury || 
           type == CategoryType.sports || 
           type == CategoryType.electric;
  }

  // Check if category is budget-friendly
  bool get isBudget {
    return type == CategoryType.economy || 
           type == CategoryType.compact;
  }

  // Check if category is family-friendly
  bool get isFamilyFriendly {
    return type == CategoryType.suv || 
           type == CategoryType.van || 
           type == CategoryType.midsize || 
           type == CategoryType.fullsize;
  }

  // Check if category is eco-friendly
  bool get isEcoFriendly {
    return type == CategoryType.electric || 
           type == CategoryType.hybrid;
  }

  // Get category display name with emoji
  String get displayName {
    switch (type) {
      case CategoryType.economy:
        return '🚗 $name';
      case CategoryType.compact:
        return '🚙 $name';
      case CategoryType.midsize:
        return '🚘 $name';
      case CategoryType.fullsize:
        return '🚖 $name';
      case CategoryType.luxury:
        return '🏎️ $name';
      case CategoryType.suv:
        return '🚐 $name';
      case CategoryType.truck:
        return '🚛 $name';
      case CategoryType.van:
        return '🚌 $name';
      case CategoryType.sports:
        return '🏁 $name';
      case CategoryType.electric:
        return '⚡ $name';
      case CategoryType.hybrid:
        return '🔋 $name';
    }
  }

  // Get category color theme (for UI purposes)
  String get colorTheme {
    switch (type) {
      case CategoryType.economy:
        return '#4CAF50'; // Green
      case CategoryType.compact:
        return '#2196F3'; // Blue
      case CategoryType.midsize:
        return '#FF9800'; // Orange
      case CategoryType.fullsize:
        return '#9C27B0'; // Purple
      case CategoryType.luxury:
        return '#FFD700'; // Gold
      case CategoryType.suv:
        return '#795548'; // Brown
      case CategoryType.truck:
        return '#607D8B'; // Blue Grey
      case CategoryType.van:
        return '#FF5722'; // Deep Orange
      case CategoryType.sports:
        return '#F44336'; // Red
      case CategoryType.electric:
        return '#00BCD4'; // Cyan
      case CategoryType.hybrid:
        return '#8BC34A'; // Light Green
    }
  }

  // Get category description based on type
  String get typeDescription {
    switch (type) {
      case CategoryType.economy:
        return 'Affordable and fuel-efficient vehicles perfect for budget-conscious travelers.';
      case CategoryType.compact:
        return 'Small, agile cars ideal for city driving and easy parking.';
      case CategoryType.midsize:
        return 'Comfortable and versatile vehicles suitable for families and business trips.';
      case CategoryType.fullsize:
        return 'Spacious and comfortable cars with premium features and amenities.';
      case CategoryType.luxury:
        return 'High-end vehicles with premium features, comfort, and performance.';
      case CategoryType.suv:
        return 'Sport Utility Vehicles perfect for families, outdoor adventures, and versatile transportation.';
      case CategoryType.truck:
        return 'Powerful trucks for hauling, towing, and heavy-duty transportation needs.';
      case CategoryType.van:
        return 'Large passenger vans ideal for groups, families, and cargo transportation.';
      case CategoryType.sports:
        return 'High-performance sports cars for enthusiasts and thrilling driving experiences.';
      case CategoryType.electric:
        return 'Environmentally friendly electric vehicles with zero emissions and modern technology.';
      case CategoryType.hybrid:
        return 'Fuel-efficient hybrid vehicles combining electric and gasoline power.';
    }
  }

  // Check if price falls within category range
  bool isPriceInRange(double price) {
    return price >= minPrice && price <= maxPrice;
  }

  // Get category popularity score
  double get popularityScore {
    return (totalCars * 0.4) + (averageRating * 0.6);
  }

  // Check if category is trending (high popularity and rating)
  bool get isTrending {
    return popularityScore > 7.0 && totalCars > 10;
  }

  // Get category availability status
  String get availabilityStatus {
    if (totalCars == 0) return 'No cars available';
    if (totalCars < 5) return 'Limited availability';
    if (totalCars < 20) return 'Good availability';
    return 'Wide selection available';
  }

  // Get category recommendations for similar categories
  List<CategoryType> get recommendedCategories {
    switch (type) {
      case CategoryType.economy:
        return [CategoryType.compact, CategoryType.hybrid];
      case CategoryType.compact:
        return [CategoryType.economy, CategoryType.midsize];
      case CategoryType.midsize:
        return [CategoryType.compact, CategoryType.fullsize, CategoryType.suv];
      case CategoryType.fullsize:
        return [CategoryType.midsize, CategoryType.luxury, CategoryType.suv];
      case CategoryType.luxury:
        return [CategoryType.fullsize, CategoryType.sports];
      case CategoryType.suv:
        return [CategoryType.midsize, CategoryType.van, CategoryType.truck];
      case CategoryType.truck:
        return [CategoryType.suv, CategoryType.van];
      case CategoryType.van:
        return [CategoryType.suv, CategoryType.truck];
      case CategoryType.sports:
        return [CategoryType.luxury, CategoryType.electric];
      case CategoryType.electric:
        return [CategoryType.hybrid, CategoryType.sports];
      case CategoryType.hybrid:
        return [CategoryType.economy, CategoryType.electric];
    }
  }
} 