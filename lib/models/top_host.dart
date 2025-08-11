class TopHost {
  final String id;
  final String name;
  final String? profileImage;
  final String hostType;
  final double rating;
  final int trips;
  final String location;
  final int carsCount;
  final String? coverImage;

  TopHost({
    required this.id,
    required this.name,
    this.profileImage,
    required this.hostType,
    required this.rating,
    required this.trips,
    required this.location,
    required this.carsCount,
    this.coverImage,
  });

  factory TopHost.fromJson(Map<String, dynamic> json) {
    return TopHost(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profile_image'],
      hostType: json['host_type'] ?? 'Host',
      rating: (json['rating'] ?? 0.0).toDouble(),
      trips: json['trips'] ?? 0,
      location: json['location'] ?? '',
      carsCount: json['cars_count'] ?? 0,
      coverImage: json['cover_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'host_type': hostType,
      'rating': rating,
      'trips': trips,
      'location': location,
      'cars_count': carsCount,
      'cover_image': coverImage,
    };
  }

  @override
  String toString() {
    return 'TopHost(id: $id, name: $name, rating: $rating, trips: $trips)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TopHost && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
